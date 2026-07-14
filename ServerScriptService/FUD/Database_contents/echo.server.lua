--[[
    echo (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.echo = [[
local logio = import("logio")
local console = args[2]

local str = ""

for i, v in ipairs(args) do
	if i > 2 then
		str = str.." "
		str = str..v
	end
end

logio.put(str, nil, console)
]]