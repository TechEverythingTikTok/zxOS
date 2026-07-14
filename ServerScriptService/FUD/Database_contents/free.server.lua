--[[
    free (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.free = [[
local logio=import("logio")
local console=args[2]
local memdets=memprops()
logio.put("Total Memory Size: "..tostring(memdets.TotalMemory),nil,console)
logio.put("Occupied Memory Size: "..tostring(memdets.OccupiedMemory),nil,console)
logio.put("Free Memory Size: "..tostring(memdets.TotalMemory-memdets.OccupiedMemory),nil,console)
]]