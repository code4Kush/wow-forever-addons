--[[ Forever Professions: read-only list from available game skill APIs.
    May not be accessible on all Forever beta builds. Does not craft.
]]
local _, addon = ...

function addon.Render()
    if type(InCombatLockdown) == "function" and InCombatLockdown() then
        addon.Print("Profession readout unavailable during combat.")
        return
    end
    if type(GetProfessions) ~= "function"
        or type(GetProfessionInfo) ~= "function" then
        addon.Print("Profession API unavailable on this build.")
        return
    end
    local ok, records = pcall(function()
        local slots = { GetProfessions() }
        local results = {}
        for _, id in ipairs(slots) do
            if type(id) == "number" then
                local name, _, rank, maxRank = GetProfessionInfo(id)
                if type(name) == "string" and type(rank) == "number"
                    and type(maxRank) == "number" then
                    results[#results + 1] = string.format(
                        "%s %d/%d", name, rank, maxRank)
                end
            end
        end
        return results
    end)
    if not ok then
        addon.Print("Profession details unavailable.")
        return
    end
    if #records == 0 then
        addon.Print("No readable trained professions returned by the client.")
        return
    end
    addon.Print("Known professions: " .. table.concat(records, "; "))
end
