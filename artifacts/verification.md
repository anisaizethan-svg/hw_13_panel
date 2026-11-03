# Verification — 3 November 2026

- Flutter 3.47.2 / Dart 3.13.2.
- `flutter pub get`: successful.
- `dart format lib test integration_test test_driver`: successful.
- `flutter analyze`: no issues found.
- `flutter test`: all 8 unit/widget tests passed.
- `flutter build apk --debug --target-platform android-arm64`: successful.
- Pixel 4 XL, Android 16 / API 36, emulator-5554: live integration test passed.

The integration test loaded real API characters, decoded a character image, scrolled beyond the first 20 results, opened details and returned, searched for Morty, opened a search result, cleared search, checked a nonexistent name, and returned to the full list. Captured screens are in `screenshots/`.

An earlier rapid-scroll run encountered HTTP 429. The app preserved its data and displayed retry; rate limiting now has an explicit wait-and-retry message. The final test stops after establishing second-page loading and supports retry if rate limited.

Offline fallback, malformed/missing cache, HTTP failures, JSON parsing, pagination retries and duplicate requests, and debounced/stale search responses were verified in automated unit tests. A narrow-screen widget test verified long text layout and detail navigation.

No reference screenshots were included with the supplied task, so exact comparison to the course screenshots was unavailable. The UI follows the written dark-theme specification. Offline image persistence is not implemented; cached metadata is persistent while Flutter caches images in memory.
