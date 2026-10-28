# Lane: Data

**Starts with:** Phase 2 (`docs/phases/P02-local-storage.md`), after P0-01 and the domain repository interfaces it implements.

## Owns (may edit)

```text
apps/mobile/lib/data/**          Drift schema + migrations, DAOs, repository implementations,
                                 pack loader (JSON asset → read-only tables), export/import, delete-all
apps/mobile/test/data/**         database, migration, crash-safety, export/import tests
apps/mobile/android/app/src/main/res/xml/backup_rules.xml   (with Platform's agreement)
```

## Must not edit

Domain interfaces (implement them; request changes via handoff), UI, controllers, app shell, pubspec.

## Rules that matter most here

- `.agent/rules/architecture.md` → Data and persistence: migrations + tests, transactions, no silent resets, snapshots.
- `.agent/rules/security.md` → secure storage, backup rules.

## Checks before handoff

`dart format` · `flutter analyze` · data tests incl. migration tests from every shipped schema.
