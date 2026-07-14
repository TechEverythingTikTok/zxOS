--[[
    cat (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.cat = [[
local logio = import("logio")
local fs = import("fs")
local current_path = args[1]
local console = args[2]
local path_or_name = args[3]

if not path_or_name then
	logio.put("Usage: cat <filename/filepath>", nil, console)
	return
end

local target = (fs.readfull(path_or_name) ~= nil) and path_or_name or (current_path.."/"..path_or_name)
local info = fs.readfull(target)
	
if info == false then
	logio.put('<font color="rgb(255, 100, 100)">Not allowed to read file (no permissions)</font>', nil, console)
	return
elseif info == nil then
	logio.put('<font color="rgb(255, 100, 100)">No such file found</font>', nil, console)
	return
end
	
if info[1] == "File" then
	logio.put(fs.read(target), nil, console)
else
	logio.put('<font color="rgb(255, 100, 100)">Cannot cat a Directory</font>', nil, console)
end
]]