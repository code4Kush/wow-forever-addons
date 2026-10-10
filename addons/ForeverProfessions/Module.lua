--[[
    ForeverProfessions: independent Core descriptor and bounded lifecycle.
    Core logical disabling discards session-only skill snapshots.
]]
local _, addon = ...
local descriptor = {
    id = "professions",
    displayName = "Forever Professions",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "professions.read", "professions.session-progress" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        if addon.ClearSnapshot then
            addon.ClearSnapshot()
        end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
