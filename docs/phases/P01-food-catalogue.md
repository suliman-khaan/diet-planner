# P1 — Food Catalogue (3–4 weeks, Content lane, parallel with P0–P3)

Can start now; needs Node or Dart for the validator, not Flutter.

## Tasks

| ID | Task | Depends on |
|---|---|---|
| P1-01 | Pack JSON Schema in `contracts/food-pack-schema/` covering blueprint §7 food + recipe fields (ids, revision, names, `aliases.romanUrdu[]`, tags, nutrition per 100 g, servings with grams + `photoRef`, allergens + review status, `oilProfile`, `isSharedDish`, `mealSlotFit[]`, source/licence/review/status) | — |
| P1-02 | Validator CLI in `tools/` rejecting: duplicate IDs, missing source metadata, invalid references, negative/non-finite nutrition, zero/negative serving weights, recipes without yields, missing allergen-review status; with its own tests | P1-01 |
| P1-03 | Household measures table (katori, pyala, chamach, roti small/medium/tandoori → grams) as draft, pending review | P1-01 |
| P1-04 | Pack skeleton for the 150-food list: ids, categories, English/Urdu/Roman Urdu names and aliases, servings, slot fit, `status: draft`, **no invented nutrition** | D-05, P1-01 |
| P1-05 | Nutrition values from licensed sources only (USDA FDC, Pakistan tables, recipe calculation) with source fields filled; licence confirmed in `DECISIONS.md` | P1-04, owner licence decision |
| P1-06 | Curated meal combinations (e.g. salan + roti + salad) | P1-04 |
| P1-07 | Build step: source → versioned pack JSON in `apps/mobile/assets/packs/`; CI validator step (handoff to Platform) | P1-02, P0-03 |
| P1-08 | Alias search test set (100 Roman Urdu queries → expected food) for later search tuning | P1-04 |
| P1-09 | Nutritionist review rounds; reviewer fills `reviewedBy/reviewedAt` | P1-05, D-04 |

## Exit criteria

- [x] Pack loads in airplane mode (verified in P2/P5) *(CI, 2026-10-29)*
- [x] Alias search works on the test set *(CI, 2026-10-29)*
- [x] Validator runs in CI and blocks bad data *(CI, 2026-10-29)*
- [x] Unverified entries cannot appear as verified *(CI, 2026-10-29)*
- [ ] ≥ 80% reviewed before beta; 100% of entries used in public auto-planning
