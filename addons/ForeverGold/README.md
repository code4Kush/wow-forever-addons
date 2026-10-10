# ForeverGold v0.2.0 — manual wallet tracking

**State:** Lightweight development candidate in [draft PR #29](https://github.com/code4Kush/wow-forever-addons/pull/29), **NOT YET LIVE TESTED**. It is built for WoW Forever interface `16001`; the player's last confirmed client is **1.60.1, build 70338, Oct 9 2026**, but `GetMoney()` has not yet been verified on that exact client.

## Why use it?

While questing, gathering or running dungeons, check your current wallet and optionally compare it with a starting balance. It is a transparent read-only diagnostic, not a gold-making automation feature.

The number is **NET WALLET CHANGE, NOT PROFIT OR EARNINGS**. Purchases, repair costs, training costs, auctions, trades, mail and guild-bank transfers affect your balance. It cannot tell you which transaction caused a change.

## Install

Install `ForeverCore` 0.2+ first, then copy `addons/ForeverGold/` to WoW's `Interface/AddOns/ForeverGold/` directory. Enable both addons in WoW's AddOns screen. To uninstall, quit WoW and remove only `ForeverGold/`; your other feature packs remain intact. The TOC suffix is `_Camelot.toc`.

## Commands — send one WoW command at a time

**Current wallet**:

```text
/fgold
```

Expected format:

```text
Forever Gold: Wallet: <G>g <S>s <C>c (current character; not earnings).
```

**Save starting wallet**:

```text
/fgold baseline
```

Expected format:

```text
Forever Gold: Baseline saved: <G>g <S>s <C>c (session only).
```

**Compare later wallet**:

```text
/fgold delta
```

Expected format (sign may be `+` or `-`; amounts depend on your gold changes):

```text
Forever Gold: Wallet change: <SIGN><G>g <S>s <C>c (was <G>g <S>s <C>c; now <G>g <S>s <C>c; net balance, NOT profit).
```

Before a baseline exists, expected exact:

```text
Forever Gold: No baseline. Use /fgold baseline first.
```

**Clear baseline**:

```text
/fgold clear
```

Expected exact:

```text
Forever Gold: Baseline cleared (session only).
```

**Version**:

```text
/fgold version
```

Expected exact:

```text
Forever Gold: Version 0.2.0
```

**Help**:

```text
/fgold help
```

Expected exact:

```text
Forever Gold: Commands: /fgold | baseline | delta | clear | version | help
Forever Gold: Net wallet change is NOT profit; tracking is session only.
```

The [full field-test guide](../../docs/GOLD_TESTING.md) separates every command and its exact expected output, including disabled-pack and reload tests.

## Lifecycle, memory and privacy

Only a single baseline copper value is stored in memory. There is **no** SavedVariables file, periodic timer, addon event listener, `OnUpdate`, data sync, background scanning, transaction logging, user-profile collection or external telemetry. A new game session or disabling Gold through Core clears the starting balance. Other packs are independent.

`ReadCopper` validates missing, protected, invalid, negative, non-integer and non-finite client readings. It refuses wallet sampling during combat when `InCombatLockdown` is available. It does not claim to provide account-wide wallets or auction data.

This is an unendorsed community addon. Its root code license, Blizzard policy and public security checks still need owner review before an installable public release is approved.
