--[[
    touch (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.touch = [[
local fs=import("fs")
local logio=import("logio")
local current_path=args[1]
local console=args[2]
local name_extension=args[3]

if not name_extension then
	logio.put("Usage: touch <filename.fileextension>",nil,console)
	return
end
local name, extension=string.match(name_extension,"^(.*)%.(.*)$")
if extension=="" then
	logio.put("Usage: touch <filename.fileextension>",nil,console)
	return
end
if name and extension then
	if fs.readfull(current_path.."/"..name.."."..extension) then 
		logio.put('Another file with the same name and extension exists in the cwd!',nil,console)
	else 
		fs.write(current_path,name,extension,"",false) 
	end
else
	logio.put('<font color="rgb(255,100,100)">Invalid argument format given!</font>',nil,console)
end
]]