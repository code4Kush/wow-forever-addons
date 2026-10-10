# Security policy

Thank you for helping keep WoW Forever Addons safe for its players and contributors.

## Supported versions

**Pre-release:** No public game-ready release is certified or supported yet. Source on the `main` branch and open development PRs may be experimental. When releases begin, this page will list supported versions and security-fix expectations.

## Reporting vulnerabilities privately

Please **do not** post credentials, full exploit instructions, account identifiers, player private data or screenshots exposing sensitive information in public issues or pull requests.

Prefer GitHub's **Private Vulnerability Reporting** if the repository owner has enabled it: open the repository's **Security** tab and select **Report a vulnerability**, or go to [private security advisories](https://github.com/code4Kush/wow-forever-addons/security/advisories/new). If that option is not available, contact the repository maintainer through their GitHub profile privately and arrange a confidential reporting channel before sending technical details. Do not assume an unverified email address is monitored.

In a private report include affected version/commit, impact, minimal reproduction, mitigation if known and whether a secret/token was exposed. Maintainers should acknowledge reports and coordinate a fix; no response-time guarantee is offered before a maintainer process is established.

If a real credential was committed, **revoke/rotate it immediately**. Deleting a current file or reverting a commit does not erase it from Git history, forks, caches or logs. Follow provider incident procedures and review GitHub secret-scanning alerts.

## Security principles

- In-game Lua addons use permitted UI APIs only. No client memory access, protected-action bypass, secret combat-value processing, botting, credential collection, arbitrary networking or automated account actions.
- All distributed code will be free, readable, unobfuscated and publicly viewable in accordance with Blizzard's published UI Add-On Development Policy.
- Optional modules must be least-privilege, event-bounded, safe when disabled and gracefully handle unavailable game APIs.
- Keep character data local by default; do not add external telemetry, analytics or account data transmission without a separate public privacy review and user consent.
- Test code comes from untrusted contributions: GitHub Actions jobs must use read-only permissions, no stored credentials, no deployment secrets and no `pull_request_target` workflow execution of contributor code.

The security scanner is intentionally a **limited preventive check**, not proof that a repository or history contains no secrets. See [security audit and owner checklist](../docs/PUBLIC_SECURITY_AUDIT.md).
