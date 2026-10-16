"""Behavioral regression tests for Android release preflight."""
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("check_android_release.py").read_text()
VALID_WORKFLOW = """name: Platform build smoke tests
- name: Verify release APK integrity and signing identity
  run: apksigner verify app-release.apk
- name: Check checksum
  run: sha256sum --check SHA256SUMS.txt
- name: Archive release APK
  uses: actions/upload-artifact@v4
"""


class ReleasePreflightTests(unittest.TestCase):
    def run_preflight(self, workflow=None, missing=None):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            files = {
                "tool/check_android_release.py": SCRIPT,
                "tool/configure_android.py": "# stub",
                "docs/android-release-checklist.md": "# checklist",
                ".github/workflows/platform-build.yml": (
                    VALID_WORKFLOW if workflow is None else workflow
                ),
            }
            if missing:
                files.pop(missing)
            for name, content in files.items():
                path = root / name
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(content)
            return subprocess.run(
                [sys.executable, str(root / "tool/check_android_release.py")],
                cwd=root, text=True, capture_output=True,
            )

    def test_all_prerequisites_pass(self):
        result = self.run_preflight()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("Production signing is NOT verified", result.stdout)

    def test_missing_files_fail(self):
        for path in (
            "tool/configure_android.py",
            "docs/android-release-checklist.md",
            ".github/workflows/platform-build.yml",
        ):
            with self.subTest(path=path):
                result = self.run_preflight(missing=path)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Missing release prerequisites", result.stderr)

    def test_missing_release_validation_fails(self):
        for required in (
            "Verify release APK integrity and signing identity",
            "sha256sum --check SHA256SUMS.txt",
            "Archive release APK",
        ):
            with self.subTest(required=required):
                result = self.run_preflight(workflow=VALID_WORKFLOW.replace(required, "omitted"))
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Missing release validation", result.stderr)


if __name__ == "__main__":
    unittest.main()
