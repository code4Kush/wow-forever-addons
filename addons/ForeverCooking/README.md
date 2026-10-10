# ForeverCooking 0.2 — optional Cooking skill + manual ingredient prep

**Draft development candidate** in [PR #39](https://github.com/code4Kush/wow-forever-addons/pull/39); **NOT YET VERIFIED IN THE REAL GAME**. Fishing/Cooking v0.1–0.2 skill reads needed an open profession window in user-reported testing of WoW Forever beta 1.60.1 build 70338. This update attempts an already-demonstrated independent profession-list route; only actual subsequent player testing can verify the new behavior.

## Modular operation

ForeverCooking is an **independent addon folder** requiring `ForeverCore` 0.2+, but no other optional pack. It reads no bags, recipes, auction prices or cast results. The skill reader first attempts `GetProfessions` and `GetProfessionInfo` with a maximum of five sparse slots, matching by English profession name and validating rank/cap. If unavailable, it attempts the preexisting `C_TradeSkillUI.GetBaseProfessionInfo` reader when the Cooking window is open. It does not infer that a missing rank is zero or that the skill is unlearned.

The **manual ingredient plan** tracks only labels and quantities typed by the player. This is not inventory, recipe progress or cooking materials possessed. The plan stores up to 10 unique labels and up to 9999 units per label in Lua memory, resets on /reload and Core logical disable, and never uses SavedVariables or network access.

## Commands — ONE WoW chat command per entry

**Read Cooking skill (when no profession window is open, new experiment):**

~~~text
/fcook
~~~

Expected format if the profession-list API returns Cooking:

~~~text
Forever Cooking: Cooking: <RANK>/<MAX> (profession list).
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

If the list isn't available but the Cooking UI is open:

~~~text
Forever Cooking: Cooking: <RANK>/<MAX> (open profession window).
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

If neither supports a valid Cooking rank:

~~~text
Forever Cooking: Cooking skill not readable; open Cooking UI and retry.
Forever Cooking: Recipes and ingredient counts are NOT scanned.
~~~

**Add an explicitly manual ingredient need:**

~~~text
/fcook need 3 Raw Brilliant Smallfish
~~~

Expected if list was empty:

~~~text
Forever Cooking: Planned manually: Raw Brilliant Smallfish +3 (need 3).
~~~

**Display manual ingredient plan:**

~~~text
/fcook needs
~~~

Expected after just that example:

~~~text
Forever Cooking: Ingredient plan: 3 units across 1 label (manual; not bag contents).
Forever Cooking: Raw Brilliant Smallfish: need 3 (player-entered).
~~~

**Remove a manually planned ingredient (without suggesting it was acquired):**

~~~text
/fcook done Raw Brilliant Smallfish
~~~

Expected after only the example 3-fish entry:

~~~text
Forever Cooking: Removed manual ingredient: Raw Brilliant Smallfish (3 planned).
~~~

**Clear manual plan:**

~~~text
/fcook clear
~~~

Expected exact:

~~~text
Forever Cooking: Manual ingredient plan cleared (session only).
~~~

**Version:**

~~~text
/fcook version
~~~

Expected exact:

~~~text
Forever Cooking: Version 0.2.0
~~~

See [FISHING_COOKING_TESTING.md](../../docs/FISHING_COOKING_TESTING.md) for guarded failure cases, optional-pack isolation and one-round player testing.

## Safety, tests and limitations

No timers, frame polling, events, logout persistence, combat automation, auto-fishing, auto-cooking, automatic item use, external services or outbound addon messages. All API reads are performed only after /fcook or /fcook skill and are blocked during combat. Ingredient notes can be entered without any game APIs. Data isn't transferred to ForeverFishing, Inventory, Professions, or other packs.

This repository has unresolved license, independent security review, game policy and public-release gates. A clean mock CI run does not authorize player distribution.
