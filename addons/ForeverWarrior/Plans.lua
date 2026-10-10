--[[
    Forever Warrior: Level Plans

    Curated, level-banded advice; NOT a live talent simulator or item scanner.
    Forever beta talents and dungeon difficulty may change before launch.
    No game APIs are used here so this file can run in Lua 5.1 tests.
]]

local _, addon = ...

addon.Plans = {}
local Plans = addon.Plans

local LEVEL_BANDS = {
    {
        minimum = 1, maximum = 9, title = "Mulgore foundations (1-9)",
        combat = "Practice controlled pulls, rage use and safe positioning.",
        dungeon = "Plan your first Ragefire Chasm run in your teens.",
        professions = "Start Fishing and Cooking; collect cloth for First Aid.",
        nextGoal = "Reach level 10; inspect the current Protection talents.",
    },
    {
        minimum = 10, maximum = 12, title = "Early Protection training (10-12)",
        combat = "Review your live talents; practice rage and shield fundamentals.",
        dungeon = "Prepare equipment and quests for your first dungeon.",
        professions = "Gather ore while leveling and keep food supplies stocked.",
        nextGoal = "Begin your first supervised dungeon tank run.",
    },
    {
        minimum = 13, maximum = 19, title = "First dungeon leadership (13-19)",
        combat = "Protect the healer; control pulls and learn target recovery.",
        dungeon = "Practice Ragefire Chasm and prepare for Wailing Caverns.",
        professions = "Advance Fishing, Cooking, Mining and First Aid steadily.",
        nextGoal = "Lead a clean run and review what went wrong after each pull.",
    },
    {
        minimum = 20, maximum = 29, title = "Growing as a tank (20-29)",
        combat = "Practice multi-target threat, interruptions and defensive timing.",
        dungeon = "Learn Wailing Caverns and other appropriate dungeon routes.",
        professions = "Keep reserve gold; compare any useful crafted upgrade before buying.",
        nextGoal = "Become comfortable leading groups through unfamiliar pulls.",
    },
    {
        minimum = 30, maximum = 39, title = "Advanced dungeon practice (30-39)",
        combat = "Improve stance decisions, interrupts and recovery under pressure.",
        dungeon = "Learn boss mechanics and dangerous enemy abilities.",
        professions = "Compare raw fish and cooked-food prices before selling.",
        nextGoal = "Maintain a reliable defensive set and a solo questing setup.",
    },
    {
        minimum = 40, maximum = 49, title = "Plate armor progression (40-49)",
        combat = "Evaluate mitigation against damage and threat in context.",
        dungeon = "Practice harder pulls and organized party communication.",
        professions = "Upgrade equipment selectively and stock buff food.",
        nextGoal = "Prepare your tanking fundamentals for high-level dungeons.",
    },
    {
        minimum = 50, maximum = 59, title = "Pre-raid foundations (50-59)",
        combat = "Practice boss positioning, cooldown planning and tank swaps.",
        dungeon = "Build familiarity with high-level dungeon routes.",
        professions = "Build reserves of food, crafting materials and gold.",
        nextGoal = "Build both survival- and threat-focused equipment choices.",
    },
    {
        minimum = 60, maximum = nil, title = "Guild raid preparation (60+)",
        combat = "Prioritize encounter knowledge, consistency and communication.",
        dungeon = "Complete pre-raid preparation before organized progression.",
        professions = "Prepare repair gold, consumables and useful camp supplies.",
        nextGoal = "Earn trust through prepared, dependable group tanking.",
    },
}

--- Returns an advisory plan for a positive integer character level.
--- @param level number|nil The actual or recorded character level.
--- @return table|nil plan Static level-band guidance, or nil if unavailable.
function Plans.ForLevel(level)
    if type(level) ~= "number"
        or level ~= level
        or level < 1
        or level % 1 ~= 0 then
        return nil
    end

    for _, plan in ipairs(LEVEL_BANDS) do
        if level >= plan.minimum
            and (plan.maximum == nil or level <= plan.maximum) then
            return plan
        end
    end

    return nil
end

--- Returns reminders requiring player verification, not automated checks.
--- @return table checklist List of strings to display as unchecked.
function Plans.ManualReadiness()
    return {
        "Equip a one-handed weapon and shield for dungeon tanking.",
        "Repair equipment and train available Warrior abilities.",
        "Bring food, bandages and appropriate consumables.",
        "Collect dungeon quests and review the route.",
        "Check healer mana and party readiness before pulling.",
    }
end
