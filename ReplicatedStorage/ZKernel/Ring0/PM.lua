--[[
    PM (ModuleScript)
    Path: ReplicatedStorage → ZKernel → Ring0
    Parent: Ring0
    Exported: 2026-07-14 13:31:45
]]

--[[
AUTHOR: 

Discord: itsaxgam
Roblox: Alexandru2201913
]]

local PM = {}

local CoreLang = require(script.CoreLang) -- the Luau bytecode compiler
local FileSystem = require(script.Parent.FS) -- the virtual filesystem
local MemoryManager = require(script.Parent.MM) -- the memory manager for heap
local logio = require(script.Parent.Parent.ScreenOutput.LogIO) -- input/output to screen
local Panic = require(script.Parent.Panic) -- kernel panic
local PayService = require(script.Parent.Parent.Parent.PayService) -- service for payments

local GetData 	= game:GetService("ReplicatedStorage").FileSystemData.GetData -- file system get data
local SaveData	= game:GetService("ReplicatedStorage").FileSystemData.SaveData -- file system save data

local islogioinit = false -- LogIO initialized flag

-- Interpret file content directly with environment
-- this calls CoreLang and compiles to bytecode directly with a custom environment, not using the default environment
function PM.ring0interpret(file_content, environment)
	return CoreLang(file_content, environment)
end

PM.date_time = os.date -- callable function to get time

-- basic Lua environment
-- these are all available in Roblox Luau and are just passed to the compiled Lua so they can be called
local global_env = {}
global_env.table = table
global_env.unpack = unpack
global_env.task = task
global_env.pcall = pcall
global_env.xpcall = xpcall
global_env.print = print
global_env.warn = warn
global_env.Color3 = Color3
global_env.ipairs = ipairs
global_env.pairs = pairs
global_env.tostring = tostring
global_env.tonumber = tonumber
global_env.type = type
global_env.typeof = typeof
global_env.string = string
global_env.date_time = os.date
global_env.math = math
global_env.error = error
global_env.Enum = {
	TextXAlignment = Enum.TextXAlignment,
	TextYAlignment = Enum.TextYAlignment
}
global_env.get_screen_res = function()
	-- returns the screen resolution (absolute)
	return workspace.CurrentCamera.ViewportSize
end
global_env.import = function(target: string)
	-- custom import
	--[[
	instead of calling local module = require(thing), in the compiled Lua you would do
	local module = import(thing)
	there are a few default imports and you can import paths too

	Basically, if you pass as target "pm" this will return PM to the import()
	]]
	if target == "pm" then
		-- process manager
		return PM
	elseif target == "fs" then
		-- file system
		return FileSystem
	elseif target == "logio" then
		-- input output to screen
		return logio
	elseif target == "keyboardio" then
		-- keyboard input output module
		return require(script.Parent.Parent.Hardware.KeyboardIO)
	elseif target == "panic" then
		-- kernel panic
		return Panic
	elseif target == "fud" then
		-- file upload download
		return require(script.Parent.Parent.Parent.FUD.FUD)
	elseif target == "payservice" then
		-- pay service
		return require(script.Parent.Parent.Parent.PayService)
	elseif target == "mm" then
		-- memory manager
		return MemoryManager
	else
		-- import custom file
		--[[
		if you have a file at Root/cool_module.lua
		and it contains

		```
		return function(msg) 
			print(msg) 
		end
		```

		then when you will do in your current file
		```
		local cool_function = import("Root/cool_module.lua")
		cool_function("Hi")
		```

		it will print Hi
		]]
		local file_content = FileSystem.read(target) -- read the specified path from the file system
		if not file_content then return nil end -- if file content doesnt exist return
		local code, error_message = CoreLang(file_content, global_env) -- interpret the new file
		if not code then return nil end -- if code function doesnt exist return
		local result = code() -- get result
		return result -- return the result
	end
end

local global_pid_count = 0 -- PID count is used to determine an UID (unique id) to each process

PM.processes = {}
local processes = PM.processes

--[[
SIGTERM and SIGINT are similar, they are both called to terminate a pprogram (in this specific OS the program must cooperate)
SIGKILL doesn't care if the program cooperates, it just kills
]]
PM.SIGNALS = {
	SIGTERM = 0,
	SIGINT = 1,
	SIGKILL = 2
}
table.freeze(PM.SIGNALS)

