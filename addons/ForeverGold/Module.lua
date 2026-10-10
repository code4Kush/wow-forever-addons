--[[
    Forever Gold: independent module descriptor for Core 0.2+.
    Only on-demand read commands; disabling clears session memory.
]]
local _, addon = ...
local descriptor = {
    id = "gold",
    displayName = "Forever Gold",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "gold.wallet", "gold.session-delta" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        if addon.ClearBaseline then
            addon.ClearBaseline()
        end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
