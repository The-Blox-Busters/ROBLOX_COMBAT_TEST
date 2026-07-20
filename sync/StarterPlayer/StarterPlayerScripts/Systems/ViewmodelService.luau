local ViewmodelService = {}

function ViewmodelService:Init()
    self.camera = game.Workspace.CurrentCamera
    self.currentViewmodel = nil
    self.clonedModel = nil
    self.isEquipped = nil
    self.swayCF = CFrame.new()
    self.bob = CFrame.new()
end

function ViewmodelService:Equip(config)
    self.isEquipped = true
    if self.clonedModel then
        self.clonedModel:Destroy()
    end

    self.currentViewmodel = game:GetService("ReplicatedStorage").Assets.Viewmodels[config.viewmodel]
    self.clonedModel = self.currentViewmodel:Clone()
    self.clonedModel.Parent = self.camera
end

function ViewmodelService:Unequip()
    self.isEquipped = false
    if self.clonedModel then
        self.clonedModel:Destroy()
    end
end

function ViewmodelService:Sway()
    local mouseDelta = game:GetService("UserInputService"):GetMouseDelta()
    local swayX = math.clamp(mouseDelta.X, -.2, .2)
    local swayY = math.clamp(mouseDelta.Y, -.2, .2)
    self.swayCF = self.swayCF:Lerp(CFrame.new(swayX, swayY, 0), .1)
end

function ViewmodelService:Bob(deltaTime)
    local targetBob = CFrame.new()
    local movement = game.Players.LocalPlayer.Character.Humanoid.MoveDirection.Magnitude > 0
    if movement then
        local bobX = math.sin(time() * 8) * 0.1
		local bobY = math.abs(math.cos(time() * 25)) * 0.05
        targetBob = CFrame.new(bobX, bobY, 0)
    end
    self.bob = self.bob:Lerp(targetBob, deltaTime * 5)
end

function ViewmodelService:Effects(deltaTime)
    ViewmodelService:Sway()
    ViewmodelService:Bob(deltaTime)
    self.clonedModel:SetPrimaryPartCFrame(self.camera.CFrame * self.swayCF * self.bob)    
end



return ViewmodelService
