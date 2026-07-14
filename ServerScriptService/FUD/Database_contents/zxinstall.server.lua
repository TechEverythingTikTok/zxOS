--[[
    zxinstall (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.zxinstall = [[
local panic=import("panic")
local logio=import("logio")

logio.clear_overlays()
logio.clear()

task.wait(1)
logio.clear_overlays()
logio.clear()

if not logio then
	panic.trigger("logio was not able to be imported","0x0002","logio was attempted to be imported, but it was not returned. Make sure your files are not corrupt!")
else
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] logio imported successfully')
end

local kbio=import("keyboardio")
if not kbio then
	panic.trigger("kbio was not able to be imported","0x0005","kbio was attempted to be imported, but it was not returned. Make sure your files are not corrupt!")
else
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] kbio imported successfully')
end

local fud=import("fud")
if not fud then
	panic.trigger("fud was not able to be imported","0x0006","fud was attempted to be imported, but it was not returned. Make sure your files are not corrupt!")
else
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] fud imported successfully')
end

local fsr0=import("fs")
if not fsr0 then
	panic.trigger("fsr0 was not able to be imported","0x0006","fsr0 was attempted to be imported, but it was not returned. Make sure your files are not corrupt!")
else
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] fsr0 imported successfully')
end

local pmr0=import("pm")
if not pmr0 then
	panic.trigger("pmr0 was not able to be imported","0x0007","pmr0 was attempted to be imported, but it was not returned. Make sure your files are not corrupt!")
else
	logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] pmr0 imported successfully')
end

task.wait(0.5)
logio.clear()
logio.put('Fetching default libraries to <font color="rgb(80, 221, 231)"><strong>Root/tmplibs</strong></font>')
fsr0.mkdir("Root","tmplibs",false)

