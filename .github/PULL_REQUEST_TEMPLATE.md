## Summary and purpose

**What changes, and why does it matter to a player?** Describe behavior before and after, not just commits.

**Linked issue / milestone:** Closes #___ / Ref #___

**Status:** [ ] Draft / implementation [ ] CI verified [ ] Live game verified [ ] Release candidate

## Scope and change inventory

| Path / module | Responsibility and public interface changed |
| --- | --- |
| `path/to/file.lua` | Describe the observable behavior and dependencies |

**Out of scope:** Call out intentionally deferred work and missing integrations.

**Dependencies and stack:** Which PRs must merge first? What base branch and version compatibility assumptions exist?

## API and architecture evidence

- **Target WoW flavor / interface / full build:** `<unknown until tested>`
- **WoW APIs introduced or changed:** List APIs, source links, runtime guard/fallback behavior, and known restrictions.
- **Module/TOC load order and dependencies:** Note required vs optional packs and event/subscription lifecycle changes.
- **Storage/settings:** None, or schema version, migration, character/account scope, reload and full-restart outcomes.
- **Compatibility and performance:** Client restrictions, protected/secret-value risks, bounded events, potential chat spam.
- **Copyright/licensing:** State third-party code/assets and license checks; no copied Blizzard quest text or media without permission.

## Verification evidence — do not conflate tests

**Automated (exact SHA):** `<full SHA>`  
CI run URL: `<URL or NOT RUN>`  
Tests and outcomes: `<PASS / FAIL / NOT RUN>`  
What mocks cannot prove: `<details>`

**In-game (record actual result or mark NOT TESTED IN GAME):**

Game build/interface: `<build>` Character: `<class/race>` Date: `<YYYY-MM-DD>`

Put each WoW slash command in **a separate fenced block**. Include each command's exact expected output in its own block, explain dynamic placeholders, and record the **actual** output, PASS/FAIL, and screenshots (if relevant).

**Command / action:**
```text
/your-addon command
```

**Expected output:**
```text
<literal expected output, with dynamic fields marked>
```

**Actual output and verdict:** `NOT TESTED / PASS / FAIL` and a reference to screenshot/log.

**Error/edge cases and regression:** Include unsupported API, missing pack, different character, invalid input, `/reload` and full client restart when relevant.

## User documentation

- [ ] Purpose, feature behavior, commands and limitations explained in README.
- [ ] Lua public functions/namespace documented with parameter/return/error contracts; modules have purpose headers and lifecycle notes.
- [ ] `docs/API_NOTES.md` or equivalent links actual API evidence and client build.
- [ ] Architecture and TOC/load-order changes recorded.
- [ ] `CHANGELOG.md` updated for user-facing behavior.
- [ ] Linked issue's acceptance checks updated with **only verified** results.

## Security and public release impact

- [ ] No automation of gameplay, protected/secret-value bypass, unsafe memory access, or network behavior from in-game Lua.
- [ ] No paid/premium features, in-game advertising or donation solicitation.
- [ ] Source is readable and unobfuscated; distribution will include public access to complete code.
- [ ] No secrets, private player information, unauthorized media or unlicensed third-party material committed.
- [ ] Does this require a documentation/license/packaging update before public release? Explain.

**Risk and rollback:** `<what might break, how to disable or restore>`

**Review decision / outstanding work:** `<clear blockers, approved scope, next check>`
