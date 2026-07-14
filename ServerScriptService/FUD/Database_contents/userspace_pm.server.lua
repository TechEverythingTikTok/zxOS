--[[
    userspace_pm (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.userspace_pm = [[
local userspace_pm = {}
local pm = import("pm")
local userspace_fs = import("Root/tmplibs/userspace_fs.lib")

userspace_pm.SIGNALS = {
	SIGTERM = 0,
	SIGINT = 1,
	SIGKILL = 2
}
table.freeze(userspace_pm.SIGNALS)

local override_env = {}
override_env.table = table
override_env.unpack = unpack
override_env.task = task
override_env.pcall = pcall
override_env.xpcall = xpcall
override_env.print = print
override_env.Color3 = Color3
override_env.ipairs = ipairs
override_env.pairs = pairs
override_env.tostring = tostring
override_env.tonumber = tonumber
override_env.type = type
override_env.typeof = typeof
override_env.string = string
override_env.date_time = pm.date_time
override_env.math = math
override_env.Enum = {
	TextXAlignment = Enum.TextXAlignment,
	TextYAlignment = Enum.TextYAlignment
}
override_env.get_screen_res = function()
	return workspace.CurrentCamera.ViewportSize
end
override_env.import = function(target)
	if target == "pm" then
		return userspace_pm
	elseif target == "fs" then
		return userspace_fs
	elseif target == "keyboardio" then
		return import("keyboardio")
	elseif target == "fud" then
		return import("fud")
	elseif target == "payservice" then
		return import("payservice")
	elseif target == "logio" then
		return import("logio")
	else
		--local file_content = userspace_fs.read(target)
		--if not file_content then return nil end
		--local code, error_message = pm.ring0interpret(file_content, override_env)
		--if not code then return nil end
		--local result = code()
		--return result
	end
end
function userspace_pm.spawn_proc(path, insargs)
	return pm.spawn_proc(path, insargs, override_env, "Ring3")
end
function userspace_pm.run_proc(PID)
	return pm.run_proc(PID)
end
function userspace_pm.destroy_proc(PID)
	pm.destroy_proc(PID)
end
function userspace_pm.signal(PID, signal)
	return pm.signal(PID, signal)
end
function userspace_pm.is_alive(PID)
	return pm.is_alive(PID)
end
function userspace_pm.ps(flag)
	return pm.ps(flag)
end
function userspace_pm.shutdown()
	pm.shutdown()
end
function userspace_pm.restart()
	pm.restart()
end

return userspace_pm
]]