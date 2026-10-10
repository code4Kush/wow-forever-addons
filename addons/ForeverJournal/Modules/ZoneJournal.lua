--[[
    Forever Journal: ZoneJournal
    Builds a read-only status snapshot for curated quest IDs.

    A completion flag is authoritative only for the specific quest ID queried.
    A false result cannot prove the quest is obtainable, abandoned, or valid.
    The module never uses the catalog to claim full zone completion.
]]

local _, addon = ...

addon.ZoneJournal = {}
local ZoneJournal = addon.ZoneJournal

--- Builds the curated Mulgore starter quest checklist for the player.
---
--- Quest status is read once per request. Each quest can be completed,
--- active, ready for turn-in, or not flagged completed.
---
--- @return table|nil snapshot Entries and completed/active/total counts.
--- @return string|nil errorMessage Explanation if APIs are unavailable.
function ZoneJournal.GetMulgoreStarterSnapshot()
    local identity = addon.Character.GetIdentity()

    -- The catalog is limited to the Tauren starting experience. Showing it
    -- to another race would produce a misleading progress denominator.
    if identity.raceToken ~= "Tauren" and identity.race ~= "Tauren" then
        return nil, "This starter catalog currently supports Tauren characters only."
    end

    local activeQuests, activeError = addon.QuestLog.GetActiveQuests()

    if not activeQuests then
        return nil, activeError
    end

    local activeByID = {}
    for _, quest in ipairs(activeQuests) do
        activeByID[quest.id] = quest
    end

    local entries = {}
    local completedCount = 0
    local activeCount = 0

    for _, definition in ipairs(addon.MulgoreStarter.entries) do
        local isWarriorOnly = definition.classToken ~= nil
        local isWarrior = identity.classToken == "WARRIOR"
            or identity.class == "Warrior"

        if not isWarriorOnly or isWarrior then
            local completed, historyError = addon.QuestHistory.IsFlaggedCompleted(
                definition.id
            )

            if completed == nil then
                return nil, historyError
            end

            local status = "not flagged"

            if completed then
                status = "done"
                completedCount = completedCount + 1
            elseif activeByID[definition.id] then
                local quest = activeByID[definition.id]
                status = quest.isComplete == true and "ready" or "active"
                activeCount = activeCount + 1
            end

            entries[#entries + 1] = {
                id = definition.id,
                label = definition.label,
                status = status,
            }
        end
    end

    return {
        name = addon.MulgoreStarter.name,
        entries = entries,
        total = #entries,
        completed = completedCount,
        active = activeCount,
    }
end
