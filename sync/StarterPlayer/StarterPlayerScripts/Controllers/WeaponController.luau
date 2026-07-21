local WeaponController = {}

function WeaponController:Init()
    self.currentTool = nil
    self.currentConfig = nil
    self.ViewmodelService = require(game.StarterPlayer.StarterPlayerScripts.Systems.ViewmodelService)
    self.AnimationService = require(game.StarterPlayer.StarterPlayerScripts.Systems.AnimationService)

    self.ViewmodelService:Init()
    self.AnimationService:Init()
end

function WeaponController:AssignTools(tool,config)
    if tool and tool:IsA("Tool") and config then
        tool.Equipped:Connect(function()
            self.currentTool = tool
            self.currentConfig = config
            self.ViewmodelService:Equip(self.currentConfig)
            print("Equipped tool: " .. tool.Name)
            print("Using config: " .. config.name)
            self.AnimationService:LoadAnimations(self.currentConfig)
            self.AnimationService:DefaultAnimations()
        end)

        tool.Unequipped:Connect(function()
            self.ViewmodelService:Unequip()
        end)

        tool.Activated:Connect(function()
            self.AnimationService:Shooting()
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
                --self.currentTool = tool
                --self.currentConfig = require(game.ReplicatedStorage.Shared.WeaponConfigs[tool.Name])\
                local config = require(game.ReplicatedStorage.Shared.WeaponConfigs[tool.Name])
                WeaponController:AssignTools(tool,config)
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
    runService.RenderStepped:Connect(function(deltaTime)
        if self.ViewmodelService.isEquipped then
            self.ViewmodelService:Effects(deltaTime)
        end
    end)
end
return WeaponController
