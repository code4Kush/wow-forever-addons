# Character profiles and optional pack presets

**Status:** Product design only — no profile selection or saved preferences exist in current shipping addon.

## Principles

A character profile determines *which installed and game-enabled packs are active for that character*. Player choice always overrides suggestions.

- Eligibility is derived from supported client APIs (race/class/profession), not a character-name allowlist.
- No stored account-wide aggregates without an explicit user decision.
- An optional pack remains physically installed if its in-game toggle is off; Disable must remove its active work and view.
- No source code must refer to Uddergrief as a special-case character, though tests can use the name as a fixture.
- Data recording depends on verified persistence; don't promise lifetime tracking until full cold-restart test passes.

## Suggested presets

| Preset | Enabled by suggestion | Optional add-ons |
| --- | --- | --- |
| Tank completionist | Dashboard, Journal, Inventory, Gold, Warrior | Professions, Fishing, Cooking, Explorer |
| Explorer | Dashboard, Journal, Explorer | Inventory, Gold |
| Gatherer/crafter | Dashboard, Inventory, Gold, Professions | Fishing, Cooking |
| Angler/chef | Dashboard, Fishing, Cooking, Inventory | Professions, Gold |
| Minimal | Core + one eligible chosen feature pack | Any other eligible module |

### First example: Uddergrief (Tauren Warrior)

Player has said the character is a Tauren Warrior named Uddergrief. Do not assume the current level, realm or known professions. Suggested initial choices: Journal + Dashboard + Warrior + Inventory + Gold. Enable Professions, Fishing and Cooking when the player wants them and they are supported. Explorer may be independently enabled.

### Testing another character

1. Record player-visible name/realm/class (dynamic; no hardcoded API values).
2. Select a different preset and disable Warrior.
3. Log onto Uddergrief. Verify his choices did not change.
4. Return to the other character. Verify the original choices remain.
5. Confirm disabled feature packs do no active work.
6. Cold restart to check setting retention, or explicitly label session-only if it fails.

Do not confuse presets with automatic class-based gameplay behavior. This is player-configured interface enablement only.
