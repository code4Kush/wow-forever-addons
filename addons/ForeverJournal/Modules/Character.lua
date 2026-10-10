--[[
    Forever Journal: Character

    Reads the currently logged-in character's display information.
    Nothing is stored, and no player name, race, or class is hardcoded.
]]

local _, addon = ...

addon.Character = {}
local Character = addon.Character

--- Returns information supplied by the game for the local character.
---
--- API values may be unavailable before the character finishes loading.
--- The user-facing function supplies sensible fallback labels.
---
--- @return table identity Name, localized race/class, level and realm.
function Character.GetIdentity()
    local name = type(UnitName) == "function" and UnitName("player") or nil
    local className = type(UnitClass) == "function" and UnitClass("player") or nil
    local raceName = type(UnitRace) == "function" and UnitRace("player") or nil
    local level = type(UnitLevel) == "function" and UnitLevel("player") or nil
    local realmName = type(GetRealmName) == "function" and GetRealmName() or nil

    return {
        name = type(name) == "string" and name ~= "" and name or "Unknown character",
        class = type(className) == "string" and className ~= ""
            and className or "Unknown class",
        race = type(raceName) == "string" and raceName ~= ""
            and raceName or "Unknown race",
        level = type(level) == "number" and tostring(level) or "?",
        realm = type(realmName) == "string" and realmName ~= ""
            and realmName or nil,
    }
end
