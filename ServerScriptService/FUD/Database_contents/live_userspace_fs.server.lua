--[[
    live_userspace_fs (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.live_userspace_fs = [[
local userspace_fs = {}
local fs = import("fs")

function userspace_fs.mkdir(parent, name, override)
	return fs.mkdir(parent, name, override, "Ring3")
end
function userspace_fs.write(parent, name, extension, write_content, override)
	return fs.write(parent, name, extension, write_content, override, "Ring3")
end
function userspace_fs.read(path)
	return fs.read(path, "Ring3")
end
function userspace_fs.readfull(path)
	return fs.readfull(path, "Ring3")
end
function userspace_fs.ls(flag)
	return fs.ls(flag)
end
function userspace_fs.rm(path)
	return fs.rm(path, "Ring3")
end
function userspace_fs.get_disk_info()
	return fs.get_disk_info()
end
return userspace_fs
]]