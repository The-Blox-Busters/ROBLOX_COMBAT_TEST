local bulletFolder = Instance.new("Folder")
bulletFolder.Name = "Bullets"
bulletFolder.Parent = workspace

local function seeRay(origin, direction)
	
	local part = Instance.new("Part")
	part.Parent = workspace
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.fromRGB(255, 21, 44)
	local length = direction.Magnitude
	local midpoint = origin + direction * 0.5
	part.Size = Vector3.new(0.1, 0.1, length)
	part.CFrame = CFrame.lookAt(midpoint, origin + direction)
	game.Debris:AddItem(part,0.5)
end

local function createBullet(origin, targetPoint,exception,plr)
	local bullet = Instance.new("Part")
	bullet.Parent = bulletFolder
	bullet.Anchored = true
	bullet.Name = "Bullet"
	bullet.CanCollide = false
	bullet.Shape = Enum.PartType.Cylinder
	bullet.Size = Vector3.new(2, 0.2, 0.2)
	bullet.Color = Color3.fromRGB(255, 255, 0)
	bullet.Material = Enum.Material.Glass
	local lookCFrame = CFrame.lookAt(origin, targetPoint) * CFrame.Angles(0, math.rad(90), 0)
	bullet.CFrame = lookCFrame

	local distance = (targetPoint - origin).Magnitude
	local duration = distance / 200

	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = game:GetService("TweenService"):Create(bullet, tweenInfo, {
		CFrame = lookCFrame + (targetPoint - origin) 
	})
	tween:Play()
	game.Debris:AddItem(bullet, duration)
	
end

local exception = RaycastParams.new()
exception.FilterType = Enum.RaycastFilterType.Exclude

local playerTable = {}

local shootingEvent = game.ReplicatedStorage.ShootingEvent
shootingEvent.OnServerEvent:Connect(function(plr,origin,mousePosition)
	local fireRate = 0.2
	local times = os.clock()

	local lastShot = playerTable[plr.UserId] or 0

	if times - lastShot < fireRate then
		return 
	end

	playerTable[plr.UserId] = times
	
	exception.FilterDescendantsInstances = {plr.Character,bulletFolder}
	local direction = (mousePosition - origin).Unit * 500
	local RayCast = workspace:Raycast(origin,direction,exception)
	local targetPoint

	
	if RayCast then
		targetPoint = RayCast.Position
		print(RayCast.Instance.Name)
		local char = RayCast.Instance:FindFirstAncestorOfClass("Model")
		
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:TakeDamage(12)
			end
		end
		
	else
		targetPoint = origin + direction
		print("Nothing hits")
	end
	
	createBullet(origin,targetPoint,exception,plr)
	
end)
