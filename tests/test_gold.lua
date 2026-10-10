--[[
    ForeverGold 0.2 mock tests: manual wallet baseline and net change.
    Lua 5.1 only, no real WoW APIs, no claims of beta compatibility.
]]
local savedPrint = print
local lines = {}
print = function(value) lines[#lines+1] = tostring(value) end
local function reset() lines = {} end
local function has(s) return table.concat(lines,"\n"):find(s,1,true) ~= nil end
local function expect(condition,reason) assert(condition,reason) end

SlashCmdList = {}
local descriptor
local enabled = true
ForeverCore = {
    RegisterModule = function(def)
        descriptor = def
        return true
    end,
    GetModuleStatus = function(id)
        expect(id == "gold", "Only gold module expected")
        return { state = enabled and "active" or "disabled" }
    end,
}
local money = 123456
local moneyCalls = 0
GetMoney = function()
    moneyCalls = moneyCalls + 1
    return money
end
InCombatLockdown = function() return false end

local ns = {}
for _, file in ipairs({
    "Bootstrap.lua","Module.lua","Read.lua","Tracker.lua","Commands.lua"
}) do
    assert(loadfile("addons/ForeverGold/" .. file))("ForeverGold", ns)
end
expect(descriptor.id == "gold", "Correct Core module")
expect(descriptor.minCoreVersion == "0.2.0", "Core compatibility")
expect(#descriptor.events == 0, "No polling or game events")
expect(#descriptor.capabilities == 2, "Wallet and manual delta supported")
expect(ns.version == "0.2.0", "Gold v0.2")
expect(moneyCalls == 0, "No game reads during module initialization")

reset(); SlashCmdList.FOREVERGOLD("version")
expect(has("Version 0.2.0"), "version")
reset(); SlashCmdList.FOREVERGOLD("help")
expect(has("baseline | delta | clear"), "help")
expect(moneyCalls == 0, "No sampling from help/version")

reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("No baseline. Use /fgold baseline first."),
    "No fabricated baseline")
expect(moneyCalls == 0, "No unnecessary money read without baseline")

reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet: 12g 34s 56c (current character; not earnings)."),
    "Legacy wallet output unchanged")
expect(moneyCalls == 1, "One read per explicit request")

reset(); SlashCmdList.FOREVERGOLD("baseline")
expect(has("Baseline saved: 12g 34s 56c (session only)."),
    "Manual baseline saved")
expect(moneyCalls == 2, "One read for baseline")

reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("Wallet change: +0g 0s 0c") and has("net balance, NOT profit"),
    "Zero change never labeled as profit")
expect(moneyCalls == 3, "Exactly one read per delta")

money = 133506 -- 10,050 copper gained = 1g 0s 50c.
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("Wallet change: +1g 0s 50c")
    and has("now 13g 35s 6c"),
    "Positive signed delta and current money")

money = 103450 -- 20,006 copper spent = 2g 0s 6c.
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("Wallet change: -2g 0s 6c")
    and has("was 12g 34s 56c"),
    "Negative signed delta and original baseline unchanged")

local priorCalls = moneyCalls
reset(); SlashCmdList.FOREVERGOLD("clear")
expect(has("Baseline cleared (session only)."), "Clear acknowledged")
expect(moneyCalls == priorCalls, "Clear never calls game API")
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("No baseline."), "Missing baseline after clear")
expect(moneyCalls == priorCalls, "No implicit read after clear")

reset(); SlashCmdList.FOREVERGOLD("baseline")
expect(has("Baseline saved: 10g 34s 50c"), "New baseline allowed")
enabled = false
descriptor.Disable(descriptor)
priorCalls = moneyCalls
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Module not active: disabled."),
    "Disabled module blocks reading")
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("Module not active: disabled."),
    "Disabled module blocks tracking")
expect(moneyCalls == priorCalls, "No game calls while disabled")
enabled = true
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("No baseline."), "Disabling clears memory")
reset(); SlashCmdList.FOREVERGOLD("version")
expect(has("Version 0.2.0"), "Safe version always available")

-- A stale baseline must remain unchanged if an API fails.
reset(); SlashCmdList.FOREVERGOLD("baseline")
local invalids = { -1, 0/0, math.huge, 1.5, "unknown" }
for _, value in ipairs(invalids) do
    money = value
    reset(); SlashCmdList.FOREVERGOLD("baseline")
    expect(has("Wallet value unavailable."),
        "Invalid baseline safely rejected")
    reset(); SlashCmdList.FOREVERGOLD("delta")
    expect(has("Wallet value unavailable."),
        "Invalid current money safely rejected")
end
money = 103450
GetMoney = nil
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet API unavailable on this build."),
    "Missing API fails visibly")
reset(); SlashCmdList.FOREVERGOLD("baseline")
expect(has("Wallet API unavailable on this build."),
    "Unavailable baseline explicit")
GetMoney = function() error("WoW API unavailable") end
reset(); SlashCmdList.FOREVERGOLD("delta")
expect(has("Wallet value unavailable."),
    "Thrown API does not crash command")

GetMoney = function()
    moneyCalls = moneyCalls + 1
    return 103450
end
InCombatLockdown = function() return true end
priorCalls = moneyCalls
reset(); SlashCmdList.FOREVERGOLD("")
expect(has("Wallet unavailable during combat."),
    "Avoid protected reads during combat")
expect(moneyCalls == priorCalls, "Combat guard suppresses money read")
InCombatLockdown = function() return false end

reset(); SlashCmdList.FOREVERGOLD("unknown")
expect(has("Usage: /fgold"), "Unknown commands rejected")

print = savedPrint
print("ForeverGold manual wallet baseline mock tests passed.")
