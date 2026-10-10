--[[
    ForeverCooking v0.2: independent on-demand skills and manual prep.
    Core retains enable/disable; no subscribed events or saved state.
]]
local _, addon = ...
local descriptor = {
    id = "cooking",
    displayName = "Forever Cooking",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = {"cooking.skill", "cooking.manual-ingredients"},
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        if addon.ClearNeeds then addon.ClearNeeds() end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then addon.Print("Registration failed: " .. tostring(reason)) end
