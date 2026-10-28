# P2 — Local Storage (1 week, Data lane)

## Tasks

| ID | Task | Depends on |
|---|---|---|
| P2-01 | Drift schema for all user entities (blueprint §7): profile, preferences, schedule, daily plan/meal/plan item, food log entry with nutrition snapshot, day status, weight, shopping list, reminder prefs, saved template, entitlement, outbox (reserved); `createdAt/updatedAt/deletedAt/revision` | P0-05, D3-01 (entities) |
| P2-02 | Pack loader: bundled JSON → read-only tables on first run / pack update; keep last valid pack | P2-01, P1-07 |
| P2-03 | Repository implementations for domain interfaces (Food, Recipe, Profile, Plan, FoodLog, Progress, ShoppingList) | P2-01, D3-01 |
| P2-04 | JSON export / import (full restore) and delete-all | P2-03 |
| P2-05 | Android backup rules (explicit include/exclude) — agree with Platform | P2-01 |
| P2-06 | Corrupt-data detection → recovery path (never silent reset) | P2-01 |
| P2-07 | Tests: process-kill survival, mid-transaction crash, migration test harness, export → wipe → import | P2-03, P2-04 |

## Exit criteria (blueprint)

- [x] Data survives process kill *(CI, 2026-10-29)*
- [x] Mid-transaction crash leaves last valid state *(CI, 2026-10-29)*
- [x] Migration tests from every shipped schema *(CI, 2026-10-29)*
- [x] Export → wipe → import restores everything *(CI, 2026-10-29)*
- [x] Corrupt data never silently resets the app *(CI, 2026-10-29)*
