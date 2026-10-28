# Global Diet Planner

Offline-first meal planner built on the food people actually eat. First market: Pakistan. First platform: Android (Flutter).

- Spec: [docs/APP_BLUEPRINT.md](docs/APP_BLUEPRINT.md)
- Working rules for developers and AI agents: [.agent/AGENTS.md](.agent/AGENTS.md)
- Phases and work board: [docs/phases/](docs/phases/README.md), [docs/WORKBOARD.md](docs/WORKBOARD.md)
- Progress: [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md)
- Decisions: [docs/DECISIONS.md](docs/DECISIONS.md)

## Layout

```text
apps/mobile/            Flutter app (lib/domain = pure rules, lib/data = SQLite, lib/features = screens)
content/pakistan/       Food pack source data (USDA-based ingredients, draft recipes, combos)
contracts/              Food-pack JSON Schema (OpenAPI added in v1.5)
tools/food-pack/        Pack build, validator and USDA import (Node, no dependencies)
design/                 UI concepts and design spec
docs/                   Blueprint, phases, work board, handoffs, status, decisions, release drafts
.agent/                 Agent rules and lanes (read by Claude Code and Antigravity)
.github/workflows/      CI (ci.yml) and manual APK build (build-apk.yml)
```

`apps/admin`, `services/api`, `services/worker` are created when Phases 10–12 start.

## Build and test without a local Flutter install

CI is the build machine. Every push to `main`, `development`, `feat/**` or `fix/**` runs `.github/workflows/ci.yml`:

1. Food pack: validator tests, rebuild check, validation.
2. Secret scan (gitleaks).
3. Mobile: `flutter pub get` → Drift code generation → `dart format` → `flutter analyze` (warnings fail) →
   `flutter test` with domain coverage ≥ 90 % → dev debug APK → prod arm64 release APK (obfuscated) with a 25 MB budget.

Download the APKs from the run's **Artifacts** (`apks`). If formatting is needed, CI uploads a `formatted` artifact with the
formatted files.

## Local setup (optional)

Requirements: Flutter stable (CI uses 3.47.8), JDK 17, Android SDK; Node 20+ for the food-pack tools.

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift code
flutter analyze
flutter test
flutter run --flavor dev -t lib/main_dev.dart               # dev: draft food data allowed, screen gallery
flutter build apk --release --flavor prod -t lib/main.dart  # prod: reviewed foods only
```

Food pack:

```bash
cd tools/food-pack
npm test
node build.js ../../content/pakistan ../../apps/mobile/assets/packs/pk-core.json
node validate.js ../../apps/mobile/assets/packs/pk-core.json
```

Release signing: create `apps/mobile/android/key.properties` (never committed) with `storeFile`, `storePassword`,
`keyAlias`, `keyPassword`. Without it, release builds are signed with the debug key (fine for testing, not for the store).

## Flavors

| Flavor | Entry point | Application ID | Food data |
|---|---|---|---|
| dev | `lib/main_dev.dart` | `dev.placeholder.dietplanner.mobile.dev` | Draft foods may be planned, labelled "draft data" |
| prod | `lib/main.dart` | `dev.placeholder.dietplanner.mobile` | Only reviewed foods are planned |

Until the nutritionist reviews the food pack, the **prod** build shows "no plan" and allows manual logging only. This is
intentional (blueprint §3).
