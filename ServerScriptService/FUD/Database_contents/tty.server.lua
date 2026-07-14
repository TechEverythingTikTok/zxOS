--[[
    tty (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database["tty"] = [[
local fs = import("fs")
local pm = import("pm")
local kbio = import("keyboardio")
local logio = import("logio")

local config = import("Root/etc/install.cfg")
local us_keyboard_layout = import("Root/libs/us_keyboard_layout.lib")

--> Stage 1: Login <--

local function handle_username_userpass(username, userpass)
	if username ~= config.username then return false end
	if userpass ~= config.userpass then return false end
	return true
end

local input_str = ""
local buf = ""
local stage = 1		-- 1 = username stage; 2 = userpass stage

local tid = logio.put("Username: ")

local should_terminate_listener = false
local is_listener_terminated = false
local function khandle(kname)
	if should_terminate_listener then return end
	if us_keyboard_layout.kmap[kname] then
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
			input_str = input_str..us_keyboard_layout.shift_kmap[kname]
		else
			input_str = input_str..us_keyboard_layout.kmap[kname]
		end
	else
		if kname == "Return" then
			if stage == 1 then
				buf = input_str
				input_str = ""
				stage = 2
			elseif stage == 2 then
				local success = handle_username_userpass(buf, input_str)
				if success then 
					should_terminate_listener = true
				else
					input_str = ""
					buf = ""
					stage = 1
					logio.modify(tid, "Username: ")
				end
			end
		elseif kname == "Backspace" then
			input_str = input_str:sub(1, -2)
		end
	end
	if stage == 1 then
		logio.modify(tid, "Username: "..input_str)
	else
		logio.modify(tid, "Userpass: "..input_str)
	end
end

local kpid = kbio.new_listener(khandle)

while should_run() do
	if should_terminate_listener then
		if not is_listener_terminated then
			kbio.destroy_listener(kpid)
			is_lstener_terminated = true
		end
	end
	task.wait(0.1)
end

--> Stage 2: tty functionality; execute arg if needed <--

logio.put("Welcome to zxOS!")

local command = ""
local function handle_command()
	
end

]]