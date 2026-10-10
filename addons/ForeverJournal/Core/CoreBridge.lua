--[[
    Forever Journal v0.5: independent Core pack descriptor.

    Preserves v0.4's read-only quest semantics, six-row pagination and
    validated Tauren starter catalog. Eligibility applies to the catalog,
    not the whole Journal pack. Core controls session/profile enablement.
]]
local _, addon = ...
local descriptor = {
    id = "journal",
    displayName = "Forever Journal",
    version = addon.version,
    minCoreVersion = "0.2.0",
    capabilities = { "journal.quests", "journal.history", "journal.catalog" },
    events = {},
    Initialize = function(self, character) end,
    Enable = function(self, character) end,
    Disable = function(self) end,
}
if type(ForeverCore) ~= "table"
    or type(ForeverCore.RegisterModule) ~= "function" then
    addon.Print("ForeverCore 0.2.0+ is required.")
else
    local ok, reason = ForeverCore.RegisterModule(descriptor)
    if not ok then
        addon.Print("Core registration failed: " .. tostring(reason))
    end
end
