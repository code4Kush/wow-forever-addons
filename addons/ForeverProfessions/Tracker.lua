--[[
    ForeverProfessions: player-requested, session-only skill comparison.

    A snapshot stores no more than five names and ranks. Nothing is saved
    to disk, published to chat channels, scanned in combat or polled in
    the background. Name-matching avoids comparing transient profession
    indexes. Locale or skill API changes can make a name uncomparable.
]]
local _, addon = ...
local snapshot

--- Saves a defensively copied, on-demand skill baseline.
--- @return number|nil count Number of readable skills captured.
--- @return string|nil reason Why no baseline could be recorded.
function addon.SaveSnapshot()
    local records, reason = addon.ReadSkills()
    if not records then
        return nil, reason
    end

    local byName = {}
    local names = {}
    for _, entry in ipairs(records) do
        byName[entry.name] = entry.rank
        names[#names + 1] = entry.name
    end
    snapshot = { byName = byName, names = names }
    return #names
end

--- Removes in-memory baseline; used by manual clear and Core Disable.
function addon.ClearSnapshot()
    snapshot = nil
end

--- Produces bounded comparison results for two manual skill readings.
--- Newly read skills are labelled incomparable, not gained-from-zero.
--- Missing skills are labelled unreadable, not lost or unlearned.
--- @return table|nil comparison Current and previous skill differences.
--- @return string|nil reason If comparison unavailable.
function addon.GetProgress()
    if not snapshot then
        return nil, "No snapshot. Use /fprof snapshot first."
    end

    local records, reason = addon.ReadSkills()
    if not records then
        return nil, reason
    end

    local rows = {}
    local now = {}
    local comparable = 0
    local changed = 0

    for _, entry in ipairs(records) do
        now[entry.name] = true
        local before = snapshot.byName[entry.name]
        if before == nil then
            rows[#rows + 1] = {
                name = entry.name, kind = "new", rank = entry.rank,
            }
        else
            local delta = entry.rank - before
            comparable = comparable + 1
            if delta ~= 0 then
                changed = changed + 1
            end
            rows[#rows + 1] = {
                name = entry.name, kind = "comparable",
                before = before, after = entry.rank, delta = delta,
            }
        end
    end

    for _, name in ipairs(snapshot.names) do
        if not now[name] then
            rows[#rows + 1] = { name = name, kind = "missing" }
        end
    end

    return {
        comparable = comparable,
        changed = changed,
        rows = rows,
    }
end

--- Renders one bounded, explicit comparison report in local chat.
function addon.RenderProgress()
    local result, reason = addon.GetProgress()
    if not result then
        addon.Print(reason)
        return
    end

    addon.Print(string.format(
        "Skill progress: %d comparable; %d changed (session only).",
        result.comparable, result.changed
    ))

    for _, row in ipairs(result.rows) do
        if row.kind == "comparable" then
            addon.Print(string.format(
                "%s: %+d skill (was %d; now %d).",
                row.name, row.delta, row.before, row.after
            ))
        elseif row.kind == "new" then
            addon.Print(string.format(
                "%s: newly readable at %d; no starting comparison.",
                row.name, row.rank
            ))
        else
            addon.Print(row.name .. ": not readable now; change unknown.")
        end
    end
end
