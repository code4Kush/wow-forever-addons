# Forever Journal

Version 0.1.0 — a small, independently installable development foundation for a future completionist addon.

## Current features

- /fj — help
- /fj version — version information
- /fj progress <completed> <total> — manually calculate completion percentage

This release does **not** automatically inspect quests or persist completion data. The progress command is a calculation tool, not a character tracker.

## Files

- ForeverJournal_Camelot.toc — manifest and file load order
- Core/Bootstrap.lua — namespace and chat output helper
- Modules/Progress.lua — pure completion math
- Core/Events.lua — minimal login lifecycle
- Core/Commands.lua — slash command parsing

## Installation

Copy the **entire ForeverJournal directory** into the appropriate Interface/AddOns folder for WoW: Forever. See ../../docs/DEVELOPMENT.md for details.

## Verification

Type /fj, /fj version, and /fj progress 3 5 in chat. The expected percentage is 60.00. No actual in-game pass has yet been recorded by this project.

## Roadmap ideas (not implemented)

Quest journal; per-zone checklist; exploration; profession logs; saved progress; optional UI panels. Prioritize user needs and client API evidence before implementation.
