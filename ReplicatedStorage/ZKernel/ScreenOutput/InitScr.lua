--[[
    InitScr (ModuleScript)
    Path: ReplicatedStorage → ZKernel → ScreenOutput
    Parent: ScreenOutput
    Exported: 2026-07-14 13:31:45
]]
function InitScreenOut()
	local PlayerGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

	local existingScreen = PlayerGUI:FindFirstChild("ScreenFrameGUI")
	if existingScreen then
		existingScreen:Destroy()
	end

	local ScreenFrameGUI = Instance.new("ScreenGui")
	ScreenFrameGUI.Name = "ScreenFrameGUI"
	ScreenFrameGUI.IgnoreGuiInset = true
	ScreenFrameGUI.Parent = PlayerGUI

	local ScreenFrame = Instance.new("Frame")
	ScreenFrame.Name = "ScreenFrame"
	ScreenFrame.Size = UDim2.fromScale(1, 1)
	ScreenFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ScreenFrame.Parent = ScreenFrameGUI

	if PlayerGUI:FindFirstChild("ScreenOutputGUI") then
		PlayerGUI.ScreenOutputGUI:Destroy()
	end

	local ScreenOutputGUI = Instance.new("ScreenGui")
	ScreenOutputGUI.Name = "ScreenOutputGUI"
	ScreenOutputGUI.Parent = PlayerGUI
end

return InitScreenOut