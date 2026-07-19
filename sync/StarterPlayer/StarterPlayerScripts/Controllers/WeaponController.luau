local WeaponController = {}

function WeaponController:Init()
    self.currentTool = nil
    self.currentConfig = nil
    self.ViewmodelService = require(game.StarterPlayer.StarterPlayerScripts.Systems.ViewmodelService)
    self.ViewmodelService:Init()
    print("WeaponController initialized")
end

function WeaponController:AssignTools()
    print("Assigning tools")
    if self.currentTool and self.currentConfig then
        print("Current tool exists")
        self.currentTool.Equipped:Connect(function()
            self.ViewmodelService:Equip(self.currentConfig)
        end)
        self.currentTool.Unequipped:Connect(function()
            self.ViewmodelService:Unequip()
        end)
    end
end

function WeaponController:CheckForWeapons()
    local player = game.Players.LocalPlayer
    
    local function checkTool()
        --this is the new version of backpack read comment below
        local backpack = player:WaitForChild("Backpack")
        print(backpack:GetChildren())
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                print("Found tool: " .. tool.Name)
                self.currentTool = tool
                self.currentConfig = require(game.ReplicatedStorage.Shared.WeaponConfigs[self.currentTool.Name])
                WeaponController:AssignTools()
                
            end
        end
        return
    end
    --[[
    roblox creates a version of the backpack before character spawns, deletes it and creates a new one after character spawns.
    i had a bug where the backpack i loaded was the deleted version and would not be able to access the tools inside
    this is why for the current system i had to check for the backpack and its content only after character is spawned
    annoying bug learn from it
    ]]--
    player.CharacterAdded:Connect(function()
        checkTool()
    end)
end

function WeaponController:Update()
    local runService = game:GetService("RunService")

    runService.RenderStepped:Connect(function(DeltaTime)
        if self.ViewmodelService.isEquipped then
            self.ViewmodelService:Effects()
        end
    end)
end
return WeaponController
