--[[
    FileSystemSave (Script)
    Path: ServerScriptService → FileSystemSave
    Parent: FileSystemSave
    Properties:
        Disabled: false
        RunContext: Enum.RunContext.Legacy
    Exported: 2026-07-14 13:31:45
]]
local HTTPService = game:GetService("HttpService")
local DataStoreService 	= game:GetService("DataStoreService")
local DataStore			= DataStoreService:GetDataStore("zKernelFileSystemDataStore")

local GetData	= game:GetService("ReplicatedStorage").FileSystemData.GetData
local SaveData	= game:GetService("ReplicatedStorage").FileSystemData.SaveData

local ZLib = require(game:GetService("ReplicatedStorage").ZLib)
local Base64 = require(game:GetService("ReplicatedStorage").Base64)

SaveData.OnServerInvoke = function(PlayerInstance: Player, JSONData: string)
	warn("JSON Size: ", #JSONData)
	local CompressedHieararchy = ZLib.Zlib.Compress(JSONData)
	warn("Compressed Size: ", #CompressedHieararchy)
	local Base64Hierarchy = Base64.EncodeData(CompressedHieararchy)
	warn("Base64 Size: ", #Base64Hierarchy)
	local Success, ErrorMessage = pcall(function()
		DataStore:SetAsync(PlayerInstance.UserId, Base64Hierarchy)
	end)
	if not Success then
		warn(ErrorMessage)
		return -1
	else
		warn("Saved data successfully")
		return 0
	end
end

GetData.OnServerInvoke = function(PlayerInstance: Player)
	local Success, DataOrError = pcall(function()
		return DataStore:GetAsync(PlayerInstance.UserId)
	end)
	
	if Success then
		if DataOrError then
			return ZLib.Zlib.Decompress(Base64.DecodeData(DataOrError))
		else
			return nil
		end
	else
		warn(DataOrError)
		return -1
	end
end