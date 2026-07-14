--[[
    uefiselect.efi (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Root
    Parent: Root
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)
task.wait(4)

local code = [[

local fs = import("fs")
local pm = import("pm")
local logio = import("logio")
local kbio = import("keyboardio")
local fud = import("fud")

-- 1 is BIOS

logio.clear()

logio.put('<font color="rgb(255, 255, 0)">(1)</font> UEFI')

-- Rest are children of Root/Boot

local children = fs.ls("Root/Boot", "-f")

local bootables = {}
local entries = {
	["Two"] = 2, ["Three"] = 3, ["Four"] = 4, ["Five"] = 5, ["Six"] = 6, ["Seven"] = 7, ["Eight"] = 8, ["Nine"] = 9
}

if children then
	for i, val in ipairs(children) do
		if fs.readfull(val)[1] == "File" and fs.readfull(val)[7] == "efi" then
			if #bootables >= 8 then
				break
			else
				table.insert(bootables, val)
			end
		end
	end
end

for i, val in ipairs(bootables) do
	logio.put('<font color="rgb(255, 255, 0)">('..tostring(i + 1)..')</font> '.. val)
end

local should_terminate_listener = false
local is_listener_terminated = false

local function waitftkbio()
	should_terminate_listener = true
	logio.put('Waiting for kbio listener to terminate')
	repeat task.wait(0.1) until is_listener_terminated
end

local function kpress(iname)
	if iname == "One" then
		-- Boot in BIOS
		if not should_terminate_listener then
			waitftkbio()
			logio.put('Starting process Root/uefi.efi')
			
			local content
			
			for i = 1, 3 do
				content = fs.read("Root/uefi.efi")
				if not content then
					if i == 3 then
						logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Root/uefi.efi not found or is corrupt.')
						logio.put("[ INFO ] Rebuilding UEFI components")
						fs.write("Root", "uefiboot", "efi", fud.get_content("uefiboot_efi"), true, "Ring0")
						fs.write("Root", "uefi", "efi", fud.get_content("uefi_efi"), true, "Ring0")
						fs.write("Root", "uefiselect", "efi", fud.get_content("uefiselect_efi"), true, "Ring0")
						fs.write("Root", "ueficonfig", "efi", fud.get_content("ueficonfig_efi"), true, "Ring0")
						fs.write("Root", "ueditor", "efi", fud.get_content("ueditor_efi"), true, "Ring0")
						content = fs.read("Root/uefi.efi")
					end
				else
					break
				end
			end
		
			local PID = pm.spawn_proc("Root/uefi.efi")
			if PID == "0x1" then
				logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] File "Root/uefi.efi" is corrupt')
				logio.put("[ INFO ] Rebuilding UEFI components")
				fs.write("Root", "uefiboot", "efi", fud.get_content("uefiboot_efi"), true, "Ring0")
				fs.write("Root", "uefi", "efi", fud.get_content("uefi_efi"), true, "Ring0")
				fs.write("Root", "uefiselect", "efi", fud.get_content("uefiselect_efi"), true, "Ring0")
				fs.write("Root", "ueficonfig", "efi", fud.get_content("ueficonfig_efi"), true, "Ring0")
				fs.write("Root", "ueditor", "efi", fud.get_content("ueditor_efi"), true, "Ring0")
				PID = pm.spawn_proc("Root/uefi.efi")
				pm.restart()
			else
				pm.run_proc(PID)
			end
			
			pm.signal(pid, pm.SIGNALS.SIGTERM)
		end
	elseif entries[iname] then
		if not should_terminate_listener then
			local entry = entries[iname]
			local PID, perror = pm.spawn_proc(bootables[entry - 1])
			if PID ~= "0x1" and PID ~= nil then
				waitftkbio()
				pm.run_proc(PID)
				pm.signal(pid, pm.SIGNALS.SIGTERM)
			else
				warn("Error in boot attempt: "..(perror or ""))
			end
		end
	end
end

local id = kbio.new_listener(kpress)

while should_run() do
	if should_terminate_listener then
		if not is_listener_terminated then
			kbio.destroy_listener(id)
			is_listener_terminated = true
		end
	end
	
	task.wait(0.75)
end

kbio.destroy_listener(id)
is_listener_terminated = true

]]

fs.write("Root", "uefiselect", "efi", code, true)