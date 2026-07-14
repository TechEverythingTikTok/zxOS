--[[
    rmdir (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.rmdir = [[
local fs=import("fs")
local logio=import("logio")
local current_path=args[1]
local console=args[2]
local path_or_name=args[3]

if not path_or_name then 
	logio.put("Usage: rmdir <path_or_name>", nil, console) 
	return 
end

local target=fs.readfull(path_or_name) and path_or_name or (current_path.."/"..path_or_name) 
local info=fs.readfull(target)

if info==nil then
	logio.put('<font color="rgb(255,100,100)">No such directory</font>',nil,console)
	return
elseif info==false then
	logio.put('<font color="rgb(255,100,100)">Not allowed to rm (no permission)</font>',nil,console)
	return
end
if info[1]=="Directory" then 
	fs.rm(target)
else 
	logio.put('<font color="rgb(255,100,100)">Cannot remove file with rmdir (use rm)</font>',nil,console)
end
]]