# Implementation Status

Labels: Not started · In progress · Implemented, awaiting verification · Verified · Blocked by <dependency>

"Verified" here means checked by CI (`.github/workflows/ci.yml`, Flutter 3.47.8): analyzer clean, tests passing.
Anything that needs a real phone (cold start, reminders after reboot, low-end performance) is **awaiting verification**
until the owner runs it on the baseline device.

Last updated: 2026-10-29 · Branch: `feat/p0-p8`

## Environment

| Tool | State |
|---|---|
| Git + GitHub | Found; CI on GitHub Actions |
| Flutter / Dart | Not installed locally — CI builds (Flutter 3.47.8, Dart 3.13.7) |
| Node.js | Found (food-pack tools run locally and in CI) |
| Baseline low-end phone | **Blocked by owner** (P0-00) |

## Phases

| Phase | Status | Notes |
|---|---|---|
| PD — Discovery | Blocked by owner | Interviews, 150-food list, nutritionist |
| P0 — Foundation | Implemented, awaiting verification | Android folder + flavors, strict analysis, CI, core utils, error boundary, Drift. Device cold start and APK size on phone not yet measured |
| PU — Complete UI | Implemented, awaiting verification (Antigravity) | Screens now wired to real data; see lane exception in DECISIONS.md |
| P1 — Food catalogue | Implemented, awaiting verification | Schema, validator (24 tests), 50 USDA ingredients, 53 draft foods, 48 combos. **0 of 53 reviewed** — nutritionist needed |
| P2 — Local storage | Verified (CI) | Drift schema, repositories, export/import/delete-all, crash and reopen tests |
| P3 — Onboarding and target | Verified (CI) | TargetPolicy, eligibility, onboarding with safety questions. Values provisional |
| P4 — Planner engine | Verified (CI) | 1,000-profile accuracy, determinism, exclusion property tests, golden data |
| P5 — Main app wiring | Implemented, awaiting verification | Flow tests pass in CI; needs on-device check |
| Gate A — Private beta | Blocked by owner | Play account, testers, nutritionist sign-off |
| P6 — Shopping and progress | Implemented, awaiting verification | Domain verified in CI; screens need device check |
| P7 — Local reminders | Implemented, awaiting verification | Scheduling logic verified in CI; OS behaviour (permission, reboot, timezone) needs a device |
| P8 — Free Android launch | In progress | Engineering parts done; owner actions and drafts in `docs/release/` |
| P9–P17 | Not started | |

Task-level status: `docs/WORKBOARD.md`. Phase details: `docs/phases/`.

## What CI proves today

- 101+ tests pass: domain (target policy, eligibility, planner, search, logging, shopping, reminders), data (Drift
  repositories, export → wipe → import, crash mid-transaction, damaged file, reopen), UI widget tests, and end-to-end
  flows through the real controllers (onboarding → plan → log → restart, manual-only, vegetarian re-plan, meal edits,
  shopping ticks, reminders, low-intake check-in).
- Domain line coverage **97.5 %** (gate ≥ 90 %).
- Prod arm64 release APK (obfuscated): **21.3 MB** (budget ≤ 25 MB), CI run 40772657361.
- Planner: ≥ 95 % of 1,000 generated profiles within ±10 % of target, zero exclusion violations, same seed → same plan.
- Food pack validator rejects every case in blueprint Phase 1.

## Known limits

- **Food data is draft.** Release (prod) builds therefore never auto-plan; they show "no plan" and allow manual logging
  until foods are reviewed. Dev builds plan with draft data and label it.
- **UI strings are not in ARB files yet** (hard-coded English). Needed before Urdu UI (P9).
- Analytics and crash reporting have no provider connected (no-op until the owner sets up Firebase).
- Support email, help link, brand and application ID are placeholders.
- Integration tests run headless in CI against real controllers and an in-memory database, not on a device.
- Performance budgets (cold start ≤ 2.5 s, search ≤ 150 ms, memory ≤ 200 MB) are not measured on a phone yet; release APK
  size is checked in CI.

## Handoff log

### 2026-10-20 — Initial structure
- Monorepo skeleton, agent rules, status/decision/release docs.

### 2026-10-28 — Phase plan and multi-agent lanes
- `docs/phases/`, `docs/WORKBOARD.md`, `docs/handoffs/`, `.agent/lanes/`, collaboration rules.

### 2026-10-28 — Phase U (Antigravity)
- Complete UI with fixtures on branch `ui`.

### 2026-10-29 — P0–P8 engineering (Claude Code, branch `feat/p0-p8`)
- **Built:** Android platform folder with dev/prod flavors and signing hooks; CI (pack checks, secret scan, format,
  analyze, tests, coverage gate, dev + prod arm64 APKs, size budget); core utils; USDA-based draft food pack with
  validator; pure domain (TargetPolicy, eligibility, planner, search, logging, progress, shopping, reminders); Drift
  storage with export/import/delete-all; controllers for every screen; onboarding safety questions; router with deep
  links; reminders via local notifications; consent-gated analytics interface; release drafts.
- **Fixed in UI:** infinite-width outlined buttons (crash), static "eligible" step, fake target fallbacks, hard-coded
  settings values, non-persisted consent toggle, missing allergen cross-contact notice, check-in sheet double pop and
  missing help link, misleading transparency text.
- **Tests:** see "What CI proves today".
- **External setup needed:** see `docs/DECISIONS.md` → Open owner decisions.
- **Next:** owner installs the dev APK on the baseline phone and checks the P5/P7 device items; nutritionist reviews
  foods, measures and safety values (Gate A); owner decisions for P8.
