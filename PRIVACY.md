# Privacy statement — development/pre-release

WoW Forever Addons is a community-developed, modular in-game addon project. **No production/public player release is certified yet.** Individual features may change before release.

## Current code

The shipped-in-repository Lua on `main` and proposed local Core module do **not** implement off-device network requests, analytics SDKs, account logins, screenshot uploads, advertising, or telemetry. In-game addons run inside the WoW client and consume permitted game-provided APIs.

The game's own service, Blizzard or platform features may handle player data independently of this project; this statement covers **our addon code only**, not the game's privacy practices.

Core's current development branch holds runtime character identity in memory for display/module eligibility. Per-character SavedVariables, cross-character aggregation, lifetime catch statistics and external companion synchronization are **future proposals, not currently available features**.

## Player controls and future changes

- Installing/enabling an addon is a separate choice from its future runtime module toggle.
- Planned future saved settings must clearly state whether data is account-wide, per-character or session-only, explain storage and deletion, and pass a game cold-restart test before promising retention.
- Do not collect passwords, Battle.net credentials, authentication tokens or private chat logs.
- No external collection, export or telemetry may be added without an explicit privacy review and disclosure. Any future companion application must be reviewed separately.

Security reports should be made privately through `.github/SECURITY.md`. Before public releases, this statement must be updated to reflect exactly what each shipped pack reads, retains and transmits.
