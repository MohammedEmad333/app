#!/usr/bin/env python3
"""Configure generated Android runner without storing credentials in git."""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

root = Path("android")
app_gradle = root / "app/build.gradle.kts"
settings = root / "settings.gradle.kts"
manifest = root / "app/src/main/AndroidManifest.xml"
assert all(path.is_file() for path in (app_gradle, settings, manifest)), "Run flutter create --platforms=android . first"

build = app_gradle.read_text()
for key, value in (
    ("minSdk", "24"),
    ("compileSdk", "36"),
    ("ndkVersion", '"27.0.12077973"'),
):
    build, count = re.subn(r"(?m)^(\s*" + key + r"\s*=\s*).+$", lambda match: match.group(1) + value, build)
    assert count == 1, f"Expected one {key} declaration, found {count}"
app_gradle.write_text(build)

content = settings.read_text()
content, count = re.subn(
    r'(id\("org.jetbrains.kotlin.android"\)\s+version\s+")[^"]+"',
    lambda m: m.group(1) + '2.2.20"',
    content,
)
assert count == 1, "Expected one Kotlin Gradle plugin declaration"
settings.write_text(content)

android_ns = "http://schemas.android.com/apk/res/android"
ET.register_namespace("android", android_ns)
tree = ET.parse(manifest)
main = tree.getroot()
assert main.tag == "manifest"
needed = ("android.permission.RECORD_AUDIO", "android.permission.INTERNET")
for name in needed:
    if not any(p.get("{" + android_ns + "}name") == name for p in main.findall("uses-permission")):
        permission = ET.Element("uses-permission")
        permission.set("{" + android_ns + "}name", name)
        main.insert(0, permission)
tree.write(manifest, encoding="utf-8", xml_declaration=True)
print("Android SDK, Kotlin and explicit microphone/network permissions configured")
