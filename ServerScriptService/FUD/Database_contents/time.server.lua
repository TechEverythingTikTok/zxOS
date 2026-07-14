--[[
    time (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.time = [[
local logio = import("logio")
local console = args[2]

logio.put(date_time("%H:%M:%S"), nil, console)
]]