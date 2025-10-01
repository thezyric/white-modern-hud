-- @https://linktr.ee/thezyric
---@diagnostic disable: cast-local-type
local logger = require("modules.utility.shared.logger")
local interface = require("modules.interface.client")
local config = require("config.shared")
local utility = require("modules.utility.shared.main")
local sharedFunctions = require("config.functions")
-- @https://linktr.ee/thezyric

local PlayerStatusThread = {}
PlayerStatusThread.__index = PlayerStatusThread

-- Cache variables for better performance
local cachedPed = nil
local cachedPlayerId = nil
local cachedCoords = nil
local lastCacheUpdate = 0
local CACHE_DURATION = 100 -- Update cache every 100ms
-- @https://linktr.ee/thezyric

---@return table
function PlayerStatusThread.new()
    local self = setmetatable({
        isVehicleThreadRunning = false,
        source = {
            server_id = GetPlayerServerId(PlayerId()),
        },
    }, PlayerStatusThread)

    return self
end

-- What was this here for?
-- AddStateBagChangeHandler("stress", ("player:%s"):format(self.source.server_id), function(_, _, value)
--     stress = value
-- end)

function PlayerStatusThread:updateCache()
    local currentTime = GetGameTimer()
    if currentTime - lastCacheUpdate > CACHE_DURATION then
        cachedPed = PlayerPedId()
        cachedPlayerId = PlayerId()
        cachedCoords = GetEntityCoords(cachedPed)
        lastCacheUpdate = currentTime
    end
end

function PlayerStatusThread:getIsVehicleThreadRunning()
    return self.isVehicleThreadRunning
end

---@param value boolean
function PlayerStatusThread:setIsVehicleThreadRunning(value)
    logger.verbose("(PlayerStatusThread:setIsVehicleThreadRunning) Setting: ", value)
    self.isVehicleThreadRunning = value
end

function PlayerStatusThread:start(vehicleStatusThread, seatbeltLogic, framework)
    CreateThread(function()
        while true do
            self:updateCache()
            
            local ped = cachedPed
            local playerId = cachedPlayerId
            local coords = cachedCoords
            -- @https://linktr.ee/thezyric

            local x, y, z = coords.x, coords.y, coords.z
            local currentStreet = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))
            local zone = GetLabelText(GetNameOfZone(x, y, z))

            local camRot = GetGameplayCamRot(0)
            local heading = utility.round(360.0 - ((camRot.z + 360.0) % 360.0))
            local compass = " "

            if heading >= 315 or heading < 45 then
                compass = "N"
            elseif heading >= 45 and heading < 135 then
                compass = "E"
            elseif heading >= 135 and heading < 225 then
                compass = "S"
            elseif heading >= 225 and heading < 315 then
                compass = "W"
            end

            local voice = 0
            if LocalPlayer.state["proximity"] then
                local voiceModes = { Whisper = 15, Normal = 50, Shouting = 100 }
                voice = voiceModes[LocalPlayer.state["proximity"].mode] or 0
            end

            local pedArmor = GetPedArmour(ped)
            local pedMaxHealth = GetEntityMaxHealth(ped)
            local pedCurrentHealth = GetEntityHealth(ped)
            local pedHealthPercentage = math.floor(((pedCurrentHealth - 100) / (pedMaxHealth - 100)) * 100)
            pedHealthPercentage = math.max(0, math.min(100, pedHealthPercentage))
            local pedHunger = framework and framework:getPlayerHunger()
            local pedThirst = framework and framework:getPlayerThirst()
            local pedStress = framework and framework:getPlayerStress()
            local pedOxygen = math.floor(GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10)
			local pedStamina = math.floor(100 - GetPlayerSprintStaminaRemaining(PlayerId()))

            local isInVehicle = IsPedInAnyVehicle(ped, false)
            local isSeatbeltOn = config.useBuiltInSeatbeltLogic and seatbeltLogic.seatbeltState or sharedFunctions.isSeatbeltOn()

            if isInVehicle then
                if not self:getIsVehicleThreadRunning() and vehicleStatusThread then
                    vehicleStatusThread:start()
                    DisplayRadar(true)
                    logger.verbose("(playerStatus) (vehicleStatusThread) Vehicle status thread started.")
                else
                    DisplayRadar(true)
                end
            else
                DisplayRadar(_G.minimapVisible)
            end

            local player_data = {
                health = pedHealthPercentage,
                armor = pedArmor,
                hunger = pedHunger,
                thirst = pedThirst,
                stress = pedStress,
                oxygen = pedOxygen,
				stamina = pedStamina,
                streetLabel = currentStreet,
                areaLabel = zone,
                heading = compass,
                voice = voice,
                mic = NetworkIsPlayerTalking(playerId),
                isSeatbeltOn = isSeatbeltOn,
                isInVehicle = isInVehicle,
            }

            interface:message("state::global::set", {
                minimap = utility.calculateMinimapSizeAndPosition(),
                player = player_data,
            })

            Wait(500)
        end
    end)
end

return PlayerStatusThread
