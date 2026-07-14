--[[
    ueditor.efi (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Root
    Parent: Root
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)
task.wait(4)

local code = [[

local kbio = import("keyboardio")
local logio = import("logio")
local fs = import("fs")
local pm = import("pm")

if typeof(args) ~= "table" then
	logio.put("Incorrect path format given!")
else
	
	local text = fs.read(args[1].."/"..args[2].."."..args[3])
	if not text then
		text = ""
	end
	local cursor_pos = #text + 1
	
	local function insert_at_cursor(str)
		text = text:sub(1, cursor_pos - 1)..str..text:sub(cursor_pos)
		cursor_pos = cursor_pos + #str
	end
	
	local should_terminate_listener = false
	local is_listener_terminated = false
	
	local oid = logio.create_overlay()
	local id = logio.put_overlay(oid, text)
	
	local function kpress(iname)
		-- Combinations only
		
		-- All inputs
		if iname == "One" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("!")
			else
				insert_at_cursor("1")
			end
		elseif iname == "Two" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("@")
			else
				insert_at_cursor("2")
			end
		elseif iname == "Three" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("#")
			else
				insert_at_cursor("3")
			end
		elseif iname == "Four" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("$")
			else
				insert_at_cursor("4")
			end
		elseif iname == "Five" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("%")
			else
				insert_at_cursor("5")
			end
		elseif iname == "Six" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("^")
			else
				insert_at_cursor("6")
			end
		elseif iname == "Seven" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("&")
			else
				insert_at_cursor("7")
			end
		elseif iname == "Eight" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("*")
			else
				insert_at_cursor("8")
			end
		elseif iname == "Nine" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("(")
			else
				insert_at_cursor("9")
			end
		elseif iname == "Zero" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor(")")
			else
				insert_at_cursor("0")
			end
		elseif iname == "Backspace" then
			if cursor_pos > 1 then
				text = text:sub(1, cursor_pos - 2)..text:sub(cursor_pos)
				cursor_pos = cursor_pos - 1
			end
		elseif iname == "Return" then
			insert_at_cursor("\n")
		elseif iname == "Slash" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("?")
			else
				insert_at_cursor("/")
			end
		elseif iname == "Minus" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("_")
			else
				insert_at_cursor("-")
			end
		elseif iname == "Equals" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("+")
			else
				insert_at_cursor("=")
			end
		elseif iname == "Backslash" or iname == "BackSlash" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("|")
			else
				insert_at_cursor("\\")
			end
		elseif iname == "Semicolon" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor(":")
			else
				insert_at_cursor(";")
			end
		elseif iname == "LeftShift" then
		elseif iname == "RightShift" then
		elseif iname == "LeftControl" then
		elseif iname == "RightControl" then
		elseif iname == "Tab" then
			insert_at_cursor("   ")
		elseif iname == "Unknown" then
		elseif iname == "CapsLock" then
		elseif iname == "Escape" then
		elseif iname == "Super" then
		elseif iname == "LeftSuper" then
		elseif iname == "LeftAlt" then
		elseif iname == "Up" then
		elseif iname == "Down" then
		elseif iname == "RightAlt" then
		elseif iname == "F1" or iname == "F2" or iname == "F3" or iname == "F4"
		or iname == "F5" or iname == "F6" or iname == "F7" or iname == "F8"
		or iname == "F9" or iname == "F10" or iname == "F11" or iname == "F12" then
		elseif iname == "Delete" then
		elseif iname == "Left" then
			if cursor_pos > 1 then
				cursor_pos = cursor_pos - 1
			end
		elseif iname == "Right" then
			if cursor_pos <= #text then
				cursor_pos = cursor_pos + 1
			end
		elseif iname == "Backquote" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("~")
			else
				insert_at_cursor("`")
			end
		elseif iname == "Period" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor(">")
			else
				insert_at_cursor(".")
			end
		elseif iname == "Comma" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("<")
			else
				insert_at_cursor(",")
			end
		elseif iname == "Space" then
			insert_at_cursor(" ")
		elseif iname == "Quote" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor('"')
			else
				insert_at_cursor("'")
			end
		elseif iname == "RightBracket" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("}")
			else
				insert_at_cursor("]")
			end
		elseif iname == "LeftBracket" then
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor("{")
			else
				insert_at_cursor("[")
			end
		elseif iname == "X" then
			if kbio.is_key_pressed("LeftControl") then
				if not should_terminate_listener then
					should_terminate_listener = true
					logio.clear_overlay(oid)
				end
			else
				if kbio.is_key_pressed("LeftShift") then
					insert_at_cursor("X")
				else
					insert_at_cursor("x")
				end
			end
		elseif iname == "B" then
			if kbio.is_key_pressed("LeftControl") then
				fs.write(args[1], args[2], args[3], text, true)
				print(fs.read(args[1], args[2], args[3]))
			else
				if kbio.is_key_pressed("LeftShift") then
					insert_at_cursor("B")
				else
					insert_at_cursor("b")
				end
			end
		else
			if kbio.is_key_pressed("LeftShift") then
				insert_at_cursor(string.upper(iname))
			else
				insert_at_cursor(string.lower(iname))
			end
		end
		
		logio.modify_overlay(oid, id, text)
	end
	
	task.wait(1)
	local kpid = kbio.new_listener(kpress)
	
	while should_run() do
		if should_terminate_listener then
			if not is_listener_terminated then
				kbio.destroy_listener(kpid)
				is_listener_terminated = true
				break
			end
		end
		task.wait(0.25)
	end
	
	kbio.destroy_listener(kpid)
	is_listener_terminated = true
end

]]

fs.write("Root", "ueditor", "efi", code, true)