--[[
    df (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.df = [[
local logio=import("logio")
local fs=import("fs")
local console=args[2]
logio.put("Total Disk Size: "..tostring(fs.get_disk_info()[3]),nil,console)
logio.put("Occupied Disk Size: "..tostring(fs.get_disk_info()[4]),nil,console)
logio.put("Free Disk Size: "..tostring(fs.get_disk_info()[3] - fs.get_disk_info()[4]),nil,console)
]]