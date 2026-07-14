--[[
    xedit (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.xedit = [[
local logio = import("logio")
local fs = import("fs")
local kbio = import("keyboardio")
local keyboard_layout = import("keyboard_layout")

local current_path = args[1]
local target_frame = args[2]
local path_or_name = args[3]

if not path_or_name then
	logio.put("Usage: xedit <path_or_name>", nil, target_frame) 
	return
end

local target = (fs.readfull(path_or_name) ~= nil) and path_or_name or (current_path.."/"..path_or_name)
local info = fs.readfull(target)

if info == nil then
	logio.put('<font color="rgb(255, 100, 100)">No such File (use -c to create a new file with xedit)</font>', nil, target_frame)
	return
elseif info == false then
	logio.put('<font color="rgb(255, 100, 100)">No permission to edit</font>', nil, target_frame)
	return
end

if info[1] == "Directory" then
	logio.put('<font color="rgb(255, 100, 100)">Cannot edit contents of a directory.</font>', nil, target_frame)
else
	-- Assign keymaps
	
	local text = fs.read(info[4].."/"..info[3].."."..info[7]) or ""
	
	local cursor_pos = #text + 1
	
	local function insert_at_cursor(str)
		text = text:sub(1, cursor_pos - 1)..str..text:sub(cursor_pos)
		cursor_pos = cursor_pos + #str
	end
	
	local kmap = keyboard_layout.kmap
	local shift_kmap = keyboard_layout.shift_kmap
	
	local should_terminate_listener = false
	local is_listener_terminated = false
	
	local oid = logio.create_overlay()
	local id = logio.put_overlay(oid, text)
	
	local function kpress(kname)
		if should_terminate_listener then return end
		
		if kname == "B" then
			if kbio.is_key_pressed("LeftControl") then
				fs.write(info[4], info[3], info[7], text, true)
				return
			end
		elseif kname == "X" then
			if kbio.is_key_pressed("LeftControl") then
				if not should_terminate_listener then
					should_terminate_listener = true
					logio.clear_overlay(oid)
					return
				end
			end
		end
		
		if kmap[kname] then
			if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then
				insert_at_cursor(shift_kmap[kname])
			else
				insert_at_cursor(kmap[kname])
			end
		else
			if kname == "Return" then
				insert_at_cursor("\n")
			elseif kname == "Tab" then
				insert_at_cursor("	")
			elseif kname == "Backspace" then
				if cursor_pos > 1 then
					text = text:sub(1, cursor_pos - 2)..text:sub(cursor_pos)
					cursor_pos = cursor_pos - 1
				end
			elseif kname == "Left" then
				if cursor_pos > 1 then
					cursor_pos = cursor_pos - 1
				end
			elseif kname == "Right" then
				if cursor_pos < #text + 1 then
					cursor_pos = cursor_pos + 1
				end
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