--!strict
local Players = game:GetService("Players") :: Players
local ReplicatedStorage = game.ReplicatedStorage

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local Inventory = require(Modules.Inventory.Inventory)

local InventoryAddEvent = Remotes.InventoryAdd
local InventoryRemoveEvent = Remotes.InventoryRemove

local inventories: { [Player]: Inventory.Inventory? } = {}

Players.PlayerAdded:Connect(function(player)
	inventories[player] = Inventory.new(10, 8) -- ! TODO
end)

Players.PlayerRemoving:Connect(function(player)
	inventories[player] = nil
end)

InventoryAddEvent.OnServerEvent:Connect(function(player, ItemUid: string, X: number, Y: number)
	local inventory: Inventory.Inventory? = inventories[player]

	if not inventory then
		warn("No inventory found for player:", player.Name)
		return
	end

	if inventory:Add(ItemUid, X, Y) then
		print("Item added to inventory:", ItemUid)
		print(inventory)
	else
		print("Failed to add item to inventory:", ItemUid)
	end
end)

InventoryRemoveEvent.OnServerEvent:Connect(function(player, x: number, y: number)
	local inventory: Inventory.Inventory? = inventories[player]

	if not inventory then
		warn("No inventory found for player:", player.Name)
		return
	end

	if inventory:RemoveAt(x, y) then
		print("Item removed from inventory at position:", x, y)
	else
		print("Failed to remove item from inventory at position:", x, y)
	end
end)
