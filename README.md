# Waddle – Water Intake Tracker (Flutter)

Penguin fills up as you drink. Android first, iOS from the same code.

- `lib/` – all app code (onboarding, goal calculator, home, beverages, history, reminders, settings, premium, AdMob)
- `tool/patch_platforms.py` – configures the android/ios folders that CI generates
- `.github/workflows/android.yml` – builds signed APK + AAB on every push (see Releases)
- `signing/` – Play upload keystore (keep this repo PRIVATE and back the file up)

Before Play Store release: replace TEST AdMob ids in `lib/services/ads.dart` and `tool/patch_platforms.py`,
and create the in-app product `premium_lifetime` in Play Console.
