-- @https://linktr.ee/thezyric
if not IsDuplicityVersion() then
    local config = require("config.shared")
    local playerStatusClass = require("modules.threads.client.player_status")
    local vehicleStatusClass = require("modules.threads.client.vehicle_status")
    local seatbeltLogicClass = require("modules.seatbelt.client")
    local utility = require("modules.utility.shared.main")
    local logger = require("modules.utility.shared.logger")
    local interface = require("modules.interface.client")
    -- @https://linktr.ee/thezyric

    local seatbeltLogic = seatbeltLogicClass.new()
    local playerStatusThread = playerStatusClass.new()
    local vehicleStatusThread = vehicleStatusClass.new(playerStatusThread, seatbeltLogic)
    local framework = utility.isFrameworkValid() and require("modules.frameworks." .. config.framework:lower()).new() or false

    playerStatusThread:start(vehicleStatusThread, seatbeltLogic, framework)
    -- @https://linktr.ee/thezyric

    _G.minimapVisible = config.minimapAlways

    exports("toggleHud", function(state)
        interface:toggle(state or nil)
        DisplayRadar(state)
        logger.info("(exports:toggleHud) Toggled HUD to state: ", state)
    end)

    local function toggleMap(state)
        _G.minimapVisible = state
        DisplayRadar(state)
        logger.info("(toggleMap) Toggled map to state: ", state)
    end

    exports("toggleMap", toggleMap)

    RegisterCommand("togglehud", function()
        interface:toggle()
    end, false)

    -- Toggle HUD when pause menu is active
    local isPauseMenuOpen = false
    local lastPauseCheck = 0
    CreateThread(function()
        while true do
            local currentTime = GetGameTimer()
            -- Only check pause menu every 250ms instead of every frame
            if currentTime - lastPauseCheck > 250 then
                local currentPauseMenuState = IsPauseMenuActive()

                if currentPauseMenuState ~= isPauseMenuOpen then
                    isPauseMenuOpen = currentPauseMenuState

                    if isPauseMenuOpen then
                        interface:toggle(false)
                    else
                        interface:toggle(true)
                    end
                end
                lastPauseCheck = currentTime
            end
            Wait(isPauseMenuOpen and 500 or 1000)
        end
    end)

    interface:on("APP_LOADED", function(_, cb)
        local data = {
            config = config,
            minimap = utility.calculateMinimapSizeAndPosition(),
        }

        cb(data)

        CreateThread(utility.setupMinimap)
        toggleMap(config.minimapAlways)
    end)

    return
end

local sv_utils = require("modules.utility.server.main")

CreateThread(function()
    if not sv_utils.isInterfaceCompiled() then
        print("^1UI not compiled, either compile the UI or download a compiled version here: ^0@https://github.com/thezyric")
    end

    sv_utils.versionCheck("thezyric/white-modern-hud")
    -- @https://linktr.ee/thezyric
    
    -- Zyric Development - HUD - Başarılı
    print("^2Zyric Development - HUD - Başarılı^0")
    print("^2Zyric Development - HUD - Başarılı^0")
    print("^2Zyric Development - HUD - Başarılı^0")
end)
