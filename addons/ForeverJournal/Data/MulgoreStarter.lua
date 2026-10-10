--[[
    Forever Journal: Mulgore Starter Quest Catalog
    Curated early Tauren quest IDs sourced from Classic/Forever reference data.
    Blizzard's server may change quest availability, titles, and requirements.

    This is deliberately a SMALL starter catalog, not the full Mulgore set.
    Keep quest IDs and titles separate from game status, which must come from
    live client APIs. Do not copy copyrighted quest text into the addon.

    Source and provenance: docs/QUEST_CATALOG.md
]]

local _, addon = ...

addon.MulgoreStarter = {
    name = "Mulgore starter catalog",
    entries = {
        { id = 747, label = "The Hunt Begins" },
        { id = 752, label = "A Humble Task (part 1)" },
        { id = 3091, label = "Simple Note (Warrior)", classToken = "WARRIOR" },
        { id = 750, label = "The Hunt Continues" },
        { id = 753, label = "A Humble Task (part 2)" },
        { id = 755, label = "Rites of the Earthmother (early)" },
        { id = 757, label = "Rite of Strength" },
        { id = 780, label = "The Battleboars" },
        { id = 781, label = "Attack on Camp Narache" },
        { id = 3376, label = "Break Sharptusk!" },
        { id = 763, label = "Rites of the Earthmother (to Bloodhoof)" },
        { id = 1656, label = "A Task Unfinished" },
    },
}
