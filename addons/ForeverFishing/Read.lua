--[[
    Forever Fishing v0.3: on-demand, read-only skill lookup.

    First try GetProfessions/GetProfessionInfo already used by the
    separately installed ForeverProfessions pack. This addon has **NO**
    hard or runtime dependency on that optional pack. If the client
    does not expose a valid named entry, fall back to the existing
    open-tradeskill-UI route. No caches, events, timers or polling.
    Actual no-window behavior is NOT verified in the Forever beta yet.
]]
local _, addon = ...
local SKILL_NAME = "Fishing"
local MAX_SLOTS = 5
local MAX_SKILL_LEVEL = 100000

local function SafeLevels(rank, maximum)
    return type(rank) == "number" and type(maximum) == "number"
        and rank == rank and maximum == maximum
        and rank >= 0 and maximum >= 0 and rank <= maximum
        and maximum <= MAX_SKILL_LEVEL
        and rank % 1 == 0 and maximum % 1 == 0
end

local function FromProfessionList()
    if type(GetProfessions) ~= "function"
        or type(GetProfessionInfo) ~= "function" then
        return nil
    end
    local ok, value = pcall(function()
        -- Sparse primary slots must not discard Fishing/Cooking in slots 3-5.
        local slots = { GetProfessions() }
        for index = 1, MAX_SLOTS do
            local slot = slots[index]
            if slot ~= nil then
                if type(slot) ~= "number" or slot ~= slot
                    or slot < 1 or slot > 100000
                    or slot % 1 ~= 0 then
                    return nil
                end
                local name, _, rank, maximum = GetProfessionInfo(slot)
                -- Match by an exact known English name. Unknown/localized
                -- names fall back rather than guessing from slot position.
                if name == SKILL_NAME then
                    if not SafeLevels(rank, maximum) then return nil end
                    return string.format("%d/%d", rank, maximum)
                end
            end
        end
        return nil
    end)
    if ok and type(value) == "string" then
        return value
    end
    return nil
end

local function FromOpenWindow()
    if type(C_TradeSkillUI) ~= "table"
        or type(C_TradeSkillUI.GetBaseProfessionInfo) ~= "function" then
        return nil
    end
    local ok, value = pcall(function()
        local info = C_TradeSkillUI.GetBaseProfessionInfo()
        local candidate = type(Enum) == "table"
            and type(Enum.Profession) == "table"
            and Enum.Profession.Fishing or nil
        if type(info) == "table"
            and ((candidate and info.profession == candidate)
                or info.professionName == SKILL_NAME)
            and SafeLevels(info.skillLevel, info.maxSkillLevel) then
            return string.format("%d/%d", info.skillLevel, info.maxSkillLevel)
        end
        return nil
    end)
    if ok and type(value) == "string" then
        return value
    end
    return nil
end

--- Reports skill rank only when a verified client value was readable.
--- No read occurs at load; only /ffish requests call this.
function addon.Render()
    if type(InCombatLockdown) == "function" then
        local ok, combat = pcall(InCombatLockdown)
        if not ok or combat then
            addon.Print("Fishing skill unavailable during combat.")
            return
        end
    end

    local listed = FromProfessionList()
    if listed then
        addon.Print("Fishing: " .. listed .. " (profession list).")
    else
        local opened = FromOpenWindow()
        if opened then
            addon.Print("Fishing: " .. opened .. " (open profession window).")
        else
            addon.Print("Fishing skill not readable; open Fishing UI and retry.")
        end
    end
    addon.Print("Catches are manually logged only; no auto-fishing.")
end
