---
trigger: always_on
---

# Testing and Quality Rules

No release ships with a known data-loss bug, wrong totals, or broken exclusion filtering.

## What to test where

| Layer | Covers |
|---|---|
| Domain unit | Target policy, portions, oil maths, aggregation, recipe scaling, unit conversion |
| Property-based | Random profiles × restrictions never break exclusions or floors; seed determinism |
| Golden data | 20 reference profiles' plans unchanged unless policy version changes |
| Database | Migrations from every shipped schema, crash mid-transaction, export/import, outbox replay |
| Widget / golden UI | Key screens at 100% / 200% text, English / Urdu |
| Integration | Onboarding → plan → log → restart; airplane mode; permission denial; upgrade; notification cold start |
| Backend (v1.5+) | OpenAPI contract, authorization, guest migration, webhook replay, pack rollback, restore |

## Rules

- Every bug fix starts with a failing test that reproduces it.
- Tests are deterministic: injected clock, seeded randomness, no network, no sleeps.
- Test behaviour, not implementation. No assertions on private details.
- Domain-layer coverage ≥ 90%; coverage is a floor, not a goal.
- Never weaken or delete a test to make it pass. If a test is wrong, say why in the change.
- No real user data in fixtures. Use synthetic profiles.
- Tests that touch the filesystem or DB use temp/in-memory instances and clean up.

## CI gates (every pull request)

1. Format check
2. Static analysis (warnings are errors)
3. Unit + widget tests
4. Food-pack validator
5. Secret and dependency scan
6. Release build

Main branch adds integration tests and internal-testing upload.

## Performance (baseline: 2–3 GB RAM, Android 10+)

APK ≤ 25 MB · cold start ≤ 2.5 s · search ≤ 150 ms per keystroke · day plan ≤ 500 ms · memory ≤ 200 MB. Measured on a real device before each release; regressions block release.

## Verification honesty

State exactly what you ran and the result. If you could not run something (no device, no SDK), say so and mark the status `Implemented, awaiting verification`.

