--[[
    lpkgs (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.lpkgs = [[
local logio = import("logio")
local fs = import("fs")
local console = args[2]

local list = fs.ls("Root/tmp", "-s")

for i, v in ipairs(list) do
	logio.put(v, nil, console)
end
]]