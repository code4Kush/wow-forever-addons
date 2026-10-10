--[[
    Standalone Lua 5.1 tests for the pure Forever Journal progress module.
    Run from the repository root: lua5.1 tests/test_progress.lua
]]

local addon = {}
local moduleChunk = assert(loadfile("addons/ForeverJournal/Modules/Progress.lua"))
moduleChunk("ForeverJournal", addon)

local calculatePercentage = addon.Progress.CalculatePercentage

local function ExpectEqual(actual, expected, scenario)
    assert(
        actual == expected,
        scenario .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)
    )
end

ExpectEqual(calculatePercentage(3, 5), 60, "ordinary progress")
ExpectEqual(calculatePercentage(1, 3), 33.33, "rounding")
ExpectEqual(calculatePercentage(0, 10), 0, "empty progress")
ExpectEqual(calculatePercentage(10, 10), 100, "complete progress")
ExpectEqual(calculatePercentage(15, 10), 100, "count above total")
ExpectEqual(calculatePercentage(-2, 10), 0, "negative count")
ExpectEqual(calculatePercentage(3, 0), 0, "zero total")
ExpectEqual(calculatePercentage(3, -1), 0, "negative total")
ExpectEqual(calculatePercentage(nil, 5), 0, "missing input")
ExpectEqual(calculatePercentage("3", 5), 0, "non-numeric input")
ExpectEqual(calculatePercentage(0 / 0, 5), 0, "not-a-number input")

print("Forever Journal progress tests passed.")
