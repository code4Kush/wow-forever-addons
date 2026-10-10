--[[
    Forever Performance 0.1: Lua 5.1 mocked memory compatibility and safety.

    The numbers below are deterministic fixtures. They are NOT measurements
    from a running WoW client; true compatibility needs live beta evidence.
]]
local originalPrint = print
local originalCollectGarbage = collectgarbage
local emitted = {}
print = function(value)
    emitted[#emitted + 1] = tostring(value)
end

local function Assert(value, message)
    assert(value, message)
end
local function Has(fragment)
    return table.concat(emitted, "\n"):find(fragment, 1, true) ~= nil
end
local function Reset()
    emitted = {}
end
local function CountLines()
    return #emitted
end

-- Ensure no feature call silently forces a GC pause.
collectgarbage = function()
    error("ForeverPerformance must not force garbage collection")
end

local statusByID = {
    dashboard = "active",
    journal = "active",
    gold = "active",
    performance = "active",
}
local corePrint = function(value)
    print("Forever Core: " .. tostring(value))
end

ForeverCore = {
    RegisterModule = function(descriptor)
        _G.recordedDescriptor = descriptor
        return true
    end,
    GetModuleStatus = function(id)
        local state = statusByID[id]
        if not state then
            return nil
        end
        return { state = state }
    end,
    FindCapabilityProviders = function(capability)
        Assert(capability == "performance.memory",
            "Only performance capability lookup is expected")
        if statusByID.performance == "active" then
            return { "performance" }
        end
        return {}
    end,
    Print = corePrint,
}

local memoryKB = {
    ForeverCore = 46.41,
    ForeverDashboard = 31.90,
    ForeverJournal = 35.61,
    ForeverGold = 14.00,
    ForeverPerformance = 12.50,
}
local refreshCalls = 0
local readCalls = 0
UpdateAddOnMemoryUsage = function()
    refreshCalls = refreshCalls + 1
end
GetAddOnMemoryUsage = function(addonName)
    readCalls = readCalls + 1
    Assert(type(addonName) == "string", "Measurement uses addon names")
    return memoryKB[addonName]
end
SlashCmdList = {}

local addon = {}
local function Load(name)
    assert(loadfile("addons/ForeverPerformance/" .. name))(
        "ForeverPerformance", addon
    )
end
Load("Bootstrap.lua")
Load("Metrics.lua")
Load("Module.lua")
Load("Commands.lua")

Assert(recordedDescriptor.id == "performance", "Core descriptor ID")
Assert(recordedDescriptor.minCoreVersion == "0.2.0",
    "Versioned optional pack contract")
Assert(#recordedDescriptor.events == 0, "No event listeners")
Assert(#recordedDescriptor.capabilities == 1
    and recordedDescriptor.capabilities[1] == "performance.memory",
    "Advertises memory capability")
Assert(refreshCalls == 0 and readCalls == 0,
    "Loading and registering must not perform measurements")

Reset()
SlashCmdList.FOREVERPERFORMANCE("help")
Assert(Has("memory | details | baseline | delta | clear"),
    "Help includes all commands")
SlashCmdList.FOREVERPERFORMANCE("version")
Assert(Has("Version 0.1.0"), "Standalone version command")
Assert(refreshCalls == 0, "Help/version must not run the memory API")

Reset()
SlashCmdList.FOREVERPERFORMANCE("delta")
Assert(Has("No baseline. Use /fperf baseline first."), "No implicit baseline")
Assert(refreshCalls == 0, "Missing baseline must not sample")

Reset()
SlashCmdList.FOREVERPERFORMANCE("memory")
Assert(Has("Memory: 5 known loaded pack(s), 140.42 KB total"),
    "Totals include Core, registered packs, and Performance")
Assert(Has("Top 1: ForeverCore 46.41 KB."), "Deterministic top ranking")
Assert(Has("Top 2: ForeverJournal 35.61 KB."), "Second largest usage")
Assert(Has("Top 3: ForeverDashboard 31.90 KB."), "Third largest usage")
Assert(not Has("ForeverInventory"), "Absent packs never falsely measured")
Assert(refreshCalls == 1 and readCalls == 5,
    "Exactly one refresh and one reading per known pack")
Assert(CountLines() == 4, "Summary never floods chat")

Reset()
SlashCmdList.FOREVERPERFORMANCE("details")
Assert(Has("Details: 5 known loaded pack(s), 140.42 KB total."),
    "Details reports bounded header and total")
Assert(Has("ForeverDashboard: 31.90 KB."), "Details shows module values")
Assert(Has("ForeverPerformance: 12.50 KB."), "Self attribution included")
Assert(CountLines() == 6, "One header and five rows")
Assert(refreshCalls == 2, "Exactly one refresh per details request")

Reset()
SlashCmdList.FOREVERPERFORMANCE("baseline")
Assert(Has("Baseline saved: 140.42 KB across 5 pack(s)"),
    "Player starts an explicit session-only baseline")
Assert(addon.baseline ~= nil, "Baseline stored in addon namespace")
Assert(refreshCalls == 3, "Baseline samples once")

memoryKB.ForeverDashboard = 40.99
Reset()
SlashCmdList.FOREVERPERFORMANCE("delta")
Assert(Has("Since baseline: +9.09 KB (was 140.42 KB; now 149.51 KB)."),
    "Delta preserves sign and measured readings")
Assert(Has("Change: ForeverDashboard +9.09 KB."),
    "Module-level delta for the largest absolute contributor")
Assert(refreshCalls == 4, "Delta samples exactly once")
Assert(addon.baseline.totalKB > 140.41
    and addon.baseline.totalKB < 140.43,
    "Delta must not overwrite the original baseline")

memoryKB.ForeverDashboard = 29.90
Reset()
SlashCmdList.FOREVERPERFORMANCE("delta")
Assert(Has("Since baseline: -2.00 KB (was 140.42 KB; now 138.42 KB)."),
    "Negative deltas are reported instead of being clamped to zero")

-- Logically disabled-but-loaded packs still occupy and report memory.
statusByID.dashboard = "disabled"
Reset()
SlashCmdList.FOREVERPERFORMANCE("details")
Assert(Has("ForeverDashboard: 29.90 KB."),
    "Disabling a module must not pretend its Lua memory is unloaded")

statusByID.inventory = "active"
memoryKB.ForeverInventory = 7.25
Reset()
SlashCmdList.FOREVERPERFORMANCE("delta")
Assert(Has("Loaded pack set changed; totals are not directly comparable."),
    "Changes in available modules invalidate direct trend comparisons")

-- Refuse invalid, unavailable or untrusted memory numbers, rather than
-- inventing zeros or showing partial summed totals.
local invalids = { -1, 0 / 0, math.huge, "unknown" }
for _, value in ipairs(invalids) do
    memoryKB.ForeverCore = value
    Reset()
    SlashCmdList.FOREVERPERFORMANCE("memory")
    Assert(Has("Memory reading unavailable for ForeverCore."),
        "Unsafe measurement must be visibly rejected")
    Assert(not Has("KB total"), "Never print partial invalid totals")
end
memoryKB.ForeverCore = 46.41

GetAddOnMemoryUsage = nil
Reset()
SlashCmdList.FOREVERPERFORMANCE("memory")
Assert(Has("WoW addon memory API unavailable on this build."),
    "Missing API is handled safely")
GetAddOnMemoryUsage = function(addonName)
    return memoryKB[addonName]
end

UpdateAddOnMemoryUsage = function()
    error("client refresh failure")
end
Reset()
SlashCmdList.FOREVERPERFORMANCE("memory")
Assert(Has("WoW memory refresh failed."), "A refresh failure is visible")
UpdateAddOnMemoryUsage = function()
    refreshCalls = refreshCalls + 1
end

Reset()
SlashCmdList.FOREVERPERFORMANCE("clear")
Assert(Has("Baseline cleared (session only).")
    and addon.baseline == nil, "Baseline clearing needs no read")
Reset()
SlashCmdList.FOREVERPERFORMANCE("delta")
Assert(Has("No baseline."), "Clear removes the comparison anchor")

Reset()
SlashCmdList.FOREVERPERFORMANCE("memory extra")
Assert(Has("Usage: /fperf"), "Unexpected arguments rejected")

statusByID.performance = "disabled"
Reset()
SlashCmdList.FOREVERPERFORMANCE("memory")
Assert(Has("Module not active: disabled."),
    "Inactive module must not sample memory")
Reset()
SlashCmdList.FOREVERPERFORMANCE("version")
Assert(Has("Version 0.1.0"), "Version still visible when disabled")

addon.baseline = { totalKB = 1, entries = {}, byFolder = {} }
recordedDescriptor.Disable(recordedDescriptor)
Assert(addon.baseline == nil, "Disable destroys session baseline")

-- Test Core navigation independently; no direct memory polling in Core.
local commands = assert(loadfile("addons/ForeverCore/Commands.lua"))
commands("ForeverCore", ForeverCore)
Reset()
SlashCmdList.FOREVERCORE("memory")
Assert(Has("install and enable ForeverPerformance"),
    "Core reports absent/inactive optional provider")
statusByID.performance = "active"
Reset()
SlashCmdList.FOREVERCORE("memory")
Assert(Has("Memory diagnostics: use /fperf"),
    "Core only points to active optional feature")
Assert(not Has("KB"), "Core navigation is not a measurement")

collectgarbage = originalCollectGarbage
print = originalPrint
print("ForeverPerformance on-demand memory diagnostics mock tests passed.")
