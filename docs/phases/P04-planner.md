# P4 — Planner Engine (2.5 weeks, Domain lane)

`generatePlan(profile, target, pack, schedule, restrictions, date, seed) → PlanResult` — pure Dart.

## Tasks

| ID | Task | Depends on |
|---|---|---|
| D4-01 | Restriction filter first (veg, allergies with unknown = unsafe, exclusions) | D3-01 |
| D4-02 | Calorie allocation across 3–6 slots incl. chai and Ramadan sehri/iftar | D3-04 |
| D4-03 | Combo selection from curated combinations; repetition reduction | D4-01, P1-06 |
| D4-04 | Portion adjustment within practical bounds (household measures) | D4-03 |
| D4-05 | Family pot portions + oil level adjustment | D4-04 |
| D4-06 | Regenerate one meal without touching completed ones | D4-04 |
| D4-07 | `NoPlanReason` for every failure; never forced portions | D4-01 |
| D4-08 | Tests: determinism, 1,000 generated profiles ±10%, zero exclusion violations (property), no double-counting of recipe ingredients, 20 golden reference profiles, ≤ 500 ms per day plan | D4-01…D4-07 |

## Exit criteria (blueprint)

- [ ] Same inputs + seed + pack version = same plan
- [ ] ≥ 95% of 1,000 generated profiles within ±10% of target
- [ ] Zero exclusion violations in property tests
- [ ] No-match returns a clear explanation, never forced portions
- [ ] No double-counting of recipe ingredients
