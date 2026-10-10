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

The beta-oriented manifest is ForeverJournal_Camelot.toc. Its current Interface value is 16001. Confirm client support for the suffix and version in the AddOns screen after updates.

## Confirm your client build

In-game, run:

~~~text
/dump GetBuildInfo()
~~~

Record the result and compare the fourth return value with the manifest's Interface setting before changing it.

## Smoke test

1. Launch the client and enable Forever Journal in AddOns.
2. Log into a character.
3. Type /fj and expect a help message.
4. Type /fj version and expect 0.1.0.
5. Type /fj progress 3 5 and expect 60.00%.
6. Type /fj progress 3 0 and expect 0.00%.
7. Type /fj progress bananas and expect usage guidance.
8. After source changes, type /reload and repeat.

If the addon is missing, confirm path, exact TOC filename, interface version, and any load errors before changing code.

## Tests

~~~sh
lua5.1 tests/test_progress.lua
~~~

For optional static analysis:

~~~sh
luacheck addons
~~~

Never treat standalone tests as evidence that the game-facing code is compatible with a particular live client build.
