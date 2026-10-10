# Blizzard policy and official developer resources

Review date: 2026-10-10. This is a developer-facing summary, not legal advice or an official certification. Recheck linked originals before release.

## Authority and scope

There are two different development routes:

1. **In-game WoW addon**: Lua/XML/TOC loaded by the game. Follow the World of Warcraft UI Add-On Development Policy and Blizzard End User License Agreement. These addons do not require a Blizzard Developer Portal API client simply to use in-game UI functions.
2. **External website/desktop/companion app using Blizzard web APIs**: This separately invokes the Blizzard Developer API Terms of Use, requiring a registered application and appropriately protected credentials.

Blizzard's old GitHub repository `Blizzard/api-wow-docs` documents **web APIs**, not the live in-game Lua API; its README redirects readers to `https://dev.battle.net/`. Do not use that repository to assert Lua compatibility.

## Official UI Add-On Development Policy — eight rules

Primary source: https://us.forums.blizzard.com/en/wow/t/ui-add-on-development-policy/24534

1. Distribute addons free of charge; no paid features, premium builds, or required payment for addon access/services.
2. Make the complete addon program code readable, unobfuscated, and publicly viewable when distributing. Source visibility is required; this policy does **not** itself prescribe an OSI-approved source-code license.
3. Do not negatively affect realms or other players (e.g., excessive chat messages, disk activity, CPU work, or frame-rate degradation).
4. Do not place advertising or commercial promotion in an addon.
5. Do not solicit donations inside the game. If requested, donation messages belong outside the game on appropriate websites or distribution pages.
6. Keep content appropriate for the game's ratings and community standards.
7. Follow the WoW Terms of Use and the Blizzard EULA.
8. Accept that Blizzard can change or disable any addon capability at its discretion.

**Project interpretation:** Developing in a private repository is not by itself public distribution; before public distribution, ensure the full addon code is accessible to everyone. Make a conscious choice of license for *our own* code, but do not imply that a particular license is mandated by Blizzard.

## EULA boundaries

Official source: https://www.blizzard.com/en-us/legal/simple/bfbbb648-bcc6-4b78-a5c7-e2fe20c135df/blizzard-end-user-license-agreement

Do not build or ship bots, automated character control, exploits, hacks, unauthorized memory readers/data mining, unauthorized client changes, protocol interception or server emulation. Do not package Blizzard copyrighted sound/music or art assets for redistribution without rights; ordinary game UI asset references are not the same as redistributing copyrighted files.

Use supported in-client UI functions, and favor informational/presentation features over automation. No anti-cheat bypasses or attempts to get secret combat values.

## Modern combat API policy and Forever status

Blizzard's official engineering communication explains that modern addons may **display** certain combat data but cannot process protected secret values to drive gameplay decisions:
https://news.blizzard.com/en-gb/article/24246290/combat-philosophy-and-addon-disarmament-in-midnight

For Forever specifically, statements attributed to Blizzard's UI team and beta observations indicate it shares the Mainline family and Midnight's addon disarmament rules. The direct official team communication was not independently authenticated in this review; do not present this community relay as an official published policy:
- https://us.forums.blizzard.com/en/wow/t/submit-your-question-for-the-live-wow-qa-on-september-17/2347251/1287
- https://github.com/Thunderz96/forever-addon-kit

The beta `## Interface: 16001`, product folder `_classic_beta_`, and `_Camelot.toc` suffix are **community-observed compatibility values**, not guarantees from an official Blizzard GitHub addon SDK. Check `GetBuildInfo()` and verify actual addon loading with the current beta build.

## Blizzard GitHub and UI source repositories: correctly categorized

- Official `https://github.com/Blizzard/api-wow-docs`: archived/legacy **web API** guidance, points to developer portal. Not a WoW addon SDK.
- `https://github.com/Gethe/wow-ui-source`: **independent mirror** of Blizzard's UI code, useful technical reference; not an official Blizzard-maintained GitHub repo.
- `https://github.com/Atraeau/WoW-Addons` and `https://github.com/Thunderz96/forever-addon-kit`: community-maintained Forever development references, useful test evidence but not policy authority.

Prefer observing live client exports/API documentation and running actual in-game tests over trusting an outdated mirror.

## External Blizzard Developer API: only if later needed

Official terms: https://www.blizzard.com/en-us/legal/a2989b50-5f16-43b1-abec-2ae17cc09dd6/blizzard-developer-api-terms-of-use
Developer portal: https://dev.battle.net/

When an external app uses Blizzard web APIs, its own registered client/credentials and API terms apply separately. Relevant provisions include: no premium features dependent on those APIs; protect API credentials; credit Blizzard as data source without implying endorsement; no use of Blizzard API data for advertising/marketing; restricted redistribution; data-refresh/retention obligations (the current linked terms describe a maximum 30-day TTL); and account/age/content limitations. Review the **full current terms** with each external-app release.

WoW's in-game Lua addons cannot simply issue arbitrary HTTP requests or access a general OS filesystem. An external companion is a separate architecture and compliance review—not a workaround for restricted game information.

## Project gate

The build is **not Blizzard certified or officially endorsed** merely because it follows these rules. See [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) before publishing.
