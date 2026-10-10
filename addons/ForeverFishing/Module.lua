--[[ ForeverFishing: standalone, character-agnostic Core registry entry.
    No automatic polling, unsolicited messages or protected actions.
]]
local _, addon = ...
local descriptor = {
    id = "fishing",
    displayName = "Forever Fishing",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "fishing.skill" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self) end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
