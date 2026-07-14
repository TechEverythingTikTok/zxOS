--[[
    uefiboot.efi (LocalScript)
    Path: StarterPlayer → StarterPlayerScripts → Root
    Parent: Root
    Properties:
        Disabled: false
    Exported: 2026-07-14 13:31:45
]]
local fs = require(game:GetService("ReplicatedStorage").ZKernel.Ring0.FS)
task.wait(4)

local code = [[

local logio = import("logio")
local fs = import("fs")
local pm = import("pm")
local panic = import("panic")

logio.put('[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Root/uefiboot.efi started successfully')
task.wait(0.1)
logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] Waiting 2 seconds for internal module initialization')
task.wait(2)
logio.put('[ <font color="rgb(142, 196, 225)"><strong>WAIT</strong></font> ] Waiting 1 second for Memory Manager')
task.wait(1)

local ueficonfig = import("Root/ueficonfig.cfg")
local uefiselect = fs.read(ueficonfig and ueficonfig["uefiboot_select"] or nil)

fs.mkdir("Root", "Boot", false)

if uefiselect then
	-- Do NOT use lowercase pid, that returns the current process pid anyway
	
	if ueficonfig and ueficonfig["uefiboot_select"] then
		local PID, perror = pm.spawn_proc(ueficonfig["uefiboot_select"])
		if PID == "0x1" then
			logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] File '..ueficonfig["uefiboot_select"].. ' is corrupt')
			logio.put('[ INFO ] Kernel will try to boot the file Root/uefiselect.efi')
			local PID, perror = pm.spawn_proc("Root/uefiselect.efi")
			if PID == "0x1" then
				logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] file Root/uefiselect.efi is corrupt')
			else
				pm.run_proc(PID)
			end
		else
			pm.run_proc(PID)
		end
	else
		logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Unable to find Root/uefiselect.efi')
		logio.put("[ INFO ] Kernel will try to boot the file Root/uefiselect.efi")
		task.wait(1)
		local PID, perror = pm.spawn_proc("Root/uefiselect.efi")
		if PID == "0x1" or not PID then
			logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] file Root/uefiselect.efi is corrupt')
			logio.put('[ <font color="rgb(255, 165, 20)"><strong>WARN</strong></font> ] Kernel will try booting into Root/uefi.efi as a last resort')
			task.wait(1)
			local PID, perror = pm.spawn_proc("Root/uefi.efi")
			if PID == "0x1" or not PID then
				panic.trigger("Root/uefi.efi is corrupt/doesn't exist, as well as Root/uefiselect.efi", "0x0001", "Error 0x0001 -- Root/uefiselect.efi, as well as Root/uefi.efi are corrupt/don't exist. PID Returned: "..(PID or "0x1").."; perror: "..(perror or "no error returned"))
			else
				pm.run_proc(PID)
			end
		else
			pm.run_proc(PID)
		end
	end
else
	logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Unable to find Root/uefiselect.efi')
	logio.put("[ INFO ] Kernel will try to boot the file Root/uefiselect.efi")
	task.wait(1)
	local PID, perror = pm.spawn_proc("Root/uefiselect.efi")
	if PID == "0x1" or not PID then
		logio.put('[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] file Root/uefiselect.efi is corrupt')
		logio.put('[ <font color="rgb(255, 165, 20)"><strong>WARN</strong></font> ] Kernel will try booting into Root/uefi.efi as a last resort')
		task.wait(1)
		local PID, perror = pm.spawn_proc("Root/uefi.efi")
		if PID == "0x1" or not PID then
			panic.trigger("Root/uefi.efi is corrupt/doesn't exist, as well as Root/uefiselect.efi", "0x0001", "Error 0x0001 -- Root/uefiselect.efi, as well as Root/uefi.efi are corrupt/don't exist. PID Returned: "..(PID or "0x1").."; perror: "..(perror or "no error returned"))
		else
			pm.run_proc(PID)
		end
	else
		pm.run_proc(PID)
	end
end

]]

fs.write("Root", "uefiboot", "efi", code, true, "Ring0")