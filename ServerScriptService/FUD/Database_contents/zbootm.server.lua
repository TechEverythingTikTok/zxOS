--[[
    zbootm (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database["zbootm"] = [[
local logio = import("logio")
local panic = import("panic")

local pmr0 = import("pm")

local pmr3 = import("Root/libs/pm.lib")

local config = import("Root/etc/zbootm.cfg")

local PID = pmr3.spawn_proc(config.init_file_location, config.init_proc_args)
pmr3.run_proc(PID)
]]

Database["zbootmcfg"] = [[
local config = {}

config.init_file_location 	= "Root/sbin/tty.zxe"
config.init_proc_args		= {}

return config
]]