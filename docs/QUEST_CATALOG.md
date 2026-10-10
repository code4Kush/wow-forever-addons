# Curated Mulgore starting quest catalog

**Catalog revision:** 2026-10-10  
**Target:** WoW: Forever interface 16001; Tauren starting quests, with one Warrior-only entry.  
**Size:** 12 known quest IDs for Tauren Warriors; 11 for other Tauren classes.

This catalog is intentionally **not a comprehensive list of all Mulgore quests**. There are quests not included here, and the beta may add, remove, or alter quests. Do **not** label the fraction as a zone-wide completion percentage. The addon does not claim an unflagged quest can be accepted.

## Data provenance

Quest names/IDs are reviewed against short publicly indexed quest references. We include IDs and short titles, not Blizzard's copyrighted quest descriptions, NPC dialogue, rewards, or objective text. Classic reference data may be inaccurate for current Forever quests. The actual completed/active status is always read from WoW at command time.

| ID | Label used in journal | Source | Status of source |
| --- | --- | --- | --- |
| 747 | The Hunt Begins | https://theforeverera.com/en/quests/747/ | Quest and ID confirmed live by player |
| 752 | A Humble Task (part 1) | https://theforeverera.com/en/quests/752/ | Quest and ID confirmed live by player |
| 3091 | Simple Note (Warrior) | https://theforeverera.com/en/quests/3091/ | Community beta ID reference; class-specific |
| 750 | The Hunt Continues | https://wowforever.wclbox.com/en/renwu/750 | Community beta ID reference |
| 753 | A Humble Task (part 2) | https://theforeverera.com/en/quests/753/ | Community beta ID reference |
| 755 | Rites of the Earthmother (early) | https://theforeverera.com/en/quests/755/ | Community beta ID reference |
| 757 | Rite of Strength | https://www.wowhead.com/classic/quest=757/rite-of-strength | Classic quest ID reference |
| 780 | The Battleboars | https://www.wowhead.com/forever/quest=780/the-battleboars | Forever quest ID reference |
| 781 | Attack on Camp Narache | https://theforeverera.com/en/quests/781/ | Community beta ID reference |
| 3376 | Break Sharptusk! | https://theforeverera.com/en/quests/3376/ | Community beta ID reference |
| 763 | Rites of the Earthmother (to Bloodhoof) | https://theforeverera.com/en/quests/763/ | Community beta ID reference |
| 1656 | A Task Unfinished | https://theforeverera.com/en/quests/1656/ | Community beta ID reference |

Sources:
- https://warcraft.wiki.gg/wiki/Mulgore_quests
- https://theforeverera.com/en/quests/zone/mulgore/

### What status means

- `done`: `C_QuestLog.IsQuestFlaggedCompleted(id)` is true.
- `ready`: not historically completed, but active and ready for turn-in.
- `active`: in active quest log, not yet ready for turn-in.
- `not flagged`: neither historically completed nor active. The quest may be unaccepted, abandoned, out of scope, or an invalid/changed ID.

New catalog entries require an ID source link, applicability notes, and validation. The denominator changes when entries are added; progress fractions from different catalog versions are not comparable.
