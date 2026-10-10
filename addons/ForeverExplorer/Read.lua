--[[ Forever Explorer: current UI map ID, NOT exploration completion.
    C_Map.GetBestMapForUnit returns the lowest current map; it may not be
    the parent zone. No waypoint automation or map manipulation.
]]
local _, addon = ...
function addon.Render()
    if type(C_Map) ~= "table"
        or type(C_Map.GetBestMapForUnit) ~= "function"
        or type(C_Map.GetMapInfo) ~= "function" then
        addon.Print("Map API unavailable on this build.")
        return
    end
    local success, mapId, mapName = pcall(function()
        local id = C_Map.GetBestMapForUnit("player")
        if type(id) ~= "number" then
            return nil, nil
        end
        local info = C_Map.GetMapInfo(id)
        return id, type(info) == "table" and info.name or nil
    end)
    if not success or not mapId then
        addon.Print("Current UI map unavailable.")
        return
    end
    addon.Print(string.format("Current UI map: %s (ID %d); NOT exploration credit.",
        type(mapName) == "string" and mapName or "<unnamed>", mapId))
end
