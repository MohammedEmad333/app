# Android production release checklist

The APK uploaded by platform CI is a **smoke-test artifact**, not a production release. Do not distribute it as a trusted production build.

## Before creating a signed release

1. Choose a permanent unique Android application ID and confirm ownership.
2. Generate an upload key using Android's official guidance. Store the keystore and passwords in a private secrets manager, never in source control.
3. Configure release signing in the generated Android project. Because platform runners are generated with `flutter create`, automate any configuration in a reviewed script that reads secrets only during a protected release workflow.
4. Configure protected GitHub environments with restricted access and approval for distribution. Avoid exposing signing secrets to untrusted pull requests.
5. Build an Android App Bundle (`flutter build appbundle --release`) for Google Play delivery; use a signed APK only for approved direct distribution.
6. Verify the resulting certificate with `apksigner verify --print-certs` for APKs; check its SHA-256 fingerprint against a separately trusted value. For AABs, use `jarsigner -verify -verbose -certs` and verify the upload certificate.
7. Test install, upgrades, offline lessons, text-to-speech, speech recognition with permissions granted and denied, progress persistence, and heart regeneration on a physical Android device.
8. Archive build provenance and release checksums, then publish only through an approved release process.

## Security caveats

- A checksum proves that bytes match the checksum manifest; it does not authenticate a publisher if both came from an untrusted source.
- Never print secret variables, passwords, or keystore contents in build logs.
- Keep debug and CI smoke-test builds clearly separate from production releases.
- This checklist does **not** configure or claim production signing.
