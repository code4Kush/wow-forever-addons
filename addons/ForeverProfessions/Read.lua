--[[
    ForeverProfessions: bounded, read-only API adapter.

    GetProfessions has up to five returned positions. Empty primary slots
    may precede secondary skills, so never use ipairs on that result.
    Returned IDs are client-specific slots, not persistent stable IDs;
    comparisons use the profession's returned display name in one session.

    API availability/semantics still require an in-game test on Forever
    build 70338. An empty readout does not prove a skill is untrained.
]]
local _, addon = ...
local MAX_SLOTS = 5
local MAX_SKILL_LEVEL = 100000

local function ReadClientSkills()
    local slots = { GetProfessions() }
    local results = {}
    local seen = {}

    for index = 1, MAX_SLOTS do
        local slot = slots[index]
        if slot ~= nil then
            if type(slot) ~= "number"
                or slot ~= slot or slot == math.huge
                or slot <= 0 or slot ~= math.floor(slot) then
                return nil
            end

            local name, _, rank, maxRank = GetProfessionInfo(slot)
            if type(name) ~= "string" or name == "" or seen[name]
                or type(rank) ~= "number" or type(maxRank) ~= "number"
                or rank ~= rank or maxRank ~= maxRank
                or rank < 0 or maxRank < 0 or maxRank > MAX_SKILL_LEVEL
                or rank > maxRank or rank ~= math.floor(rank)
                or maxRank ~= math.floor(maxRank) then
                return nil
            end

            -- Formatting inside pcall ensures any protected client value
            -- produces a clear unavailable result rather than a Lua error.
            local display = string.format("%s %d/%d", name, rank, maxRank)
            results[#results + 1] = {
                name = name,
                rank = rank,
                maximum = maxRank,
                display = display,
            }
            seen[name] = true
        end
    end

    return results
end

--- Reads up to five currently exposed skills, without saving anything.
--- @return table|nil records Bounded current profession entries.
--- @return string|nil reason Safe diagnostic if client data unavailable.
function addon.ReadSkills()
    if type(InCombatLockdown) == "function" then
        local ok, locked = pcall(InCombatLockdown)
        if not ok or locked then
            return nil, "Profession readout unavailable during combat."
        end
    end

    if type(GetProfessions) ~= "function"
        or type(GetProfessionInfo) ~= "function" then
        return nil, "Profession API unavailable on this build."
    end

    local ok, result = pcall(ReadClientSkills)
    if not ok or type(result) ~= "table" then
        return nil, "Profession details unavailable."
    end

    if #result == 0 then
        return nil, "No readable trained professions returned by the client."
    end

    return result
end

--- Preserves v0.1's familiar on-demand profession-list output.
function addon.Render()
    local skills, reason = addon.ReadSkills()
    if not skills then
        addon.Print(reason)
        return
    end

    local names = {}
    for _, entry in ipairs(skills) do
        names[#names + 1] = entry.display
    end
    addon.Print("Known professions: " .. table.concat(names, "; "))
end
