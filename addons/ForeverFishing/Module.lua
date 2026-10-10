--[[
    ForeverFishing: Core 0.2 module with session-only state cleanup.
    No periodic work, registered game events or external communications.
]]
local _, addon = ...
local descriptor = {
    id = "fishing",
    displayName = "Forever Fishing",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "fishing.skill", "fishing.manual-catches" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        if addon.ClearCatches then
            addon.ClearCatches()
        end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
