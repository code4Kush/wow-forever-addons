"""Offline tests for developer-only modular WoW Forever bundle generation.

These verify packaging, dependency isolation, TOC safety, and reproducibility,
not in-game functionality or performance against competing addons.
"""
import io
import os
import sys
import tempfile
import unittest
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
import build_dev_bundle as bundle  # noqa: E402


class SelectionTests(unittest.TestCase):
    def test_minimal_is_core_only(self):
        self.assertEqual(bundle.choose_modules("minimal"), ("ForeverCore",))

    def test_full_contains_all_independent_packs(self):
        selected = bundle.choose_modules("full")
        self.assertEqual(set(selected), bundle.KNOWN)
        self.assertEqual(selected[0], "ForeverCore")
        self.assertEqual(len(selected), 12)

    def test_tank_and_professions_are_bounded(self):
        tank = bundle.choose_modules("tank")
        craft = bundle.choose_modules("professions")
        self.assertIn("ForeverWarrior", tank)
        self.assertNotIn("ForeverGuild", tank)
        self.assertIn("ForeverCooking", craft)
        self.assertIn("ForeverFishing", craft)
        self.assertNotIn("ForeverWarrior", craft)

    def test_include_and_exclude_preserve_core(self):
        chosen = bundle.choose_modules(
            "tank", include=["ForeverCooking"], exclude=["ForeverJournal"]
        )
        self.assertIn("ForeverCooking", chosen)
        self.assertNotIn("ForeverJournal", chosen)
        self.assertEqual(len(chosen), len(set(chosen)))
        with self.assertRaises(bundle.BundleError):
            bundle.choose_modules("full", exclude=["ForeverCore"])
        with self.assertRaises(bundle.BundleError):
            bundle.choose_modules("minimal", include=["TestProbeEvil"])


class RealSourceTests(unittest.TestCase):
    def test_all_real_manifests_validate_without_game_apis(self):
        paths = bundle.gather_source(bundle.choose_modules("full"))
        roots = {p.split("/")[0] for p in paths}
        self.assertEqual(roots, set(bundle.KNOWN))
        self.assertTrue(all(
            p.startswith("Forever") and (
                p.endswith(".lua") or p.endswith(".toc") or p.endswith(".md")
            ) for p in paths
        ))
        self.assertFalse(any("Probe" in p or "WTF" in p or "test-addons" in p
                             or "__pycache__" in p or ".DS_Store" in p
                             for p in paths))
        self.assertTrue(all(len(content) < 512 * 1024
                            for content in paths.values()))

    def test_profile_shrinks_payload(self):
        full = bundle.gather_source(bundle.choose_modules("full"))
        minimum = bundle.gather_source(bundle.choose_modules("minimal"))
        tank = bundle.gather_source(bundle.choose_modules("tank"))
        self.assertLess(len(minimum), len(tank))
        self.assertLess(len(tank), len(full))
        self.assertTrue(set(minimum).issubset(tank))
        self.assertTrue(set(tank).issubset(full))

    def test_deterministic_zip_bytes_and_root_layout(self):
        sources = bundle.gather_source(bundle.choose_modules("professions"))
        first = bundle.make_zip(sources)
        second = bundle.make_zip(sources)
        self.assertEqual(first, second)
        with zipfile.ZipFile(io.BytesIO(first)) as archive:
            self.assertEqual(archive.namelist(), sorted(sources))
            self.assertFalse(any("/../" in s for s in archive.namelist()))
            self.assertIn("ForeverCore/ForeverCore_Camelot.toc",
                          archive.namelist())
            self.assertIn("ForeverFishing/ForeverFishing_Camelot.toc",
                          archive.namelist())
            self.assertNotIn("ForeverGuild/ForeverGuild_Camelot.toc",
                             archive.namelist())


class UnsafeSourceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addons = Path(self.temp.name)
        self.folder = self.addons / "ForeverCore"
        self.folder.mkdir()
        self.toc = self.folder / "ForeverCore_Camelot.toc"
        self.toc.write_text(
            "## Interface: 16001\n## Title: Core\n\nBootstrap.lua\n",
            encoding="utf-8",
        )
        (self.folder / "Bootstrap.lua").write_text(
            "local _, addon = ...\n", encoding="utf-8"
        )

    def tearDown(self):
        self.temp.cleanup()

    def test_valid_minimal_fixture(self):
        files = bundle.read_module_files("ForeverCore", self.addons)
        self.assertEqual(len(files), 2)

    def test_malformed_or_wrong_toc_rejected(self):
        self.toc.write_text(
            "## Interface: 99999\nBootstrap.lua\n", encoding="utf-8"
        )
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)

    def test_path_traversal_is_refused(self):
        self.toc.write_text(
            "## Interface: 16001\n../outside.lua\n", encoding="utf-8"
        )
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)

    def test_unlisted_lua_is_refused(self):
        (self.folder / "Hidden.lua").write_text("print(1)\n")
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)

    def test_unexpected_file_is_refused(self):
        (self.folder / "secrets.json").write_text("{}")
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)

    def test_unreadable_lua_bytecode_is_refused(self):
        # Lua 5.1 bytecode begins with ESC Lua; player-readable public
        # sources must never silently accept compiled chunks.
        (self.folder / "Bootstrap.lua").write_bytes(bytes([27, 76, 117, 97, 81, 0]))
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)

    def test_nul_and_terminal_control_bytes_are_refused(self):
        for contents in (b"print(1)" + bytes([0]), b"print(1)" + bytes([27]) + b"[0m"):
            (self.folder / "Bootstrap.lua").write_bytes(contents)
            with self.assertRaises(bundle.BundleError):
                bundle.read_module_files("ForeverCore", self.addons)

    def test_legal_utf8_comments_are_accepted(self):
        (self.folder / "Bootstrap.lua").write_text(
            "-- exposed source: " + chr(233) + chr(10), encoding="utf-8"
        )
        files = bundle.read_module_files("ForeverCore", self.addons)
        self.assertIn("ForeverCore/Bootstrap.lua", files)

    def test_symlink_is_refused_even_if_target_is_valid(self):
        link = self.folder / "Alias.lua"
        try:
            os.symlink(self.folder / "Bootstrap.lua", link)
        except (OSError, NotImplementedError):
            self.skipTest("Platform does not support symlinks")
        with self.assertRaises(bundle.BundleError):
            bundle.read_module_files("ForeverCore", self.addons)


if __name__ == "__main__":
    unittest.main()
