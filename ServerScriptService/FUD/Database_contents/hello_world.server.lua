--[[
    hello_world (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.hello_world = [[
local logio = import("logio")
local console = args[2]
logio.put("This is a punctuated sentence, with the target being 'Hello World'! It does not do anything, but is here just for testing.", nil, console)
]]