#!/usr/bin/env python3
"""Check tracked paths and selected secret formats before public distribution.

This is a high-confidence preventive check, NOT a whole-history scan,
secret-detection service, or proof of absence of private information.
Reports only rule names and file paths; never prints matched token values.
No third-party dependencies or network access are required.
"""

from __future__ import annotations

import pathlib
import re
import subprocess
import sys

REPOSITORY_ROOT = pathlib.Path(__file__).resolve().parent.parent
MAX_FILE_BYTES = 5_000_000

# Deliberately build the token prefixes from pieces to avoid false positives
# when this scanner scans its own source.
SECRET_PATTERNS = {
    "GitHub access token": re.compile(
        r"(?:gh" + r"[pousr]_" + r"[A-Za-z0-9_]{30,}|github_" + r"pat_[A-Za-z0-9_]{30,})"
    ),
    "AWS access key ID": re.compile(r"(?:AK" + r"IA|AS" + r"IA)[A-Z0-9]{16}"),
    "OpenAI API key": re.compile(r"sk" + r"-(?:proj-)?[A-Za-z0-9_-]{24,}"),
    "Slack access token": re.compile(r"xox" + r"[baprs]-[A-Za-z0-9-]{20,}"),
    "Private-key header": re.compile(
        r"-----BEGIN " + r"(?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"
    ),
}

PROHIBITED_NAMES = {
    ".ds_store",
    "credentials.json",
    "wow-dev.config.local.json",
    "id_rsa",
    "id_ed25519",
}
PROHIBITED_SUFFIXES = {
    ".pem", ".key", ".p12", ".pfx", ".jks", ".keystore",
    ".sqlite", ".sqlite3", ".db",
}
PROHIBITED_DIRS = {"wtf", "cache", "logs", "screenshots"}


def path_violation(path: pathlib.PurePosixPath) -> str | None:
    """Identify tracked paths that often reveal player or credential data."""
    parts = [part.lower() for part in path.parts]
    name = parts[-1] if parts else ""

    if any(part in PROHIBITED_DIRS for part in parts[:-1]):
        return "local game/user-data directory"
    if name in PROHIBITED_NAMES or name.endswith(".local.json"):
        return "private configuration or key file"
    if name == ".env" or (name.startswith(".env.") and name != ".env.example"):
        return "environment secrets file"
    if pathlib.PurePosixPath(name).suffix.lower() in PROHIBITED_SUFFIXES:
        return "credential/database file extension"
    if name.startswith("id_rsa") or name.startswith("id_ed25519"):
        return "private SSH key path"
    return None


def inspect_text(text: str) -> list[str]:
    """Return only names of matching rules; never expose credential text."""
    return [name for name, pattern in SECRET_PATTERNS.items() if pattern.search(text)]


def tracked_files() -> list[pathlib.PurePosixPath]:
    """Ask Git for the exact current-tree file set, including ignored tracks."""
    result = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=REPOSITORY_ROOT,
        check=True,
        capture_output=True,
    )
    return [
        pathlib.PurePosixPath(value.decode("utf-8", "surrogateescape"))
        for value in result.stdout.split(b"\0")
        if value
    ]


def main() -> int:
    """Fail CI for known-risk tracked paths or high-confidence token patterns."""
    failures = []
    paths = tracked_files()

    for path in paths:
        label = path_violation(path)
        if label:
            failures.append((str(path), label))

        # Avoid following symlinks out of the checkout.
        disk_path = REPOSITORY_ROOT.joinpath(*path.parts)
        if disk_path.is_symlink():
            failures.append((str(path), "symbolic link requires manual review"))
            continue

        try:
            data = disk_path.read_bytes()
        except OSError:
            failures.append((str(path), "unreadable tracked file"))
            continue

        if len(data) > MAX_FILE_BYTES:
            failures.append((str(path), "file exceeds review size limit"))
            continue
        if b"\0" in data:
            failures.append((str(path), "binary file requires manual review"))
            continue

        content = data.decode("utf-8", "replace")
        for secretType in inspect_text(content):
            failures.append((str(path), secretType))

    if failures:
        for path, reason in failures:
            print(f"REVIEW REQUIRED: {path} — {reason}")
        print(f"Public safety check failed: {len(failures)} finding(s).")
        return 1

    print(f"Public safety check passed for {len(paths)} tracked file(s).")
    print("Scope: current checkout, selected patterns only; not Git history.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
