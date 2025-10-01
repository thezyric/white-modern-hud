-- @https://linktr.ee/thezyric
return {
    framework = "qb", -- Framework for player stats: "none", "esx", "qb", "ox", "custom".
    speedUnit = "kmh", -- Speed unit: "mph" or "kmh".
    -- @https://linktr.ee/thezyric

    useBuiltInSeatbeltLogic = true, -- Enable custom seatbelt logic (true/false).
    ejectMinSpeed = 20.0, -- Using built-in seatbelt logic: Minimum speed to eject when not wearing a seatbelt (in speedUnit).

    minimapAlways = false, -- Always show minimap (true) or only in vehicles (false).
    compassAlways = false, -- Always show compass (true) or only in vehicles (false).
    compassLocation = "hidden", -- Compass position: "top", "bottom", "hidden".

    useSkewedStyle = false, -- Enable skewed style for HUD (true/false).
    skewAmount = 15, -- Amount of skew to apply (recommended 10-20).
}