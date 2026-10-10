--[[
    Forever Journal: Progress
    Pure Lua completion arithmetic. This module deliberately avoids WoW APIs
    so it can be tested without launching the game client.
]]

local _, addon = ...

addon.Progress = {}
local Progress = addon.Progress

--- Calculates a completion percentage rounded to two decimal places.
---
--- Invalid inputs and non-positive totals return zero. Completed counts
--- are clamped to the range [0, total], so results remain in [0, 100].
---
--- @param completed number Count of completed objectives.
--- @param total number Count of all available objectives.
--- @return number percentage A number between 0 and 100.
function Progress.CalculatePercentage(completed, total)
    if type(completed) ~= "number" or type(total) ~= "number" or total <= 0 then
        return 0
    end

    if completed ~= completed or total ~= total then
        return 0
    end

    local boundedCompleted = math.max(0, math.min(completed, total))
    local unroundedPercentage = (boundedCompleted / total) * 100

    return math.floor(unroundedPercentage * 100 + 0.5) / 100
end
