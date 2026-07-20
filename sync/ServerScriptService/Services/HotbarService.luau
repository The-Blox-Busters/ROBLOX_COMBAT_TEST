--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ToolsFolder = ServerStorage.Tools

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local Item = require(ReplicatedStorage.Modules.Item)
local Hotbar = require(Modules.Hotbar)

local HotbarService = {}

export type HotbarService = typeof(HotbarService)

function HotbarService.Init(self: HotbarService, services)
	self.Services = services

	self.Services.PlayerData.PlayerReady.Event:Connect(function(player: Player)
		-- TODO: remove it later --
		local hotbar = self:GetHotbar(player)
		hotbar:Set(4, "pistol")
		---------------------------

		player.CharacterAdded:Connect(function()
			self:SyncHotbar(player)
		end)
	end)

	Remotes.Equip.OnServerEvent:Connect(function(player: Player, slot: number?)
		if slot then
			self:Equip(player, slot)
		else
			self:Unequip(player)
		end

		local hotbar = self:GetHotbar(player)
		print(hotbar)
	end)
end

function HotbarService:SyncHotbar(player: Player)
	print("Synching hotbar...")
	player:WaitForChild("Backpack"):ClearAllChildren()
	local hotbar = self:GetHotbar(player)

	for slot, item in hotbar.Slots do
		if item then
			self:GiveTool(player, slot, item)
		end
	end

	if hotbar.EquippedSlot then
		self:Equip(player, hotbar.EquippedSlot)
	end
end

function HotbarService:Unequip(player: Player)
	local hotbar = self:GetHotbar(player)
	local item = hotbar:Unequip()
	if not item then
		return
	end
	local character = player.Character
	if not character then
		return
	end
	local equippedTool = character:FindFirstChild(item.Uid)
	if equippedTool then
		equippedTool.Parent = player:WaitForChild("Backpack")
	end
end

function HotbarService:Equip(player: Player, slot: number)
	self:Unequip(player)

	local hotbar = self:GetHotbar(player)

	local item = hotbar:Equip(slot)
	if not item then
		return
	end

	local tool = player:WaitForChild("Backpack"):FindFirstChild(item.Uid)
	if tool then
		tool.Parent = player.Character
	end
end

function HotbarService:GiveTool(player: Player, slot: number, item: Item.Item)
	if not item then
		print("Player have no item at slot", slot)
		return
	end
	local template = ToolsFolder:FindFirstChild(item.Uid)
	if not template then
		warn("Missing tool:", item.Uid)
		return
	end
	local tool = template:Clone()
	tool.Slot.Value = slot
	tool.Parent = player:WaitForChild("Backpack")
end

function HotbarService:GetHotbar(player: Player): Hotbar.Hotbar
	return self.Services.PlayerData:GetProfile(player).Hotbar :: Hotbar.Hotbar
end

return HotbarService
