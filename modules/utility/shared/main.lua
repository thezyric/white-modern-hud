local utility = {}
-- @https://linktr.ee/thezyric
local logger = require("modules.utility.shared.logger")
local config = require("config.shared")

-- Cache for minimap calculations
local minimapCache = nil
local lastMinimapUpdate = 0
local MINIMAP_CACHE_DURATION = 1000 -- Update minimap cache every 1 second
-- @https://linktr.ee/thezyric

---@param value number
---@return number
utility.convertRpmToPercentage = function(value)
    local percentage = math.ceil(value * 10000 - 2001) / 80
    return math.max(0, math.min(percentage, 100))
end

---@param num number
---@param numDecimalPlaces number?
---@return integer
utility.round = function(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num + 0.5 * mult)
end

utility.convertEngineHealthToPercentage = function(value)
    -- Engine health ranges from 1000 (perfect) to 0 (about to catch fire)
    -- Values below 0 are just shown as 0% since they're critically damaged
    local clampedValue = math.max(0, math.min(value, 1000))

    local percentage = (clampedValue / 1000) * 100

    percentage = math.floor(percentage + 0.5)

    return percentage
end

---@return {width: number, height: number, left: number, top: number}
utility.calculateMinimapSizeAndPosition = function()
    local currentTime = GetGameTimer()
    if minimapCache and currentTime - lastMinimapUpdate < MINIMAP_CACHE_DURATION then
        return minimapCache
    end
    
    SetBigmapActive(false, false)
    local minimap = {}
    local resX, resY = GetActiveScreenResolution()
    local aspectRatio = GetAspectRatio(false)
    -- @https://linktr.ee/thezyric

    SetScriptGfxAlign(string.byte("L"), string.byte("B"))
    
    local minimapRawX, minimapRawY
    if IsBigmapActive() then
        minimapRawX, minimapRawY = GetScriptGfxPosition(-0.00, 0.022 + -0.435416666)
        minimap.width = resX / (2.52 * aspectRatio)
        minimap.height = resY / 2.4374
    else
        minimapRawX, minimapRawY = GetScriptGfxPosition(0.000, 0.002 + -0.229888)
        minimap.width = resX / (3.48 * aspectRatio)
        minimap.height = resY / 5.55
    end

    ResetScriptGfxAlign()

    minimap.leftX = minimapRawX
    minimap.rightX = minimapRawX + minimap.width
    minimap.topY = minimapRawY
    minimap.bottomY = minimapRawY + minimap.height
    minimap.X = minimapRawX + (minimap.width / 2)
    minimap.Y = minimapRawY + (minimap.height / 2)

    minimap.webLeft = minimapRawX * resX
    minimap.webTop = minimapRawY * resY
    minimap.webWidth = (minimap.width / resX) * resX
    minimap.webHeight = (minimap.height / resY) * resY

    local result = {
        top = minimap.webTop,
        left = minimap.webLeft,
        height = minimap.webHeight,
        width = minimap.webWidth,
    }
    
    minimapCache = result
    lastMinimapUpdate = GetGameTimer()
    
    return result
end

--- Checks whether the specified framework is valid.
---@return boolean
utility.isFrameworkValid = function()
    local framework = config.framework and config.framework:lower()

    if not framework then
        logger.info("(utility:isFrameworkValid) No framework specified, defaulting to 'none'.")
        return false
    end

    local validFrameworks = {
        esx = true,
        qb = true,
        ox = true,
        custom = true,
    }

    logger.verbose("(utility:isFrameworkValid) Checking if framework is valid: ", validFrameworks[framework] ~= nil)
    return validFrameworks[framework] ~= nil
end

-- Prevents the bigmap from staying active after the minimap is closed, since sometimes the bigmap is still active and stuck on the screen
utility.preventBigmapFromStayingActive = function()
    local timeout = 0
    while true do
        logger.debug("(utility:preventBigmapFromStayingActive) Running, timeout: ", timeout)

        SetBigmapActive(false, false)

        if timeout >= 10000 then
            return
        end

        timeout = timeout + 1000
        Wait(2000)
    end
end

utility.setupMinimap = function()
    logger.info("(utility:setupMinimap) Setting up minimap.")
    local defaultAspectRatio = 1920 / 1080
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX / resolutionY
    local minimapOffset = 0

    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
    end

    RequestStreamedTextureDict("squaremap", false)

    while not HasStreamedTextureDictLoaded("squaremap") do
        Wait(200)
    end

    SetMinimapClipType(0)
    AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
    AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")

    SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
    SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.20)
    SetMinimapComponentPosition("minimap_blur", "L", "B", -0.01 + minimapOffset, 0.025, 0.262, 0.300)

    SetBlipAlpha(GetNorthRadarBlip(), 0)
    SetBigmapActive(true, false)
    SetMinimapClipType(0)
    CreateThread(utility.preventBigmapFromStayingActive)

    if not _G.minimapVisible then
        DisplayRadar(false)
    end
end

---@param coords vector3
---@return boolean
---@return table
utility.get2DCoordFrom3DCoord = function(coords)
    if not coords then
        return false, {}
    end
    local onScreen, x, y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z)
    return onScreen, { left = tostring(x * 100) .. "%", top = tostring(y * 100) .. "%" }
end

return utility
