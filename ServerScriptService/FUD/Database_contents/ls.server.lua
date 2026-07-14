--[[
    ls (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.ls = [[
local fs=import("fs")
local logio=import("logio")
local current_path=args[1]
local console=args[2]
local flag=args[3]

local lsres=fs.ls(current_path, flag)
for i,v in ipairs(lsres) do 
	logio.put(v,nil,console)
end
]]