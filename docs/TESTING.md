# Testing strategy

## Fast local tests

Run: lua5.1 tests/test_progress.lua

These exercises the pure calculation module without WoW and cover ordinary progress, rounding, bounds, zero totals, and invalid inputs.

GitHub Actions runs the same tests on pushes and pull requests. CI cannot launch the game client, so it does **not** certify addon load or API compatibility.

## Manual in-game test matrix

For each tested build, record:

- Game build and interface from /dump GetBuildInfo()
- Operating system and AddOns installation path
- Addon enabled/disabled state
- /fj help output
- /fj version output
- /fj progress 3 5 => 60.00%
- /fj progress 3 0 => 0.00%
- /fj progress bananas => usage text
- /reload followed by the same commands
- Lua errors or blocked API warnings

## Release policy

Do not call a version game-tested until an actual in-game pass has been recorded. Current status: **not tested in game by this repository initializer**.

Document failures with reproduction steps, expected/actual output, and the client build.
