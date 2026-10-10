--[[ ForeverGold: independent, read-only client addon namespace. ]]
local name, addon = ...
addon.name = name
addon.version = "0.2.0"
function addon.Print(message)
    print("|cff66ccffForever Gold|r: " .. tostring(message))
end
