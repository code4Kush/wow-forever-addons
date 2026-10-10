--[[
    ForeverCooking v0.2 Lua 5.1 simulation: windowless skill adapter,
    guarded UI fallback and manually-entered ingredient planning.
    These mocks do NOT prove Forever client or real inventory behavior.
]]
local savedPrint = print
local lines = {}
print = function(line) lines[#lines + 1] = tostring(line) end
local function reset() lines = {} end
local function has(fragment)
    return table.concat(lines, "\n"):find(fragment, 1, true) ~= nil
end
local function expect(value, reason) assert(value, reason) end
SlashCmdList = {}
local registered, active = nil, true
ForeverCore = {
    RegisterModule = function(descriptor)
        registered = descriptor
        return true
    end,
    GetModuleStatus = function(id)
        expect(id == "cooking", "No cross-pack status lookup")
        return {state = active and "active" or "disabled"}
    end,
}
local listCalls, infoCalls, uiCalls = 0, 0, 0
GetProfessions = function()
    listCalls = listCalls + 1
    return nil, nil, 3, 4, 5
end
GetProfessionInfo = function(slot)
    infoCalls = infoCalls + 1
    local entries = {
        [3] = {"First Aid", 1,75},
        [4] = {"Fishing", 2,75},
        [5] = {"Cooking", 3,75},
    }
    local e = entries[slot]
    if e then return e[1], nil, e[2], e[3] end
end
C_TradeSkillUI = {GetBaseProfessionInfo = function()
    uiCalls = uiCalls + 1
    return { professionName="Fishing", skillLevel=2, maxSkillLevel=75 }
end}
InCombatLockdown = function() return false end

local addon = {}
for _, name in ipairs({
    "Bootstrap.lua", "Module.lua", "Read.lua", "Ingredients.lua", "Commands.lua"
}) do
    assert(loadfile("addons/ForeverCooking/" .. name))("ForeverCooking", addon)
end

expect(addon.version == "0.2.0", "New standalone Cooking version")
expect(registered.id == "cooking" and #registered.events == 0,
    "Still an independent event-free Core module")
expect(#registered.capabilities == 2
    and registered.capabilities[2] == "cooking.manual-ingredients",
    "Manual ingredient capability documented")
expect(listCalls == 0 and infoCalls == 0 and uiCalls == 0,
    "Addon load causes zero profession API calls")
reset(); SlashCmdList.FOREVERCOOKING("version")
expect(has("Version 0.2.0"), "version bumped")
reset(); SlashCmdList.FOREVERCOOKING("help")
expect(has("need <count> <ingredient>") and has("NOT confirmed bags"),
    "Manual note limitation shown")
reset(); SlashCmdList.FOREVERCOOKING("needs")
expect(has("No manual ingredients planned."),
    "Empty plan is explicit")
expect(listCalls == 0 and infoCalls == 0 and uiCalls == 0,
    "Help/version/manual plan do not read client API")

reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking: 3/75 (profession list)."),
    "Current skill read without opening Cooking window")
expect(has("Recipes and ingredient counts are NOT scanned."),
    "Readout does not falsely claim recipe data")
expect(listCalls == 1 and uiCalls == 0,
    "Successful first read bypasses trade skill window API")
reset(); SlashCmdList.FOREVERCOOKING("skill")
expect(has("Cooking: 3/75 (profession list)."),
    "Skill alias returns the same value")
expect(listCalls == 2 and uiCalls == 0,
    "At most one GetProfessions call per request")

reset(); SlashCmdList.FOREVERCOOKING("need 3 Raw Brilliant Smallfish")
expect(has("Planned manually: Raw Brilliant Smallfish +3 (need 3)."),
    "Explicit human ingredient note")
reset(); SlashCmdList.FOREVERCOOKING("need 2 raw brilliant smallfish")
expect(has("Planned manually: Raw Brilliant Smallfish +2 (need 5)."),
    "Case-insensitive accumulation")
reset(); SlashCmdList.FOREVERCOOKING("need 1 Refreshing Spring Water")
expect(has("Planned manually: Refreshing Spring Water +1 (need 1)."),
    "Independent ingredient name")
reset(); SlashCmdList.FOREVERCOOKING("needs")
expect(has("Ingredient plan: 6 units across 2 labels") and #lines == 3,
    "At most one header and one line per human label")
expect(has("Raw Brilliant Smallfish: need 5 (player-entered).")
    and has("Refreshing Spring Water: need 1 (player-entered)."),
    "Rendered counts never claim bag holdings")
expect(listCalls == 2 and uiCalls == 0,
    "Manual planning has no hidden game reads")