-- spawn a process and return a PID or nothing in case of error
function PM.spawn_proc(path: string, args, env_override, permission: string?): number?
	local file_content = FileSystem.read(path, "Ring0") -- read the file at the specified path in ring0 mode	
	if not file_content then
		-- return in case if error happened during read
		return nil 
	end
	
	local proc_env = {} -- the process' environment
	for k, v in pairs(global_env) do
		proc_env[k] = v
	end
	
	global_pid_count += 1 -- increase PID by 1
	local pid = global_pid_count -- set the process' PID to the current global PID
	
	proc_env.pid = pid -- process can access it's pid directly
	proc_env.args = args -- process can access it's args directly
	
	proc_env.cwd = function()
		-- get the current working directory
		return processes[pid].cwd
	end
	proc_env.cd = function(new_dir)
		-- change the current working directory into a new one
		if new_dir == ".." then
			processes[pid].cwd = FileSystem.readfull(processes[pid].cwd)[4] -- set the process' cwd to the parent of the current
		else
			if FileSystem.readfull(new_dir) then
				-- change to custom path
				processes[pid].cwd = new_dir
			end
		end
	end
	proc_env.malloc = function(size)
		-- alllocate memory
		return MemoryManager.malloc(pid, size)
	end
	proc_env.getheap = function(ptr)
		-- get buffer
		return MemoryManager.getheap(pid, ptr)
	end
	proc_env.free = function(ptr)
		-- free pointer
		return MemoryManager.free(pid, ptr)
	end
	proc_env.proc_path = function()
		-- get process path (not cwd)
		return processes[proc_env.pid] and processes[proc_env.pid].location
	end
	proc_env.should_run = function()
		-- check if process should run
		return processes[proc_env.pid] and processes[proc_env.pid].should_run
	end
	
	if type(env_override) == "table" then
		for k, v in pairs(env_override) do
			-- add (OR OVERRIDE) new values to the current environment
			proc_env[k] = v
		end
	end
	
	local executable, error_message = CoreLang(file_content, proc_env) -- spawn the executable with the file content and the determined environment
	if not executable then
		-- return error code and error message if the executable doesn't exist
		return "0x1", error_message 
	end

	-- write the process at the processes table with the determined PID
	processes[pid] = {
		exec = executable,
		env = proc_env,
		should_run = false,
		is_alive = false,
		handle = nil,
		location = path,
		cwd = (FileSystem.readfull(path) and FileSystem.readfull(path)[4]) or "Root",
		lifetime = 0,
		perms = permission or "Ring0"
	}
	
	return pid -- return the PID 
end

function PM.run_proc(pid: number, permission: string?)
	-- runs a process by its given PID
	-- on paper, it looks in the processes table for the PID and it executes it based on the metadata
	
	local process = processes[pid] -- get the process
	
	if not process then
		-- process doesn't exist, return
		return false 
	end
	
	if permission then
		if process.perms == "Ring0" and permission == "Ring3" then
			-- Ring3 process can not run a Ring0 process
			return "0x1"
		end
	end
	
	processes[pid].handle = task.spawn(function()
		-- spawn a handle that the roblox scheduler will execute
		-- initialize the should run and is alive values
		process.should_run = true
		process.is_alive = true

		-- run the process in a pcall() so in case of failure it will not make the whole script crash
		-- this runs the compiled bytecode
		local success, error_message = pcall(function()
			process.exec()
		end)

		-- an error happened in the PID execution (list it too)
		if not success then
			warn("[PM -- run_proc()] > failed; error in pid execution: ", pid, " (error: ", error_message,")")
		end

		-- reset values
		process.should_run = false
		process.is_alive = false
		
		-- clear memory
		pcall(MemoryManager.free_program, pid)
		processes[pid] = nil
		print("[PM -- run_proc()] > process thread finished and despawned: ", pid)
	end)
	
	task.spawn(function()
		-- count the lifetime of the process up as a separate thread
		-- this will run until the process is dead
		while processes[pid] and processes[pid].is_alive do
			task.wait(1)
			if processes[pid] then
				processes[pid].lifetime += 1
			end
		end
	end)
end

-- destroy a process (remove it from the processes table)
-- this only works if the process isn't running anymore
function PM.destroy_proc(pid: number, permission: string?)
	if not processes[pid] then return nil end
	if processes[pid].is_alive then return nil end
	processes[pid] = nil
end

function PM.signal(pid: number, signal, permission: string?)
	-- send a signal to a process
	if not processes[pid] then
		-- PID doesn't correlate to a real process, return
		return "0x2" 
	end
	if not processes[pid].is_alive then
		-- the process is not alive, return
		return "0x3" 
	end
	if not processes[pid].handle then
		-- there is no valid handle in the process, return
		return "0x4" 
	end
	if processes[pid].perms == "Ring0" and permission == "Ring3" then
		-- no permission to execute, return
		return "0x1"
	end
	
	if signal == PM.SIGNALS.SIGTERM or signal == PM.SIGNALS.SIGINT then
		-- the process has to stop by itself in this case
		-- send the signal
		processes[pid].should_run = false
		return "0x0"
	elseif signal == PM.SIGNALS.SIGKILL then
		-- this will kill the process
		-- send the signal
		local succ, err = pcall(function()
			-- cancel the handle that is running
			task.cancel(processes[pid].handle)
		end)
		if not succ	then
			warn("[PM -- signal()] > SIGKILL failed on pid: ", pid) 
		end
		
		-- dump memory from process
		pcall(MemoryManager.free_program, pid)
		processes[pid] = nil
		return "0x0"
	else
		-- invalid signal
		warn("[PM -- signal()] > signal not found: ", signal) 
		return "0x2"
	end
