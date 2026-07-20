--!strict
local Item = require(script.Parent.Item)

local Inventory = {}
Inventory.__index = Inventory

type InventoryData = {
	Width: number,
	Height: number,
	Grid: { { Item.Item } }, -- 2D array representing the inventory grid, where each cell can hold an Item object or Item.Empty
}

export type Inventory = typeof(setmetatable({} :: InventoryData, Inventory))

function Inventory.new(Width: number, Height: number): Inventory
	local Grid: { { Item.Item } } = table.create(Height)
	for y = 1, Height do
		Grid[y] = table.create(Width)
		for x = 1, Width do
			Grid[y][x] = Item.new("empty", y, x)
		end
	end

	return setmetatable({
		Width = Width,
		Height = Height,
		Grid = Grid,
	}, Inventory) :: Inventory
end

function Inventory.__tostring(self: Inventory): string
	local rowsStr: { string } = table.create(self.Height)
	local colMaxWidth: { number } = table.create(self.Width)

	for _, row in ipairs(self.Grid) do
		for i, cell in ipairs(row) do
			colMaxWidth[i] = math.max(colMaxWidth[i] or 0, #cell.Uid)
		end
	end

	for _, row in ipairs(self.Grid) do
		local cells: { string } = table.create(self.Width)
		for i, cell in ipairs(row) do
			local text = cell.Uid
			table.insert(cells, text .. string.rep(" ", colMaxWidth[i] - #text))
		end
		table.insert(rowsStr, table.concat(cells, " "))
	end

	return "\n" .. table.concat(rowsStr, "\n")
end

function Inventory.AddAt(self: Inventory, ItemUid: string, X: number, Y: number): Item.Item?
	if not self:IsValidCoordinate(X, Y) then
		return nil
	end

	local item: Item.Item = self.Grid[Y][X]
	if item.Uid == ItemUid then
		if item.Quantity < item.Properties.MaxStack then
			item = self.Grid[item.Top][item.Left]
			item.Quantity += 1
			return item
		end
		return nil
	end

	item = Item.new(ItemUid)
	if item.Properties.MaxStack <= 0 or not self:CanPlaceAt(item, X, Y) then
		return nil
	end

	for y = Y, Y + item:GetHeight() - 1 do
		for x = X, X + item:GetWidth() - 1 do
			self.Grid[y][x] = item
		end
	end

	item.Top = Y
	item.Left = X
	item.Quantity += 1

	return item
end

function Inventory.CanPlaceAt(self: Inventory, Item: Item.Item, X: number, Y: number): boolean
	-- Check if the item fits within the inventory bounds
	if
		not self:IsValidCoordinate(X, Y)
		or X + Item:GetWidth() - 1 > self.Width
		or Y + Item:GetHeight() - 1 > self.Height
	then
		return false
	end

	-- Check if the slots are empty
	for y = Y, Y + Item:GetHeight() - 1 do
		for x = X, X + Item:GetWidth() - 1 do
			if self.Grid[y][x].Uid ~= "empty" then
				return false
			end
		end
	end

	-- If all checks pass, the item can be placed
	return true
end

function Inventory.RemoveAt(self: Inventory, X: number, Y: number): Item.Item?
	if not self:IsValidCoordinate(X, Y) then
		return nil
	end

	local item: Item.Item = self.Grid[Y][X]

	if item.Uid == "empty" then
		return nil
	end

	if item.Quantity > 1 then
		item.Quantity -= 1
	else
		-- Remove the item from the grid
		for y = item.Top, item.Top + item:GetHeight() - 1 do
			for x = item.Left, item.Left + item:GetWidth() - 1 do
				self.Grid[y][x] = Item.new("empty", y, x)
			end
		end
	end

	return item
end

function Inventory.GetItemsList(self: Inventory): { Item.Item }
	local items: { Item.Item } = {}
	for i, row in ipairs(self.Grid) do
		for j, cell in ipairs(row) do
			if cell.Uid ~= "empty" and cell.Top == i and cell.Left == j then
				table.insert(items, cell)
			end
		end
	end
	return items
end

function Inventory.IsValidCoordinate(self: Inventory, X: number, Y: number): boolean
	return X >= 1 and Y >= 1 and X <= self.Width and Y <= self.Height
end

return Inventory
