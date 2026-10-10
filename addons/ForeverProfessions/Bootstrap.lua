--[[
    ForeverProfessions 0.3: isolated local-only namespace.
    No persistent settings, unsolicited reports or external sharing.
]]
local name, addon = ...
addon.name = name
addon.version = "0.3.0"

--- Displays one local message for a user-invoked action.
--- @param message string Human-readable summary.
function addon.Print(message)
    print("|cff66ccffForever Professions|r: " .. tostring(message))
end
