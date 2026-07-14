--[[
    Panic (ModuleScript)
    Path: ReplicatedStorage → ZKernel → Ring0
    Parent: Ring0
    Exported: 2026-07-14 13:31:45
]]
local Panic = {}
local is_triggered = false

local logio = require(game:GetService("ReplicatedStorage").ZKernel.ScreenOutput.LogIO)
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)

Panic.PM = nil

function Panic.trigger(message: string, id: string, log_msg: string?)
	
	if not Panic.PM then return end
	
	logio.clear()
	logio.clear_overlays()
	
	logio.put("Kernel Panic", {SizeX = 1, TextXAlignment = Enum.TextXAlignment.Center, TextColor = Color3.fromRGB(255, 100, 100)})
	logio.put("")
	logio.put("A kernel panic has occured!")
	logio.put("Error id: ".. id)
	logio.put("Additional: ".. message)
	logio.put("Logging to Root/Logs")
	
	fs.mkdir("Root", "Logs", false)
	local ls = fs.ls("Root/Logs")
	fs.write("Root/Logs", tostring(#ls).."_Info_"..id, "log", (log_msg and log_msg.."\nError id is: "..id) or "No additional logs provided; Error id is: "..id, true)
	
	task.wait(5)
	task.spawn(function()
		Panic.PM.restart()
	end)
end

return Panic