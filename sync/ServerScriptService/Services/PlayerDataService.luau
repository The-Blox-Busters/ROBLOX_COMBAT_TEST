--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules

local Hotbar = require(Modules.Hotbar)
local Inventory = require(Modules.Inventory)

local PlayerDataService = {}

PlayerDataService._profiles = {}

export type PlayerProfile = {
	Inventory: Inventory.Inventory,
	Hotbar: Hotbar.Hotbar,
}

function PlayerDataService:Init(_services)
	Players.PlayerAdded:Connect(function(player)
		self:CreateProfile(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:DestroyProfile(player)
	end)

	-- ? Studio case: players already in-game
	for _, player in Players:GetPlayers() do
		self:CreateProfile(player)
	end
end

function PlayerDataService:CreateProfile(player: Player)
	self._profiles[player] = {
		Inventory = Inventory.new(10, 6), -- ! TODO: Change it later
		Hotbar = Hotbar.new(),
	}
end

function PlayerDataService:GetProfile(player: Player): PlayerProfile
	assert(self._profiles[player], `No profile for {player.Name}`)
	return self._profiles[player]
end

function PlayerDataService:DestroyProfile(player: Player)
	-- TODO: later SaveService:Save(player)

	self._profiles[player] = nil
end

return PlayerDataService
