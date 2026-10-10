--[[ ForeverDashboard 0.2: lazy, locally rendered modular hub. ]]
local name, addon = ...
addon.name = name
addon.version = "0.2.0"

--- Print a message in local chat only after a user command.
--- @param message string Local status message.
function addon.Print(message)
    print("|cff66ccffForever Dashboard|r: " .. tostring(message))
end
