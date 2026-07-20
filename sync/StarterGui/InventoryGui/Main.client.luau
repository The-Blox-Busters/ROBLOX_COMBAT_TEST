--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage.Remotes
local Modules = ReplicatedStorage.Modules

local Item = require(Modules.Item)
local Inventory = require(Modules.Inventory)

local InventoryGui = script.Parent
local MainFrame = InventoryGui.Frame
local GridContainer = MainFrame.Grid
local ItemsContainer = MainFrame.Items

local CELL_SIZE = 50
local CELL_PADDING = 1
local INVENTORY_VIEW_KEY = Enum.KeyCode.B

function GetInventory(): Inventory.Inventory
	local inventory = setmetatable(Remotes.InventoryGet:InvokeServer(), Inventory) :: Inventory.Inventory
	for _, row in inventory.Grid do
		for _, cell in row do
			cell = setmetatable(cell, Item)
		end
	end
	return inventory
end

local PlayerInventory = GetInventory()
local DraggingItem: Item.Item? = nil
local DraggingItemFrame: Frame? = nil
local DragConnection = nil

GridContainer.Size = UDim2.new(0, CELL_SIZE * PlayerInventory.Width + CELL_PADDING * (PlayerInventory.Width - 1), 1, 0)

ItemsContainer.Size = GridContainer.Size

for i = 1, PlayerInventory.Width * PlayerInventory.Height do
	local cell = Instance.new("Frame")
	local y = math.floor(1 + (i - 1) / PlayerInventory.Width)
	local x = 1 + ((i - 1) % PlayerInventory.Width)
	cell.Name = `Cell_{tostring(y)}_{tostring(x)}`
	cell.BackgroundColor3 = Color3.fromHex("#282828")
	cell.BorderColor3 = Color3.fromHex("#3c3c3c")
	cell.ClipsDescendants = false
	cell.Parent = GridContainer

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = `({y}, {x})`
	textLabel.TextSize = 12
	textLabel.TextColor3 = Color3.fromHex("#22ff00")
	textLabel.BackgroundTransparency = 1
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Parent = cell
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent then
		return
	end

	if input.KeyCode == INVENTORY_VIEW_KEY then
		MainFrame.Visible = not MainFrame.Visible
	end
end)

UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if not MainFrame.Visible then
		return
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1 and DraggingItem and DraggingItemFrame then
		DragConnection:Disconnect()
		local gridPos = ((DraggingItemFrame.AbsolutePosition - ItemsContainer.AbsolutePosition) / CELL_SIZE):Floor()
			+ Vector2.one

		print(gridPos)

		if PlayerInventory:CanPlaceAt(DraggingItem, gridPos.X, gridPos.Y) then
			local pos = (gridPos - Vector2.one) * (CELL_SIZE + CELL_PADDING)
			DraggingItemFrame.Position = UDim2.fromOffset(pos.X, pos.Y)
		else
			warn("Cannot place item here!")
		end

		DraggingItem = nil
		DraggingItemFrame = nil
	end
end)

function CreateItemUI(item: Item.Item)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = item.Uid
	itemFrame.BackgroundColor3 = item.Properties.Color
	itemFrame.ZIndex = 3

	local width = (item:GetWidth() * CELL_SIZE) + ((item:GetWidth() - 1) * CELL_PADDING)
	local height = (item:GetHeight() * CELL_SIZE) + ((item:GetHeight() - 1) * CELL_PADDING)
	itemFrame.Size = UDim2.fromOffset(width, height)

	local xPos = (item.Left - 1) * (CELL_SIZE + CELL_PADDING)
	local yPos = (item.Top - 1) * (CELL_SIZE + CELL_PADDING)
	itemFrame.Position = UDim2.fromOffset(xPos, yPos)

	itemFrame.Parent = ItemsContainer

	itemFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not DraggingItem then
			PlayerInventory:RemoveAt(item.Left, item.Top)
			DraggingItem = item
			DraggingItemFrame = itemFrame

			local mouseOffset = UserInputService:GetMouseLocation() - itemFrame.AbsolutePosition
			DragConnection = RunService.RenderStepped:Connect(function(_dt: number)
				local newPos = UserInputService:GetMouseLocation() - mouseOffset - ItemsContainer.AbsolutePosition
				itemFrame.Position = UDim2.fromOffset(newPos.X, newPos.Y)
			end)
		end
	end)
end

function GuiRefresh()
	-- TODO: separate this to two function BuildGui and UpdateGui that update Gui without rebuilding it from scratch (Just the updated item)
	ItemsContainer:ClearAllChildren()
	PlayerInventory = GetInventory()
	local items = PlayerInventory:GetItemsList()
	for _, item in pairs(items) do
		CreateItemUI(item)
	end
end

GuiRefresh()
