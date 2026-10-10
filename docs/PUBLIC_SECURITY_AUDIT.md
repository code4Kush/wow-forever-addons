# Public repository security and release audit

**Review date:** 2026-10-10  
**Repository:** `code4Kush/wow-forever-addons`  
**Status:** In-progress hardening; **NOT CERTIFIED SAFE / NOT A PUBLIC PLAYER RELEASE**.

## Verified observations (via GitHub connector)

- **Visibility transition verified:** initial GitHub API metadata read on 2026-10-10 returned `private`, but a later authenticated GitHub REST read returned **`private: false`, `visibility: public`**. Owner also reports changing it to public. For release readiness, verify the site and full source from a signed-out browser; no public *player release* is implied.
- Branches endpoint showed `main` **`protected: false`**. A later rulesets read returned **zero rulesets**. A direct branch-protection endpoint returned 403 for this GitHub integration, so protection must be configured and verified through the owner's GitHub UI. **This is the most urgent remaining repository-level control.**
- All eight branch **current-tree filename inventories** were reviewed (main, policy, roadmap, contributor docs, Core, quest log, historical flags, Mulgore); no tracked files had obvious credential extensions, `.env`, game `WTF/`/SavedVariables, screenshots, or oversized binary attachments. **This was not an exhaustive content or Git-history secret scan.**
- Current main GitHub workflow ran on `push` and `pull_request`, checked out with `actions/checkout@v4` and did not explicitly constrain the default GITHUB_TOKEN permissions. No `pull_request_target` was present in the inspected workflow.
- Source currently has **no root LICENSE**. The owner must choose a compatible license and audit third-party rights before distributing a public addon.
- Current feature work is **still in open pull requests**, not merged into main; no shipped public release or security certification has been demonstrated.
- **Current security branch CI evidence:** [GitHub Actions run 38067092007](https://github.com/code4Kush/wow-forever-addons/actions/runs/38067092007) passed the public-source scanner, its synthetic unit tests, and existing Lua 5.1 tests on the initial security commit `1b795d9f2f301b1ebc11db899df90e6ccfd518bc`. This is automated evidence only; subsequent edits require their own CI run.

## Safeguards in this PR

1. Explicit GitHub Actions read-only contents permission, checkout `persist-credentials: false`, pinned checkout commit, bounded job timeout and cancellation of superseded runs.
2. Tracked-path and high-confidence token/private-key text scanner executed by CI; scanner never prints the matched secret itself. Synthetic unit tests prove that known examples would be flagged.
3. More defensive `.gitignore` for secrets, local settings, WoW game user data, screenshots, database files and key stores. **Ignore rules do not remove already-tracked files or past history.**
4. Dependabot update PRs for GitHub Actions pinned revisions.
5. Public vulnerability reporting guidance and privacy boundaries.

## Required owner actions in GitHub Settings

These are **manual steps**, not changes already applied by this PR.

1. **Confirm visibility independently:** GitHub REST now reports public; open **Settings → General** to confirm and test that the public repository is accessible while signed out. Do not post a public addon download until the complete source is accessible.
2. **Protect main:** go to **Settings → Rules → Rulesets → New branch ruleset** (or Branch protection if appropriate). Target `main`, enable **Require a pull request**, **Require status checks** (select the confirmed `Lua 5.1` job), **Block force pushes**, and **Restrict deletion**. If a second trusted reviewer is available, require review approval and dismiss stale approvals. Solo maintainer configurations should avoid a deadlock; do not enable a required approval you cannot obtain. Verify ruleset is **Active**. Consider preventing admins from bypassing except an explicitly documented break-glass recovery.
3. **Security controls:** under **Settings → Advanced Security** or **Security and analysis** (UI wording varies), enable **Secret scanning**, **Push protection**, **Dependabot alerts**, and **Dependabot security updates** where offered. Review unresolved alerts immediately and rotate any leaked credentials. Enable **Private Vulnerability Reporting** if offered.
4. **Actions permissions:** under **Settings → Actions → General**, set default `GITHUB_TOKEN` to **read-only**; restrict allowed actions to trusted publishers as feasible. Require PR workflow review for outside contributors where offered. No production repository/API keys in fork PR workflows.
5. **Access and account security:** audit collaborators and third-party apps; remove stale write/admin permissions; enable 2FA/passkeys on the maintainer account and avoid permanent personal access tokens. Monitor GitHub audit/notifications.
6. **Check all history and all branches:** GitHub secret scanning and a full-history credential scan should supplement the current-tree CI check; PR metadata, attachments and forks may also contain leaked values. Any exposure requires provider-side revocation/rotation. Do not treat deletion or force-push as sufficient cleanup.
7. **Review releases:** exclude `test-addons/`, local game data, credentials, screenshots, unlicensed assets and internal notes from public installable archives.
8. **Choose a license:** a public repository's visibility does not grant rights to reuse its code. Decide the code license and audit third-party materials. Do not infer a license for the owner.
9. **Release checklist:** review official Blizzard addon policy and EULA, record full client build, complete PR-based code review, verify `/reload` and a cold restart, validate independent packs and protected combat restrictions.

## CI scanner limitations

`scripts/check_public_repo.py` detects **selected high-confidence credential formats** and **forbidden tracked file paths in the checked-out commit**. It cannot guarantee detection of all passwords, split/encoded secrets, proprietary text, hidden credentials, private data in issue discussions, secrets in older commits, third-party dependency issues or runtime exploits. GitHub secret scanning/push protection and independent manual review remain necessary. It does not transmit repository contents to external servers.

## Existing work that still needs review

- [Official policy docs PR #1](https://github.com/code4Kush/wow-forever-addons/pull/1)
- [Journal PRs #2–#4](https://github.com/code4Kush/wow-forever-addons/pulls)
- [Modular roadmap PR #17](https://github.com/code4Kush/wow-forever-addons/pull/17)
- [Core M1 draft PR #18](https://github.com/code4Kush/wow-forever-addons/pull/18)
- [Public contributor standards PR #19](https://github.com/code4Kush/wow-forever-addons/pull/19)

Do not mistake an open PR for a deployed or game-verified player release. Every public distribution must have approved licensing, source availability, a reproducible install package, supported build evidence, and no prohibited gameplay automation.