local function fetch_lib(libname)
	local tid=logio.put('Writing library <font color="rgb(200, 255, 200)"><strong>'..libname..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmplibs</strong></font>')
	local content=fud.get_content(libname)
	if not content then 
		logio.modify(tid,'[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] No content for '..libname) 
		return 
	end
	fsr0.write("Root/tmplibs",libname,"lib",content,true)
	if fsr0.read("Root/tmplibs/"..libname..".lib") then 
		logio.modify(tid,'[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Writing library <font color="rgb(200, 255, 200)"><strong>'..libname..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmplibs</strong></font>')
	else 
		logio.modify(tid,'[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Writing library <font color="rgb(200, 255, 200)"><strong>'..libname..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmplibs</strong></font>')
	end
end

fetch_lib("live_userspace_pm")
fetch_lib("live_userspace_fs")
fetch_lib("us_keyboard_layout")
task.wait(1)
local fs=import("Root/tmplibs/live_userspace_fs.lib")
local pm=import("Root/tmplibs/live_userspace_pm.lib")
local keyboard_layout=import("Root/tmplibs/us_keyboard_layout.lib")
logio.put('Fetching default programs to <font color="rgb(80, 221, 231)"><strong>Root/tmp</strong></font>')
fs.mkdir("Root","tmp",false)

local function fetch_program(name)
	local tid=logio.put('Writing program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmp</strong></font>')
	local content=fud.get_content(name)
	if not content then 
		logio.modify(tid, '[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] No content for '..name) 
		return 
	end
	fs.write("Root/tmp", name, "cpr", content, true)
	if fs.read("Root/tmp/"..name..".cpr") then
    	logio.modify(tid,'[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Writing program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmp</strong></font>')
    else
		logio.modify(tid,'[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Writing program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/tmp</strong></font>')
	end
end

fetch_program("echo")
fetch_program("mkdir")
fetch_program("rmdir")
fetch_program("ls")
fetch_program("touch")
fetch_program("rm")
fetch_program("pwd")
fetch_program("cp")
fetch_program("df")
fetch_program("free")
fetch_program("lpman")
fetch_program("cat")
fetch_program("ps")
fetch_program("xedit")

logio.put("[ INFO ] Root/tmp files are cleared by the system after every shutdown.")
task.wait(2)

logio.clear()
logio.put('Welcome to zxinstall!')
logio.put('Type "help" in the console if you need assistance with the commands')
logio.put('Type "install" to begin the actual installation process.')

local kmap=keyboard_layout.kmap
local shift_kmap=keyboard_layout.shift_kmap

local tid=logio.put(" > ")
local text=""

local function convert_to_table(str)
	local current_working_directory=cwd()
	local result = {}
	result[1] = current_working_directory 
	result[2] = false
	for word in str:gmatch("%S+") do 
		result[#result + 1] = word:gsub(" ", "")
		task.wait() 
	end
	return result
end

local should_terminate_listener=false
local is_listener_terminated=false
local current_pid=0

local function handle_command(command)
	if not command then return end
	if should_terminate_listener then return true end
	local first,rest = command:match("^%s*(%S+)(.*)$")
	
	if first=="clear"then
		logio.clear()
	elseif first=="cd"then
		local clean_rest=rest:match("^%s*(.-)%s*$") 
		if clean_rest==".." then 
			cd(clean_rest)
		else 
			local target=fs.readfull(clean_rest) and clean_rest or (cwd().."/"..clean_rest)
			local info=fs.readfull(target)
			if not info then 
				logio.put('<font color="rgb(255, 100, 100)">Could not find specified directory</font>') 
				return 
			end 
			
			if info[1]=="File" then 
				logio.put('<font color="rgb(255, 100, 100)">Cannot cd to a file</font>') 
				return 
			end 
			cd(target) 
		end
	elseif first=="shutdown" then
		text=""
		should_terminate_listener = true 
		logio.clear()
		repeat task.wait(0.1) until is_listener_terminated==true 
		fs.rm(proc_path())
		pm.shutdown()
		return true
	elseif first=="reboot"then
		fs.rm(proc_path())
		text=""
		should_terminate_listener=true 
		logio.clear()
		repeat task.wait(0.1) until is_listener_terminated==true 
		pm.restart()
		return true
	elseif first=="help"then
		logio.put("'echo' - Prints given message to console")
		logio.put("'clear' - Clears the console")
		logio.put("'cd' - Change the current working directory")
		logio.put("'install' - Begin zxOS installation process")
		logio.put("'shutdown' - Triggers a shutdown")
		logio.put("'reboot' - Triggers a reboot")
		logio.put("'ueditor' - Builtin text editor [Ring0 Only. Will not work in current env]")
		logio.put("<font color='rgb(0, 255, 0)'>*BUILTIN PACKAGES*</font>")
		logio.put("'mkdir' - Create a new directory")
		logio.put("'rmdir' - Remove a directory")
		logio.put("'ls' - List child files of specified path")
		logio.put("'touch' - Create a new file")
		logio.put("'rm' - Remove a file")
		logio.put("'pwd' - Print working directory")
		logio.put("'cp' - Copy file content to another file")
		logio.put("'df' - List disk info")logio.put("'free' - List RAM info")
		logio.put("'lpman' - Builtin package manager")
		logio.put("'cat' - Display file contents")
		logio.put("'ps' - Display all current processes PIDs")
		logio.put("'xedit' - Extremely lightweight text editor")
	elseif first=="install"then
		logio.put("Fetching install files...")
		task.wait(0.02)
		fsr0.write("Root","coreinstall","zxe",fud.get_content("zxinstall/core"),true)
		local PID=pmr0.spawn_proc("Root/coreinstall.zxe",nil,nil,"Ring0")
		pmr0.run_proc(PID)
		should_terminate_listener=true 
		repeat task.wait(0.1) until is_listener_terminated==true 
		pmr0.signal(pmr0.SIGNALS.SIGTERM, pid)
		error("Exiting")
	else
		if fs.read("Root/tmp/"..first..".cpr")then
			local PID, perror=pm.spawn_proc("Root/tmp/"..first..".cpr", convert_to_table(rest))
			if PID =="0x1" then 
				logio.put('<font color="rgb(255, 100, 100)">Error in script interpreting</font>')
				print(perror)
			else
				local success, error_message = pcall(function() 
					current_pid=PID 
					pm.run_proc(PID) 
					repeat task.wait(0.1) until not pm.is_alive(PID) 
				end)
				
				if not success then logio.put("Error in execution: "..first..".cpr") end
			end
		else
			local possible_cwd=string.sub(first, 1, 2)
			if possible_cwd=="./"then
				local rest_path=string.sub(first, 3, #first)
				if fs.readfull(cwd().."/"..rest_path) and fs.readfull(cwd().."/"..rest_path)[1]=="File" then
					local PID = pm.spawn_proc(cwd().."/"..rest_path,convert_to_table(rest))
					current_pid=PID 
					pm.run_proc(PID)
					
					repeat task.wait(0.1) until not pm.is_alive(PID)
				else 
					logio.put('<font color="rgb(255, 100, 100)"><strong>Invalid command. Did you try to execute a folder with ./ instead of a file?</strong></font>')
				end
			else
				if fs.readfull(first) and fs.readfull(first)[1]=="File" then 
					local PID=pm.spawn_proc(first, convert_to_table(rest))
					current_pid=PID 
					pm.run_proc(PID)
					repeat task.wait(0.1) until not pm.is_alive(PID)
				else 
					logio.put('<font color="rgb(255, 100, 100)"><strong>Invalid command</strong></font>') 
				end
			end
		end
	end
end

local exitbool = false
local inp_suspended=false
local old_comms={}
old_comms[1]=""
local scroll_i=0
local function kpress(kname)
	if should_terminate_listener then return end
	if kname=="C" then
		if kbio.is_key_pressed("LeftControl") then
			pm.signal(current_pid, pm.SIGNALS.SIGTERM)
		end
	elseif kname=="T" then
		if kbio.is_key_pressed("LeftControl") then
			pm.signal(current_pid, pm.SIGNALS.SIGKILL)
		end
	end
	if inp_suspended then return end
	if kname=="Up" then 
		scroll_i=scroll_i-1 
		if not old_comms[scroll_i] then 
			scroll_i=scroll_i+1 
			return 
		end
		text=old_comms[scroll_i]
	elseif kname == "Down" then 
		scroll_i=scroll_i+1 
		if not old_comms[scroll_i] then 
			scroll_i=scroll_i-1 
			return 
		end 
		text=old_comms[scroll_i] 
	end
	if kmap[kname] then 
		if kbio.is_key_pressed("LeftShift") or kbio.is_key_pressed("RightShift") then 
			text=text..shift_kmap[kname] 
		else 
			text=text..kmap[kname]
		end
	else
		if kname == "Backspace" then 
			text = text:sub(1,-2)
		elseif kname == "Return" then
			if not text or text=="" then return end 
			inp_suspended=true 
			local shouldexit=handle_command(text)
			table.insert(old_comms, text)
			scroll_i=#old_comms
			text=""
			if not shouldexit then 
				tid = logio.put(" > ")
				inp_suspended = false 
			else
				exitbool = true
			end
		end
	end
	if is_listener_terminated then return end
	if exitbool == true then return end
	if not should_run() then return end
	logio.modify(tid, " > "..text or "")
end
task.wait(1)
local kpid=kbio.new_listener(kpress)
while should_run() do
	if should_terminate_listener then 
		if not is_listener_terminated then 
			kbio.destroy_listener(kpid)
			is_listener_terminated=true 
			break 
		end 
	end
	task.wait(0.25)
end
kbio.destroy_listener(kpid)is_listener_terminated = true
]]