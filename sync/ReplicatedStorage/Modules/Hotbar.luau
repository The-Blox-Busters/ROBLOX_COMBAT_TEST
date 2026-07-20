--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local Item = require(Modules.Item)

local HotBar = {}
HotBar.__index = HotBar

const HOTBAR_SIZE = 10

export type Hotbar = typeof(setmetatable(
	{} :: {
		Slots: { [number]: Item.Item? },
		EquippedSlot: number?,
	},
	HotBar
))

function HotBar.new(): Hotbar
	return setmetatable({
		Slots = table.create(HOTBAR_SIZE),
		EquippedSlot = nil,
	}, HotBar) :: Hotbar
end

function HotBar.__tostring(self: Hotbar): string
	local slots: { string } = {}
	for _, slot in self.Slots do
		table.insert(slots, tostring(slot))
	end
	return `Hotbar(Slots={table.concat(slots, ", ")}, EquippedSlot={self.EquippedSlot})`
end

function HotBar.Set(self: Hotbar, slot: number, itemUid: string): Item.Item?
	if slot < 1 or slot > HOTBAR_SIZE then
		return nil
	end
	local item = Item.new(itemUid, 0, slot)
	self.Slots[slot] = item
	return item
end

function HotBar.Remove(self: Hotbar, slot: number): Item.Item?
	local item = self.Slots[slot]
	self.Slots[slot] = nil
	if self.EquippedSlot == slot then
		self:Unequip()
	end
	return item
end

function HotBar.Get(self: Hotbar, slot: number): Item.Item?
	return self.Slots[slot]
end

function HotBar.Equip(self: Hotbar, slot: number): Item.Item?
	local item = self:Get(slot)
	if item then
		self.EquippedSlot = slot
	end
	return item
end

function HotBar.Unequip(self: Hotbar): Item.Item?
	if not self.EquippedSlot then
		return nil
	end
	local item = self:Get(self.EquippedSlot)
	self.EquippedSlot = nil
	return item
end

return HotBar
