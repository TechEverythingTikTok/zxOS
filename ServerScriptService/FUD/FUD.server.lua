--[[
    FUD (Script)
    Path: ServerScriptService → FUD
    Parent: FUD
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Get = game:GetService("ReplicatedStorage").FUD.Get
local Database = require(script.Parent.Database)

Get.OnServerInvoke = function(player, package_name)
	if package_name == "-l" then
		local rt = {}
		for k, v in pairs(Database) do
			table.insert(rt, k)
		end
		return rt
	else
		return Database[package_name]
	end
	
end