--[[
    pwd (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.pwd = [[
local logio=import("logio")
local current_path=args[1]
local console=args[2]
logio.put(current_path,nil,console)
]]