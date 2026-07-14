--[[
    MM (ModuleScript)
    Path: ReplicatedStorage → ZKernel → Ring0
    Parent: Ring0
    Exported: 2026-07-14 13:31:45
]]
local MM = {}
local Panic = require(script.Parent.Panic)

MM.MemData = {
	TotalSize = 4_096,
	OccupiedSize = 0
}
MM.Memory = {}


function MM.malloc(pid: number, size: number): number
	if size < 0 then return 0 end
	if MM.MemData.OccupiedSize + size > MM.MemData.TotalSize then
		-- OOM - kernel panic
		Panic.trigger("OOM - Out Of Memory", "0x0006", "OS has run out of memory; Kernel panic has been triggered to prevent further damage")
		return 0	-- equivalent: NULL
	end
	
	if not MM.Memory[pid] then
		MM.Memory[pid] = {}
	end
	
	MM.MemData.OccupiedSize += size	
	
	local blk = {
		bufobj = buffer.create(size),
		size = size,
		methods = {}
	}
	
	table.insert(MM.Memory[pid], blk)
	
	local uniqptr = #MM.Memory[pid]
	
	blk.methods = {
		readu8 = function(offset: number)
			if offset < 0 or offset + 1 > blk["size"] then return nil end
			return buffer.readu8(blk["bufobj"], offset)
		end,
		
		readu16 = function(offset: number)
			if offset < 0 or offset + 2 > blk["size"] then return nil end
			return buffer.readu16(blk["bufobj"], offset)
		end,
		
		readu32 = function(offset: number)
			if offset < 0 or offset + 4 > blk["size"] then return nil end
			return buffer.readu32(blk["bufobj"], offset)
		end,
		
		readi8 = function(offset: number)
			if offset < 0 or offset + 1 > blk["size"] then return nil end
			return buffer.readi8(blk["bufobj"], offset)
		end,
		
		readi16 = function(offset: number)
			if offset < 0 or offset + 2 > blk["size"] then return nil end
			return buffer.readi16(blk["bufobj"], offset)
		end,
		
		readi32 = function(offset: number)
			if offset < 0 or offset + 4 > blk["size"] then return nil end
			return buffer.readi32(blk["bufobj"], offset)
		end,
		
		readf32 = function(offset: number)
			if offset < 0 or offset + 4 > blk["size"] then return nil end
			return buffer.readf32(blk["bufobj"], offset)
		end,
		
		readf64 = function(offset: number)
			if offset < 0 or offset + 8 > blk["size"] then return nil end
			return buffer.readf64(blk["bufobj"], offset)
		end,
		
		readstr = function(offset: number, len)
			if offset < 0 or offset + len > blk["size"] then return nil end
			return buffer.readstring(blk["bufobj"], offset, len)
		end,
		
		writeu8 = function(offset: number, val)
			if offset < 0 or offset + 1 > blk["size"] then return false end
			buffer.writeu8(blk["bufobj"], offset, val)
		end,
		
		writeu16 = function(offset: number, val)
			if offset < 0 or offset + 2 > blk["size"] then return false end
			buffer.writeu16(blk["bufobj"], offset, val)
		end,
		
		writeu32 = function(offset: number, val)
			if offset < 0 or offset + 4 > blk["size"] then return false end
			buffer.writeu32(blk["bufobj"], offset, val)
		end,
		
		writei8 = function(offset: number, val)
			if offset < 0 or offset + 1 > blk["size"] then return false end
			buffer.writei8(blk["bufobj"], offset, val)
		end,
		
		writei16 = function(offset: number, val)
			if offset < 0 or offset + 2 > blk["size"] then return false end
			buffer.writei16(blk["bufobj"], offset, val)
		end,
		
		writei32 = function(offset: number, val)
			if offset < 0 or offset + 4 > blk["size"] then return false end
			buffer.writei32(blk["bufobj"], offset, val)
		end,
		
		writef32 = function(offset: number, val)
			if offset < 0 or offset + 4 > blk["size"] then return false end
			buffer.writef32(blk["bufobj"], offset, val)
		end,
		
		writef64 = function(offset: number, val)
			if offset < 0 or offset + 8 > blk["size"] then return false end
			buffer.writef64(blk["bufobj"], offset, val)
		end,
		
		writestr = function(offset: number, val)
			if offset < 0 or offset + #val > blk["size"] then return false end
			buffer.writestring(blk["bufobj"], offset, val)
		end,
	}
	return uniqptr
end

function MM.getheap(pid: number, ptr: number)
	return MM.Memory[pid][ptr]["methods"]
end

function MM.free(pid: number, ptr: number)
	MM.MemData.OccupiedSize -= MM.Memory[pid][ptr]["size"]
	table.remove(MM.Memory[pid], ptr)
end

function MM.free_program(pid: number)
	for i = #MM.Memory[pid], 1, -1 do
		MM.MemData.OccupiedSize -= MM.Memory[pid][i].size
		table.remove(MM.Memory[pid], i)
	end
end

function MM.get_mem_properties()
	return MM.MemData
end

return MM