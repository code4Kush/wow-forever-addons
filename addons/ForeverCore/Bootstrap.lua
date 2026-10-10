--[[
    Forever Core: Bootstrap

    A small, intentionally public namespace for separate WoW addon packages.
    Other packs may use ForeverCore.RegisterModule after their Dependencies
    metadata has caused Core to load. No game actions occur here.
]]

local addonName, addon = ...
local API_VERSION = "0.2.0"

-- Export only one documented global for cross-addon integration.
_G.ForeverCore = addon

addon.name = addonName
addon.version = API_VERSION

--- Writes a single readable line to the local chat window.
--- @param message string|number Human-readable local diagnostic.
function addon.Print(message)
    print("|cff66ccffForever Core|r: " .. tostring(message))
end
