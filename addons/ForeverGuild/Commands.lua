--[[
    Forever Guild: explicitly initiated in-game commands.
    No slash command triggers unrequested or repeated network chatter.
]]
local _, addon = ...

--- Executes one player command and reports bounded session-only behavior.
--- @param message string|nil Text after /fguild.
local function Handle(message)
    local cmd = (message or ""):match("^%s*(.-)%s*$")
    if cmd == "version" then
        addon.Print("Version " .. addon.version .. " (opt-in only).")
        return
    end

    if cmd == "" or cmd == "help" then
        addon.Print("Commands: /fguild status | optin | optout | announce | peers")
        addon.Print("No data is shared automatically; consent is session only.")
        return
    end

    local record = ForeverCore.GetModuleStatus("guild")
    if not record or record.state ~= "active" then
        addon.Print("Module not active: "
            .. (record and record.state or "not registered") .. ".")
        return
    end

    if cmd == "status" then
        addon.Print("Sharing: " .. (addon.consent and "opted in" or "OFF")
            .. "; API " .. (addon.registered and "registered"
                or "unavailable") .. "; session only.")
    elseif cmd == "optin" then
        if not addon.RegisterPrefix() then
            addon.Print("Addon messaging unavailable; consent remains OFF.")
            return
        end
        addon.SetConsent(true)
        addon.Print("Opted in for this session. Nothing sent; use /fguild announce.")
    elseif cmd == "optout" then
        addon.SetConsent(false)
        addon.Print("Opted out. Session peer list cleared.")
    elseif cmd == "announce" then
        local ok, reason = addon.Announce()
        addon.Print(reason)
    elseif cmd == "peers" then
        local peers = addon.GetPeers()
        addon.Print(#peers .. " recent compatible announcer(s).")
        for _, name in ipairs(peers) do
            addon.Print("- " .. name .. " (unverified guild peer)")
        end
    else
        addon.Print("Usage: /fguild [status|optin|optout|announce|peers]")
    end
end
SLASH_FOREVERGUILD1 = "/fguild"
SlashCmdList.FOREVERGUILD = Handle
