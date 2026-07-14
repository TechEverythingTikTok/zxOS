--[[
    Initialize (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts
    Parent: StarterPlayerScripts
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local PM = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.PM)

local StarterGui = game:GetService("StarterGui")
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

local UIS = game:GetService("UserInputService")
UIS.MouseIconEnabled = false

local PlayerGUI = game:GetService("Players").LocalPlayer.PlayerGui
if PlayerGUI:FindFirstChild("Freecam") then
	PlayerGUI.Freecam:Destroy()
end

task.wait(1)

PM.start()