--[[
    Forever Performance: On-Demand Memory Reader

    WoW's addon memory readings are in KB. They are *attributed addon Lua*
    usage, not whole-process RAM, and may fluctuate until garbage collection.
    UpdateAddOnMemoryUsage is invoked once per player-requested reading.
    No code in this file invokes collectgarbage or monitors frames over time.

    This intentionally tracks only known Forever packages whose descriptors
    are registered with Core, including packages logically disabled within
    the running session (loaded Lua remains allocated). It is NOT a global
    report of all installed or running third-party addons.
]]
local _, addon = ...

-- Upper bound: 12 folders, including Core and this optional pack.
-- Adding a released pack here is an explicit, reviewable change.
local KNOWN_PACKS = {
    { folder = "ForeverCore" },
    { folder = "ForeverDashboard", id = "dashboard" },
    { folder = "ForeverJournal", id = "journal" },
    { folder = "ForeverInventory", id = "inventory" },
    { folder = "ForeverGold", id = "gold" },
    { folder = "ForeverProfessions", id = "professions" },
    { folder = "ForeverFishing", id = "fishing" },
    { folder = "ForeverCooking", id = "cooking" },
    { folder = "ForeverWarrior", id = "forever-warrior" },
    { folder = "ForeverExplorer", id = "explorer" },
    { folder = "ForeverGuild", id = "guild" },
    { folder = "ForeverPerformance", id = "performance" },
}

local function ValidMemoryKB(value)
    -- Reject nil, NaN and infinity; never interpret missing API data as 0.
    return type(value) == "number" and value >= 0
        and value == value and value < math.huge
end

--- Takes exactly one fresh sample for the known, Core-registered pack set.
--- @return table|nil snapshot List of bounded rows and combined KB.
--- @return string|nil reason Error if an API or reading is unavailable.
function addon.TakeSnapshot()
    if type(UpdateAddOnMemoryUsage) ~= "function"
        or type(GetAddOnMemoryUsage) ~= "function" then
        return nil, "WoW addon memory API unavailable on this build."
    end

    -- A failed refresh cannot produce a trustworthy measurement.
    local refreshed = pcall(UpdateAddOnMemoryUsage)
    if not refreshed then
        return nil, "WoW memory refresh failed."
    end

    local entries = {}
    local totalKB = 0
    local byFolder = {}

    for _, pack in ipairs(KNOWN_PACKS) do
        local present = pack.id == nil
            or ForeverCore.GetModuleStatus(pack.id) ~= nil
        if present then
            local ok, kb = pcall(GetAddOnMemoryUsage, pack.folder)
            if not ok or not ValidMemoryKB(kb) then
                return nil, "Memory reading unavailable for " .. pack.folder .. "."
            end
            entries[#entries + 1] = { folder = pack.folder, kb = kb }
            byFolder[pack.folder] = kb
            totalKB = totalKB + kb
        end
    end

    if not ValidMemoryKB(totalKB) then
        return nil, "Combined memory reading invalid."
    end

    return {
        totalKB = totalKB,
        entries = entries,
        byFolder = byFolder,
    }
end

--- Returns at most N copied rows ranked by memory, with stable ties.
--- @param entries table Snapshot rows.
--- @param maximum number Upper bound of rows to return.
--- @return table ranking New array; original snapshot is unchanged.
function addon.TopMemory(entries, maximum)
    local sorted = {}
    for _, row in ipairs(entries or {}) do
        sorted[#sorted + 1] = { folder = row.folder, kb = row.kb }
    end
    table.sort(sorted, function(left, right)
        if left.kb == right.kb then
            return left.folder < right.folder
        end
        return left.kb > right.kb
    end)
    local limited = {}
    for index = 1, math.min(maximum, #sorted) do
        limited[#limited + 1] = sorted[index]
    end
    return limited
end

--- Compares only explicitly requested session snapshots.
--- A changed installed pack set means totals aren't directly comparable.
--- @param before table Captured baseline.
--- @param after table Current snapshot.
--- @return table comparison Total KB change and top absolute contributors.
function addon.Compare(before, after)
    local differences = {}
    local differentSet = #before.entries ~= #after.entries

    for folder, value in pairs(after.byFolder) do
        local previous = before.byFolder[folder]
        if previous == nil then
            differentSet = true
        else
            differences[#differences + 1] = {
                folder = folder,
                kb = value - previous,
            }
        end
    end
    for folder in pairs(before.byFolder) do
        if after.byFolder[folder] == nil then
            differentSet = true
        end
    end

    table.sort(differences, function(left, right)
        if math.abs(left.kb) == math.abs(right.kb) then
            return left.folder < right.folder
        end
        return math.abs(left.kb) > math.abs(right.kb)
    end)

    return {
        deltaKB = after.totalKB - before.totalKB,
        currentKB = after.totalKB,
        baselineKB = before.totalKB,
        changedSet = differentSet,
        differences = differences,
    }
end
