local player = game:GetService("Players").LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

local WeaponController = require(playerScripts.Controllers.WeaponController)
local viewmodelService = require(playerScripts.Systems.ViewmodelService)
--local animationService = require(playerScripts.Systems.AnimationService)

--animationService:Init()
--animationService:LoadAnimations(require(game.ReplicatedStorage.Shared.WeaponConfigs.Glock))
---animationService:PickingWeaponPlay()

WeaponController:Init()
WeaponController:CheckForWeapons()
WeaponController:Update()







