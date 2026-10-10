--[[
    Forever Journal: Bootstrap
    Establishes the shared addon namespace and chat output helper.
    The TOC loads this file before other modules.
]]

local addonName, addon = ...

addon.name = addonName
addon.version = "0.2.0"

--- Prints a readable, consistently prefixed addon message.
---
--- @param message string|number Text or numeric value to display.
function addon.Print(message)
    print("|cff66ccffForever Journal|r: " .. tostring(message))
end
