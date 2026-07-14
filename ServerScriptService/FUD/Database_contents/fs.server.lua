--[[
    fs (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.fs = [[
local filesys = {}
local fs = import("fs")

function filesys.mkdir(parent, name, override)
	return fs.mkdir(parent, name, override, "Ring3")
end
function filesys.write(parent, name, extension, write_content, override)
	return fs.write(parent, name, extension, write_content, override, "Ring3")
end
function filesys.read(path)
	return fs.read(path, "Ring3")
end
function filesys.readfull(path)
	return fs.readfull(path, "Ring3")
end
function filesys.ls(flag)
	return fs.ls(flag)
end
function filesys.rm(path)
	return fs.rm(path, "Ring3")
end
function filesys.get_disk_info()
	return fs.get_disk_info()
end

return userspace_fs
]]