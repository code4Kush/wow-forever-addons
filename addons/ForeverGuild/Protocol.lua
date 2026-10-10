--[[
    Forever Guild: Minimal Opt-In Discovery Protocol v1.

    No automatic guild broadcasts, character stats or profile exchange.
    Payload is exactly "HELLO|0.1.0" (a protocol/version marker).
    Only a player's explicit /fguild announce sends ONE GUILD message;
    at most one every 30 seconds. Incoming messages are untrusted input:
    validate prefix, channel, body and sender before displaying.
    Peer list is session-only, bounded and expires after five minutes.
]]

local _, addon = ...

addon.PREFIX = "FVRGUILD1"
addon.consent = false
addon.registered = false
addon.lastAnnouncement = nil
addon.peers = {}

local function Now()
    return type(GetTime) == "function" and GetTime() or nil
end

--- Registers the limited message namespace; does NOT share any data.
--- @return boolean success Whether the client accepted the prefix.
function addon.RegisterPrefix()
    if addon.registered then return true end
    if type(C_ChatInfo) ~= "table"
        or type(C_ChatInfo.RegisterAddonMessagePrefix) ~= "function" then
        return false
    end
    local ok, code = pcall(C_ChatInfo.RegisterAddonMessagePrefix, addon.PREFIX)
    -- 0=success, 1=already registered. Other values are not confirmed.
    if ok and (code == 0 or code == 1 or code == true) then
        addon.registered = true
    end
    return addon.registered
end

--- Changes in-memory consent without persistently sharing player data.
--- @param enabled boolean Explicit player choice.
function addon.SetConsent(enabled)
    addon.consent = enabled == true
    if not addon.consent then
        addon.peers = {}
        addon.lastAnnouncement = nil
    end
end

--- Sends one manually requested version probe over GUILD, never automatically.
--- @return boolean success Whether the client accepted the send request.
--- @return string reason Player-safe diagnostic; delivery is NOT confirmed.
function addon.Announce()
    if not addon.consent then
        return false, "Opt in first: /fguild optin"
    end
    if not addon.RegisterPrefix() then
        return false, "Addon messaging API unavailable."
    end
    if type(IsInGuild) ~= "function" then
        return false, "Guild membership API unavailable."
    end
    local inGuildOk, inGuild = pcall(IsInGuild)
    if not inGuildOk or inGuild ~= true then
        return false, "Not in a guild or guild state unavailable."
    end
    local now = Now()
    if not now then
        return false, "Game clock unavailable; cannot safely throttle."
    end
    if addon.lastAnnouncement and now - addon.lastAnnouncement < 30 then
        return false, "Rate limited: wait 30 seconds between announcements."
    end
    if type(C_ChatInfo.SendAddonMessage) ~= "function" then
        return false, "Addon send API unavailable."
    end
    local ok, code = pcall(
        C_ChatInfo.SendAddonMessage, addon.PREFIX, "HELLO|0.1.0", "GUILD"
    )
    if not ok or (code ~= 0 and code ~= true) then
        return false, "Game client did not accept the send request."
    end
    addon.lastAnnouncement = now
    return true, "Announcement requested; delivery not confirmed."
end

--- Accepts only a short, fixed, well-formed guild hello after consent.
--- @param prefix string Transport prefix.
--- @param payload string Fixed protocol body.
--- @param channel string Must be GUILD.
--- @param sender string Transport-supplied player name (not authorization).
function addon.Receive(prefix, payload, channel, sender)
    if not addon.consent or prefix ~= addon.PREFIX
        or channel ~= "GUILD" or payload ~= "HELLO|0.1.0"
        or type(sender) ~= "string" or #sender < 1 or #sender > 100
        or sender:find("[%c|]") then
        return
    end
    local now = Now()
    if not now then return end
    local count = 0
    for _ in pairs(addon.peers) do count = count + 1 end
    if count >= 20 and addon.peers[sender] == nil then
        return
    end
    addon.peers[sender] = now
end

--- Lists current consenting senders; stale records expire after 300 secs.
--- @return table names Sorted peer names, bounded by 20.
function addon.GetPeers()
    local now = Now()
    local results = {}
    if not addon.consent or not now then return results end
    for sender, lastSeen in pairs(addon.peers) do
        if now - lastSeen > 300 or now - lastSeen < 0 then
            addon.peers[sender] = nil
        else
            results[#results + 1] = sender
        end
    end
    table.sort(results)
    return results
end
