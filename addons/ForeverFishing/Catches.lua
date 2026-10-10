--[[
    ForeverFishing v0.2 manual, session-only catch tally.

    Every record is ENTERED BY THE PLAYER; no fishing or loot API confirms
    that the character caught, kept, owns or sold these items. This is a
    simple note-taking aid for future cooking/sale choices, not inventory
    or historical catch telemetry.

    Bounded to 10 species, each ≤9999 and total ≤99999; never polls,
    uses SavedVariables, reads game state, or sends network messages.
]]
local _, addon = ...
local MAX_SPECIES = 10
local MAX_COUNT_PER_ENTRY = 999
local MAX_COUNT_PER_SPECIES = 9999
local MAX_TOTAL = 99999
local MAX_NAME_BYTES = 60

local entries = {}
local order = {}
local total = 0

--- Validates a local display label; rejects WoW escape/link control codes.
--- @param value string Species label from the player.
--- @return string|nil name Validated, unmodified display name.
local function ValidateName(value)
    if type(value) ~= "string" or #value < 1
        or #value > MAX_NAME_BYTES or value:find("[%c|]")
        or value:match("^%s") or value:match("%s$") then
        return nil
    end
    if not value:match("^[%w]") then
        return nil
    end
    return value
end

--- Records an explicit player declaration; never reads inventory/loot.
--- @param quantity number Positive integer 1..999.
--- @param species string Label up to 60 bytes.
--- @return table|nil result Normalized recorded entry summary.
--- @return string|nil reason Rejection diagnostic.
function addon.LogCatch(quantity, species)
    local name = ValidateName(species)
    if not name or type(quantity) ~= "number"
        or quantity ~= quantity or quantity == math.huge
        or quantity < 1 or quantity > MAX_COUNT_PER_ENTRY
        or quantity ~= math.floor(quantity) then
        return nil, "Usage: /ffish log <1-999> <fish name>"
    end

    local key = string.lower(name)
    local old = entries[key]
    if not old and #order >= MAX_SPECIES then
        return nil, "Catch log full (10 species). Use /ffish clear."
    end
    if old and old.count + quantity > MAX_COUNT_PER_SPECIES then
        return nil, "Catch quantity limit reached (9999 per species)."
    end
    if total + quantity > MAX_TOTAL then
        return nil, "Catch total limit reached (99999)."
    end

    if not old then
        old = { name = name, count = 0 }
        entries[key] = old
        order[#order + 1] = key
    end
    old.count = old.count + quantity
    total = total + quantity
    return { name = old.name, count = old.count, added = quantity }
end

--- Drops all local catch notes; no client API reads.
function addon.ClearCatches()
    entries = {}
    order = {}
    total = 0
end

--- Only diagnostic counts; does not copy out the internal table.
--- @return number totalCount Manually logged fish total.
--- @return number uniqueSpecies Number of distinct manual labels.
function addon.CatchTotals()
    return total, #order
end

--- Prints at most 11 local chat lines (one header and ten species).
function addon.RenderCatches()
    if #order == 0 then
        addon.Print("No manual catches logged. Use /ffish log <count> <fish name>.")
        return
    end
    addon.Print(string.format(
        "Manual catches: %d fish across %d species (session only; not verified).",
        total, #order
    ))
    for _, key in ipairs(order) do
        local entry = entries[key]
        addon.Print(string.format(
            "%s: %d manually entered.", entry.name, entry.count
        ))
    end
end
