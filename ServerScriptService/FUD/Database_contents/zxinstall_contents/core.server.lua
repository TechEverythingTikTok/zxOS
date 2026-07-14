--[[
    core (Script)
    Path: ServerScriptService → FUD → Database → zxinstall
    Parent: zxinstall
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent.Parent)

Database["zxinstall/core"] = [[
local fs = import("fs")
local pm = import("pm")
local logio = import("logio")
local kbio = import("keyboardio")
local fud = import("fud")

local keyboard_layout = import("Root/tmplibs/us_keyboard_layout.lib")

logio.clear()
fs.mkdir("Root", "zxinstall", true)
fs.write("Root/zxinstall", "hostname", "zpi", "", true, "Ring3")
fs.write("Root/zxinstall", "hostpass", "zpi", "", true, "Ring3")
fs.write("Root/zxinstall", "username", "zpi", "", true, "Ring3")
fs.write("Root/zxinstall", "userpass", "zpi", "", true, "Ring3")
fs.write("Root/zxinstall", "desktopenv", "zpi", "", true, "Ring3")

local coid = nil
local ctid = nil
local cstr = ""

local should_terminate_listener = false
local is_listener_terminated = false

local kpid = nil

local function hostname_khandle(kname)
	if should_terminate_listener then return end
	if keyboard_layout.kmap[kname] then
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
			cstr = cstr..keyboard_layout.shift_kmap[kname]
		else
			cstr = cstr..keyboard_layout.kmap[kname]
		end
	else
		if kname == "Backspace" then
			cstr = string.sub(cstr, 1, -2)
		elseif kname == "Return" then
			fs.write("Root/zxinstall", "hostname", "zpi", cstr, true, "Ring0")
			should_terminate_listener = true
		end
	end
	logio.modify_overlay(coid, ctid, "Hostname: "..cstr)
end
local function hostname()
	coid = logio.create_overlay()
	cstr = fs.read("Root/zxinstall/hostname.zpi")
	if not cstr then cstr = "" end
	ctid = logio.put_overlay(coid, "Hostname: "..cstr)
	
	should_terminate_listener, is_listener_terminated = false, false
	task.wait(0.5)
	kpid = kbio.new_listener(hostname_khandle)
	
	while not is_listener_terminated do
		if should_terminate_listener then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
			break
		end
		task.wait(0.1)
	end
	
	logio.clear_overlay(coid)
	coid = nil
	ctid = nil
	cstr = ""
	
	should_terminate_listener, is_listener_terminated = false, false
	kpid = nil
end


local function hostpass_khandle(kname)
	if should_terminate_listener then return end
	if keyboard_layout.kmap[kname] then
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
			cstr = cstr..keyboard_layout.shift_kmap[kname]
		else
			cstr = cstr..keyboard_layout.kmap[kname]
		end
	else
		if kname == "Backspace" then
			cstr = string.sub(cstr, 1, -2)
		elseif kname == "Return" then
			fs.write("Root/zxinstall", "hostpass", "zpi", cstr, true, "Ring0")
			should_terminate_listener = true
		end
	end
	logio.modify_overlay(coid, ctid, "Hostpass: "..cstr)
end
local function hostpass()
	coid = logio.create_overlay()
	cstr = fs.read("Root/zxinstall/hostpass.zpi")
	if not cstr then cstr = "" end
	ctid = logio.put_overlay(coid, "Hostpass: "..cstr)
	
	should_terminate_listener, is_listener_terminated = false, false
	task.wait(0.5)
	kpid = kbio.new_listener(hostpass_khandle)
	
	while not is_listener_terminated do
		if should_terminate_listener then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
			break
		end
		task.wait(0.1)
	end
	
	logio.clear_overlay(coid)
	coid = nil
	ctid = nil
	cstr = ""
	
	should_terminate_listener, is_listener_terminated = false, false
	kpid = nil
end


local function useraccount_khandle_username(kname)
	if should_terminate_listener then return end
	if keyboard_layout.kmap[kname] then
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
			cstr = cstr..keyboard_layout.shift_kmap[kname]
		else
			cstr = cstr..keyboard_layout.kmap[kname]
		end
	else
		if kname == "Backspace" then
			cstr = string.sub(cstr, 1, -2)
		elseif kname == "Return" then
			fs.write("Root/zxinstall", "username", "zpi", cstr, true, "Ring0")
			should_terminate_listener = true
		end
	end
	logio.modify_overlay(coid, ctid, "Username: "..cstr)
end
local function useraccount_khandle_userpass(kname)
	if should_terminate_listener then return end
	if keyboard_layout.kmap[kname] then
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
			cstr = cstr..keyboard_layout.shift_kmap[kname]
		else
			cstr = cstr..keyboard_layout.kmap[kname]
		end
	else
		if kname == "Backspace" then
			cstr = string.sub(cstr, 1, -2)
		elseif kname == "Return" then
			fs.write("Root/zxinstall", "userpass", "zpi", cstr, true, "Ring0")
			should_terminate_listener = true
		end
	end
	logio.modify_overlay(coid, ctid, "Userpass: "..cstr)
end
local function useraccount()
	coid = logio.create_overlay()
	cstr = fs.read("Root/zxinstall/username.zpi")
	if not cstr then cstr = "" end
	ctid = logio.put_overlay(coid, "Username: "..cstr)
	
	should_terminate_listener, is_listener_terminated = false, false
	task.wait(0.5)
	kpid = kbio.new_listener(useraccount_khandle_username)
	
	while not is_listener_terminated do
		if should_terminate_listener then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
			break
		end
		task.wait(0.1)
	end
	
	logio.clear_overlay(coid)
	coid = logio.create_overlay()
	cstr = fs.read("Root/zxinstall/userpass.zpi")
	if not cstr then cstr = "" end
	ctid = logio.put_overlay(coid, "Userpass: "..cstr)
	
	should_terminate_listener, is_listener_terminated = false, false
	task.wait(0.5)
	kpid = kbio.new_listener(useraccount_khandle_userpass)
	
	while not is_listener_terminated do
		if should_terminate_listener then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
			break
		end
		task.wait(0.1)
	end
	
	logio.clear_overlay(coid)
	coid = nil
	ctid = nil
	cstr = ""
	
	should_terminate_listener, is_listener_terminated = false, false
	kpid = nil
end


local function desktopenv_khandle(kname)
	if kname == "One" then
		should_terminate_listener = true
		fs.write("Root/zxinstall", "desktopenv", "zpi", "None", true, "Ring0")
	elseif kname == "Two" then
		should_terminate_listener = true
		fs.write("Root/zxinstall", "desktopenv", "zpi", "zxDE", true, "Ring0")
	end
end
local function desktopenv()
	coid = logio.create_overlay()
	if not cstr then cstr = "" end
	logio.put_overlay(coid, "(1) -- None")
	logio.put_overlay(coid, "(2) -- zxDE")
	
	should_terminate_listener, is_listener_terminated = false, false
	task.wait(0.5)
	kpid = kbio.new_listener(desktopenv_khandle)
	
	while not is_listener_terminated do
		if should_terminate_listener then
			kbio.destroy_listener(kpid)
			is_listener_terminated = true
			break
		end
		task.wait(0.1)
	end
	
	logio.clear_overlay(coid)
	coid = nil
	ctid = nil
	cstr = ""
	
	should_terminate_listener, is_listener_terminated = false, false
	kpid = nil
end

local function install()
	fs.write("Root", "zxinstallprocess", "zxe", fud.get_content("zxinstall/install"), true)
	local PID, perror = pm.spawn_proc("Root/zxinstallprocess.zxe")
	if PID == "0x1" then
		warn("Error in zxinstallprocess compiling: "..perror)
	else
		pm.run_proc(PID)
	end
end

local function abort()
	fs.rm("Root/zxinstall")
	pm.restart()
end

logio.put("zxinstall", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
logio.put("")

local selection_i = 1
local opts = {}

opts[1] = logio.put("Host name", {
	TextColor = Color3.fromRGB(0, 0, 0),
	BackgroundColor = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 0,
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[2] = logio.put("Host password", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[3] = logio.put("User account", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[4] = logio.put("Desktop environment", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[5] = logio.put("Install", {
	Size = {x = get_screen_res().X},
	TextXAlignment = Enum.TextXAlignment.Center
})
opts[6] = logio.put("Abort", {
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

local main_should_terminate, main_is_listener_terminated = false, false

local t_i = 1
local inp_suspended = false

local function main_kpress(kname)
	if inp_suspended then return end
	if kname == "Down" then
		if t_i + 1 > 6 then
			t_i = 1
		else 
			t_i = t_i + 1
		end
	elseif kname == "Up" then
		if t_i - 1 <= 0 then
			t_i = 6
		else
			t_i = t_i - 1
		end
	elseif kname == "Return" then
		if t_i == 1 then
			inp_suspended = true
			hostname()
			inp_suspended = false
		elseif t_i == 2 then
			inp_suspended = true
			hostpass()
			inp_suspended = false
		elseif t_i == 3 then
			inp_suspended = true
			useraccount()
			inp_suspended = false
		elseif t_i == 4 then
			inp_suspended = true
			desktopenv()
			inp_suspended = false
		elseif t_i == 5 then
			if fs.read("Root/zxinstall/hostname.zpi") == "" then return end
			if fs.read("Root/zxinstall/hostpass.zpi") == "" then return end
			if fs.read("Root/zxinstall/username.zpi") == "" then return end
			if fs.read("Root/zxinstall/userpass.zpi") == "" then return end
			if fs.read("Root/zxinstall/desktopenv.zpi") == "" then return end
			inp_suspended = true
			main_should_terminate = true
			install()
		elseif t_i == 6 then
			inp_suspended = true
			main_should_terminate = true
			abort()
		end
	end
	update(t_i)
end

local main_kpid = kbio.new_listener(main_kpress)

while should_run() do
	if main_should_terminate then
		if not main_is_listener_terminated then
			kbio.destroy_listener(main_kpid)
			main_is_listener_terminated = true
		end
	end
	task.wait(0.1)
end

kbio.destroy_listener(main_kpid)
main_is_listener_terminated = true
]]