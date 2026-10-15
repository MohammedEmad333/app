"""Regression coverage for Android release prerequisite checks."""
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("check_android_release.py").read_text()


class ReleasePreflightTests(unittest.TestCase):
    def test_required_checks_present(self):
        self.assertIn("Verify release APK integrity and signing identity", SCRIPT)
        self.assertIn("sha256sum --check SHA256SUMS.txt", SCRIPT)
        self.assertIn("Archive release APK", SCRIPT)

    def test_missing_inputs_report_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            base = pathlib.Path(directory)
            target = base / "tool/check_android_release.py"
            target.parent.mkdir(parents=True)
            target.write_text(SCRIPT)
            result = subprocess.run(
                [sys.executable, str(target)],
                cwd=base, capture_output=True, text=True,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("Missing release prerequisites", result.stderr)


if __name__ == "__main__":
    unittest.main()
