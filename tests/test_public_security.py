"""Unit tests for public-source safety checks using synthetic fixtures only."""

import pathlib
import sys
import unittest

REPOSITORY_ROOT = pathlib.Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPOSITORY_ROOT / "scripts"))

import check_public_repo as scanner  # noqa: E402


class PublicSecurityTests(unittest.TestCase):
    """Check path rejection and token patterns without committing real keys."""

    def test_sensitive_paths_are_detected(self):
        examples = (
            ".env",
            ".env.local",
            "config/credentials.json",
            "screenshots/session.png",
            "WTF/Account/SavedVariables/AddOn.lua",
            "keys/service.pem",
            "id_ed25519",
            "cache/some.db",
        )

        for path in examples:
            with self.subTest(path=path):
                self.assertIsNotNone(
                    scanner.path_violation(pathlib.PurePosixPath(path))
                )

    def test_safe_paths_do_not_raise_path_alert(self):
        for path in (
            "addons/ForeverCore/Registry.lua",
            "docs/PUBLIC_SECURITY_AUDIT.md",
            ".env.example",
            ".github/workflows/lua-tests.yml",
        ):
            with self.subTest(path=path):
                self.assertIsNone(
                    scanner.path_violation(pathlib.PurePosixPath(path))
                )

    def test_synthetic_token_formats_are_detected(self):
        examples = {
            "github": "gh" + "p_" + "A" * 36,
            "aws": "AK" + "IA" + "Q" * 16,
            "openai": "sk" + "-proj-" + "A" * 36,
            "private_key": "-----BEGIN " + "PRIVATE KEY-----",
        }

        for name, token in examples.items():
            with self.subTest(name=name):
                self.assertTrue(scanner.inspect_text(token))

    def test_plain_docs_are_not_marked_as_secrets(self):
        self.assertEqual(
            scanner.inspect_text("Use /fj status 747 for a quest flag"),
            [],
        )


if __name__ == "__main__":
    unittest.main()
