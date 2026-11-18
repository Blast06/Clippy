# Clippy — instructions for Claude

Flutter clipboard history manager (Dart package `clipboard_ai_manager`) with an
optional n8n webhook backend. App ID / bundle ID: `com.juliodelgado.clippy`.

## Stack and structure
- Flutter stable, Dart >= 3.2. State management, routing and DI with **GetX**.
- Feature-first layout under `lib/features/<feature>/{data,domain,presentation}`;
  shared code in `lib/core` (api, routes, theme) and `lib/features/shared`.
- Local persistence with `sqflite` (`clipboard_database_service.dart`).
- Backend base URL comes from `--dart-define=CLIPPY_BACKEND_BASE_URL` or the
  runtime Settings page. Never hard-code URLs or secrets.
- Planned refactors: `docs/architecture_refactor_roadmap.md`.

## Before every push
1. `flutter pub get`
2. `flutter analyze` — must have no errors or warnings.
3. `flutter test` — must pass. Add or update tests for changed behaviour.

If Flutter is not available in the environment, say so in the summary and rely
on the CI workflow (`.github/workflows/ci.yml`) to run these checks.

## Branches and deploys
- `main` = stable. `develop` = test builds.
- **A push to `develop` ships a build to the owner's phones**:
  Android via GitHub Actions → Firebase App Distribution, iOS via Codemagic →
  TestFlight. Only push to `develop` when the change is ready to try on a device.
- For larger or risky work, use a feature branch (`feature/<name>`) and open a
  PR into `develop`. Never push directly to `main`.
- Do not bump `version:` in `pubspec.yaml` for test builds; CI sets the build
  number automatically. Bump the version name only when asked.

## Do not touch without being asked
- Signing: `android/key.properties`, keystores, `codemagic.yaml` signing block,
  `ios/Runner.xcodeproj` team/bundle settings.
- CI/CD files in `.github/workflows/` and `codemagic.yaml`.

## Style
- Commit messages in English, imperative mood, short subject line.
- Code, identifiers and comments in English; UI copy as already used in the app.
- The owner reads summaries in Spanish.
