--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local Inventory = require(Modules.Inventory)

local InventoryService = {}

export type InventoryService = typeof(InventoryService)

function InventoryService.Init(self: InventoryService, services)
	self.Services = services

	-- TODO: Remove this later ----------
	self.Services.PlayerData.PlayerReady.Event:Connect(function(player: Player)
		local inventory = self:GetInventory(player)
		inventory:AddAt("pistol", 1, 1)
		inventory:AddAt("pistol", 1, 4)
		inventory:AddAt("ammo", 1, 3)
		inventory:AddAt("ammo", 1, 3)
		inventory:AddAt("ammo", 1, 3)
		inventory:AddAt("ammo", 1, 3)
		inventory:AddAt("ammo", 1, 3)
		inventory:AddAt("medkit", 8, 6)
		inventory:AddAt("medkit", 8, 6)
		inventory:AddAt("medkit", 8, 6)

		print(inventory)
	end)
	-- !--------------------------------

	Remotes.InventoryGet.OnServerInvoke = function(player)
		return self:GetInventory(player)
	end
end

function InventoryService:GetInventory(player: Player): Inventory.Inventory
	return self.Services.PlayerData:GetProfile(player).Inventory :: Inventory.Inventory
end

return InventoryService
