#!/usr/bin/env python3
"""Build an offline, reproducible, MODULAR WoW Forever development ZIP.

Usage:
    python3 tools/build_dev_bundle.py --list
    python3 tools/build_dev_bundle.py --check --profile full
    python3 tools/build_dev_bundle.py --profile tank --output dist/Tank-DEV.zip
    python3 tools/build_dev_bundle.py --profile full --output dist/Full-DEV.zip

This utility never installs into the WoW folder and never contacts a server.
Development ZIPs are NOT approved player releases; no project license or
compatibility guarantee is implied by a successful build.
"""

from __future__ import annotations

import argparse
import hashlib
import io
import sys
import zipfile
from pathlib import Path, PurePosixPath

REPO_ROOT = Path(__file__).resolve().parent.parent
ADDON_ROOT = REPO_ROOT / "addons"
INTERFACE = "16001"
CORE = "ForeverCore"

# Audited explicit allowlist: unknown folders never ship by accident.
OPTIONAL = (
    "ForeverCooking",
    "ForeverDashboard",
    "ForeverExplorer",
    "ForeverFishing",
    "ForeverGold",
    "ForeverGuild",
    "ForeverInventory",
    "ForeverJournal",
    "ForeverPerformance",
    "ForeverProfessions",
    "ForeverWarrior",
)
KNOWN = frozenset((CORE, *OPTIONAL))
PROFILES = {
    "minimal": (CORE,),
    "tank": (
        CORE, "ForeverDashboard", "ForeverGold", "ForeverInventory",
        "ForeverJournal", "ForeverPerformance", "ForeverWarrior",
    ),
    "professions": (
        CORE, "ForeverCooking", "ForeverDashboard", "ForeverFishing",
        "ForeverGold", "ForeverInventory", "ForeverPerformance",
        "ForeverProfessions",
    ),
    "full": (CORE, *OPTIONAL),
}
SOURCE_SUFFIXES = frozenset((".lua", ".toc", ".md"))
MAX_SOURCE_SIZE = 512 * 1024
MAX_FILES_PER_PACK = 64
ZIP_TIMESTAMP = (1980, 1, 1, 0, 0, 0)


class BundleError(ValueError):
    """An unsafe or incomplete addon folder must never be packaged."""


def choose_modules(profile: str, include=(), exclude=()) -> tuple[str, ...]:
    """Return exactly the selected Core and optional pack directories.

    Every profile retains Core. Each optional pack stays a separate folder,
    with no forced dependencies on any other optional pack.
    """
    if profile not in PROFILES:
        raise BundleError("Unknown bundle profile: " + profile)
    include = tuple(include)
    exclude = tuple(exclude)
    unknown = (set(include) | set(exclude)) - KNOWN
    if unknown:
        raise BundleError("Unknown pack(s): " + ", ".join(sorted(unknown)))
    if CORE in exclude:
        raise BundleError("ForeverCore cannot be excluded from a bundle.")

    selected = (set(PROFILES[profile]) | set(include)) - set(exclude)
    selected.add(CORE)
    return (CORE,) + tuple(sorted(selected - {CORE}))


def _ensure_safe(root: Path, candidate: Path) -> None:
    """Refuse symlinks or path traversal, including symlink ancestors."""
    try:
        parts = candidate.relative_to(root).parts
    except ValueError as exc:
        raise BundleError("Source escapes addon root: " + str(candidate)) from exc
    check = root
    if root.is_symlink():
        raise BundleError("Addon source root is a symlink.")
    for part in parts:
        if part in ("", ".", ".."):
            raise BundleError("Invalid source path component.")
        check = check / part
        if check.is_symlink():
            raise BundleError("Symlink source refused: " + str(check))