local total, unique = addon.NeedTotals()
expect(total == 6 and unique == 2, "Correct bounded plan totals")

for _, bad in ipairs({
    "need 0 Water", "need 1000 Water", "need 1.5 Water",
    "need -1 Water", "need 2", "need 1 |Hunsafe",
    "need 1 Water|cffff0000Red", "need 1 Bad"..string.char(10).."Name",
}) do
    reset(); SlashCmdList.FOREVERCOOKING(bad)
    expect(has("Usage: /fcook need <1-999> <ingredient name>"),
        "Reject malformed/unsafe manual item: " .. bad)
end
total, unique = addon.NeedTotals()
expect(total == 6 and unique == 2, "Rejected input leaves store unchanged")

reset(); SlashCmdList.FOREVERCOOKING("clear")
expect(has("Manual ingredient plan cleared (session only)."),
    "Explicit manual clear acknowledgement")
total, unique = addon.NeedTotals()
expect(total == 0 and unique == 0, "Clear removes all entries")

for i = 1, 10 do
    reset(); SlashCmdList.FOREVERCOOKING("need 1 Ingredient" .. i)
    expect(has("Planned manually:"), "Up to ten labels accepted")
end
reset(); SlashCmdList.FOREVERCOOKING("need 1 Ingredient11")
expect(has("Ingredient list full (10 names)."), "11th item rejected")
reset(); SlashCmdList.FOREVERCOOKING("need 1 Ingredient1")
expect(has("need 2"), "Existing ingredient can accumulate at full capacity")
reset(); SlashCmdList.FOREVERCOOKING("clear")
for i = 1, 10 do
    reset(); SlashCmdList.FOREVERCOOKING("need 999 Ingredient")
    expect(has("Planned manually:"), "Up to 9990 same ingredient")
end
reset(); SlashCmdList.FOREVERCOOKING("need 9 Ingredient")
expect(has("need 9999"), "Per-item cap exactly 9999")
reset(); SlashCmdList.FOREVERCOOKING("need 1 Ingredient")
expect(has("Ingredient quantity limit reached (9999 per name)."),
    "11th accumulation beyond 9999 rejected")
total, unique = addon.NeedTotals()
expect(total == 9999 and unique == 1,
    "Overflow never changes stored amount")

active = false
registered.Disable(registered)
reset(); SlashCmdList.FOREVERCOOKING("needs")
expect(has("Module not active: disabled."),
    "Core disabling blocks reads")
reset(); SlashCmdList.FOREVERCOOKING("need 1 Water")
expect(has("Module not active: disabled."),
    "Core disabling blocks mutation")
active = true
reset(); SlashCmdList.FOREVERCOOKING("needs")
expect(has("No manual ingredients planned."),
    "Core disable clears all notes")
expect(listCalls == 2 and uiCalls == 0,
    "None of the manual commands required game reads")

-- Fallback to the Cooking profession window when list API is missing.
GetProfessions = nil
C_TradeSkillUI.GetBaseProfessionInfo = function()
    uiCalls = uiCalls + 1
    return {professionName="Cooking",skillLevel=8,maxSkillLevel=75}
end
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking: 8/75 (open profession window)."),
    "Original UI-only fallback preserved")
expect(uiCalls == 1, "Only one requested UI read")

-- Do not accidentally show Fishing if the wrong skill window is open.
C_TradeSkillUI.GetBaseProfessionInfo = function()
    uiCalls = uiCalls + 1
    return {professionName="Fishing",skillLevel=20,maxSkillLevel=75}
end
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill not readable; open Cooking UI and retry."),
    "Reject currently open but wrong profession")

GetProfessions = function() error("API changed") end
GetProfessionInfo = nil
C_TradeSkillUI = nil
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill not readable; open Cooking UI and retry."),
    "No invented skill for missing/broken APIs")

GetProfessions = function()
    listCalls = listCalls + 1
    return nil,nil,nil,4,5
end
GetProfessionInfo = function(slot)
    return slot == 5 and "Cooking" or "Fishing", nil,
        900, 75
end
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill not readable; open Cooking UI and retry."),
    "Reject malformed rank greater than maximum")

InCombatLockdown = function() return true end
local beforeCombat = listCalls
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill unavailable during combat."),
    "Explicit combat restriction")
expect(listCalls == beforeCombat, "No API read in combat")
InCombatLockdown = function() error("protected API") end
reset(); SlashCmdList.FOREVERCOOKING("")
expect(has("Cooking skill unavailable during combat."),
    "Fail closed if combat API itself raises")

print = savedPrint
print("ForeverCooking v0.2 standalone readout and manual prep mocks passed.")
