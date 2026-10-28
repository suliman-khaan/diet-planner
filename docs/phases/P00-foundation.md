# P0 — Foundation (1.5 weeks)

Goal: a Flutter project every lane can work in without touching each other's files.

## Tasks

| ID | Task | Lane | Depends on |
|---|---|---|---|
| P0-00 | Install Flutter (stable), Dart, JDK 17, Android SDK, emulator; get a 2–3 GB RAM test phone; `git init` + first commit on `main` | Owner | — |
| P0-01 | `flutter create` in `apps/mobile` (org placeholder `dev.placeholder.dietplanner`); dev/prod flavors; **full folder skeleton for every lane** (below) with placeholder files; `lib/app/routes.dart` with every route name from PU; pin core packages (riverpod + generator, go_router, freezed, json_serializable, drift, intl, flutter_localizations); commit `pubspec.lock` | Platform | P0-00 |
| P0-02 | `analysis_options.yaml` (strict, warnings = errors); format check script | Platform | P0-01 |
| P0-03 | CI: format, analyze, tests, release build, secret scan; pack validator step stub | Platform | P0-01 |
| P0-04 | Core utils: typed failures/`Result`, structured logger without PII, injectable clock, UUIDv7 ids | Platform | P0-01 |
| P0-05 | Drift setup: empty database class, migration harness, test helper with in-memory DB | Data | P0-01 |
| P0-06 | Error boundary + crash-safe startup screen (shell only; copy from UI) | Platform | P0-04 |
| P0-07 | Measure baseline: release APK size, cold start on test phone → `IMPLEMENTATION_STATUS.md` | Platform | P0-03 |
| P0-08 | `README.md` setup section: a new developer can build and test from it | Platform | P0-01 |

### Folder skeleton created by P0-01

```text
apps/mobile/lib/
  main_dev.dart, main_prod.dart        Platform
  app/ (app.dart, bootstrap.dart, router.dart, routes.dart, providers/)   Platform (providers/ = Integration)
  core/theme/  core/widgets/           UI
  core/errors/ core/logging/ core/clock/ core/ids/   Platform
  domain/                              Domain
  data/                                Data
  services/                            Platform
  fixtures/                            UI
  l10n/                                UI
  features/<name>/{ui,view_model,controller}/   UI, UI, Integration
apps/mobile/test/{ui,domain,data,features}/      by lane
apps/mobile/integration_test/                    Integration
apps/mobile/assets/{fonts,images/ui,packs}/      UI, UI, Content
```

Feature names: `onboarding`, `today`, `meal`, `foods`, `log`, `history`, `progress`, `shopping`, `reminders`, `settings`, `privacy`, `transparency`, `gallery`.

## Exit criteria (blueprint)

- [ ] Debug and release builds compile and run on emulator and physical phone
- [ ] CI runs analysis, tests and build
- [ ] Release APK ≤ 25 MB; cold start ≤ 2.5 s on baseline phone
- [ ] No secrets committed
