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

local isEquipped = false

local debouncer = true	
local swayCF = CFrame.new()
local bob = CFrame.new()
local recoilTarget = CFrame.new()
local recoilCameraCF = CFrame.new()
local recoilViewModel = CFrame.new()
local recoil = 0


local function recoilCompounder()
	recoil = math.clamp(recoil+.5,0,3)
end

GunTool.Equipped:Connect(function()
	isEquipped = true
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
	local mousePosition = mouse.Hit.Position
	recoilCompounder()
	mousePosition = mousePosition
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
			
			recoilViewModel = recoilViewModel:Lerp(CFrame.new(0,math.rad(recoil*100),0), deltaTime) 
			Camera.ViewFrame:SetPrimaryPartCFrame(Camera.CFrame * swayCF * bob * recoilViewModel)	
		end
	else
		if Camera:FindFirstChild('ViewFrame') ~= nil then
			Camera:FindFirstChild('ViewFrame'):Destroy()		
		end
	end
end)

RunService:BindToRenderStep("Recoil", Enum.RenderPriority.Camera.Value + 1, function(deltaTime	)
	local baseCamera = Camera.CFrame
	recoil = math.clamp(recoil- deltaTime * 8,0,5)
	print("recoil: " .. recoil)
	recoilTarget = CFrame.Angles(
	math.rad(recoil * .4),
	math.rad(math.random(-math.floor(recoil * 2), math.floor(recoil * 2))),
	0
)
	recoilCameraCF = recoilCameraCF:Lerp(recoilTarget, deltaTime * 70)
	print("deltaTime: " .. deltaTime)
	Camera.CFrame = baseCamera * recoilCameraCF
end)