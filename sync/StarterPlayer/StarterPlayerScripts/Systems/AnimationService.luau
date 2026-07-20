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

function AnimationService:PickingWeaponPlay()
    

    if self.PickingWeapon then
        if self.Animator then
            local pickingWeaponTrack = self.Animator:LoadAnimation(self.PickingWeapon)
            pickingWeaponTrack:Play()
        end
    end
end

function AnimationService:IdlePlay()
    
    if self.Idle then
        if self.Animator then
            local idleTrack = self.Animator:LoadAnimation(self.Idle)
            idleTrack:Play()
        end
    end
end

function AnimationService:SteadyPlay()
    if self.Steady then
        if self.Animator then
            local steadyTrack = self.Animator:LoadAnimation(self.Steady)
            steadyTrack:Play()
        end
    end
end

return AnimationService
