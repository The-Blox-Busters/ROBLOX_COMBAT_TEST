local AnimationService = {}

function AnimationService:Init()
    self.Idle = nil
    self.Shoot = nil
    self.Steady = nil
    self.PickingWeapon = nil
    self.Animator = nil
end

function AnimationService:LoadAnimations(config)
    local viewmodel = game.Workspace.CurrentCamera:FindFirstChild(config.viewmodel)
    if viewmodel then
        self.Animator = viewmodel:WaitForChild("AnimationController")
        self.Idle = game.ReplicatedStorage.Assets.Animations[config.name].Idle
        self.Shoot = game.ReplicatedStorage.Assets.Animations[config.name].Shoot
        self.Steady = game.ReplicatedStorage.Assets.Animations[config.name].Steady
        self.PickingWeapon = game.ReplicatedStorage.Assets.Animations[config.name].PickingWeapon
    end
end

function AnimationService:DefaultAnimations()
    local pickingWeaponTrack = self.Animator:LoadAnimation(self.PickingWeapon)
    local idleTrack = self.Animator:LoadAnimation(self.Idle)
    local steadyTrack = self.Animator:LoadAnimation(self.Steady)
    
    pickingWeaponTrack:Play()
    local movement = game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0
    if movement then
        pickingWeaponTrack.Stopped:Once(function()
            steadyTrack:Play()
        end)
    else
        pickingWeaponTrack.Stopped:Once(function()
            idleTrack:Play()
        end)
    end
end

function AnimationService:Shooting()
    local shootTrack = self.Animator:LoadAnimation(self.Shoot)
    print("Self.shoot: " .. self.Shoot:GetFullName())
    print("Self.Animator: " .. self.Animator:GetFullName())
    
    shootTrack:Play()
end

return AnimationService
