--[[
    Forever Warrior: Bootstrap

    Provides one private namespace for this installable addon.
    The separately installed ForeverCore is the only cross-addon API.
]]

local addonName, addon = ...

addon.name = addonName
addon.version = "0.1.0"

--- Writes local, non-automating advice to the player's chat window.
--- @param message string|number Text to display.
function addon.Print(message)
    print("|cffd8ac63Forever Warrior|r: " .. tostring(message))
end
