local ServicesFolder = script.Parent.Services

local Services = {
	PlayerData = require(ServicesFolder.PlayerDataService),
	Hotbar = require(ServicesFolder.HotbarService),
	-- Inventory = require(ServicesFolder.InventoryService),
	-- MoveItem = require(ServicesFolder.MoveItemService),
}

for _, service in pairs(Services) do
	if service.Init then
		service:Init(Services)
	end
end
