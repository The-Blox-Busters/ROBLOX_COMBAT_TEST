local player = game.Players.LocalPlayer 
player.CameraMode = Enum.CameraMode.LockFirstPerson
local ViewFrame = game.ReplicatedStorage.ViewFrame
local GunTool = script.Parent
local Camera = workspace.Camera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local shootingEvent = game.ReplicatedStorage.ShootingEvent
local mouse = player:GetMouse()
local shooting
local pickPistol
local idle
local steady

local animator 

local animationPickPistol
local animationShooting
local animationIdle
local animationSteady

local boolean = 0
isEquipped = false

local debouncer = true	
local swayCF = CFrame.new()
local bob = CFrame.new()

GunTool.Equipped:Connect(function()
	isEquipped = true
	boolean = 1
	local ViewFrameClone = ViewFrame:Clone()
	ViewFrameClone.Parent = Camera
	shooting = ViewFrameClone.Shooting
	pickPistol = ViewFrameClone.PickingPistol
	idle = ViewFrameClone.Idle
	steady = ViewFrameClone.Steady
	animator = ViewFrameClone.AnimationController.Animator
	animationPickPistol = animator:LoadAnimation(pickPistol)
	animationShooting = animator:LoadAnimation(shooting)
	animationIdle = animator:LoadAnimation(idle)
	animationSteady = animator:LoadAnimation(steady)
	animationPickPistol:Play()
	animationPickPistol.Stopped:Connect(function()
		animationIdle:Play()
		animationIdle:AdjustSpeed(0.5)
	end)
end)

GunTool.Unequipped:Connect(function()
	isEquipped = false
	if Camera:FindFirstChild('ViewFrame') ~= nil then
		Camera:FindFirstChild('ViewFrame'):Destroy()
	end
end)

GunTool.Activated:Connect(function()
	boolean = 0
	local mousePosition = mouse.Hit.Position

	if debouncer == false then
		return
	end
	debouncer = false
	
	local flash = Camera.ViewFrame.Gun.Origin.FlashEmitter

	if flash then
		flash:Emit(1)
	end
	
	animationIdle:Stop()
	animationPickPistol:Stop()
	
	animationShooting:Play()
	animationShooting:AdjustSpeed(4)
	
	animationShooting.Stopped:Connect(function()
		animationIdle:Play()
		animationIdle:AdjustSpeed(0.5)
	end)

	shootingEvent:FireServer(Camera.ViewFrame.Gun.Origin.WorldPosition,mousePosition)	
	
	task.delay(0.25, function()
		debouncer = true
	end)
end)

local lastMoving = false

RunService.RenderStepped:Connect(function(deltaTime)
	local targetBob = CFrame.new()
	
	if isEquipped == true then
		
		local movement = player.Character.Humanoid.MoveDirection.Magnitude > 0

		if movement ~= lastMoving then
			lastMoving = movement

			if movement then
				animationIdle:Stop()
				animationSteady:Play()
			else
				animationSteady:Stop()
				animationIdle:Play()
				animationIdle:AdjustSpeed(0.5)
			end
		end
		
		if movement then
			local bobX = math.sin(time() * 8) * 0.1
			local bobY = math.abs(math.cos(time() * 25)) * 0.05

			targetBob = CFrame.new(bobX, bobY, 0)
		end
		
		if player.Character.Humanoid.Health <= 0 then
			if Camera:FindFirstChild('ViewFrame') ~= nil then
				Camera:FindFirstChild('ViewFrame'):Destroy()		
			end
		end
		if Camera:FindFirstChild('ViewFrame') ~= nil then
			local mouseDelta = UserInputService:GetMouseDelta()
			local swayX = math.clamp(mouseDelta.X, -.2,.2)
			local swayY = math.clamp(mouseDelta.Y, -.2,.2) 
			swayCF = swayCF:Lerp(CFrame.new(swayX, swayY, 0), .1)
			bob = bob:Lerp(targetBob, deltaTime * 5)
			Camera.ViewFrame:SetPrimaryPartCFrame(Camera.CFrame * swayCF * bob)	
		end
	else
		if Camera:FindFirstChild('ViewFrame') ~= nil then
			Camera:FindFirstChild('ViewFrame'):Destroy()		
		end
	end
end)