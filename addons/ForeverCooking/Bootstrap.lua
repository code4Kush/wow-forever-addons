--[[ ForeverCooking: isolated addon namespace and chat output.
    Loaded first by TOC; no global exports besides WoW slash registrations.
]]
local name, addon = ...
addon.name = name
addon.version = "0.1.0"
function addon.Print(message)
    print("|cff66ccffForever Cooking|r: " .. tostring(message))
end
