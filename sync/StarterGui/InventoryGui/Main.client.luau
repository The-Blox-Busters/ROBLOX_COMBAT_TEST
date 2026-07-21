--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Item = require(Modules.Item)
local Inventory = require(Modules.Inventory)

local InventoryGui = script.Parent
local MainFrame = InventoryGui.Frame
local GridContainer = MainFrame.Grid
local ItemsContainer = MainFrame.Items

local CELL_SIZE = GridContainer.UIGridLayout.CellSize.Width.Offset
local INVENTORY_VIEW_KEY = Enum.KeyCode.B

export type DragState = {
	Item: Item.Item,
	Frame: Frame,
	OriginalPosition: Vector2,
	MouseOffset: Vector2,
	Connection: RBXScriptConnection,
}

local PlayerInventory: Inventory.Inventory
local DragState: DragState? = nil

function Start()
	RefreshInventory()
	RenderGrid()
	RenderInventory()
	ConnectInput()
end

function RenderGrid()
	GridContainer.Size = UDim2.new(0, CELL_SIZE * PlayerInventory.Width, 1, 0)

	ItemsContainer.Size = GridContainer.Size

	for i = 1, PlayerInventory.Width * PlayerInventory.Height do
		local y = math.floor(1 + (i - 1) / PlayerInventory.Width)
		local x = 1 + ((i - 1) % PlayerInventory.Width)

		local cell = GridContainer.BaseCell:Clone()
		cell.Name = `Cell_{tostring(y)}_{tostring(x)}`
		cell.Text = `({y}, {x})`
		cell.Visible = true
		cell.ZIndex = 2
		cell.Parent = GridContainer
	end
end

function RefreshInventory()
	local inventoryData = Remotes.InventoryGet:InvokeServer()
	for _, row in inventoryData.Grid do
		for i, cell in row do
			row[i] = setmetatable(cell, Item)
		end
	end
	PlayerInventory = setmetatable(inventoryData, Inventory)
end

function RenderInventory()
	ItemsContainer:ClearAllChildren()
	local items = PlayerInventory:GetItemsList()
	for _, item in pairs(items) do
		RenderItem(item)
	end
end

function RenderItem(item: Item.Item)
	local itemFrame = Instance.new("Frame")
	itemFrame.Name = item.Uid
	itemFrame.BackgroundColor3 = item.Properties.Color
	itemFrame.ZIndex = 3
	itemFrame.Size = UDim2.fromOffset(item:GetWidth() * CELL_SIZE, item:GetHeight() * CELL_SIZE)
	itemFrame.Position = UDim2.fromOffset((item.Left - 1) * CELL_SIZE, (item.Top - 1) * CELL_SIZE)
	itemFrame.Parent = ItemsContainer

	local textLabel = Instance.new("TextLabel")
	textLabel.Text = item.Uid .. ": " .. tostring(item.Quantity)
	textLabel.TextColor3 = Color3.fromHex("#000000")
	textLabel.TextWrapped = true
	textLabel.TextSize = 14
	textLabel.Active = false
	textLabel.Size = UDim2.fromScale(1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.Parent = itemFrame

	itemFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and not DragState then
			local mouseOffset = UserInputService:GetMouseLocation() - itemFrame.AbsolutePosition

			local dragConnection = RunService.RenderStepped:Connect(function(_dt: number)
				local newPos = UserInputService:GetMouseLocation() - mouseOffset - ItemsContainer.AbsolutePosition
				itemFrame.Position = UDim2.fromOffset(newPos.X, newPos.Y)
			end)

			DragState = {
				Item = item,
				Frame = itemFrame,
				OriginalPosition = itemFrame.AbsolutePosition,
				MouseOffset = mouseOffset,
				Connection = dragConnection,
			}
		end
	end)
end

function ConnectInput()
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

		if input.UserInputType == Enum.UserInputType.MouseButton1 and DragState then
			DragState.Connection:Disconnect()
			local gridPos = ((DragState.Frame.AbsolutePosition - ItemsContainer.AbsolutePosition) / CELL_SIZE):Floor()
				+ Vector2.one
			print("Grid pos:", gridPos)

			local newPos: Vector2
			if
				PlayerInventory:CanPlaceAt(DragState.Item, gridPos.X, gridPos.Y)
				-- TODO: and Remotes.MoveItem:InvokeServer({})
			then
				-- TODO: RefreshInventory()
				newPos = (gridPos - Vector2.one) * CELL_SIZE
			else
				warn("Cannot place item here!")
				newPos = DragState.OriginalPosition - ItemsContainer.AbsolutePosition
			end
			DragState.Frame:TweenPosition(UDim2.fromOffset(newPos.X, newPos.Y))

			DragState = nil
		end
	end)
end

Start()
