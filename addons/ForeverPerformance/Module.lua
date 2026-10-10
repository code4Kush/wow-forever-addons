--[[
    Forever Performance: Independent ForeverCore Lifecycle

    Register only metadata and callbacks. Absolutely no memory sampling or
    automatic reporting happens on login, enable, or game events.
]]
local _, addon = ...
local descriptor = {
    id = "performance",
    displayName = "Forever Performance",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "performance.memory" },
    events = {},

    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        -- Even a session-only baseline should not outlive the enabled pack.
        addon.baseline = nil
    end,
}

local accepted, reason = ForeverCore.RegisterModule(descriptor)
if not accepted then
    addon.Print("Registration failed: " .. tostring(reason))
end
