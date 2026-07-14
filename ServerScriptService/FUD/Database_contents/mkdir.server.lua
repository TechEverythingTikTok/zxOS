--[[
    mkdir (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)
Database.mkdir = [[
local fs = import("fs")
local logio = import("logio")
local current_path = args[1]
local console = args[2]
local path_or_name = args[3]

if not path_or_name then 
	logio.put("Usage: mkdir <path_or_name>", nil, console)
else
	local function split_last_segment(target) 
		local base, last = target:match("(.+)/([^/]+)$") 
		return base or "", last or target 
	end
	local path, fname = split_last_segment(path_or_name)
	if fs.readfull(path) then 
		fs.mkdir(path, fname, false)
	else 
		fs.mkdir(current_path, fname, false) 
	end
end
]]