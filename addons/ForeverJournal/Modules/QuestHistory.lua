--[[
    Forever Journal: QuestHistory

    Queries the game's own historical completion flag for one quest ID.
    This is not a quest catalog or a saved quest-history database.
]]

local _, addon = ...

addon.QuestHistory = {}
local QuestHistory = addon.QuestHistory

--- Queries whether the game has flagged a quest as completed.
---
--- False is intentionally not described as "never completed": an invalid
--- quest ID also returns false. Missing APIs return nil with an error.
---
--- @param questID number Positive integer identifying a quest.
--- @return boolean|nil completed True, false, or nil if unavailable.
--- @return string|nil errorMessage Reason when completion cannot be read.
function QuestHistory.IsFlaggedCompleted(questID)
    if type(questID) ~= "number" or questID < 1
        or questID ~= math.floor(questID) then
        return nil, "A positive integer quest ID is required."
    end

    if type(C_QuestLog) ~= "table"
        or type(C_QuestLog.IsQuestFlaggedCompleted) ~= "function" then
        return nil, "Historical quest completion API unavailable on this client."
    end

    local result = C_QuestLog.IsQuestFlaggedCompleted(questID)

    if type(result) ~= "boolean" then
        return nil, "The game did not return a completion flag."
    end

    return result
end
