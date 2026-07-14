--[[
    ps (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.ps = [[
local logio = import("logio")
local pm = import("pm")

local console = args[2]
local flag = args[3]

if not flag then
	local processes = pm.ps()

	for i, v in ipairs(processes) do
		logio.put("PID: "..v, nil, console)
	end
else
	if flag == "-s" then
		local processes = pm.ps(flag)

		for k, v in pairs(processes) do
			logio.put("PID: "..k.."; ALIVE: "..tostring(v), nil, console)
		end
	elseif flag == "-l" then
		local processes = pm.ps(flag)

		for k, v in pairs(processes) do
			logio.put("PID: "..k.."; LIFETIME: "..v, nil, console)
		end
	else
		logio.put("Invalid argument for ps. Valid arguments: {'-s'; '-l'}", nil, console)
	end
end
]]