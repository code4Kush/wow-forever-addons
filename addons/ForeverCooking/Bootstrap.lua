--[[ ForeverCooking v0.2: independent skill read and manual prep notes. ]]
local name, addon = ...
addon.name = name
addon.version = "0.2.0"

--- Write local chat only; never disclose ingredients to other players.
--- @param message string Local report.
function addon.Print(message)
    print("|cff66ccffForever Cooking|r: " .. tostring(message))
end
