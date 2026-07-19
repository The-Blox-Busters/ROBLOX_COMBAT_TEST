local ServicesFolder = script.Parent.Services

local Services = {
	PlayerData = require(ServicesFolder.PlayerDataService),
	-- Inventory = require(ServicesFolder.InventoryService),
	-- Hotbar = require(ServicesFolder.HotbarService),
	-- MoveItem = require(ServicesFolder.MoveItemService),
}

for _, service in pairs(Services) do
	if service.Init then
		service:Init(Services)
	end
end
