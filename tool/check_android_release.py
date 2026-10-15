"""Check Android release prerequisites without accessing signing secrets."""
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
REQUIRED = [
    ROOT / "docs/android-release-checklist.md",
    ROOT / "tool/configure_android.py",
    ROOT / ".github/workflows/platform-build.yml",
]


def main():
    missing = [str(p.relative_to(ROOT)) for p in REQUIRED if not p.is_file()]
    if missing:
        print("Missing release prerequisites: " + ", ".join(missing), file=sys.stderr)
        return 1
    workflow = (ROOT / ".github/workflows/platform-build.yml").read_text()
    required_steps = ("Verify release APK integrity and signing identity", "sha256sum --check SHA256SUMS.txt", "Archive release APK")
    absent = [step for step in required_steps if step not in workflow]
    if absent:
        print("Missing release validation: " + ", ".join(absent), file=sys.stderr)
        return 1
    print("CI smoke-test prerequisites present. Production signing is NOT verified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
