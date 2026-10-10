--[[
    ForeverFishing v0.2 Lua 5.1 mock tests for manually entered catch tally.
    Mocks do not prove client support or real fish caught.
]]
local savedPrint = print
local lines = {}
print = function(value) lines[#lines + 1] = tostring(value) end
local function reset() lines = {} end
local function has(part)
    return table.concat(lines, "\n"):find(part, 1, true) ~= nil
end
local function expect(value, description)
    assert(value, description)
end

SlashCmdList = {}
local descriptor
local active = true
ForeverCore = {
    RegisterModule = function(entry)
        descriptor = entry
        return true
    end,
    GetModuleStatus = function(id)
        expect(id == "fishing", "Only fishing module is expected")
        return {state = active and "active" or "disabled"}
    end,
}
local fishingAPICalls = 0
C_TradeSkillUI = {
    GetBaseProfessionInfo = function()
        fishingAPICalls = fishingAPICalls + 1
        return {professionName = "Fishing",skillLevel = 2,maxSkillLevel = 75}
    end,
}
InCombatLockdown = function() return false end

local ns = {}
for _, file in ipairs({
    "Bootstrap.lua","Module.lua","Read.lua","Catches.lua","Commands.lua"
}) do
    assert(loadfile("addons/ForeverFishing/"..file))("ForeverFishing",ns)
end
expect(ns.version == "0.2.0", "Version bump")
expect(descriptor.id == "fishing"
    and #descriptor.capabilities == 2 and #descriptor.events == 0,
    "Independent event-free Core registration")
expect(fishingAPICalls == 0, "No profession API reads at load")

reset(); SlashCmdList.FOREVERFISHING("version")
expect(has("Version 0.2.0"), "Version command")
reset(); SlashCmdList.FOREVERFISHING("help")
expect(has("log <count> <fish name>") and has("NOT verified loot"),
    "Help explicitly disclaims verification")
expect(fishingAPICalls == 0, "Help/version do not sample client API")

reset(); SlashCmdList.FOREVERFISHING("")
expect(has("Fishing: 2/75 (open profession window)."),
    "Original fishing skill view unchanged")
expect(has("Catches are manually logged only; no auto-fishing."),
    "Previous skill-view caveat retained")
expect(fishingAPICalls == 1, "One requested skill read")

reset(); SlashCmdList.FOREVERFISHING("catches")
expect(has("No manual catches logged."), "Empty state is explicit")
expect(fishingAPICalls == 1, "No API read when listing empty notes")

reset(); SlashCmdList.FOREVERFISHING("log 3 Raw Brilliant Smallfish")
expect(has("Logged manually: Raw Brilliant Smallfish +3 (session total: 3)."),
    "One manual fish entry")
reset(); SlashCmdList.FOREVERFISHING("log 2 raw brilliant smallfish")
expect(has("Logged manually: Raw Brilliant Smallfish +2 (session total: 5)."),
    "Case-insensitive dedup and original display name")
reset(); SlashCmdList.FOREVERFISHING("log 1 Raw Longjaw Mud Snapper")
expect(has("Logged manually: Raw Longjaw Mud Snapper +1 (session total: 1)."),
    "Independent second entry")
reset(); SlashCmdList.FOREVERFISHING("catches")
expect(has("Manual catches: 6 fish across 2 species (session only; not verified)."),
    "Bounded session-only header")
expect(has("Raw Brilliant Smallfish: 5 manually entered.")
    and has("Raw Longjaw Mud Snapper: 1 manually entered."),
    "Two correct per-species totals")
expect(#lines == 3, "No unnecessary output")
expect(fishingAPICalls == 1, "Catch logging/listing never reads game API")

local before, species = ns.CatchTotals()
expect(before == 6 and species == 2, "Internal counters match user output")

for _, bad in ipairs({
    "log 0 Raw Fish", "log 1000 Raw Fish", "log 1.5 Raw Fish",
    "log -3 Raw Fish", "log 12", "log 1 |Hmalformed",
    "log 3 Raw|cffff0000Fish", "log 1 Fish!"..string.char(10).."broken"
}) do
    reset(); SlashCmdList.FOREVERFISHING(bad)
    expect(has("Usage: /ffish log <1-999> <fish name>"),
        "Bad quantity or unsafe name refused: "..bad)
end
local unchanged, unique = ns.CatchTotals()
expect(unchanged == 6 and unique == 2, "Invalid entries never change tallies")

reset(); SlashCmdList.FOREVERFISHING("clear")
expect(has("Manual catch log cleared (session only)."), "Clear acknowledgement")
local now, remaining = ns.CatchTotals()
expect(now == 0 and remaining == 0, "Cleared state")
expect(fishingAPICalls == 1, "Clear makes no client API calls")

-- Test species cap and per-species quantity overflow.
for i = 1, 10 do
    reset(); SlashCmdList.FOREVERFISHING("log 1 Fish"..i)
    expect(has("Logged manually:"), "Unique species "..i.." accepted")
end
reset(); SlashCmdList.FOREVERFISHING("log 1 Fish11")
expect(has("Catch log full (10 species)."), "Eleventh species denied")
now, remaining = ns.CatchTotals()
expect(now == 10 and remaining == 10, "Bounded species count")
reset(); SlashCmdList.FOREVERFISHING("log 9 Fish1")
expect(has("session total: 10"), "Update existing species at capacity")
reset(); SlashCmdList.FOREVERFISHING("catches")
expect(#lines == 11, "Bounded output: max 11 local lines")

reset(); SlashCmdList.FOREVERFISHING("clear")
for i = 1, 10 do
    reset(); SlashCmdList.FOREVERFISHING("log 999 Fish1")
    expect(has("Logged manually:"), "Up to 9999 per species")
end
reset(); SlashCmdList.FOREVERFISHING("log 9 Fish1")
expect(has("session total: 9999"), "Per-species cap reached")
reset(); SlashCmdList.FOREVERFISHING("log 1 Fish1")
expect(has("Catch quantity limit reached (9999 per species)."),
    "Reject over-limit accumulation")
now, remaining = ns.CatchTotals()
expect(now == 9999 and remaining == 1, "Failed entry never increments total")
expect(fishingAPICalls == 1, "No hidden game API use for catch commands")

-- Logical disabling must prevent command mutation and discard notes.
active = false
descriptor.Disable(descriptor)
reset(); SlashCmdList.FOREVERFISHING("catches")
expect(has("Module not active: disabled."), "Disabled catch list blocked")
reset(); SlashCmdList.FOREVERFISHING("log 1 Fish2")
expect(has("Module not active: disabled."), "Disabled logging blocked")
expect(fishingAPICalls == 1, "No sampling while disabled")
active = true
reset(); SlashCmdList.FOREVERFISHING("catches")
expect(has("No manual catches logged."), "Core disable clears notes")

reset(); SlashCmdList.FOREVERFISHING("whatever")
expect(has("Usage: /ffish"), "Unknown command rejected")
reset(); SlashCmdList.FOREVERFISHING("log 4 Raw Fish")
expect(has("session total: 4"), "Can log after enabling")
C_TradeSkillUI = nil
reset(); SlashCmdList.FOREVERFISHING("catches")
expect(has("Raw Fish: 4 manually entered."),
    "Manual notes remain usable even if profession API unavailable")
reset(); SlashCmdList.FOREVERFISHING("")
expect(has("Fishing skill not readable; open Fishing UI and retry."),
    "Missing profession API fails safely")
print = savedPrint
print("ForeverFishing manual catch tally mock tests passed.")
