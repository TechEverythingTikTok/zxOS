--[[
    PayService (ModuleScript)
    Path: ReplicatedStorage
    Parent: ReplicatedStorage
    Exported: 2026-07-14 13:31:45
]]
local PayService = {}
local MPS = game:GetService("MarketplaceService")
local player = game:GetService("Players").LocalPlayer

local cid = 0
local connections_table = {}

function PayService.PromptProductPurchase(productId)
	MPS:PromptProductPurchase(player, productId)	
end

function PayService.PromptGamepassPurchase(gamepassId)
	MPS:PromptGamePassPurchase(player, gamepassId)
end

function PayService.GamepassPurchaseFinished(callback)
	cid += 1
	connections_table[cid] = MPS.PromptGamePassPurchaseFinished:Connect(function(plr, gpid, purchased)
		callback(gpid, purchased)
	end)
	return cid
end

function PayService.UserOwnsGamepass(gamepassId)
	return MPS:UserOwnsGamePassAsync(player.UserId, gamepassId)
end

function PayService.DisconnectCID(cid)
	if connections_table[cid] then connections_table[cid]:Disconnect() end
end

function PayService.DisconnectAll()
	for i, v in ipairs(connections_table) do
		v:Disconnect()
	end
end

return PayService