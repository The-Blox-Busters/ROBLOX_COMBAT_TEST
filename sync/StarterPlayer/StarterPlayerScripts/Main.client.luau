local player = game:GetService("Players").LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")
local config = require(game.ReplicatedStorage.Shared.WeaponConfigs.Glock)

local WeaponController = require(playerScripts.Controllers.WeaponController)
local viewmodelService = require(playerScripts.Systems.ViewmodelService)

WeaponController:Init()
WeaponController:CheckForWeapons()
WeaponController:Update()





