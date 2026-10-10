--[[
    Forever Core: Character

    Read-only identity snapshot populated after PLAYER_LOGIN.
    Never infer a character from addon settings or a hardcoded player name.
]]

local _, core = ...

--- Returns a snapshot of the currently logged-in character.
--- @return table character Name, realm, class/race tokens, level and GUID.
function core.ReadCharacter()
    local name = type(UnitName) == "function" and UnitName("player") or nil
    local className, classToken
    local raceName, raceToken

    if type(UnitClass) == "function" then
        className, classToken = UnitClass("player")
    end

    if type(UnitRace) == "function" then
        raceName, raceToken = UnitRace("player")
    end

    local level = type(UnitLevel) == "function" and UnitLevel("player") or nil
    local realm = type(GetRealmName) == "function" and GetRealmName() or nil
    local guid = type(UnitGUID) == "function" and UnitGUID("player") or nil

    return {
        name = type(name) == "string" and name ~= "" and name or "Unknown",
        realm = type(realm) == "string" and realm ~= "" and realm or nil,
        className = type(className) == "string" and className ~= ""
            and className or "Unknown",
        classToken = type(classToken) == "string" and classToken or nil,
        raceName = type(raceName) == "string" and raceName ~= ""
            and raceName or "Unknown",
        raceToken = type(raceToken) == "string" and raceToken or nil,
        level = type(level) == "number" and level or nil,
        guid = type(guid) == "string" and guid or nil,
    }
end
