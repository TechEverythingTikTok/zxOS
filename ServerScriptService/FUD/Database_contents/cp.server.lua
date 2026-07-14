--[[
    cp (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.cp = [[
local logio = import("logio")
local fs=import("fs")
local current_path=args[1]
local console=args[2]
local path_or_name_to_cp=args[3]
local path_or_name_to_overwrite=args[4]

if not path_or_name_to_cp or not path_or_name_to_overwrite then 
	logio.put("Usage: cp <cp_target> <overwrite_target>",nil,console)
	return 
end

local target_to_cp=fs.readfull(path_or_name_to_cp) and path_or_name_to_cp or (current_path.."/"..path_or_name_to_cp)
local info_cp=fs.readfull(target_to_cp)

if info_cp==nil then
	logio.put('<font color="rgb(255,100,100)">Target to cp doesn\'t exist</font>',nil,console) 
	return
elseif info_cp==false then 
	logio.put('<font color="rgb(255,100,100)">Not allowed to read target to cp (no permission)</font>',nil,console)
	return
end
if info_cp[1]~="File" then 
	logio.put('<font color="rgb(255,100,100)">cp is only supported for files.</font>',nil,console)
	return 
end

local target_to_overwrite = fs.readfull(path_or_name_to_overwrite) and path_or_name_to_overwrite or (current_path.."/"..path_or_name_to_overwrite)

local info_overwrite=fs.readfull(target_to_overwrite)
if info_overwrite==nil then 
	logio.put('<font color="rgb(255,100,100)">Target to overwrite doesn\'t exist</font>',nil,console)
	return
elseif info_overwrite==false then
	logio.put('<font color="rgb(255,100,100)">Not allowed to read target to overwrite (no permission)</font>',nil,console)
	return 
end
if info_overwrite[1]~="File" then 
	logio.put('<font color="rgb(255,100,100)">cp is only supported for files.</font>',nil,console)
	return 
end

local len = #fs.read(target_to_cp)

local ptr = malloc(len)
getheap(ptr).writestr(0, fs.read(target_to_cp))

fs.write(info_overwrite[4], info_overwrite[3], info_overwrite[7], getheap(ptr).readstr(0, len), true)
free(ptr)
]]