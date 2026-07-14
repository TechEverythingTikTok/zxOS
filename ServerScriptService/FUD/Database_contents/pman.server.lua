--[[
    pman (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.lpman = [[
local fs = import("fs")
local logio = import("logio")
local fud = import("fud")

local console = args[2]
local pname = args[3]

if not pname then
	logio.put("Usage: lpman <package_name OR special_flag>", nil, console)
	return
end

local function fetch_program(name)

	if fs.readfull("Root/etc/"..name..".zxe") then
		logio.put("Root/etc/"..name..".zxe".." Already exists! For updates use 'lpupd' instead", nil, console)
		return
	end

    local tid = logio.put(
        'Fetching program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/etc</strong></font>', 
        nil, 
        console
    )

    local content = fud.get_content(name)
    if not content then
        logio.modify(tid, '[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Program "'..name..'" not found in database.', nil, console)
        return
    end

    fs.write("Root/etc", name, "zxe", content, true)

    if fs.read("Root/etc/"..name..".zxe") then
        logio.modify(tid, '[  <font color="rgb(120, 230, 130)"><strong>OK</strong></font>  ] Fetching program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/etc</strong></font>', nil, console)
    else
        logio.modify(tid, '[<font color="rgb(255, 150, 130)"><strong>FAILED</strong></font>] Fetching program <font color="rgb(200, 255, 200)"><strong>'..name..'</strong></font> to <font color="rgb(80, 221, 231)"><strong>Root/etc</strong></font>', nil, console)
    end
end

if pname == "-l" then
	local tbl = fud.get_content(pname)
	for i, v in ipairs(tbl) do
		logio.put(v, nil, console)
	end
else
	fetch_program(pname)
end
]]