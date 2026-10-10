--[[
    ForeverWarrior v0.2: five bounded USER-CHECKED dungeon reminders.
    No gear/buff/talent scans, game events, timers or SavedVariables.
    Core disable and reload discard all flags. Never mark automatically.
]]
local _, addon = ...
local tasks = addon.Plans.ManualReadiness()
local flags = {}

--- Mark or unmark exactly one user-verified checklist item.
function addon.MarkReady(index, checked)
    if type(index) ~= "number" or index < 1 or index > #tasks
        or index % 1 ~= 0 or type(checked) ~= "boolean" then
        return false
    end
    flags[index] = checked or nil
    return true
end

--- Drop session-only manual progress on request or Core disable.
function addon.ClearReady()
    flags = {}
end

--- Display five human-verified tasks, without any client API reads.
function addon.RenderReady()
    local count = 0
    for index = 1, #tasks do
        if flags[index] then count = count + 1 end
    end
    addon.Print("Dungeon readiness checklist (MANUAL; not checked by addon):")
    addon.Print(string.format("Readiness: %d/%d manually checked (session only).",
        count, #tasks))
    for index, task in ipairs(tasks) do
        addon.Print(string.format("%d. [%s] %s",
            index, flags[index] and "x" or " ", task))
    end
end
