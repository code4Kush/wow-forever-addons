--[[
    Forever Performance: One-Command Memory Reports

    Players trigger all measurements themselves. No data leaves the client,
    no timer or OnUpdate work, no forced garbage collection, and at most
    12 per-addon lines from a deliberately bounded built-in catalog.
]]
local _, addon = ...

local function PrintHelp()
    addon.Print("Commands: /fperf memory | details | baseline | delta | clear")
    addon.Print("/fperf version | help; samples are on demand, not continuous.")
end

local function Acquire()
    local snapshot, reason = addon.TakeSnapshot()
    if not snapshot then
        addon.Print(reason or "Memory measurement unavailable.")
    end
    return snapshot
end

local function PrintSummary()
    local snapshot = Acquire()
    if not snapshot then
        return
    end
    addon.Print(string.format(
        "Memory: %d known loaded pack(s), %.2f KB total (addon-attributed).",
        #snapshot.entries, snapshot.totalKB
    ))
    for index, row in ipairs(addon.TopMemory(snapshot.entries, 3)) do
        addon.Print(string.format(
            "Top %d: %s %.2f KB.", index, row.folder, row.kb
        ))
    end
end

local function PrintDetails()
    local snapshot = Acquire()
    if not snapshot then
        return
    end
    addon.Print(string.format(
        "Details: %d known loaded pack(s), %.2f KB total.",
        #snapshot.entries, snapshot.totalKB
    ))
    -- Bounded rows in stable catalog order. Disabled-but-loaded modules
    -- still consume memory and appear here.
    for _, row in ipairs(snapshot.entries) do
        addon.Print(string.format("%s: %.2f KB.", row.folder, row.kb))
    end
end

local function SaveBaseline()
    local snapshot = Acquire()
    if not snapshot then
        return
    end
    addon.baseline = snapshot
    addon.Print(string.format(
        "Baseline saved: %.2f KB across %d pack(s) (session only).",
        snapshot.totalKB, #snapshot.entries
    ))
end

local function PrintDelta()
    if not addon.baseline then
        addon.Print("No baseline. Use /fperf baseline first.")
        return
    end

    local snapshot = Acquire()
    if not snapshot then
        return
    end
    local comparison = addon.Compare(addon.baseline, snapshot)
    addon.Print(string.format(
        "Since baseline: %+.2f KB (was %.2f KB; now %.2f KB).",
        comparison.deltaKB, comparison.baselineKB, comparison.currentKB
    ))

    if comparison.changedSet then
        addon.Print("Loaded pack set changed; totals are not directly comparable.")
    end

    for index = 1, math.min(3, #comparison.differences) do
        local row = comparison.differences[index]
        addon.Print(string.format("Change: %s %+.2f KB.", row.folder, row.kb))
    end
end

--- Handles a player-entered slash command without running game actions.
--- @param message string|nil Text after /fperf.
local function HandleSlashCommand(message)
    local command = (message or ""):match("^%s*(.-)%s*$")
    command = string.lower(command)

    if command == "" or command == "help" then
        PrintHelp()
        return
    end
    if command == "version" then
        addon.Print("Version " .. addon.version .. " (on-demand only).")
        return
    end

    -- All working memory commands require an actively enabled module.
    local status = ForeverCore.GetModuleStatus("performance")
    if not status or status.state ~= "active" then
        addon.Print("Module not active: "
            .. (status and status.state or "not registered") .. ".")
        return
    end

    if command == "memory" then
        PrintSummary()
    elseif command == "details" then
        PrintDetails()
    elseif command == "baseline" then
        SaveBaseline()
    elseif command == "delta" then
        PrintDelta()
    elseif command == "clear" then
        addon.baseline = nil
        addon.Print("Baseline cleared (session only).")
    else
        addon.Print("Usage: /fperf [memory|details|baseline|delta|clear|version|help]")
    end
end

SLASH_FOREVERPERFORMANCE1 = "/fperf"
SlashCmdList.FOREVERPERFORMANCE = HandleSlashCommand
