--[[
    ForeverProfessions: independent Core 0.2 lifecycle and capabilities.
    Session skill snapshots and goals are cleared on logical disable.
]]
local _, addon = ...
local descriptor = {
    id = "professions",
    displayName = "Forever Professions",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = {
        "professions.read",
        "professions.session-progress",
        "professions.session-goals",
    },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self)
        if addon.ClearSnapshot then
            addon.ClearSnapshot()
        end
        if addon.ClearGoals then
            addon.ClearGoals()
        end
    end,
}
local ok, reason = ForeverCore.RegisterModule(descriptor)
if not ok then
    addon.Print("Registration failed: " .. tostring(reason))
end
