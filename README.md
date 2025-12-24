# Clipboard AI Manager (Flutter scaffold)

This repository contains a Flutter scaffold for **Clipboard AI Manager**, a cross-platform clipboard history manager that is ready for backend-powered AI features.

## Getting started
1. Install Flutter (3.16+ recommended).
2. From the project root, run `flutter pub get` to install dependencies.
3. Launch the app with `flutter run` on your target simulator or device.

## Key architecture decisions
- **State management:** `get` (GetX) powers lightweight dependency injection and reactive UI via controllers.
- **Data layer:** `ClipboardRepository` wraps a `ClipboardService` for REST calls and local storage stubs. Swap in SQLite or secure storage as needed.
- **Backend-ready:** Configure the base URL from the Settings screen. The service illustrates POST calls to `/clipboard/analyze` and can be extended for transform/classify endpoints.
- **UI structure:** A three-tab layout (History, Favorites, Settings) with detailed item view and AI analysis placeholder.

## Next steps
- Replace the in-memory store with SQLite or Drift for persistent clipboard history.
- Implement platform channels to capture clipboard updates in the background.
- Wire the transform/classify actions to your backend for summarization, cleanup, translation, or tagging.
- Add authentication (tokens) and sync logic for multi-device support.
