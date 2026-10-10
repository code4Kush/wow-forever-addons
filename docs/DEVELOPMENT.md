# Development setup

## Prerequisites

- World of Warcraft: Forever beta client (or a later supported client, after compatibility review).
- A text editor with Lua support; Lua Language Server is recommended.
- Lua 5.1 for local tests; Luacheck is optional.
- Git for source control.

## Installing on macOS

First locate the game directory used by your own Battle.net installation. For the beta, the expected addon folder is often:

~~~text
/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/
~~~

Actual locations can differ. Copy the **ForeverJournal** directory from addons/ into that AddOns directory. The TOC file must sit directly inside the ForeverJournal folder.

For an existing installation, synchronize the full addon directory so newly added modules are included:

~~~sh
cd ~/Developer/wow-forever-addons
git fetch origin
git switch --track origin/feat/forever-journal-quest-log

rsync -av addons/ForeverJournal/ \
    "/Applications/World of Warcraft/_classic_beta_/Interface/AddOns/ForeverJournal/"
~~~

If you installed WoW elsewhere, replace the destination with your own client directory. Check `git status` first if you have local source changes and do not switch branches until those changes are committed or saved. Run `/reload` after synchronization.

The beta-oriented manifest is ForeverJournal_Camelot.toc. Its current Interface value is 16001. Confirm client support for the suffix and version in the AddOns screen after updates.

## Confirm your client build

In-game, run:

~~~text
/dump GetBuildInfo()
~~~

Record the result and compare the fourth return value with the manifest's Interface setting before changing it.

## Smoke test

1. Launch the client and enable Forever Journal in AddOns.
2. Log into a character and type `/fj`; check the help message.
3. Type `/fj version`; confirm 0.2.0 on the development branch.
4. Type `/fj progress 3 5`; confirm 60.00%.
5. Type `/fj zone`; confirm your current area or map.
6. Type `/fj quests`; inspect your currently accepted quests.
7. Use an ID from the list with `/fj quest <ID>`; compare objective text against the game's quest log.
8. Try `/fj quests 0` and `/fj quest invalid`; expect help, not Lua errors.
9. After source changes, type `/reload` and repeat.

See `docs/TESTING.md` for the complete v0.2.0 manual verification matrix.

If the addon is missing, confirm path, exact TOC filename, interface version, and any load errors before changing code.

## Tests

~~~sh
lua5.1 tests/test_progress.lua
lua5.1 tests/test_questlog.lua
~~~

For optional static analysis:

~~~sh
luacheck addons
~~~

Never treat standalone tests as evidence that the game-facing code is compatible with a particular live client build.
