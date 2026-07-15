--!strict
local Item = require(script.Parent.Item)

local Inventory = {}
Inventory.__index = Inventory

type InventoryData = {
	Width: number,
	Height: number,
	Grid: { { string } }, -- 2D array representing the inventory grid, where each cell can hold an item ID or be empty ("")
	Items: { [string]: Item.Item }, -- Keyed by item ID, stores the actual item objects -- ! We can't store the same item if we exceeded max stack
}

export type Inventory = typeof(setmetatable({} :: InventoryData, Inventory))

function Inventory.__tostring(self: Inventory): string
	local rowsStr: { string } = {}
	local colMaxWidth: { number } = {}

	for _, row in ipairs(self.Grid) do
		for i, cell in ipairs(row) do
			local text = cell == "" and "." or cell
			colMaxWidth[i] = math.max(colMaxWidth[i] or 0, #text)
		end
	end

	for _, row in ipairs(self.Grid) do
		local cells: { string } = {}
		for i, cell in ipairs(row) do
			local text = cell == "" and "." or cell
			table.insert(cells, cell .. string.rep(" ", colMaxWidth[i] - #text))
		end
		table.insert(rowsStr, table.concat(cells, " "))
	end

	return table.concat(rowsStr, "\n")
end

function Inventory.new(Width: number, Height: number): Inventory
	local Grid: { { string } } = {}
	for y = 1, Height do
		Grid[y] = {}
		for x = 1, Width do
			Grid[y][x] = ""
		end
	end

	return setmetatable({
		Width = Width,
		Height = Height,
		Grid = Grid,
		Items = {},
	}, Inventory) :: Inventory
end

function Inventory.Add(self: Inventory, ItemUid: string, X: number, Y: number): boolean
	local item: Item.Item = self.Items[ItemUid] or Item.new(ItemUid)

	-- if item already in the inventory and can be stacked just increase the quantity
	if item.Quantity > 0 then
		if item.Quantity < item.Properties.MaxStack then
			item.Quantity += 1
			return true
		end
		-- ! Must read
		-- TODO: in the future self.Items[Uid] will be a list
		-- TODO: append a new item to the list if max stack exceeded
		return false
	end

	if item.Properties.MaxStack == 0 or not self:CanPlaceAt(item, X, Y) then
		return false
	end

	for y = Y, Y + item:GetHeight() - 1 do
		for x = X, X + item:GetWidth() - 1 do
			self.Grid[y][x] = item.Uid
		end
	end

	item.Top = Y
	item.Left = X
	item.Quantity += 1

	self.Items[item.Uid] = item

	return true
end

function Inventory.CanPlaceAt(self: Inventory, Item: Item.Item, X: number, Y: number): boolean
	-- Check if the item fits within the inventory bounds
	if X < 1 or Y < 1 or X + Item:GetWidth() - 1 > self.Width or Y + Item:GetHeight() - 1 > self.Height then
		return false
	end

	-- Check if the slots are empty
	for y = Y, Y + Item:GetHeight() - 1 do
		for x = X, X + Item:GetWidth() - 1 do
			if self.Grid[y][x] ~= "" then
				return false
			end
		end
	end

	-- If all checks pass, the item can be placed
	return true
end

function Inventory.RemoveAt(self: Inventory, X: number, Y: number): boolean
	local itemUid: string = self.Grid[Y][X]

	if itemUid == "" then
		return false
	end

	return self:Remove(itemUid)
end

function Inventory.Remove(self: Inventory, ItemUid: string): boolean
	local item: Item.Item? = self.Items[ItemUid]

	if not item then
		return false
	end

	if item.Quantity > 1 then
		item.Quantity -= 1
	else
		-- Remove the item from the grid
		for y = item.Top, item.Top + item:GetHeight() - 1 do
			for x = item.Left, item.Left + item:GetWidth() - 1 do
				self.Grid[y][x] = ""
			end
		end
		self.Items[ItemUid] = nil
	end

	return true
end

return Inventory
