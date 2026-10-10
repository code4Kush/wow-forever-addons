--[[
    ForeverFishing 0.2: local-only namespace and chat helper.
    All catch quantities are PLAYER ENTERED, not verified by game APIs.
]]
local name, addon = ...
addon.name = name
addon.version = "0.2.0"

--- Prints locally only, never sends to guild, party or other players.
--- @param message string Human-readable diagnostic.
function addon.Print(message)
    print("|cff66ccffForever Fishing|r: " .. tostring(message))
end
