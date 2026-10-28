# Lane: Platform

**Starts with:** Phase 0 (`docs/phases/P00-foundation.md`). Everyone else waits for task P0-01.

## Owns (may edit)

```text
apps/mobile/pubspec.yaml, pubspec.lock, analysis_options.yaml, build.yaml, l10n.yaml
apps/mobile/android/**  (except backup_rules.xml, shared with Data)
apps/mobile/lib/main_*.dart
apps/mobile/lib/app/**           app widget, bootstrap, router + routes.dart, DI root, flavors
apps/mobile/lib/core/errors/**, core/logging/**, core/clock/**, core/ids/**, core/platform/**
apps/mobile/lib/services/**      notification, analytics, crash adapters behind interfaces
.github/**, .gitignore, .editorconfig, root tooling
```

## Must not edit

Theme, widgets, screens, domain, data, content.

## Serving other lanes

Dependency, route and CI requests arrive in `docs/handoffs/`. Handle them promptly; record each new
dependency in `docs/DECISIONS.md` (reason, licence, size).

## Checks before handoff

Debug and release builds compile · CI green · APK size recorded · no secrets.
