--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage.Modules
local ItemDatabase = require(Modules.ItemDatabase)

local Item = {}
Item.__index = Item

type ItemData = {
	Uid: string,
	Quantity: number,
	Top: number,
	Left: number,
	Rotated: boolean,
	Properties: ItemDatabase.ItemProperties,
}

export type Item = typeof(setmetatable({} :: ItemData, Item))

function Item.__tostring(self: Item): string
	return `Item(Uid={self.Uid}, Qty={self.Quantity}, Pos=({self.Left}, {self.Top}), Rotated={self.Rotated})`
end

function Item.new(Uid, Top: number?, Left: number?): Item
	local itemProperties = ItemDatabase[Uid]

	if not itemProperties then
		error("Item ID not found in database: " .. Uid)
	end

	if not Top then
		Top = 0
	end
	if not Left then
		Left = 0
	end

	return setmetatable({
		Uid = Uid,
		Quantity = 0,
		Top = Top,
		Left = Left,
		Rotated = false,
		Properties = itemProperties,
	}, Item) :: Item
end

function Item.GetHeight(self: Item): number
	if self.Rotated then
		return self.Properties.Width
	end
	return self.Properties.Height
end

function Item.GetWidth(self: Item): number
	if self.Rotated then
		return self.Properties.Height
	end
	return self.Properties.Width
end

return Item
