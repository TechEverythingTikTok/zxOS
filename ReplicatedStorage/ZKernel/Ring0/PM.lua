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

local CoreLang = require(script.CoreLang)
local FileSystem = require(script.Parent.FS)
local MemoryManager = require(script.Parent.MM)
local logio = require(script.Parent.Parent.ScreenOutput.LogIO)
local Panic = require(script.Parent.Panic)
local PayService = require(script.Parent.Parent.Parent.PayService)

local GetData 	= game:GetService("ReplicatedStorage").FileSystemData.GetData
local SaveData	= game:GetService("ReplicatedStorage").FileSystemData.SaveData

local islogioinit = false

function PM.ring0interpret(file_content, environment)
	return CoreLang(file_content, environment)
end

PM.date_time = os.date

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
	return workspace.CurrentCamera.ViewportSize
end
global_env.import = function(target: string)
	if target == "pm" then
		return PM
	elseif target == "fs" then
		return FileSystem
	elseif target == "logio" then
		return logio
	elseif target == "keyboardio" then
		return require(script.Parent.Parent.Hardware.KeyboardIO)
	elseif target == "panic" then
		return Panic
	elseif target == "fud" then
		return require(script.Parent.Parent.Parent.FUD.FUD)
	elseif target == "payservice" then
		return require(script.Parent.Parent.Parent.PayService)
	elseif target == "mm" then
		return MemoryManager
	else
		local file_content = FileSystem.read(target)
		if not file_content then return nil end
		local code, error_message = CoreLang(file_content, global_env)
		if not code then return nil end
		local result = code()
		return result
	end
end

local global_pid_count = 0

PM.processes = {}
local processes = PM.processes

PM.SIGNALS = {
	SIGTERM = 0,
	SIGINT = 1,
	SIGKILL = 2
}
table.freeze(PM.SIGNALS)

function PM.spawn_proc(path: string, args, env_override, permission: string?)
	print("[PM -- spawn_proc()] > --path: ", path, "--args: ", args, "--env_override", env_override, "--perm", permission)
	local file_content = FileSystem.read(path, "Ring0")
	
	if not file_content then
		warn("[PM -- spawn_proc()] > no file content found for path: ", path)
		return nil 
	end
	
	local proc_env = {}
	for k, v in pairs(global_env) do
		proc_env[k] = v
	end
	
	global_pid_count += 1
	local pid = global_pid_count
	
	proc_env.pid = pid
	proc_env.args = args
	
	proc_env.cwd = function()
		return processes[pid].cwd
	end
	proc_env.cd = function(new_dir)
		if new_dir == ".." then
			processes[pid].cwd = FileSystem.readfull(processes[pid].cwd)[4]
		else
			if FileSystem.readfull(new_dir) then
				processes[pid].cwd = new_dir
			end
		end
	end
	proc_env.malloc = function(size)
		return MemoryManager.malloc(pid, size)
	end
	proc_env.getheap = function(ptr)
		return MemoryManager.getheap(pid, ptr)
	end
	proc_env.free = function(ptr)
		return MemoryManager.free(pid, ptr)
	end
	proc_env.proc_path = function()
		return processes[proc_env.pid] and processes[proc_env.pid].location
	end
	proc_env.should_run = function()
		return processes[proc_env.pid] and processes[proc_env.pid].should_run
	end
	
	if type(env_override) == "table" then
		for k, v in pairs(env_override) do
			proc_env[k] = v
		end
	end
	
	local executable, error_message = CoreLang(file_content, proc_env)
	if not executable then
		warn("[PM -- spawn_proc()] > executable failed to 'compile': ", error_message)
		return "0x1", error_message 
	end

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
	
	print("[PM -- spawn_proc()] > successfully spawned process: ", pid)
	return pid
end

