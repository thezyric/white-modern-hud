-- @https://linktr.ee/thezyric
local logger = require("modules.utility.shared.logger")

local qbFramework = {}
qbFramework.__index = qbFramework
-- @https://linktr.ee/thezyric

function qbFramework.new()
    local self = setmetatable({}, qbFramework)
    self.values = {}

    RegisterNetEvent("hud:client:UpdateNeeds", function(hunger, thirst)
        self.values.hunger = hunger
        self.values.thirst = thirst
    end)

    RegisterNetEvent("hud:client:UpdateStress", function(stress)
        self.values.stress = stress
    end)

    RegisterNetEvent("hud:client:UpdateOxygen", function(oxygen)
		self.values.oxygen = oxygen
	end)

	RegisterNetEvent("hud:client:UpdateStamina", function(stamina)
		self.values.stamina = stamina
	end)

    return self
end

function qbFramework:getPlayerHunger()
    return self.values.hunger or "disabled"
end


function qbFramework:getPlayerThirst()
    return self.values.thirst or "disabled"
end

function qbFramework:getPlayerOxygen()
    return self.values.oxygen or "disabled"
end

function qbFramework:getPlayerStamina()
    return self.values.stamina or "disabled"
end

function qbFramework:getPlayerStress()
    return self.values.stress or "disabled"
end

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    print("^2Zyric Development - HUD - Success^0")
end)

AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    print("^2Zyric Development - HUD - Success^0")
end)

return qbFramework
