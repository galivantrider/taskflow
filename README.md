# TaskFlow

A Flutter project-management demo built against a single local JSON asset—no network backend is used.

## Included flows

- Splash/session check, secure mock-token storage, refresh after expiry, login, local registration simulation, and logout
- Organization-scoped projects with refresh, creation, details, task summaries, and admin-protected deletion
- Tasks with creation, details, status and priority changes, assignment/unassignment, filtering, and deletion confirmation
- Loading, empty, retry/error, and pull-to-refresh UI states

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md). The presentation layer talks to repository contracts; implementations access `MockDataSource`, which is the only code that reads `assets/mock_data/mock-data.json`.

## Demo credentials

Use the credentials in `auth_mock.test_credentials` inside the mock asset. For example: `ava.admin@nimbusdigital.test` / `password123`.

## Run

```bash
flutter pub get
flutter run
flutter test
flutter build apk --release
```

Requires Flutter with Dart `^3.13.1` (the SDK constraint in `pubspec.yaml`).

## Mock behavior and limitations

The data source adds a small artificial delay so loading states are observable. Project and task mutations live in repository memory for the active app run; persisting those mutations and an offline mutation queue are intentionally out of scope for this mock implementation. The provided data is retained for offline-style local viewing because it is packaged with the app.
