--[[
    Forever Core: Per-Character Profile (EXPERIMENTAL)

    WoW loads ForeverCharacterDB before our Lua files according to the TOC.
    Persistent SavedVariables on Forever beta are NOT validated until a
    full client quit and restart confirms the same manual test marker.
    This file never sends player identity or preferences over the network.
]]

local _, core = ...

local SCHEMA_VERSION = 1
local profile
local failureReason

--- Initializes the per-character SavedVariables table after PLAYER_LOGIN.
--- @return boolean writable Whether the schema can be safely modified.
function core.OpenCharacterProfile()
    local current = _G.ForeverCharacterDB

    if current == nil then
        current = { schemaVersion = SCHEMA_VERSION, modules = {} }
        _G.ForeverCharacterDB = current
    end

    if type(current) ~= "table" then
        profile = nil
        failureReason = "invalid saved data; profile is read-only"
        return false
    end

    if current.schemaVersion ~= SCHEMA_VERSION then
        -- Unknown schema versions must never be silently overwritten.
        profile = nil
        failureReason = "unsupported profile schema; no changes saved"
        return false
    end

    if type(current.modules) ~= "table" then
        profile = nil
        failureReason = "invalid module preferences; no changes saved"
        return false
    end

    profile = current
    failureReason = nil
    return true
end

--- Reads a preference; nil means the feature pack's default (enabled).
--- @param moduleId string Registered module identifier.
--- @return boolean|nil setting true/false if saved; nil if unset.
function core.GetProfilePreference(moduleId)
    if profile then
        local value = profile.modules[moduleId]
        if type(value) == "boolean" then
            return value
        end
    end
    return nil
end

--- Writes one preference for this character only, without transmitting data.
--- The game client may fail to restore it across a cold restart in beta.
--- @param moduleId string Registered module identifier.
--- @param enabled boolean Player-selected preference.
--- @return boolean success Whether it was saved in this game session.
--- @return string|nil errorMessage Why writing was blocked.
function core.WriteProfilePreference(moduleId, enabled)
    if not profile then
        return false, failureReason or "profile not initialized"
    end

    if type(moduleId) ~= "string" or type(enabled) ~= "boolean" then
        return false, "invalid preference"
    end

    profile.modules[moduleId] = enabled
    return true
end

--- Returns a limited, nonidentifying status for on-demand diagnostics.
--- @return table info schema, data availability, saved preference count.
function core.GetProfileInfo()
    local count = 0
    if profile then
        for _, value in pairs(profile.modules) do
            if type(value) == "boolean" then
                count = count + 1
            end
        end
    end

    return {
        writable = profile ~= nil,
        reason = failureReason,
        schemaVersion = SCHEMA_VERSION,
        preferenceCount = count,
        marker = profile and profile.testMarker or nil,
    }
end

--- Stores a harmless marker to test reload and full-restart persistence.
--- @param marker string An alphanumeric/hyphen marker, max 32 bytes.
--- @return boolean success
--- @return string|nil errorMessage
function core.SetProfileMarker(marker)
    if not profile then
        return false, failureReason or "profile unavailable"
    end
    if type(marker) ~= "string" or #marker > 32
        or not marker:match("^[%w%-]+$") then
        return false, "marker must be 1-32 letters, digits or hyphens"
    end

    profile.testMarker = marker
    return true
end
