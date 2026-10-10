--[[ ForeverCooking: standalone, character-agnostic Core registry entry.
    No automatic polling, unsolicited messages or protected actions.
]]
local _, addon = ...
local descriptor = {
    id = "cooking",
    displayName = "Forever Cooking",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "cooking.skill" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self) end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
