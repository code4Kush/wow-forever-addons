--[[ ForeverInventory: standalone, character-agnostic Core registry entry.
    No automatic polling, unsolicited messages or protected actions.
]]
local _, addon = ...
local descriptor = {
    id = "inventory",
    displayName = "Forever Inventory",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "inventory.snapshot" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self) end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
