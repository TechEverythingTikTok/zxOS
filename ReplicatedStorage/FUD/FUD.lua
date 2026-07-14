--[[
    FUD (ModuleScript)
    Path: ReplicatedStorage → FUD
    Parent: FUD
    Exported: 2026-07-14 13:31:45
]]
local Get = script.Parent.Get
local fud = {}

function fud.get_content(package_name)
	local content = Get:InvokeServer(package_name)
	return content
end

return fud