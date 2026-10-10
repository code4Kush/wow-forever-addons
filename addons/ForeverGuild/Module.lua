--[[
    Forever Guild: optional Core feature pack.

    Even if loaded and enabled as an addon, no guild data is sent until
    explicit /fguild optin AND /fguild announce. Disabling the module
    through Core clears consent and peer state. Guild sender labels from
    CHAT_MSG_ADDON are informational, never an authorization mechanism.
]]
local _, addon = ...
local descriptor = {
    id = "guild",
    displayName = "Forever Guild",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "guild.manual-discovery" },
    events = { "CHAT_MSG_ADDON" },

    Initialize = function(self, character) end,
    Enable = function(self, character)
        -- Register prefix to receive opt-in peers; no outbound traffic.
        addon.RegisterPrefix()
    end,
    Disable = function(self)
        addon.SetConsent(false)
    end,
    OnEvent = function(self, eventName, prefix, payload, channel, sender)
        if eventName == "CHAT_MSG_ADDON" then
            addon.Receive(prefix, payload, channel, sender)
        end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