function PM.run_proc(pid: number, permission: string?)
	print("[PM -- run_proc()] > --pid: ", pid, "--perm: ", permission)
	
	local process = processes[pid]
	
	if not process then
		warn("[PM -- run_proc()] > pid not found: ", pid)
		return false 
	end
	
	if permission then
		if process.perms == "Ring0" and permission == "Ring3" then
			warn("[PM -- run_proc()] > no permission to run: ", pid, " (perm: ", permission, ")")
			return "0x1"
		end
	end
	
	processes[pid].handle = task.spawn(function()
		print("[PM -- run_proc()] > spawned thread for pid: ", pid)
		process.should_run = true
		process.is_alive = true
		local success, error_message = pcall(function()
			process.exec()
		end)
		if not success then
			warn("[PM -- run_proc()] > failed; error in pid execution: ", pid, " (error: ", error_message,")")
		end
		
		process.should_run = false
		process.is_alive = false
		
		-- Clear memory
		pcall(MemoryManager.free_program, pid)
		print("[PM -- run_proc()] > cleared memory for pid: ", pid)
		processes[pid] = nil
		print("[PM -- run_proc()] > process thread finished and despawned: ", pid)
	end)
	
	task.spawn(function()
		while processes[pid] and processes[pid].is_alive do
			task.wait(1)
			if processes[pid] then
				processes[pid].lifetime += 1
			end
		end
	end)
end

function PM.destroy_proc(pid: number, permission: string?)
	if not processes[pid] then return nil end
	if processes[pid].is_alive then return nil end
	processes[pid] = nil
end

function PM.signal(pid: number, signal, permission: string?)
	print("[PM -- signal()] > received signal function for pid: ", pid, " signal: ", signal, " perm: ", permission)
	
	if not processes[pid] then
		warn("[PM -- signal()] > pid not found: ", pid)
		return "0x2" 
	end
	if not processes[pid].is_alive then
		warn("[PM -- signal()] > pid not alive: ", pid)
		return "0x3" 
	end
	if not processes[pid].handle then
		warn("[PM -- signal()] > pid has no thread handle: ", pid)
		return "0x4" 
	end
	if processes[pid].perms == "Ring0" and permission == "Ring3" then
		warn("[PM -- signal()] > no permission to signal pid: ", pid)
		return "0x1"
	end
	
	if signal == PM.SIGNALS.SIGTERM or signal == PM.SIGNALS.SIGINT then
		processes[pid].should_run = false
		print("[PM -- signal()] > SIGTERM/SIGINT executed on pid: ", pid)
		return "0x0"
	elseif signal == PM.SIGNALS.SIGKILL then
		local succ, err = pcall(function()
			task.cancel(processes[pid].handle)
		end)
		if not succ	then
			warn("[PM -- signal()] > SIGKILL failed on pid: ", pid) 
		end
		-- Dump memory
		pcall(MemoryManager.free_program, pid)
		print("[PM -- signal()] > dumped PID memory: ", pid) 
		processes[pid] = nil
		print("[PM -- signal()] > SIGKILL executed on PID: ", pid) 
		return "0x0"
	else
		warn("[PM -- signal()] > signal not found: ", signal) 
		return "0x2"
	end
end

function PM.is_alive(pid)
	if not processes[pid] then return end
	return processes[pid].is_alive
end

function PM.ps(flag)
	local proc_table = {}
		
	if flag then
		if flag == "-s" then
			for k, v in pairs(processes) do
				proc_table[k] = v.is_alive
			end
		elseif flag == "-l" then
			for k, v in pairs(processes) do
				proc_table[k] = v.lifetime
			end
		end
	else
		for k, v in pairs(processes) do
			table.insert(proc_table, k)
		end
	end
	
	return proc_table
end

