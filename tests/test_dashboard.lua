--[[
    ForeverDashboard 0.2 Lua 5.1 mocked lazy/paginated lifecycle tests.
    UI is simulated; no claims of real beta performance or UI compatibility.
]]
local savedPrint = print
local logs = {}
print = function(s) logs[#logs + 1] = tostring(s) end
local function clear() logs = {} end
local function contains(fragment)
    return table.concat(logs, "\n"):find(fragment, 1, true) ~= nil
end
local function expect(value, reason) assert(value, reason) end

local frameCount, fontCount, readCalls = 0, 0, 0
local status = "active"
local descriptor
local list = {}
for i = 1, 14 do
    list[i] = {
        id = "module-" .. i,
        displayName = "Module " .. i,
        version = "0.1.0",
        state = i % 4 == 0 and "disabled" or "active",
    }
end
ForeverCore = {
    RegisterModule = function(module) descriptor = module; return true end,
    GetModuleStatus = function(id)
        expect(id == "dashboard", "Only the dashboard may be requested")
        return { state = status }
    end,
    ListModules = function()
        readCalls = readCalls + 1
        return list
    end,
}
UIParent = {}
InCombatLockdown = function() return false end
SlashCmdList = {}
local frame = {
    shown = false,
    scripts = {},
    SetSize = function() end,
    SetPoint = function() end,
    EnableMouse = function() end,
    SetMovable = function() end,
    RegisterForDrag = function() end,
    StartMoving = function() end,
    StopMovingOrSizing = function() end,
    SetScript = function(self, key, callback)
        expect(key ~= "OnUpdate", "Forbidden polling script")
        self.scripts[key] = callback
    end,
    Show = function(self) self.shown = true end,
    Hide = function(self) self.shown = false end,
    IsShown = function(self) return self.shown end,
    CreateTexture = function()
        return {
            SetAllPoints = function() end,
            SetColorTexture = function() end,
        }
    end,
    CreateFontString = function()
        fontCount = fontCount + 1
        return {
            SetPoint = function() end,
            SetWidth = function() end,
            SetJustifyH = function() end,
            SetJustifyV = function() end,
            SetText = function(self, text) self.text = text end,
        }
    end,
}
CreateFrame = function()
    frameCount = frameCount + 1
    return frame
end

local ns = {}
for _, name in ipairs({
    "Bootstrap.lua", "Module.lua", "Read.lua", "Commands.lua"
}) do
    assert(loadfile("addons/ForeverDashboard/" .. name))(
        "ForeverDashboard", ns
    )
end
expect(ns.version == "0.2.0", "Version bumped")
expect(descriptor.id == "dashboard" and #descriptor.events == 0,
    "Independent Core registry, no game events")
expect(frameCount == 0 and fontCount == 0 and readCalls == 0,
    "Zero GUI/API work on load")

clear(); SlashCmdList.FOREVERDASHBOARD("version")
expect(contains("Version 0.2.0"), "Version command")
clear(); SlashCmdList.FOREVERDASHBOARD("help")
expect(contains("next | prev | status"), "Navigation help")
expect(frameCount == 0 and readCalls == 0, "Help/version never render")

clear(); SlashCmdList.FOREVERDASHBOARD("status")
expect(contains("14 registered module(s); 11 active."),
    "Core registry status distinguishes disabled from active")
expect(frameCount == 0 and fontCount == 0,
    "Status report requires zero UI allocations")

clear(); SlashCmdList.FOREVERDASHBOARD("")
expect(contains("Dashboard shown.") and frame.shown,
    "Original /fdash toggle opens")
expect(frameCount == 1 and fontCount == 1,
    "One frame, one label lazy allocated")

clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(contains("Dashboard page 2/3."), "Second module page")
clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(contains("Dashboard page 3/3."), "Third module page")
clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(contains("Dashboard page 3/3."), "Last page clamps")
clear(); SlashCmdList.FOREVERDASHBOARD("prev")
expect(contains("Dashboard page 2/3."), "Page back")
clear(); SlashCmdList.FOREVERDASHBOARD("")
expect(contains("Dashboard hidden.") and not frame.shown,
    "Legacy toggle hides")

for i = 1, 20 do
    SlashCmdList.FOREVERDASHBOARD("")
    SlashCmdList.FOREVERDASHBOARD("")
end
expect(frameCount == 1 and fontCount == 1,
    "Repeated UI use reuses existing frame/string")
expect(frame.scripts["OnUpdate"] == nil, "No background polling")

status = "disabled"
descriptor.Disable(descriptor)
expect(not frame.shown, "Disabling must hide existing UI")
local before = readCalls
clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(contains("Module not active: disabled."),
    "Disabled module blocks live registry requests")
expect(readCalls == before, "Disabled module makes no registry call")
status = "active"

-- Empty list and single-page state must be supported.
list = {}
clear(); SlashCmdList.FOREVERDASHBOARD("next")
expect(contains("Dashboard page 1/1."), "Empty list has one page")
expect(frameCount == 1, "Empty list does not reconstruct UI")
list = { { id="gold", displayName="Gold", version="0.2.0",
    state="disabled" } }
clear(); SlashCmdList.FOREVERDASHBOARD("prev")
expect(contains("Dashboard page 1/1."), "Single module page")

InCombatLockdown = function() return true end
before = readCalls
clear(); SlashCmdList.FOREVERDASHBOARD("status")
expect(contains("Dashboard unavailable during combat; try afterward."),
    "Combat guard")
expect(readCalls == before, "No registry read in combat")

print = savedPrint
print("ForeverDashboard lazy paginated module tests passed.")
