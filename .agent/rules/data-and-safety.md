---
trigger: always_on
---

# Health Data, Nutrition Content and Safety Rules

## Nutrition content

- Every food/recipe has `source`, `license`, `reviewedBy`, `reviewedAt`, `status` (draft / reviewed / published).
- **Never invent values.** Unknown stays unknown. Only a named reviewer may move an entry to `reviewed`.
- Confirm a dataset's licence before using it; record it.
- Nutrition per 100 g in canonical units; prepared dishes separate recipe/yield from raw ingredient weights so nothing is double-counted.
- Unreviewed entries must never appear as verified, and must never be used by public auto-planning.
- The food-pack validator runs in CI and blocks: duplicate IDs, missing source metadata, bad references, negative or non-finite nutrition, zero/negative serving weights, recipes without yields, missing allergen-review status.
- Catalogue corrections create a new revision; historical logs keep their snapshot.

## Safety (blueprint §3 is authoritative)

- Eligibility gate: automated plans need age 18+; excluded groups get manual logging only.
- Targets come only from the versioned `TargetPolicy` service. Floors and rate caps are **configuration**, covered by unit tests, and confirmed by a nutrition professional before public release. Do not hard-code them in UI or planner.
- Allergens: unknown status is never treated as safe; always show the cross-contact notice.
- Exclusions and allergies are never silently ignored. If no safe plan exists, return a clear `NoPlanReason`, never forced portions.
- Missed days are "not logged", never 0 kcal. Planned meals are never assumed eaten.
- Copy: no shaming, no red warnings for eating more, no medical claims. Very low intake for 3+ days → gentle check-in with help link.
- Every calculation is explainable via "How we calculated this" (formula, inputs, policy version).

## Planner determinism

- Same inputs + seed + pack version → same plan.
- Planner is pure; golden-data tests lock 20 reference profiles; changes to output require a policy-version bump.

## Privacy of health data

See `security.md`. In short: on-device by default, never in analytics, uploaded only on explicit sync.

