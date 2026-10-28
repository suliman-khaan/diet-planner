# Lane: Domain

**Starts with:** Phase 3 (TargetPolicy) and Phase 4 (planner), after P0-01.

## Owns (may edit)

```text
apps/mobile/lib/domain/**        entities (freezed), value types, units, TargetPolicy, planner,
                                 eligibility, shopping aggregation, repository + service interfaces
apps/mobile/test/domain/**       unit, property-based and golden-data tests
apps/mobile/test/golden_data/**  reference profiles and expected plans
```

## Must not edit

UI, data, controllers, app shell, pubspec, content.

## Rules that matter most here

- Pure Dart only: no Flutter, no I/O, no `DateTime.now()`, no unseeded randomness.
- `.agent/rules/data-and-safety.md` in full: floors and rate caps are config, never relaxed; exclusions never ignored; `NoPlanReason` instead of forced portions.
- Repository interfaces here are contracts for Data and Integration: change them via handoff.

## Checks before handoff

`dart format` · `dart analyze` · `dart test` · coverage ≥ 90% for `lib/domain`.
