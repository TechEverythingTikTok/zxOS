--[[
    ueficonfig.cfg (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Root
    Parent: Root
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)
task.wait(2)

local code = [[
local ueficonfig = {
	["uefiboot_select"] = "Root/uefiselect.efi"
}
return ueficonfig
]]

fs.write("Root", "ueficonfig", "cfg", code, false)