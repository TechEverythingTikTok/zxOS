--[[
    uefi.efi (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Root
    Parent: Root
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)
task.wait(4)

local code = [[

local logio = import("logio")
local fs = import("fs")
local pm = import("pm")
local kbio = import("keyboardio")
local payservice = import("payservice")
local fud = import("fud")

logio.clear()

logio.put("UEFI", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})

logio.put("")

local opts = {}

opts[1] = logio.put("Fetch zxOS installation media", {
	TextColor = Color3.fromRGB(0, 0, 0),
	BackgroundColor = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0,
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[2] = logio.put("Configure ueficonfig.cfg", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[3] = logio.put("Reboot", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[4] = logio.put("Shutdown", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[5] = logio.put("Support the development", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[6] = logio.put("+4MB Storage", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})

local function update(t_i)
	for i, _ in pairs(opts) do
		if t_i == i then
			logio.modify(opts[i], logio.get_text(opts[i]), {
				TextColor = Color3.fromRGB(0, 0, 0),
				BackgroundColor = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 0
			})
		else
			logio.modify(opts[i], logio.get_text(opts[i]), {
				TextColor = Color3.fromRGB(255, 255, 255),
				BackgroundColor = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1
			})
		end
	end
end

local t_i = 1

local should_terminate_listener = false
local is_listener_terminated = false

local inp_suspended = false
local start_allowed = true

local function kpress(iname)
	if inp_suspended then return end
	if iname == "Down" then
		if t_i + 1 > 6 then
			t_i = 1
		else
			t_i = t_i + 1
		end
	elseif iname == "Up" then
		if t_i - 1 <= 0 then
			t_i = 6
		else
			t_i = t_i - 1
		end
	elseif iname == "Return" then
		if t_i == 6 then
			payservice.PromptGamepassPurchase(1559315426)
			local CanDisconnect = false
			local CID = payservice.GamepassPurchaseFinished(function(gpid, purchased)
				if gpid == 1559315426 then
					if purchased or payservice.UserOwnsGamepass(1559315426) then
						fs.increase_storage()
					end
					CanDisconnect = true
				end
			end)
			repeat task.wait(0.1) until CanDisconnect
			payservice.DisconnectCID(CID)
		elseif t_i == 5 then
			payservice.PromptProductPurchase(3361442508)
		elseif t_i == 4 then
			should_terminate_listener = true
			repeat task.wait(0.1) until is_listener_terminated
			pm.shutdown()
		elseif t_i == 3 then
			should_terminate_listener = true
			repeat task.wait(0.1) until is_listener_terminated
			pm.restart()
		elseif t_i == 2 then
			local ueditor = fs.read("Root/ueditor.efi")
			if ueditor then
				local PID, perror = pm.spawn_proc("Root/ueditor.efi", {"Root", "ueficonfig", "cfg"})
				if PID == "0x1" then
					logio.modify(opts[2], logio.get_text(opts[2]), {ForegroundColor = Color3.fromRGB(255, 100, 100)})
					task.wait(0.1)
					if t_i == 1 then
						logio.modify(opts[2], logio.get_text(opts[2]), {ForegroundColor = Color3.fromRGB(255, 255, 255)})					
					end
				else
					pm.run_proc(PID)
					inp_suspended = true
					repeat task.wait(0.5) until not pm.is_alive(PID)
					inp_suspended = false
				end
			end
		elseif t_i == 1 then
			if not start_allowed then return end
			start_allowed = false
			logio.clear()
			logio.clear_overlays()
			logio.put("Fetching 'zxinstall.efi' from fud")
			fs.write("Root", "zxinstall", "efi", fud.get_content("zxinstall"), true)
			local PID, perror = pm.spawn_proc("Root/zxinstall.efi")
			pm.run_proc(PID)
			pm.signal(pid, pm.SIGNALS.SIGTERM)
		end
	end
	update(t_i)
end

local kpid = kbio.new_listener(kpress)

while should_run() do
	if should_terminate_listener then
		if not is_listener_terminated then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
		end
	end
	
	task.wait(0.05)
end

kbio.destroy_listener(kpid)
is_listener_terminated = true

]]

fs.write("Root", "uefi", "efi", code, true)
