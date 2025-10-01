-- @https://linktr.ee/thezyric
local interface = require("modules.interface.client")
local utility = require("modules.utility.shared.main")
local logger = require("modules.utility.shared.logger")
local functions = require("config.functions")
local config = require("config.shared")
-- @https://linktr.ee/thezyric

local VehicleStatusThread = {}
VehicleStatusThread.__index = VehicleStatusThread

-- Cache variables for better performance
local cachedVehicle = nil
local cachedVehicleType = nil
local lastVehicleCacheUpdate = 0
local VEHICLE_CACHE_DURATION = 50 -- Update vehicle cache every 50ms
-- @https://linktr.ee/thezyric

function VehicleStatusThread:updateVehicleCache()
    local currentTime = GetGameTimer()
    if currentTime - lastVehicleCacheUpdate > VEHICLE_CACHE_DURATION then
        cachedVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        cachedVehicleType = cachedVehicle ~= 0 and GetVehicleType(cachedVehicle) or nil
        lastVehicleCacheUpdate = currentTime
    end
end

function VehicleStatusThread.new(playerStatus, seatbeltLogic)
    local self = setmetatable({}, VehicleStatusThread)
    self.playerStatus = playerStatus
    self.seatbelt = seatbeltLogic

    SetHudComponentPosition(6, 999999.0, 999999.0) -- VEHICLE NAME
    SetHudComponentPosition(7, 999999.0, 999999.0) -- AREA NAME
    SetHudComponentPosition(8, 999999.0, 999999.0) -- VEHICLE CLASS
    SetHudComponentPosition(9, 999999.0, 999999.0) -- STREET NAME

    return self
end

function GetNosLevel(veh)
    local noslevelraw = functions.getNosLevel(veh)
    local noslevel

    if noslevelraw == nil then
        noslevel = 0
    else
        noslevel = math.floor(noslevelraw)
    end

    return noslevel
end

function VehicleStatusThread:start()
    CreateThread(function()
        local ped = PlayerPedId()
        local playerStatusThread = self.playerStatus
        local convertRpmToPercentage = utility.convertRpmToPercentage
        local convertEngineHealthToPercentage = utility.convertEngineHealthToPercentage

        playerStatusThread:setIsVehicleThreadRunning(true)

        while IsPedInAnyVehicle(ped, false) do
            self:updateVehicleCache()
            
            local vehicle = cachedVehicle
            local vehicleType = cachedVehicleType
            -- @https://linktr.ee/thezyric
            local engineHealth = convertEngineHealthToPercentage(GetVehicleEngineHealth(vehicle))
            local noslevel = GetNosLevel(vehicle)
            local rawFuelValue = functions.getVehicleFuel(vehicle)
            local fuelValue = math.max(0, math.min(rawFuelValue or 0, 100))
            local engineState = GetIsVehicleEngineRunning(vehicle)
            local fuel = math.floor(fuelValue)
            local highGear = GetVehicleHighGear(vehicle)
            local currentGear = GetVehicleDashboardCurrentGear()
            local newGears = highGear
            local _, lightsOn, highbeamsOn = GetVehicleLightsState(vehicle)

            -- Fix for vehicles that only have 1 gear
            if highGear == 1 then
                newGears = 0
            end

            -- Display vehicle gear
            local gearString = "N"
            if not engineState then
                gearString = ""
            elseif currentGear == 0 and GetEntitySpeed(vehicle) > 0 then
                gearString = "R"
            elseif currentGear == 1 and GetEntitySpeed(vehicle) < 0.1 and engineState then
                gearString = "N"
            elseif currentGear == 1 then
                gearString = "1"
            elseif currentGear > 1 then
                gearString = tostring(math.floor(currentGear))
            end
            -- Fix for vehicles that only have 1 gear
            if highGear == 1 then
                gearString = ""
            end

            -- Handle MPH and KMH
            local speed
            if config.speedUnit:lower() == "kmh" then
                speed = math.floor(GetEntitySpeed(vehicle) * 3.6)
            elseif config.speedUnit:lower() == "mph" then
                speed = math.floor(GetEntitySpeed(vehicle) * 2.236936)
            else
                logger.error("Invalid speed unit in config. Expected 'kmh' or 'mph', but got:", config.speedUnit)
            end

            local rpm = vehicleType == 8 and math.min(speed / 150, 1) * 100 or convertRpmToPercentage(GetVehicleCurrentRpm(vehicle))

            local headlights = (lightsOn and highbeamsOn) and 100 or (lightsOn or highbeamsOn) and 50 or 0

            interface:message("state::vehicle::set", {
                speedUnit = config.speedUnit,
                speed = speed,
                rpm = rpm,
                engineHealth = engineHealth,
                engineState = engineState,
                gears = newGears,
                currentGear = gearString,
                fuel = fuel,
                nos = noslevel,
                headlights = headlights
            })

            Wait(150)
        end

        if self.seatbelt then
            logger.verbose("(vehicleStatusThread) seatbelt found, toggling to false")
            self.seatbelt:toggle(false)
        end

        playerStatusThread:setIsVehicleThreadRunning(false)
        logger.verbose("(vehicleStatusThread) Vehicle status thread ended.")
    end)
end

return VehicleStatusThread