function PM.shutdown()
	print("[PM -- shutdown()] > got shutdown signal")
	logio.clear()
	logio.clear_overlays()
	print("[PM -- shutdown()] > cleared logio overlays and logio")
	for pid, process in pairs(processes) do
		print("[PM -- shutdown()] > looping over pid: ", pid)
		if process.is_alive then
			print("[PM -- shutdown()] > pid alive: ", pid)
			PM.signal(pid, PM.SIGNALS.SIGTERM)
			if not process.is_alive then
				print("[PM -- shutdown()] > terminated pid: ", pid)
				logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')')
			else
				task.wait(1)
				if not process.is_alive then
					print("[PM -- shutdown()] > terminated pid: ", pid)
					logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')')
				end
			end
		end
	end
	task.wait(1)
	for pid, process in pairs(processes) do
		print("[PM -- shutdown()] > looping over pid: ", pid)
		if process.is_alive then
			print("[PM -- shutdown()] > pid is still alive. stop job: ", pid)
			local id = logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] A stop job is running for PID '..tostring(pid)..' ('..process.location..') (10s timeout)')
			for i = 1, 10 do
				PM.signal(pid, PM.SIGNALS.SIGTERM)
				print("[PM -- shutdown()] > signaled SIGTERM attempt ", i, "on pid: ", pid)
				if not process.is_alive then
					print("[PM -- shutdown()] > terminated pid: ", pid)
					logio.put('[ INFO ] Terminated process '..tostring(pid)..' ('..process.location..')')
					break
				end
				task.wait(1)
			end
			if process.is_alive then
				print("[PM -- shutdown()] > pid is still alive. SIGKILL sent to pid: ", pid)
				PM.signal(pid, PM.SIGNALS.SIGKILL)
				logio.put('[ INFO ] Killed process '..tostring(pid)..' ('..process.location..')')
			end
		end
	end
	task.wait(1)
	for pid, process in pairs(processes) do
		print("[PM -- shutdown()] > looping over pid: ", pid)
		print("[PM -- shutdown()] > destroying ended process: ", pid)
		PM.destroy_proc(pid)
	end
	task.wait(0.5)
	logio.clear()
	PayService.DisconnectAll()
	print("[PM -- shutdown()] > cleared logio")
	global_pid_count = 0
	print("[PM -- shutdown()] > reset pid count")
	FileSystem.rm("Root/tmp")
	print("[PM -- shutdown()] > removed Root/tmp")
	FileSystem.rm("Root/tmplibs")
	print("[PM -- shutdown()] > removed Root/tmplibs")
	Panic.PM = nil
	print("[PM -- shutdown()] > removed stale reference to Panic.PM")
	SaveData:InvokeServer(FileSystem.save_data())
	print("[PM -- shutdown()] > successfull shutdown")
	logio.put('[ <font color="rgb(255, 0, 255)"><strong>SAFE</strong></font> ] It is now safe to turn off your computer.')
end

function PM.start()
	print("[PM -- start()] > received start function")
	local ScrOut = require(game:GetService("ReplicatedStorage").ZKernel.ScreenOutput.InitScr)

	ScrOut()
	logio.InitTxtOut() -- Always re-init
	logio.clear()
	islogioinit = true
	
	print("[PM -- start()] > initialized screen and logio")
	
	logio.clear()
	
	local Data = GetData:InvokeServer()
	if Data == -1 then
		logio.put('[<font color="rgb(120, 230, 130)"><strong>FAILED</strong></font>] Failed to read File System data')
	elseif Data == nil then
		logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized File System')
	else
		FileSystem.load_data(Data)
		logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized File System')
	end
	
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Initialized Process Manager')
	
	logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] Waiting 6 seconds for UEFI initialization')
	
	task.wait(6)
	
	print("[PM -- start()] > printed initial warnings")
	
	Panic.PM = PM
	
	print("[PM -- start()] > set Panic.PM to new reference")
	
	task.spawn(function()
		while true do
			SaveData:InvokeServer(FileSystem.save_data())
			task.wait(30)
		end
	end)
	
	task.wait(1)
	
	local PID = PM.spawn_proc("Root/uefiboot.efi")
	print("[PM -- start()] > spawned Root/uefiboot.efi")
		
	PM.run_proc(PID)
end

function PM.restart()
	PM.shutdown()
	task.wait(1)
	PM.start()
end

return PM
