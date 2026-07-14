--[[
    us_keyboard_layout (Script)
    Path: ServerScriptService → FUD → Database
    Parent: Database
    ⚠️  NESTED SCRIPT: This script is inside another script
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local Database = require(script.Parent)

Database.us_keyboard_layout = [[
local us_kb_layout = {}

us_kb_layout.kmap = {
	["A"] = "a", ["B"] = "b", ["C"] = "c", ["D"] = "d",
	["E"] = "e", ["F"] = "f", ["G"] = "g", ["H"] = "h",
	["I"] = "i", ["J"] = "j", ["K"] = "k", ["L"] = "l",
	["M"] = "m", ["N"] = "n", ["O"] = "o", ["P"] = "p",
	["Q"] = "q", ["R"] = "r", ["S"] = "s", ["T"] = "t",
	["U"] = "u", ["V"] = "v", ["W"] = "w", ["X"] = "x",
	["Y"] = "y", ["Z"] = "z", ["One"] = "1", 
	["Two"] = "2", ["Three"] = "3", ["Four"] = "4",
	["Five"] = "5", ["Six"] = "6", ["Seven"] = "7",
	["Eight"] = "8", ["Nine"] = "9", ["Zero"] = "0",
	["Minus"] = "-", ["Equals"] = "=",
	["Semicolon"] = ";", ["Tab"] = "   ",
	["Backquote"] = "`", ["Period"] = ".",
	["Comma"] = ",", ["Space"] = " ", ["Quote"] = "'",
	["RightBracket"] = "]", ["LeftBracket"] = "[",
	["Slash"] = "/"
}

us_kb_layout.shift_kmap = {
	["A"] = "A", ["B"] = "B", ["C"] = "C", ["D"] = "D",
	["E"] = "E", ["F"] = "F", ["G"] = "G", ["H"] = "H",
	["I"] = "I", ["J"] = "J", ["K"] = "K", ["L"] = "L",
	["M"] = "M", ["N"] = "N", ["O"] = "O", ["P"] = "P",
	["Q"] = "Q", ["R"] = "R", ["S"] = "S", ["T"] = "T",
	["U"] = "U", ["V"] = "V", ["W"] = "W", ["X"] = "X",
	["Y"] = "Y", ["Z"] = "Z", ["One"] = "!", 
	["Two"] = "@", ["Three"] = "#", ["Four"] = "$",
	["Five"] = "%", ["Six"] = "^", ["Seven"] = "&",
	["Eight"] = "*", ["Nine"] = "(", ["Zero"] = ")",
	["Minus"] = "_", ["Equals"] = "+",
	["Semicolon"] = ":", ["Tab"] = "   ",
	["Backquote"] = "~", ["Period"] = ">",
	["Comma"] = "<", ["Space"] = " ", ["Quote"] = '"',
	["RightBracket"] = "}", ["LeftBracket"] = "{",
	["Slash"] = "?"
}

return us_kb_layout
]]