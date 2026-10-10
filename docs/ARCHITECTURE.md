# Architecture

## Design objectives

A single repository contains independently installable addons. No cross-addon dependency is required for Forever Journal version 0.1.0.

## Module boundaries

- Core/Bootstrap.lua: shared addon namespace and stable print helper.
- Modules/Progress.lua: pure completion arithmetic; no WoW dependencies.
- Core/Events.lua: client event registration and runtime lifecycle.
- Core/Commands.lua: chat command parsing and delegation.

The manifest lists files in dependency order: Bootstrap, Progress, Events, Commands.

## Data flow

Player types /fj progress 3 5 -> Commands parses counts -> Progress calculates percentage -> Bootstrap print helper writes to chat.

No external requests, filesystem access, automatic quest inspection, or saved-variable storage are performed.

## M1 independent ForeverCore candidate (not yet game-verified)

A second, separate addon package under `addons/ForeverCore/` now hosts a public cross-addon registry, character context and shared event frame. It can load by itself, or load before explicitly dependent optional probe packs. See `docs/CORE_CONTRACT.md`. This is additive: the working ForeverJournal code is not modified, integrated or migrated in M1. Durable profiles and Dashboard remain separate later milestones.

## Future expansion

Quest tracking, exploration, collections, persistence, and UI will be separate modules only after their APIs and data semantics are verified on the target game build. Avoid creating empty placeholders now.

## Dependencies

Shipped addon code depends only on the WoW Lua runtime and its exposed API. Standalone arithmetic tests run under Lua 5.1.
