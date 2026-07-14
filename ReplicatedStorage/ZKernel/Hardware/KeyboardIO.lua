--[[
    KeyboardIO (ModuleScript)
    Path: ReplicatedStorage → ZKernel → Hardware
    Parent: Hardware
    Exported: 2026-07-14 13:31:45
]]
local keyboardio = {}
keyboardio._listeners = {}

local UIS = game:GetService("UserInputService")

local uid = 0
local held_keys = {}

-- Check if key is down
function keyboardio.is_key_pressed(kname)
	local kenum = Enum.KeyCode[kname]
	if kenum then
		return UIS:IsKeyDown(kenum)
	end
	return false
end

-- Register a new listener
function keyboardio.new_listener(press_callback, release_callback)
	uid += 1
	local id = uid

	keyboardio._listeners[id] = {
		presscb = press_callback,
		releasecb = release_callback
	}

	return id
end

-- Remove listener
function keyboardio.destroy_listener(id)
	keyboardio._listeners[id] = nil
end

-- Internal key repeat poller
task.spawn(function()
	while true do
		for kname, state in pairs(held_keys) do
			-- state = {held, repeating}
			if state[1] and state[2] and UIS:IsKeyDown(Enum.KeyCode[kname]) then
				for _, listener in pairs(keyboardio._listeners) do
					if listener.presscb then
						listener.presscb(kname, true)
					end
				end
			end
		end
		task.wait(0.1) -- Repeat rate
	end
end)

-- Handle key press
UIS.InputBegan:Connect(function(input, gp)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local kname = input.KeyCode.Name
		if not held_keys[kname] then
			held_keys[kname] = {true, false} -- {held, repeating}

			-- Immediate press
			for _, listener in pairs(keyboardio._listeners) do
				if listener.presscb then
					listener.presscb(kname, false)
				end
			end

			-- Start repeating after delay
			task.spawn(function()
				task.wait(0.6)
				if held_keys[kname] and held_keys[kname][1] and UIS:IsKeyDown(Enum.KeyCode[kname]) then
					held_keys[kname][2] = true -- enable repeating
				end
			end)
		end
	end
end)

-- Handle key release
UIS.InputEnded:Connect(function(input, gp)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local kname = input.KeyCode.Name
		if held_keys[kname] then
			-- Immediately stop repeat
			held_keys[kname] = nil
			for _, listener in pairs(keyboardio._listeners) do
				if listener.releasecb then
					listener.releasecb(kname)
				end
			end
		end
	end
end)

return keyboardio