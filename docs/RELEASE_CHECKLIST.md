# Pre-release review checklist

Complete a fresh copy of this checklist for every publicly distributed addon release. Store evidence in PR/release notes.

## Compliance

- [ ] Read official Blizzard UI addon policy and EULA; record date reviewed.
- [ ] All addon behavior is free; no paywalls, premium features, in-game ads or in-game donation prompts.
- [ ] All distributed source is complete, readable, unobfuscated and publicly accessible.
- [ ] Third-party code/assets are reviewed for permission and licensing; no bundled proprietary Blizzard music/art.
- [ ] No botting, unauthorized client modification, combat automation, exploit use, memory reading, secret-value bypasses or protocol manipulation.
- [ ] No excessive event scanning, frame-rate impact, chat flooding or unnecessary persistence writes.
- [ ] Content, naming, and branding do not imply Blizzard endorsement.

## Client compatibility

- [ ] Target game client and build are explicitly recorded.
- [ ] TOC interface and flavor suffix are observed against this client.
- [ ] All APIs used have evidence links or actual in-game test notes in API_NOTES.md.
- [ ] Lua 5.1 syntax and TOC file order verified.
- [ ] Game starts with the addon enabled and no reported Lua errors.
- [ ] Slash commands, /reload, fresh login, and cold game restart manually tested.
- [ ] Any persisted settings survive a cold restart.
- [ ] Behavior in combat respects protected/secret-value restrictions.

## Engineering

- [ ] Unit tests run; actual results recorded.
- [ ] Static analysis run where available; results recorded.
- [ ] Documentation and changelog updated.
- [ ] Code review confirms naming, comments, modularity, and no copied unlicensed code.
- [ ] Publication location and full source link documented.
- [ ] Distinguish **game tested** from **CI passing** and **community reported**.

## External application gate (if a companion app is added)

- [ ] Registered a Blizzard Developer API client if using Blizzard web APIs.
- [ ] Reviewed current Developer API Terms including API-key confidentiality, data source attribution, premium-feature prohibitions, privacy and data-retention rules.
- [ ] No API keys committed to Git or embedded in publicly distributed client code.
- [ ] External companion does not scrape game memory, circumvent restrictions, or claim access to unavailable in-game data.

References and scope: see [BLIZZARD_POLICY.md](BLIZZARD_POLICY.md).
