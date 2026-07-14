--[[
    GraphicsManager (ModuleScript)
    Path: ReplicatedStorage → ZKernel → ScreenOutput
    Parent: ScreenOutput
    Exported: 2026-07-14 13:31:45
]]
local GraphicsManager = {}

function GraphicsManager.Init()
	local ScrOutGUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	
	if ScrOutGUI:FindFirstChild("GraphicsManagerFolder") then
		ScrOutGUI:FindFirstChild("GraphicsManagerFolder"):Destroy()
	end
	
	local GraphicsManagerFolder = Instance.new("Folder")
	GraphicsManagerFolder.Name = "GraphicsManagerFolder"
	GraphicsManagerFolder.Parent = ScrOutGUI
end

function GraphicsManager.Clear()
	local ScrOutGUI = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	
	if ScrOutGUI:FindFirstChild("GraphicsManagerFolder") then
		ScrOutGUI:FindFirstChild("GraphicsManagerFolder"):Destroy()
	end
end

return GraphicsManager