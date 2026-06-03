# Clippy

Clippy is a Flutter clipboard history manager with optional backend-powered AI
actions. It stores clipboard items locally, detects common content types, and
can send selected snippets to a configured backend for transforms such as
summarization, translation, rewriting, classification, and entity extraction.

## Features

- Local clipboard history with duplicate prevention.
- Content type detection for text, URL, email, phone, and number values.
- Favorites, search, copy, and item detail views.
- Persistent settings for backend enabled, local-only mode, and backend base URL.
- Optional AI actions backed by webhook endpoints.
- Locally persisted AI action results with copy, save-as-snippet, and replace-original actions.

## Backend Configuration

The backend is optional. By default, Clippy runs in local-only mode.

Configure a backend in either of these ways:

- Runtime setting: open `Settings`, disable local-only mode, enable backend, and set the base URL.
- Build-time default: pass `--dart-define=CLIPPY_BACKEND_BASE_URL=https://your-domain.example`.

Expected endpoints:

- `POST /webhook/clipboard/analyze`
- `POST /webhook/clipboard/transform`
- `POST /webhook/clipboard/classify`

Transform requests include `text`, `action`, and `instruction`.

## Development

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release Configuration

Current placeholder app identity:

- App name: `Clippy`
- Dart package: `clipboard_ai_manager`
- Android application ID: `com.juliodelgado.clippy`
- iOS bundle ID: `com.juliodelgado.clippy`

Before store submission:

- Replace placeholder app icons in `android/app/src/main/res` and `ios/Runner/Assets.xcassets/AppIcon.appiconset`.
- Configure Android release signing in CI or local `key.properties`.
- Set the iOS development team, signing profile, and final bundle ID in Xcode if needed.
- Confirm backend URL, privacy copy, and any store-specific clipboard disclosure language.

## Build

Android:

```sh
flutter build apk --release
flutter build appbundle --release
```

iOS:

```sh
flutter build ios --release
```

For iOS distribution, archive and sign from Xcode after configuring the Apple
team and provisioning profile.
