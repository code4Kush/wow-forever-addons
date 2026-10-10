--[[
    Journal 0.5: Core integration mock test for independent registration,
    class-neutral eligibility, and per-character profile disable behavior.
    Does NOT prove live Forever client compatibility.
]]
local savedPrint = print
local messages = {}
print = function(v) messages[#messages+1] = tostring(v) end
local function has(s) return table.concat(messages,"\n"):find(s,1,true) end
local function reset() messages = {} end
SlashCmdList = {}
local descriptor
local mode = "active"
ForeverCore = {
    RegisterModule = function(value)
        descriptor = value
        return true
    end,
    GetModuleStatus = function(id)
        assert(id == "journal", "wrong module ID")
        return { state = mode }
    end,
}
local ns = {}
for _, path in ipairs({ "Core/Bootstrap.lua", "Core/CoreBridge.lua" }) do
    assert(loadfile("addons/ForeverJournal/" .. path))("ForeverJournal", ns)
end
assert(descriptor and descriptor.id == "journal", "Journal registered")
assert(descriptor.minCoreVersion == "0.2.0", "Core min version")
assert(descriptor.IsEligible == nil, "Quest catalog may filter race, not pack")
ns.Progress = { CalculatePercentage = function(a,b) return (a/b)*100 end }
assert(loadfile("addons/ForeverJournal/Core/Commands.lua"))("ForeverJournal", ns)
reset(); SlashCmdList.FOREVERJOURNAL("version")
assert(has("Version 0.5.0"), "new integration version")
reset(); SlashCmdList.FOREVERJOURNAL("progress 3 5")
assert(has("Progress: 60.00%"), "Core enabled allows read-only progress")
mode = "disabled"
reset(); SlashCmdList.FOREVERJOURNAL("progress 3 5")
assert(has("Journal module not active: disabled."),
    "Core disabled must suppress Journal queries")
assert(not has("Progress: "), "no quest progress while disabled")
reset(); SlashCmdList.FOREVERJOURNAL("help")
assert(has("Commands: /fj"), "help remains available when disabled")
print = savedPrint
print("Journal Core bridge mock tests passed.")
