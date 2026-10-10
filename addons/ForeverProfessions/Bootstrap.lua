--[[
    ForeverProfessions 0.2: standalone, local-only module namespace.
    No saved variables, automatic profiling, or external communication.
]]
local name, addon = ...
addon.name = name
addon.version = "0.2.0"

--- Displays one user-requested, local status message.
--- @param message string Human-readable, safely formatted status.
function addon.Print(message)
    print("|cff66ccffForever Professions|r: " .. tostring(message))
end
