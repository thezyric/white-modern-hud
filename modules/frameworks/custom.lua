-- @https://linktr.ee/thezyric
local logger = require("modules.utility.shared.logger")

local customFramework = {}
customFramework.__index = customFramework
-- @https://linktr.ee/thezyric

function customFramework.new()
    local self = setmetatable({}, customFramework)
    return self
end

-- Change this function to return the hunger value of the player.
function customFramework:getPlayerHunger()
    return 100
end

-- Change this function to return the thirst value of the player.
function customFramework:getPlayerThirst()
    return 100
end

-- Change this function to return the stress value of the player.
function customFramework:getPlayerStress()
    return 0
end

-- Change this function to return the oxygen value of the player.
function customFramework:getPlayerOxygen()
    return 100
end

-- Change this function to return the stamina value of the player.
function customFramework:getPlayerStamina()
    return 100
end

-- Change this EventHandler to toggle the HUD on player load
AddEventHandler('customFramework:client:Connect', function()
    print("^2Zyric Development - HUD - Success^0")
end)

-- Change this EventHandler to toggle the HUD on player logout
AddEventHandler('customFramework:client:Disconnect', function()
    print("^2Zyric Development - HUD - Success^0")
end)

return customFramework
