# Rick and Morty — Clean Architecture

Flutter Android application using the official https://rickandmortyapi.com API.

The dark character list supports infinite scrolling and retrying failed pages. Tap a card for image-focused details. Search uses a 350 ms debounce, supports pagination, clearing, empty results, and retry. Successful list pages are cached separately with SharedPreferences and used when offline or when the API fails. Search requires a connection. Cached character metadata survives restarts; image availability offline depends on Flutter's in-memory image cache.

## Architecture

- `core`: failures, network information, use case contract, API URL.
- `features/person/domain`: Equatable entities, repository contract, list and search use cases. No Flutter dependencies.
- `features/person/data`: JSON models, HTTP and local data sources, repository implementation with cache fallback.
- `features/person/presentation`: list Cubit, debounced search BLoC, pages and shared widgets.
- `locator_service.dart`: GetIt registrations initialized before app startup.

Connectivity reports available network transports; every remote request also handles HTTP errors, timeouts and invalid data. Cached pages carry their original next-page metadata. Pagination errors preserve existing characters and expose an explicit retry.

## Run and verify

```sh
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter build apk --debug --target-platform android-arm64
flutter emulators --launch Pixel_4_XL
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
flutter run -d emulator-5554
```

Unit tests cover JSON parsing, HTTP handling, per-page caching, offline fallback, duplicate request prevention, pagination retries, debounce and stale response suppression. The Android integration test uses the live API and checks images, scrolling past the first page, search, empty results, details and back navigation. It requires network access and a booted emulator. Device IDs may differ; check `flutter devices`.

The screenshot references mentioned in the task were not included in the attachment. Styling follows the supplied written specification: dark background and app bar, gray cards, left-hand images, status dots, and location/origin labels.

The integration driver writes captured list, detail, and search images to `artifacts/screenshots/`.
