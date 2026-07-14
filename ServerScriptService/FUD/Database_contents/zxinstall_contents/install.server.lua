--[[
    install (Script)
    Path: ServerScriptService → FUD → Database → zxinstall
    Parent: zxinstall
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent.Parent)

Database["zxinstall/install"] = [=[

local fs = import("fs")
local pm = import("pm")
local fud = import("fud")
local logio = import("logio")

local hostname = fs.read("Root/zxinstall/hostname.zpi")
local hostpass = fs.read("Root/zxinstall/hostpass.zpi")
local username = fs.read("Root/zxinstall/username.zpi")
local userpass = fs.read("Root/zxinstall/userpass.zpi")
local desktopenv = fs.read("Root/zxinstall/desktopenv.zpi")

if hostname == "" or hostpass == "" or username == "" or userpass == "" or desktopenv == ""
	or hostname == nil or hostpass == nil or username == nil or userpass == nil or desktopenv == nil then
	pm.signal(pid, pm.SIGNALS.SIGKILL)
end

--> Stage 1: Remove all files from disk that do not have anything to do with the boot stage <--
local hierarchy_copy = fs.get_hierarchy()	-- get hierarchy copy

-- 1.1 -> Remove Root/tmp and Root/tmplibs
fs.rm("Root/tmp")
fs.rm("Root/tmplibs")

-- 1.2 -> Remove everything else from disk except:
local excludetbl = {
	["Root/Boot"] = true,
	["Root/ueditor.efi"] = true,
	["Root/uefi.efi"] = true,
	["Root/uefiboot.efi"] = true,
	["Root/uefiselect.efi"] = true,
	["Root/ueficonfig.cfg"] = true,
	["Root/zxinstallprocess.zxe"] = true,
	["Disk"] = true
}

-- Format
for k, v in pairs(hierarchy_copy) do
	if not excludetbl[k] then
		fs.rm(k)
	end
end

fs.rm("Root/libs")
fs.rm("Root/bin")
fs.rm("Root/sbin")
fs.rm("Root/etc")
fs.rm("Root/home")
fs.rm("Root/usr")

--> Stage 2: Create core directories
fs.mkdir("Root", "libs", true, "Ring3")
fs.mkdir("Root", "bin", true, "Ring3")
fs.mkdir("Root", "sbin", true, "Ring3")
fs.mkdir("Root", "etc", true, "Ring3")
fs.mkdir("Root", "home", true, "Ring3")
fs.mkdir("Root", "usr", true, "Ring3")

--> Stage 3: Fetch "zxdefinstall.lib" (contains targets to fetch for lib, bin, sbin, and etc)
fs.write("Root/libs", "zxdefinstall", "lib", fud.get_content("zxdefinstall"), true)

logio.put("Fetched zxdefinstall")

local zxdefinstall = import("Root/libs/zxdefinstall.lib")

--> Stage 4: If 'etc' in entry, fetch config file (prefix name with cfg); If not, fetch normal file to specified folder

for k, v in pairs(zxdefinstall) do
	for ek, ev in pairs(v) do
		logio.put("Fetching: "..ev[1])
		if ek == "etc" then
			fs.write("Root/etc", ev[1], ev[2], fud.get_content(k.."cfg"), true, "Ring3")
		else
			if k == "fs" or k == "pm" then
				fs.write("Root/"..ek, ev[1], ev[2], fud.get_content(k), true, "Ring0")
			else
				fs.write("Root/"..ek, ev[1], ev[2], fud.get_content(k), true, "Ring3")
			end
		end
	end
end

--> Step 5: Write desktop environment to disk
if desktopenv ~= "None" then
	logio.put("Fetching DE ("..desktopenv..")")
	fs.write("Root/sbin", desktopenv, "zxe", fud.get_content("de_"..desktopenv), true, "Ring3")
end

--> Stage 6: Override config for zbootm if we have a desktop env
if desktopenv ~= "None" then
	logio.put("Rebuilding zbootm config for DE")
	fs.write("Root/etc", "zbootm", "cfg", [[
	local config = {}

	config.init_file_location 	= "Root/sbin/tty.zxe"
	config.init_proc_args		= {"Root/sbin/]]..desktopenv..[[.zxe"}

	return config
	]], true, "Ring3")
end

--> Stage 7: Write installation details to a single file
fs.write("Root/etc", "install", "cfg", [[
local config = {}

config.hostname = ]] .. hostname .. [[

config.hostpass = ]] .. hostpass .. [[

config.username = ]] .. username .. [[

config.userpass = ]] .. userpass .. [[

config.desktopenv = ]] .. desktopenv .. [[

return config
]], true, "Ring3")

--> Stage 8: Remove installation and reboot
pm.restart()
fs.rm("Root/zxinstallprocess.zxe")

]=]