--[[
    zxdefinstall (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database["zxdefinstall"] = [[
local defaultconfig = {}

defaultconfig["zbootm"] = {
	["Boot"] = {"zbootm", "efi"},
	["etc"] = {"zbootm", "cfg"}
}

defaultconfig["fs"] = {
	["libs"] = {"fs", "lib"}
}

defaultconfig["pm"] = {
	["libs"] = {"pm", "lib"}
}

defaultconfig["us_keyboard_layout"] = {
	["libs"] = {"us_keyboard_layout", "lib"}
}

defaultconfig["tty"] = {
	["sbin"] = {"tty", "zxe"},
	["etc"] = {"tty", "cfg"}
}

defaultconfig["shutdown"] = {
	["sbin"] = {"shutdown", "zxe"}
}

defaultconfig["reboot"] = {
	["sbin"] = {"reboot", "zxe"}
}

defaultconfig["pman"] = {
	["bin"] = {"tty", "zxe"}
}

defaultconfig["cat"] = {
	["bin"] = {"cat", "zxe"}
}

defaultconfig["cp"] = {
	["bin"] = {"cp", "zxe"}
}

defaultconfig["date"] = {
	["bin"] = {"date", "zxe"}
}

defaultconfig["df"] = {
	["bin"] = {"df", "zxe"}
}

defaultconfig["echo"] = {
	["bin"] = {"echo", "zxe"}
}

defaultconfig["free"] = {
	["bin"] = {"free", "zxe"}
}

defaultconfig["ls"] = {
	["bin"] = {"ls", "zxe"}
}

defaultconfig["mkdir"] = {
	["bin"] = {"mkdir", "zxe"}
}

defaultconfig["ps"] = {
	["bin"] = {"ps", "zxe"}
}

defaultconfig["pwd"] = {
	["bin"] = {"pwd", "zxe"}
}

defaultconfig["rm"] = {
	["bin"] = {"rm", "zxe"}
}

defaultconfig["rmdir"] = {
	["bin"] = {"rmdir", "zxe"}
}

defaultconfig["time"] = {
	["bin"] = {"time", "zxe"}
}

defaultconfig["touch"] = {
	["bin"] = {"touch", "zxe"}
}

defaultconfig["xedit"] = {
	["bin"] = {"xedit", "zxe"}
}

return defaultconfig
]]