--[[
    FS (ModuleScript)
    Path: ReplicatedStorage → ZKernel → Ring0
    Parent: Ring0
    Exported: 2026-07-14 13:31:45
]]
local FS = {}

local HTTPService = game:GetService("HttpService")

FS.Hierarchy = {
	["Disk"] = {
		"Disk",		-- Object Type
		"Ring0",	-- Object Permission
		8_388_608,	-- Max Size
		69			-- Occupied Size (Initial)
	},

	["Root"] = {
		"RootDirectory", 	-- Object Type
		"Ring0",			-- Object Permission
		"Root",				-- Object Name
		"Root",				-- Object Parent
		42,					-- Object Size
		"Root"				-- Object Identity
	}
}

local Hierarchy = FS.Hierarchy

local function CalculateDiskSize()
	local CalculatedSize = 0
	for k, v in pairs(Hierarchy) do
		CalculatedSize += #k
		for i, v in ipairs(Hierarchy[k]) do
			if type(v) == "string" then
				CalculatedSize += #v
			else
				CalculatedSize += 8
			end
		end
	end
	return CalculatedSize
end

function FS.mkdir(
	Parent: string,
	Name: string,
	Override: boolean,
	Permission: string?
)
	print(
		"[FS -- mkdir()] > received call: --parent: ", 
		Parent, 
		" --name: ", 
		Name,
		" --override: ",
		Override,
		" --perm: ",
		Permission
	)
	if Name:find("%.") or Name:find("/") or Name:find(" ") then
		warn("[FS -- mkdir()] > found illegal characters in name")
		return "0x5"
	end
	if not Hierarchy[Parent] then
		warn("[FS -- mkdir()] > parent not found")
		return "0x1"
	end
	local Path = Parent.."/"..Name
	if Hierarchy[Path] and not Override then
		warn("[FS -- mkdir()] > specified path found and Override false")
		return "0x2"
	end
	if Hierarchy[Parent][1] == "File" then
		warn("[FS -- mkdir()] > parent is File and not Directory")
		return "0x3"
	end
	if Hierarchy[Path] and Override then
		if Permission == "Ring3" and Hierarchy[Path][2] == "Ring0" then
			warn("[FS -- mkdir()] > no perms")
			return "0x4"
		else
			FS.rm(Path)
		end
	end
	
	local ContentSize = #Name + #Parent + #("Directory") + #(Permission or "Ring0") + 8 + #Name + #Path
	local RemainingSize = Hierarchy["Disk"][3] - Hierarchy["Disk"][4]
	
	if ContentSize > RemainingSize then
		warn("[FS -- mkdir()] > not enough size on disk")
		return "0x6"
	end
	
	Hierarchy["Disk"][4] += ContentSize
	print("[FS -- mkdir()] > populated disk size")
	
	Hierarchy[Path] = {
		"Directory",			-- Object Type
		Permission or "Ring0",	-- Object Permission
		Name,					-- Object Name
		Parent,					-- Object Parent
		ContentSize,			-- Object Size
		Name					-- Object Identity
	}
	
	print("[FS -- mkdir()] > successfully created directory")
	return "0x0"
end

function FS.write(
	Parent: string,
	Name: string,
	Extension: string,
	WriteContent: string,
	Override: boolean,
	Permission: string?
)
	print(
		"[FS -- write()] > received call: --parent: ", 
		Parent, 
		" --name: ", 
		Name,
		" --extension: ",
 		Extension,
		" --override: ",
		Override,
		" --perm: ",
		Permission
	)
	if Name:find("%.") or Name:find("/") or Name:find(" ") then
		warn("[FS -- write()] > found illegal characters in name")
		return "0x6" 
	end
	if Extension:find("%.") or Extension:find("/") or Extension:find(" ") then
		warn("[FS -- write()] > found illegal characters in extension")
		return "0x7"
	end
	if not Hierarchy[Parent] then
		warn("[FS -- write()] > parent not found")
		return "0x1" 
	end
	local Path = Parent.."/"..Name.."."..Extension
	if Hierarchy[Path] and not Override then
		warn("[FS -- write()] > specified path found and Override false")
		return "0x2" 
	end
	if Hierarchy[Parent][1] == "File" then 
		warn("[FS -- write()] > parent is File and not Directory")
		return "0x3" 
	end
	if not WriteContent then
		warn("[FS -- write()] > writecontent is nil. provide empty string to write nothing.")
		return "0x5"
	end
	if Hierarchy[Path] and Override then
		if Permission == "Ring3" and Hierarchy[Path][2] == "Ring0" then
			warn("[FS -- write()] > no perms")
			return "0x4"
		end
	end
	
	local ContentSize = #("File") + #(Permission or "Ring0") + #Name + #Parent + 8 + #(Name.."."..Extension) + #Extension
		+ #WriteContent + #Path
	local RemainingSize = Hierarchy["Disk"][3] - Hierarchy["Disk"][4]
	
	if ContentSize > RemainingSize then
		warn("[FS -- write()] > not enough size on disk")
		return "0x8"
	end
	
	Hierarchy["Disk"][4] += ContentSize
	print("[FS -- write()] > populated disk size")
	
	Hierarchy[Path] = {
		"File",					-- Object Type
		Permission or "Ring0",	-- Object Permission
		Name,					-- Object Name
		Parent,					-- Object Parent
		ContentSize,			-- Object Size
		Name.."."..Extension,	-- Object Identity
		Extension,				-- Object Extension
		WriteContent			-- Object Content
	}
	
	print("[FS -- write()] > written file successfully")
	return "0x0"
