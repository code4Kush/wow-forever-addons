--[[ Forever Guild: isolated session-only, no automatic data sharing. ]]
local name, addon = ...
addon.name = name
addon.version = "0.1.0"
function addon.Print(message)
    print("|cff66ccffForever Guild|r: " .. tostring(message))
end
