# Jal Mitra – Water Intake Tracker (Flutter)

A desi matka fills up as you drink and animal friends come to visit. Android first, iOS from the same code.

- `lib/` – all app code (onboarding, goal calculator, home, beverages, history, reminders, settings, premium, AdMob)
- `tool/patch_platforms.py` – configures the android/ios folders that CI generates
- `.github/workflows/android.yml` – builds signed APK + AAB on every push (see Releases)

## Development

Install Flutter 3.35.x and the Android SDK. From the repository root:

```sh
flutter create --org com.sukhadewe --project-name waterintaker --platforms=android,ios .
python tool/patch_platforms.py
flutter pub get
dart run flutter_launcher_icons
flutter analyze
flutter test
flutter run
```

The platform folders are generated locally. iOS builds require macOS and Xcode.

## Release signing

Never commit signing keys or passwords. The previously committed upload key must
be treated as exposed and must not be reused for future releases.

For signed CI builds, configure a **new** keystore through GitHub Actions secrets:
`KEYSTORE_BASE64` (base64-encoded keystore) and `KEYSTORE_PASSWORD` (the store and
key password). The workflow expects the alias `upload`. Without these secrets,
the release-signing step fails rather than using a key from the repository.
Local development uses the standard Flutter debug key.

## Contributions

Bug reports and pull requests are welcome. Include reproduction steps for bugs;
run `flutter analyze` and `flutter test` before proposing code changes.

## Status

This project is under development. Store publication, usage figures, and iOS
release validation are not claimed by this repository.

Before Play Store release: replace TEST AdMob ids in `lib/services/ads.dart` and `tool/patch_platforms.py`,
and create the in-app product `premium_lifetime` in Play Console.
