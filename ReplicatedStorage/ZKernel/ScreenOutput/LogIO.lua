--[[
    LogIO (ModuleScript)
    Path: ReplicatedStorage → ZKernel → ScreenOutput
    Parent: ScreenOutput
    Exported: 2026-07-14 13:31:45
]]
local log_io = {}

function log_io.InitTxtOut()
	
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	
	if ScrOut:FindFirstChild("TxtOutFrame") then
		ScrOut:FindFirstChild("TxtOutFrame"):Destroy()
	end
	
	local TxtOutFrame = Instance.new("ScrollingFrame")
	TxtOutFrame.Parent = ScrOut
	TxtOutFrame.Name = "TxtOutFrame"
	TxtOutFrame.Size = UDim2.fromScale(1, 1)
	TxtOutFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TxtOutFrame.CanvasSize = UDim2.fromScale(0, 0)
	TxtOutFrame.ScrollBarImageTransparency = 1
	TxtOutFrame.ScrollingEnabled = true
	TxtOutFrame.ZIndex = 1
	TxtOutFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	
	local Layout = Instance.new("UIListLayout")
	Layout.Parent = TxtOutFrame
	Layout.Name = "Layout"
end

function log_io.put(text: string, params: {
	TextColor: Color3?, 
	TextStrokeColor: Color3?, 
	TextStrokeTransparency: number?,
	TextTransparency: number?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	SizeX: number?,
	TextSize: number?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?,
	SetAutomaticCanvasPosition: boolean?
}?, target_frame: ScrollingFrame?)
	print("[logio -- put() > Got call to print text: ", text)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	if target_frame then
		if not target_frame:FindFirstChildOfClass("UILayout") then
			print("[logio -- put() > target frame has no UILayout children")
			return nil
		end
	end
	local TxtOutFrame = target_frame or ScrOut:FindFirstChild("TxtOutFrame")
	local layout = TxtOutFrame:FindFirstChild("Layout")
	
	local name: string = string.format("%05d", #TxtOutFrame:GetChildren())
	
	local Text = Instance.new("TextLabel")
	Text.Name = name -- ex: 00001
	Text.RichText = true
	Text.Text = text
	Text.AutomaticSize = Enum.AutomaticSize.Y
	Text.TextWrapped = true
	Text.AnchorPoint = Vector2.new(0.5, 0)
	Text.Parent = TxtOutFrame
	Text.TextSize = params and params.TextSize or 20
	Text.Font = "Code"
	Text.Size = UDim2.new(params and params.SizeX or 1, 0, 0, 0)
	Text.TextXAlignment = params and params.TextXAlignment or Enum.TextXAlignment.Left
	Text.TextYAlignment = params and params.TextYAlignment or Enum.TextYAlignment.Top
	Text.TextColor3 = params and params.TextColor or Color3.fromRGB(255, 255, 255)
	Text.TextStrokeColor3 = params and params.TextStrokeColor or Color3.fromRGB(0, 0, 0)
	Text.TextStrokeTransparency = params and params.TextStrokeTransparency or 1
	Text.TextTransparency = params and params.TextTransparency or 0
	Text.BackgroundColor3 = params and params.BackgroundColor or Color3.fromRGB(0, 0, 0)
	Text.BackgroundTransparency = params and params.BackgroundTransparency or 1
	
	if params then
		if params.SetAutomaticCanvasPosition then
			TxtOutFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
		end
	else
		TxtOutFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
	end
	
	print("[logio -- put() > successfully printed text: ", text)
	return name
end

function log_io.get_text(name: string, target_frame: ScrollingFrame?)
	print("[logio -- get_text() > got call to return text on name: ", name)
	if target_frame then
		if not target_frame:FindFirstChildOfClass("UILayout") then
			print("[logio -- get_text() > target frame has no UILayout children: ", name)
			return nil
		end
	end
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame = target_frame or ScrOut:FindFirstChild("TxtOutFrame")
	if not TxtOutFrame:FindFirstChild(name) then
		print("[logio -- get_text() > text not found on name: ", name)
		return nil
	end
	if not TxtOutFrame:FindFirstChild(name):IsA("TextLabel") then
		print("[logio -- get_text() > text not found on name: ", name)
		return nil
	end
	
	print("[logio -- get_text() > successfully retrieved text for name: ", name)
	return TxtOutFrame:FindFirstChild(name).Text
end

function log_io.modify(name: string, newtext: string, params: {
	TextColor: Color3?, 
	TextStrokeColor: Color3?, 
	TextStrokeTransparency: number?,
	TextTransparency: number?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	TextSize: number
}?)
	print("[logio -- modify() > got call to modify name: ", name)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame: ScrollingFrame = ScrOut:FindFirstChild("TxtOutFrame")
	local layout = TxtOutFrame:FindFirstChild("Layout")
	
	if not TxtOutFrame then return end
	if not TxtOutFrame:FindFirstChild(name) then
		print("[logio -- modify() > text not found on name: ", name)
		return nil
	end
	if not TxtOutFrame:FindFirstChild(name):IsA("TextLabel") then
		print("[logio -- modify() > text not found on name: ", name)
		return nil 
	end
	
	local Text = TxtOutFrame:FindFirstChild(name)
	
	Text.Text = newtext
	Text.TextSize = params and params.TextSize or 20
	Text.TextColor3 = params and params.TextColor or Text.TextColor3
	Text.TextStrokeColor3 = params and params.TextStrokeColor or Text.TextStrokeColor3
	Text.TextStrokeTransparency = params and params.TextStrokeTransparency or Text.TextStrokeTransparency
	Text.TextTransparency = params and params.TextTransparency or Text.TextTransparency
	Text.BackgroundColor3 = params and params.BackgroundColor or Text.BackgroundColor3
	Text.BackgroundTransparency = params and params.BackgroundTransparency or Text.BackgroundTransparency
	TxtOutFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
	
	print("[logio -- modify() > successfully modified name: ", name)
end

function log_io.clear()
	print("[logio -- clear() > got call to clear tty")
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame: ScrollingFrame = ScrOut:FindFirstChild("TxtOutFrame")

	for i, child in ipairs(TxtOutFrame:GetChildren()) do
		if child:IsA("UIListLayout") then continue end
		child:Destroy()
	end
	print("[logio -- clear() > cleared tty successfully")
end

function log_io.create_overlay(index)
	print("[logio -- create_overlay() > got call to create overlay")
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	
	local name: string = string.format("%05d", #ScrOut:GetChildren())
	
	if type(index) ~= "number" then index = 2 end
	if index > 5 then
		index = 5
	end
	if index < 2 then
		index = 2
	end
	
	local CTxtOutFrame 						= Instance.new("ScrollingFrame")
	CTxtOutFrame.Parent 					= ScrOut
	CTxtOutFrame.Name   					= name
	CTxtOutFrame.Size   					= UDim2.fromScale(1, 1)
	CTxtOutFrame.BackgroundColor3   		= Color3.new(0, 0, 0)
	CTxtOutFrame.CanvasSize         		= UDim2.fromScale(0, 0)
	CTxtOutFrame.ScrollBarImageTransparency = 1
	CTxtOutFrame.ScrollingEnabled   		= false
	CTxtOutFrame.ZIndex             		= index
	CTxtOutFrame.AutomaticCanvasSize 		= Enum.AutomaticSize.Y
	
	local Layout 		= Instance.new("UIListLayout")
	Layout.Name 		= "Layout"
	Layout.Parent    	= CTxtOutFrame
	Layout.SortOrder 	= Enum.SortOrder.LayoutOrder
	
	print("[logio -- create_overlay() > successfully created overlay")
	return name
end

function log_io.put_overlay(id: string, text: string, params: {
	TextColor: Color3?, 
	TextStrokeColor: Color3?, 
	TextStrokeTransparency: number?,
	TextTransparency: number?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	SizeX: number?,
	TextSize: number?,
	TextXAlignment: Enum.TextXAlignment?,
	TextYAlignment: Enum.TextYAlignment?
}?)
	print("[logio -- put_overlay() > got call to print on ovelay id: ", id)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame: ScrollingFrame = ScrOut:FindFirstChild(id)
	
	if not TxtOutFrame then
		print("[logio -- put_overlay() > no overlay found: ", id)
		return nil
	end
	
	local layout = TxtOutFrame:FindFirstChild("Layout")
	
	local name: string = string.format("%05d", #TxtOutFrame:GetChildren())

	local Text = Instance.new("TextLabel")
	Text.Name = name -- ex: 00001
	Text.RichText = true
	Text.Text = text
	Text.AutomaticSize = Enum.AutomaticSize.Y
	Text.TextWrapped = true
	Text.Parent = TxtOutFrame
	Text.TextSize = params and params.TextSize or 20
	Text.Font = "Code"
	Text.ZIndex = 3
	Text.Size = UDim2.new(params and params.SizeX or 1, 0, 0, 0)
	Text.TextXAlignment = params and params.TextXAlignment or Enum.TextXAlignment.Left
	Text.TextYAlignment = params and params.TextYAlignment or Enum.TextYAlignment.Top
	Text.TextColor3 = params and params.TextColor or Color3.fromRGB(255, 255, 255)
	Text.TextStrokeColor3 = params and params.TextStrokeColor or Color3.fromRGB(0, 0, 0)
	Text.TextStrokeTransparency = params and params.TextStrokeTransparency or 1
	Text.TextTransparency = params and params.TextTransparency or 0
	Text.BackgroundColor3 = params and params.BackgroundColor or Color3.fromRGB(0, 0, 0)
	Text.BackgroundTransparency = params and params.BackgroundTransparency or 1
	TxtOutFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
	
	print("[logio -- put_overlay() > successfully printed on overlay: ", id)
	return name
end

function log_io.modify_overlay(id: string, name: string, newtext: string, params: {
	TextColor: Color3?, 
	TextStrokeColor: Color3?, 
	TextStrokeTransparency: number?,
	TextTransparency: number?,
	BackgroundColor: Color3?,
	BackgroundTransparency: number?,
	TextSize: number
}?)
	print("[logio -- modify_overlay() > got call to modify overlay: ", id, ", name: ", name)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame: ScrollingFrame = ScrOut:FindFirstChild(id)
	if not TxtOutFrame then
		print("[logio -- modify_overlay() > overlay does not exist: ", id)
		return nil 
	end
	local layout = TxtOutFrame:FindFirstChild("Layout")
	
	
	if not TxtOutFrame:FindFirstChild(name) then
		print("[logio -- modify_overlay() > name does not exist: ", name, " in overlay: ", id)
		return nil
	end
	if not TxtOutFrame:FindFirstChild(name):IsA("TextLabel") then
		print("[logio -- modify_overlay() > name does not exist: ", name, " in overlay: ", id)
		return nil
	end

	local Text = TxtOutFrame:FindFirstChild(name)

	Text.Text = newtext
	Text.TextSize = params and params.TextSize or 20
	Text.TextColor3 = params and params.TextColor or Text.TextColor3
	Text.TextStrokeColor3 = params and params.TextStrokeColor or Text.TextStrokeColor3
	Text.TextStrokeTransparency = params and params.TextStrokeTransparency or Text.TextStrokeTransparency
	Text.TextTransparency = params and params.TextTransparency or Text.TextTransparency
	Text.BackgroundColor3 = params and params.BackgroundColor or Text.BackgroundColor3
	Text.BackgroundTransparency = params and params.BackgroundTransparency or Text.BackgroundTransparency
	TxtOutFrame.CanvasPosition = Vector2.new(0, layout.AbsoluteContentSize.Y)
	
	print("[logio -- modify_overlay() > successfully modified: ", name, " in overlay: ", id)
end

function log_io.get_text_overlay(id: string, name: string)
	
	print("[logio -- get_text_overlay() > got call to return text on name: ", name, ", id: ", id)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame = ScrOut:FindFirstChild(id)
	
	if not TxtOutFrame then return end
	if not TxtOutFrame:FindFirstChild(name) then return end
	if not TxtOutFrame:FindFirstChild(name):IsA("TextLabel") then return end
	
	print("[logio -- get_text_overlay() > successfully retrieved text on name: ", name, ", id: ", id)
	return TxtOutFrame:FindFirstChild(name).Text
end

function log_io.clear_overlay(id: string)
	print("[logio -- clear_overlay() > got call to clear overlay id: ", id)
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	local TxtOutFrame: ScrollingFrame = ScrOut:FindFirstChild(id)
	
	if not TxtOutFrame then
		print("[logio -- clear_overlay() > id not found: ", id)
		return nil
	end
	if id == "TxtOutFrame" then
		print("[logio -- clear_overlay() > illegal id: ", id)
		return nil
	end
	
	print("[logio -- clear_overlay() > successfully cleared overlay with id: ", id)
	TxtOutFrame:Destroy()
end

function log_io.clear_overlays()
	print("[logio -- clear_overlays() > got call to clear all overlays")
	
	local ScrOut = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ScreenOutputGUI")
	
	for i, child in ipairs(ScrOut:GetChildren()) do
		if child.Name == "TxtOutFrame" then continue end
		child:Destroy()
	end
	print("[logio -- clear_overlays() > cleared all overlays successfully")
end

return log_io