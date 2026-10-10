--[[
    ForeverFishing 0.3: on-demand list/window skill read and manual catches.
    No optional pack dependencies, timers, network or auto-fishing.
]]
local name, addon = ...
addon.name = name
addon.version = "0.3.0"

--- Print local chat only after user command.
--- @param message string Status or manual catch note.
function addon.Print(message)
    print("|cff66ccffForever Fishing|r: " .. tostring(message))
end