end

function FS.read(Path: string, Permission: string?)
	print(
		"[FS -- read()] > received call: --path: ", Path, " --perm", Permission
	)
	if not Hierarchy[Path] then
		warn("[FS -- read()] > path not found: ", Path)
		return nil 
	end
	if Hierarchy[Path][1] == "Directory" or Hierarchy[Path][1] == "RootDirectory" then
		warn("[FS -- read()] > path is not a File: ", Path)
		return nil
	end
	if Permission then
		if Hierarchy[Path][2] == "Ring0" and Permission == "Ring3" then
			warn("[FS -- read()] > no perms")
			return false
		end
	end
	
	print("[FS -- read()] > sucessfully read: ", Path)
	return Hierarchy[Path][8]
end

function FS.readfull(Path: string, Permission: string?)
	print(
		"[FS -- readfull()] > received call: --path: ", Path, " --perm: ", Permission 
	)
	if not Hierarchy[Path] then
		warn("[FS -- readfull()] > path not found: ", Path)
		return nil 
	end
	if Permission then
		if Hierarchy[Path][2] == "Ring0" and Permission == "Ring3" then
			warn("[FS -- readfull()] > no permission: ", Path)
			return false
		end
	end
	
	print("[FS -- readfull()] > successfully read meta: ", Path)
	return Hierarchy[Path]
end

function FS.ls(path: string, flag)
	print("[FS -- ls()] > received call: --path: ", path, " --flag: ", flag)
	if not Hierarchy[path] then return nil end
	
	local paths = {}
	
	if flag == "-f" then
		for k, v in pairs(Hierarchy) do
			if k:find(path) == 1 and Hierarchy[k] ~= Hierarchy[path] and FS.readfull(k)[4] == path then
				table.insert(paths, k)
			end
		end
	elseif flag == "-i" or not flag then
		for k, v in pairs(Hierarchy) do
			if k:find(path) == 1 and Hierarchy[k] ~= Hierarchy[path] and FS.readfull(k)[4] == path then
				table.insert(paths, Hierarchy[k][6])
			end
		end
	elseif flag == "-s" then
		for k, v in pairs(Hierarchy) do
			if k:find(path) == 1 and Hierarchy[k] ~= Hierarchy[path] and FS.readfull(k)[4] == path then
				table.insert(paths, Hierarchy[k][3])
			end
		end
	end
	
	print("[FS -- ls()] > successfully retrieved information")
	return paths
end


function FS.rm(Path: string, Permission: string?)
	print(
		"[FS -- rm()] > received call: --path: ", Path, " --perm: ", Permission
	)
	if not Hierarchy[Path] then
		warn("FS -- rm() > path not found: ", Path)
		return nil
	end
	if Permission then
		if Hierarchy[Path][2] == "Ring0" and Permission == "Ring3" then
			warn("FS -- rm() > no permission")
			return false 
		end
	end
	if Path == "Root" then
		warn("FS -- rm() > cannot remove root")
		return nil
	end

	local toDelete = {}
	for k, v in pairs(Hierarchy) do
		if k == Path or k:sub(1, #Path + 1) == Path .. "/" then
			table.insert(toDelete, k)
		end
	end
		
	for _, k in ipairs(toDelete) do
		Hierarchy["Disk"][4] -= Hierarchy[k][5]
		Hierarchy[k] = nil
	end
	
	print("FS -- rm() > successfully removed")
	return true
end

function FS.get_hierarchy()
	local HierarchyCopy = {}
	for k, v in pairs(Hierarchy) do
		HierarchyCopy[k] = v
	end
	return HierarchyCopy
end

function FS.load_data(JSONData: string)
	local TempHierarchy = HTTPService:JSONDecode(JSONData)
	FS.Hierarchy = TempHierarchy
	task.wait(1)
	FS.Hierarchy.Disk[4] = CalculateDiskSize()
	Hierarchy = FS.Hierarchy
end

function FS.save_data()
	local JSONData = HTTPService:JSONEncode(Hierarchy)
	return JSONData
end

function FS.get_disk_info()
	return Hierarchy["Disk"]
end

function FS.increase_storage()
	FS.Hierarchy.Disk[3] = 12_582_912
	FS.save_data()
end

return FS
