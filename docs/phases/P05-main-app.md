# P5 — Main App Wiring (3 weeks, Integration lane)

Screens exist from PU. This phase replaces fixtures with real controllers, one feature at a time.
Each task = one controller + provider override + controller tests + one integration test.

## Tasks

| ID | Task | Depends on |
|---|---|---|
| I5-01 | Today controller: plan for date, planned vs consumed, macros + fibre, next meal, statuses, remaining target | U-07, D4-*, P2-03 |
| I5-02 | Logging: mark planned meal eaten ≤ 2 taps with snapshot; undo; no duplicate logs | I5-01 |
| I5-03 | Meal detail: add/replace/remove/resize items, family pot, oil level, regenerate meal | U-08, U-11, D4-06 |
| I5-04 | Foods: search (English + Roman Urdu, ≤ 150 ms/keystroke), food detail, missing-food request | U-10, P2-02 |
| I5-05 | History and saved plans | U-12 |
| I5-06 | Settings, privacy and data controls (export/import/delete-all), transparency screen | U-16, U-17, U-18, P2-04 |
| I5-07 | Ramadan mode and manual-only mode on Today | I5-01, D4-02, D3-03 |
| I5-08 | Low-intake check-in trigger (3+ days) | I5-02, U-18 |
| I5-09 | Integration tests: onboarding → plan → log → restart; airplane mode; upgrade path | I5-01…I5-08 |

## Exit criteria (blueprint)

- [ ] First plan works offline
- [ ] Add / replace / remove / resize items
- [ ] Logging a planned meal ≤ 2 taps; no accidental duplicate logs
- [ ] Usable at 200% text and 360 dp width
- [ ] Every screen has empty, error and recovery states
