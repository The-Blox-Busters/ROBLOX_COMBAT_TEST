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

local fireRate = .2

local debouncer = true
local swayCF = CFrame.new()
local bob = CFrame.new()
local generalRecoil = 0

local recoilCameraTarget = CFrame.new()
local recoilCameraCF = CFrame.new()

local maxRecoil = 2
local recoilInstensity = 0.3
local recoilRecovery = 5

local recoilViewModel = CFrame.new()
local recoilKick = CFrame.new()
local recoilKickTarget = CFrame.new(0, 0, 0)
local viewmodelRecoilPitch = 55
local viewmodelRecoilYaw = 5
local viewmodelRecoilRoll = 34

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
	if debouncer == false then
		return
	end
	debouncer = false
	local mousePosition = mouse.Hit.Position
	generalRecoil = math.clamp(generalRecoil + recoilInstensity, 0, maxRecoil)
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
	task.delay(fireRate, function()
		debouncer = true
	end)
end)

GunTool.Deactivated:Connect(function()
	--
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
			--orice camera se duce spre o directie si nu se intoarce inapoi
			local mouseDelta = UserInputService:GetMouseDelta()
			local swayX = math.clamp(mouseDelta.X, -.2, .2)
			local swayY = math.clamp(mouseDelta.Y, -.2, .2)
			swayCF = swayCF:Lerp(CFrame.new(swayX, swayY, 0), .1)
			bob = bob:Lerp(targetBob, deltaTime * 5)
			recoilKickTarget = CFrame.new(0, 0, generalRecoil * 5)
			recoilKick = recoilKick:Lerp(recoilKickTarget, deltaTime * 10)

			recoilViewModel = recoilViewModel:Lerp(
				CFrame.Angles(math.rad(generalRecoil * viewmodelRecoilPitch),
					math.rad(generalRecoil * viewmodelRecoilYaw),
					math.rad(generalRecoil * viewmodelRecoilRoll)), deltaTime)
			Camera.ViewFrame:SetPrimaryPartCFrame(Camera.CFrame * swayCF * bob * recoilViewModel * recoilKick)




			local baseCamera = Camera.CFrame
			generalRecoil = math.max(generalRecoil - (recoilRecovery * deltaTime), 0)
			print("generalRecoil: " .. generalRecoil)

			recoilCameraTarget = CFrame.Angles(
				math.rad(generalRecoil * recoilInstensity),
				math.rad(math.random(-generalRecoil * (recoilInstensity * 3), generalRecoil * (recoilInstensity * 3))),
				0)

			recoilCameraCF = recoilCameraCF:Lerp(recoilCameraTarget, deltaTime * 30)
			print("deltaTime: " .. deltaTime)

			Camera.CFrame = baseCamera * recoilCameraCF
		end
	else
		if Camera:FindFirstChild('ViewFrame') ~= nil then
			Camera:FindFirstChild('ViewFrame'):Destroy()
		end
	end
end)