def read_module_files(name: str, addons: Path = ADDON_ROOT) -> dict[str, bytes]:
    """Validate one _Camelot.toc and all shipped files before bundling.

    Only source, documented manifests, and README markdown are eligible.
    Runtime Lua files must be explicitly ordered by their TOC. The
    installed path is always '<AddonName>/file.ext' beneath AddOns/.
    """
    if name not in KNOWN:
        raise BundleError("Unknown pack: " + name)
    folder = addons / name
    _ensure_safe(addons, folder)
    if not folder.is_dir():
        raise BundleError("Missing addon folder: " + name)

    toc = folder / (name + "_Camelot.toc")
    _ensure_safe(addons, toc)
    if not toc.is_file():
        raise BundleError("Missing Camelot TOC for " + name)
    try:
        toc_data = toc.read_text(encoding="utf-8")
    except UnicodeError as exc:
        raise BundleError("Non-UTF8 TOC: " + name) from exc

    if "## Interface: " + INTERFACE not in toc_data.splitlines():
        raise BundleError("Wrong client interface in " + name)
    dependencies = [
        line.partition(":")[2].strip()
        for line in toc_data.splitlines()
        if line.startswith("## Dependencies:")
    ]
    if name == CORE and dependencies:
        raise BundleError("Core must not depend on optional packs.")
    if name != CORE and dependencies != [CORE]:
        raise BundleError(name + " must depend only on ForeverCore.")

    declarations: list[str] = []
    for raw in toc_data.splitlines():
        entry = raw.strip()
        if not entry or entry.startswith("#"):
            continue
        source = PurePosixPath(entry.replace("\\", "/"))
        if (
            entry.startswith("/") or "\\" in entry
            or source.suffix != ".lua" or
            source.is_absolute() or len(source.parts) > 5
            or any(part in ("", ".", "..") for part in source.parts)
        ):
            raise BundleError(name + " contains unsafe/non-Lua TOC line: " + entry)
        normalized = source.as_posix()
        if normalized in declarations:
            raise BundleError(name + " lists duplicate Lua file " + normalized)
        declarations.append(normalized)
    if not declarations:
        raise BundleError(name + " has no Lua entrypoints.")

    discovered: dict[str, bytes] = {}
    for item in sorted(folder.rglob("*")):
        if item.is_dir():
            _ensure_safe(addons, item)
            continue
        _ensure_safe(addons, item)
        if not item.is_file():
            raise BundleError("Nonregular source file in " + name)
        relative = item.relative_to(folder).as_posix()
        if item.suffix not in SOURCE_SUFFIXES:
            raise BundleError(name + " contains unexpected file: " + relative)
        if item.name.startswith(".") or "__pycache__" in item.parts:
            raise BundleError(name + " contains hidden/build file.")
        size = item.stat().st_size
        if size > MAX_SOURCE_SIZE:
            raise BundleError(name + " exceeds per-file source size bound.")
        discovered[relative] = item.read_bytes()

    if len(discovered) > MAX_FILES_PER_PACK:
        raise BundleError(name + " exceeds file-count bound.")
    actual_lua = sorted(path for path in discovered if path.endswith(".lua"))
    if sorted(declarations) != actual_lua:
        missing = sorted(set(declarations) - set(actual_lua))
        unlisted = sorted(set(actual_lua) - set(declarations))
        raise BundleError(
            name + " TOC/source mismatch. Missing: " + str(missing)
            + "; unlisted: " + str(unlisted)
        )
    if toc.name not in discovered:
        raise BundleError("Manifest missing from output: " + name)
    return {name + "/" + k: value for k, value in discovered.items()}


def gather_source(modules: tuple[str, ...],
                  addons: Path = ADDON_ROOT) -> dict[str, bytes]:
    """Aggregate only selected addon folders into a deterministic archive map."""
    result: dict[str, bytes] = {}
    for name in modules:
        for path, data in read_module_files(name, addons).items():
            if path in result:
                raise BundleError("Duplicate output source: " + path)
            result[path] = data
    return dict(sorted(result.items()))


def make_zip(source: dict[str, bytes]) -> bytes:
    """Make byte-for-byte stable ZIP contents (regardless of source mtimes)."""
    output = io.BytesIO()
    with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED,
                         compresslevel=9) as archive:
        for name, content in sorted(source.items()):
            info = zipfile.ZipInfo(name, date_time=ZIP_TIMESTAMP)
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, content, compress_type=zipfile.ZIP_DEFLATED,
                             compresslevel=9)
    return output.getvalue()


def main(argv: list[str] | None = None) -> int:
    """CLI for local developer only; never installs or publishes a release."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", choices=sorted(PROFILES), default="minimal")
    parser.add_argument("--include", action="append", default=[], metavar="PACK")
    parser.add_argument("--exclude", action="append", default=[], metavar="PACK")
    parser.add_argument("--output", type=Path,
                        help="Explicit output ZIP file (never game installation)")
    parser.add_argument("--check", action="store_true",
                        help="Validate source without generating a ZIP")
    parser.add_argument("--list", action="store_true",
                        help="Display allowed pack names and profiles")
    args = parser.parse_args(argv)

    if args.list:
        print("Allowed packages: " + ", ".join((CORE, *OPTIONAL)))
        for name in sorted(PROFILES):
            print(name + ": " + ", ".join(PROFILES[name]))
        return 0

    try:
        modules = choose_modules(args.profile, args.include, args.exclude)
        sources = gather_source(modules)
        raw_bytes = sum(len(data) for data in sources.values())
        print("DEV candidate: " + args.profile + "; " + str(len(modules))
              + " separately installable addon folder(s), "
              + str(len(sources)) + " source file(s); "
              + str(raw_bytes) + " uncompressed source bytes.")
        print("Modules: " + ", ".join(modules))
        if args.check:
            print("Manifest and TOC validation: PASS (not live client testing).")
            return 0
        if args.output is None:
            raise BundleError("Provide --output PATH or use --check.")
        output = args.output.expanduser()
        if output.suffix.lower() != ".zip":
            raise BundleError("Output must have a .zip suffix.")
        data = make_zip(sources)
        output.parent.mkdir(parents=True, exist_ok=True)
        if output.is_symlink():
            raise BundleError("Output path cannot be a symlink.")
        output.write_bytes(data)
        print("Wrote developer-only ZIP: " + str(output))
        print("ZIP bytes: " + str(len(data)))
        print("SHA256: " + hashlib.sha256(data).hexdigest())
        print("NOT A PUBLIC RELEASE; install, test, and approve separately.")
        return 0
    except (BundleError, OSError) as error:
        print("Bundle validation FAILED: " + str(error), file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
