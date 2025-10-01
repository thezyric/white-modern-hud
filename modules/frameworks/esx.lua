ESX = exports["es_extended"]:getSharedObject()
-- @https://linktr.ee/thezyric
local logger = require("modules.utility.shared.logger")

local esxFramework = {}
esxFramework.__index = esxFramework
-- @https://linktr.ee/thezyric

function esxFramework.new()
    local self = setmetatable({}, esxFramework)
    self.values = {}

    AddEventHandler("esx_status:onTick", function(data)
        for i = 1, #data do
            if data[i].name == "hunger" then
                self.values.hunger = math.floor(data[i].percent)
            end

            if data[i].name == "thirst" then
                self.values.thirst = math.floor(data[i].percent)
            end

            if data[i].name == "stress" then
                self.values.stress = math.floor(data[i].percent)
            end
        end
    end)

    return self
end

function esxFramework:getPlayerHunger()
    return self.values.hunger
end

function esxFramework:getPlayerThirst()
    return self.values.thirst
end

function esxFramework:getPlayerStress()
    return self.values.stress
end

function esxFramework:getPlayerOxygen()
    return self.values.oxygen
end

function esxFramework:getPlayerStamina()
    return self.values.stamina
end

ESX.SecureNetEvent("esx:playerLoaded", function()
    print("^2Zyric Development - HUD - Success^0")
end)

ESX.SecureNetEvent("esx:onPlayerLogout", function()
    print("^2Zyric Development - HUD - Success^0")
end)

return esxFramework
