# ForeverDashboard 0.2 — optional lazy module hub

**Status:** Development candidate in [draft PR #37](https://github.com/code4Kush/wow-forever-addons/pull/37). Lua 5.1 mock tests assert one reusable frame/label and bounded paging, but the new UI has **not yet been verified in game** on WoW Forever 1.60.1 build 70338.

## Purpose

A small, optional, draggable window for showing exactly which **installed and Core-registered** modules are active, disabled, ineligible, blocked, or unavailable. Up to six modules per page. Core handles actual lifecycle; Dashboard **never** disables or enables another pack automatically.

Modules not installed or disabled in the game's **AddOns** screen do not load and cannot register; Dashboard must not invent their presence. Core-logically-disabled modules can still occupy Lua memory until interface reload, so Dashboard shows their disabled status instead of pretending they were unloaded.

## Installation

The only dependency is `ForeverCore` 0.2+. Copy the entire `addons/ForeverDashboard/` directory to WoW beta's `Interface/AddOns/ForeverDashboard/` while the client is closed and enable it in the AddOns menu. No other optional pack is required. A full modular test build may instead be assembled with `python3 tools/build_dev_bundle.py --profile full --output dist/ForeverSuite-full-DEV.zip`. See [FULL_SUITE_TESTING.md](../../docs/FULL_SUITE_TESTING.md).

## Single-command WoW chat interface

**Toggle the dashboard:**

~~~text
/fdash
~~~

Expected exact on first open:

~~~text
Forever Dashboard: Dashboard shown.
~~~

Enter the same command separately to close; expected exact:

~~~text
Forever Dashboard: Dashboard hidden.
~~~

**Next page:**

~~~text
/fdash next
~~~

Expected when at least seven registered modules exist:

~~~text
Forever Dashboard: Dashboard page 2/<PAGES>.
~~~

Pages clamp to the available registered packs. For fewer than seven, expect `Dashboard page 1/1.`

**Previous page:**

~~~text
/fdash prev
~~~

Expected when there are two pages:

~~~text
Forever Dashboard: Dashboard page 1/2.
~~~

**Local status report without creating a frame:**

~~~text
/fdash status
~~~

Expected format:

~~~text
Forever Dashboard: <N> registered module(s); <ACTIVE> active. (Core logical disabling does not unload Lua.)
~~~

**Version:**

~~~text
/fdash version
~~~

Expected exact:

~~~text
Forever Dashboard: Version 0.2.0
~~~

**Help:**

~~~text
/fdash help
~~~

Expected exact:

~~~text
Forever Dashboard: Commands: /fdash | next | prev | status | version | help
Forever Dashboard: On-demand, six module rows per page; never polls.
~~~

## Performance, boundaries and risks

The pack registers **no game events**, performs no idle work, creates the first frame on the first visible window open, then reuses one frame and one font label for every page. `/fdash status` only requests one current Core registry snapshot and never allocates a frame. It does not use `OnUpdate`, timers, SavedVariables, permanent UI tracking or network connections. Frame movement is explicitly user initiated and guarded during combat. If UI APIs are missing, commands produce an unavailable line instead of crashing.

Lua mocked tests check frame/label creation count and legacy toggle regression. **This is not a measured in-game memory or FPS comparison.** The earlier Dashboard 0.1 observed 11.32 KB at first and 31.90 KB after manually collecting garbage during repeated open/close testing; those observations were not made on this version and cannot be used to claim v0.2 optimization.

Source is readable, free development code but repository license, security and public-release gates remain unfinished. Nothing here authorizes a public player release.
