-- @https://linktr.ee/thezyric
local logger = require("modules.utility.shared.logger")

if not _G.interface then
    logger.info("(modules/interface) _G.interface not found, creating first global instance")
    -- @https://linktr.ee/thezyric

    local interface = {
        store = {
            status = {
                app = {
                    loaded = false,
                },
            },
            visibility = {
                app = false,
            },
            callbacks = {},
        },
    }

    interface.__index = interface

    function interface.new()
        local self = setmetatable({}, interface)

        self:registerInitialCallbacks()

        return self
    end

    ---@param action string The action you wish to target
    ---@param data any The data you wish to send along with this action
    function interface:message(action, data)
        assert(action, "(interface:message) `action` parameter is nil.")

        -- Throttle NUI messages to prevent spam
        local currentTime = GetGameTimer()
        if not self.lastMessageTime then self.lastMessageTime = 0 end
        
        if currentTime - self.lastMessageTime > 16 then -- ~60fps limit
            SendNUIMessage({ action = action, data = data })
            self.lastMessageTime = currentTime
        end
        -- @https://linktr.ee/thezyric
    end

    ---@param state? boolean
    function interface:toggle(state, affectInputFocus)
        local newState = not self.store.visibility.app

        if type(state) == "boolean" then
            newState = state
        end

        print("^2Zyric Development - HUD - Success^0")

        self:message("state::visibility::app::set", newState)
    end

    function interface:registerInitialCallbacks()
        self:on("state::visibility::app::sync", function(state, cb)
            self.store.visibility.app = state
            cb(true)
        end)

        self:on("APP_LOADED", function(_, cb)
            self.store.status.app.loaded = true
            local config = require("config.shared")
            cb(config)
            self:toggle(false) -- Hide HUD by default
        end)
    end

    ---@param event string
    ---@param callback function
    ---@return number? The index of the callback, or nil if failed
    function interface:on(event, callback)
        assert(event, "[Interface] [On] `event` parameter is nil.")
        assert(callback, "[Interface] [On] `callback` parameter is nil.")

        logger.info("[Interface] [On] Registering: ", event)

        if self.store.callbacks[event] then
            goto continue
        end

        self.store.callbacks[event] = {}

        RegisterNuiCallback(event, function(data, cb)
            logger.debug("[Interface] [On] Received callback for event: ", event, " data: ", data)

            for i = 1, #self.store.callbacks[event] do
                if not self.store.callbacks[event][i] then
                    return logger.verbose("[Interface] [Callback] Event:", event, "Handler with index:", i, " is nil.")
                end

                local success, result = pcall(self.store.callbacks[event][i], data, cb)

                if not success then
                    logger.error("[Interface] [On] Callback failed with error:", result, "handler:", self.store.callbacks[event][i])
                end
            end
        end)

        ::continue::

        local newIndex = #self.store.callbacks[event] + 1

        self.store.callbacks[event][newIndex] = callback

        return newIndex
    end

    ---@param event string
    ---@param callbackIndex number
    function interface:removeCallback(event, callbackIndex)
        assert(event, "[Interface] [RemoveCallback] `event` parameter is nil.")
        assert(callbackIndex, "[Interface] [RemoveCallback] `callback` parameter is nil.")
        assert(self.store.callbacks[event], "[Interface] [RemoveCallback] Event not found, event: " .. event)
        assert(self.store.callbacks[event][callbackIndex], "[Interface] [RemoveCallback] Callback not found, event: " .. event .. " callbackIndex: " .. callbackIndex)

        self.store.callbacks[event][callbackIndex] = nil
    end

    _G.interface = interface.new()
end

return _G.interface
