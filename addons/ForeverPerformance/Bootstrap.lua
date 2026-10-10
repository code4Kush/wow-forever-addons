--[[
    Forever Performance: Bootstrap

    The namespace is local to this optional WoW addon. No timers, saved
    variables, third-party analytics, or automatic measurement are started.
]]
local addonName, addon = ...
addon.name = addonName
addon.version = "0.2.0"
addon.baseline = nil

--- Writes one locally visible diagnostic line.
--- @param message string|number Human-readable status or metric.
function addon.Print(message)
    print("|cff66ccffForever Performance|r: " .. tostring(message))
end