end

-- checks if a process is alive or not
function PM.is_alive(pid)
	if not processes[pid] then return end
	return processes[pid].is_alive
end

function PM.ps(flag)
	-- list processes with a custom flag
	local proc_table = {}
		
	if flag then
		if flag == "-s" then
			for k, v in pairs(processes) do
				-- correspond PID to running
				proc_table[k] = v.is_alive
			end
		elseif flag == "-l" then
			for k, v in pairs(processes) do
				-- correspond PID to lifetime 
				proc_table[k] = v.lifetime
			end
		end
	else
		for k, v in pairs(processes) do
			-- just list the PID
			table.insert(proc_table, k)
		end
	end
	
	return proc_table
end

function PM.shutdown()
	-- OS specific function
	-- shut down
	logio.clear() -- clear the screen
	logio.clear_overlays() -- clear overlays
	for pid, process in pairs(processes) do
		-- terminate an alive process cooperatively
		if process.is_alive then
			PM.signal(pid, PM.SIGNALS.SIGTERM)
			if not process.is_alive then
				-- terminated process
				logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')')
			else
				task.wait(1)
				-- delay message by 1 second if the process doesn't end immediately
				if not process.is_alive then
					print("[PM -- shutdown()] > terminated pid: ", pid)
					logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')')
				end
			end
		end
	end
	
	task.wait(1)
	
	for pid, process in pairs(processes) do
		-- attempt to terminate an alive process cooperatively
		if process.is_alive then
			local id = logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] A stop job is running for PID '..tostring(pid)..' ('..process.location..') (1s timeout)')
			for i = 1, 10 do
				-- attempt to terminate process
				PM.signal(pid, PM.SIGNALS.SIGTERM)
				if not process.is_alive then
					logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')') -- process terminated after stop job
					break
				end
				task.wait(0.1)
			end
			
			if process.is_alive then
				-- forcefully kill the process if it fails to cooperate
				PM.signal(pid, PM.SIGNALS.SIGKILL)
				logio.put('[ INFO ] Killed process '..tostring(pid)..' ('..process.location..')')
			end
		end
	end
	
	task.wait(1)
	
	for pid, process in pairs(processes) do
		-- destroy every process from memory
		PM.destroy_proc(pid)
	end
	
	task.wait(0.5)
	
	logio.clear() -- clear the screen
	
	PayService.DisconnectAll() -- disconnect all callbacks to payments (this is just memory cleanup)
	
	global_pid_count = 0 -- reset the PID count
	
	FileSystem.rm("Root/tmp") -- remove tempporary directory
	FileSystem.rm("Root/tmplibs") -- remote temporary libraries
	
	Panic.PM = nil -- set PM table to nil in the panic table
	
	SaveData:InvokeServer(FileSystem.save_data()) -- save file system data (sends request to server)
	logio.put('[ <font color="rgb(255, 0, 255)"><strong>SAFE</strong></font> ] It is now safe to turn off your computer.')
end

function PM.start()
	local ScrOut = require(game:GetService("ReplicatedStorage").ZKernel.ScreenOutput.InitScr) -- function to initialize the screen output and make sure it is ready

	ScrOut()
	logio.InitTxtOut() -- Always re-init the logio
	logio.clear() -- clear logio in case of any outputs on the screen
	islogioinit = true -- set islogioinit to true
	
	local Data = GetData:InvokeServer() -- get file system data
	if Data == -1 then
		-- an error occurred
		logio.put('[<font color="rgb(120, 230, 130)"><strong>FAILED</strong></font>] Failed to read File System data') -- couldn't read fs data
	elseif Data == nil then
		-- first time playing, good initialization
		logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized File System') 
	else
		-- load the data if it is good and player has played
		FileSystem.load_data(Data)
		logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized File System')
	end

	-- delay for UEFI initialization and mark process manager as initialized
	
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized Process Manager')
	logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] Waiting 6 seconds for UEFI initialization')
	
	task.wait(6)
	Panic.PM = PM -- new reference of PM
	
	task.spawn(function()
		while true do
			-- save the data every 30 seconds to make sure data loss doesn't happen or is minimal
			SaveData:InvokeServer(FileSystem.save_data())
			task.wait(30)
		end
	end)

	-- wait one final second before spawining the boot protocol
	task.wait(1)
	
	local PID = PM.spawn_proc("Root/uefiboot.efi")
	PM.run_proc(PID) -- hand off control to uefiboot.efi
end

function PM.restart()
	-- just shutdown, wait a bit and then start
	-- that is what a restart is
	PM.shutdown()
	task.wait(1)
	PM.start()
end

return PM
