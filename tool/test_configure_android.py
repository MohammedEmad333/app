"""Checks the generated Android configuration script remains repeatable."""
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("configure_android.py")


class ConfigureAndroidTest(unittest.TestCase):
    def test_repeatable(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory) / "android"
            (root / "app/src/main").mkdir(parents=True)
            (root / "app/build.gradle.kts").write_text(
                "compileSdk = flutter.compileSdkVersion\n"
                "minSdk = flutter.minSdkVersion\n"
                "ndkVersion = flutter.ndkVersion\n"
            )
            (root / "settings.gradle.kts").write_text(
                'id("org.jetbrains.kotlin.android") version "1.8.0"'
            )
            (root / "app/src/main/AndroidManifest.xml").write_text(
                '<manifest xmlns:android="http://schemas.android.com/apk/res/android" />'
            )
            files = list(root.rglob("*"))
            files = [p for p in files if p.is_file()]
            for attempt in range(2):
                subprocess.run([sys.executable, str(SCRIPT)], cwd=directory, check=True)
                current = {str(p.relative_to(root)): p.read_bytes() for p in files}
                if attempt:
                    self.assertEqual(previous, current)
                previous = current
            self.assertIn(b"compileSdk = 36", (root / "app/build.gradle.kts").read_bytes())
            self.assertIn(b"RECORD_AUDIO", (root / "app/src/main/AndroidManifest.xml").read_bytes())


if __name__ == "__main__":
    unittest.main()
