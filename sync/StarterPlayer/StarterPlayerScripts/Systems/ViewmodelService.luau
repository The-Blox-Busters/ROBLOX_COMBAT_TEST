local ViewmodelService = {}

function ViewmodelService:Init()
    self.camera = game.Workspace.CurrentCamera
    self.currentViewmodel = nil
    self.clonedModel = nil
    self.isEquipped = nil
    self.swayCF = nil
end

function ViewmodelService:Equip(config)
    self.isEquipped = true
    if self.currentViewmodel  then
        self.currentViewmodel:Destroy()
    end
    if self.clonedModel then
        self.clonedModel:Destroy()
    end

    self.currentViewmodel = game:GetService("ReplicatedStorage").Assets.Viewmodels[config.viewmodel]
    self.clonedModel = self.currentViewmodel:Clone()
    self.clonedModel.Parent = self.camera

end

function ViewmodelService:Unequip()
    if self.currentViewmodel  then
        self.currentViewmodel:Destroy()
    end
    if self.clonedModel then
        self.clonedModel:Destroy()
    end
    self.isEquipped = false
end

function ViewmodelService:Sway()
    local mouseDelta = game:GetService("UserInputService"):GetMouseDelta()
    local swayX = math.clamp(mouseDelta.X, -.2, .2)
    local swayY = math.clamp(mouseDelta.Y, -.2, .2)
    self.swayCF = self.swayCF:Lerp(CFrame.new(swayX, swayY, 0), .1)
end

function ViewmodelService:Effects()
    ViewmodelService:Sway()

    self.camera.ViewFrame:SetPrimaryPartCFrame(self.camera.CFrame * self.swayCF)
end



return ViewmodelService
