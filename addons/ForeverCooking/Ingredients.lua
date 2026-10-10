--[[
    ForeverCooking: PLAYER-ENTERED ingredient shopping/meal prep notes.

    No client inventory API, recipe scan, crafting action, or cached item
    holdings. This is a short bounded checklist, session-only, discarded
    whenever Core disables the cooking module or WoW reloads. Entries never
    transfer to Fishing, Inventory or other optional packs.
]]
local _, addon = ...
local MAX_LABELS = 10
local MAX_ENTRY_AMOUNT = 999
local MAX_PER_LABEL = 9999
local MAX_NAME_BYTES = 60
local items = {}
local order = {}
local total = 0

local function ValidName(name)
    return type(name) == "string" and #name > 0 and #name <= MAX_NAME_BYTES
        and not name:find("[%c|]")
        and not name:match("^%s") and not name:match("%s$")
        and name:match("^[%w]") ~= nil
end

--- Add a manual ingredient quantity to an in-memory shopping plan.
--- @param count number Human-entered quantity (1..999).
--- @param name string Display name, not a verified game item ID.
--- @return table|nil entry Added and accumulated human-entered amounts.
--- @return string|nil reason Safety or capacity error.
function addon.AddNeed(count, name)
    if not ValidName(name) or type(count) ~= "number"
        or count ~= count or count < 1 or count > MAX_ENTRY_AMOUNT
        or count % 1 ~= 0 then
        return nil, "Usage: /fcook need <1-999> <ingredient name>"
    end
    local key = string.lower(name)
    local old = items[key]
    if not old and #order >= MAX_LABELS then
        return nil, "Ingredient list full (10 names). Use /fcook clear."
    end
    if old and old.count + count > MAX_PER_LABEL then
        return nil, "Ingredient quantity limit reached (9999 per name)."
    end
    if not old then
        old = { name = name, count = 0 }
        items[key] = old
        order[#order + 1] = key
    end
    old.count = old.count + count
    total = total + count
    return {name = old.name, count = old.count, added = count}
end

--- Display only explicitly entered notes, never actual bag counts.
function addon.RenderNeeds()
    if #order == 0 then
        addon.Print("No manual ingredients planned. Use /fcook need <count> <ingredient>.")
        return
    end
    addon.Print(string.format(
        "Ingredient plan: %d units across %d %s (manual; not bag contents).",
        total, #order, #order == 1 and "label" or "labels"
    ))
    for _, key in ipairs(order) do
        local entry = items[key]
        addon.Print(string.format("%s: need %d (player-entered).",
            entry.name, entry.count))
    end
end

--- Remove one human-entered ingredient without reading actual inventory.
--- @param name string Player-entered ingredient name, matched case-insensitively.
--- @return table|nil removed Previous name/count if note existed.
--- @return string|nil reason Why removal was rejected.
function addon.RemoveNeed(name)
    if not ValidName(name) then
        return nil, "Usage: /fcook done <ingredient name>"
    end
    local key = string.lower(name)
    local previous = items[key]
    if not previous then
        return nil, "Ingredient not in manual plan."
    end
    items[key] = nil
    for index, existing in ipairs(order) do
        if existing == key then
            table.remove(order, index)
            break
        end
    end
    total = total - previous.count
    return {name = previous.name, count = previous.count}
end

--- Delete human-entered plan on /fcook clear and Core disable.
function addon.ClearNeeds()
    items, order, total = {}, {}, 0
end

--- Return only aggregate count for tests/diagnostics.
--- @return number totalUnits Sum of manual quantities.
--- @return number labels Count of distinct player-entered names.
function addon.NeedTotals()
    return total, #order
end
