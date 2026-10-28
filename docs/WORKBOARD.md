# Work Board

How to use: `.agent/rules/collaboration.md` §2. Claim a task by setting **Status**, **Agent** and **Branch**.
One task per agent at a time. Task details are in `docs/phases/`.

Status: `Open` · `In progress` · `Implemented, awaiting verification` · `Verified` · `Blocked by <x>`
"Verified" = checked in CI. Device checks are listed under each phase as "awaiting verification".

## P0 Foundation

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| P0-00 | Flutter/SDK, test phone, git | Owner | Blocked by owner (test phone; Flutter optional — CI builds) | owner | main |
| P0-01 | Flutter project + flavors + skeleton + pinned packages | Platform | Verified | Claude Code | feat/p0-p8 |
| P0-02 | Strict analysis options, format check | Platform | Verified | Claude Code | feat/p0-p8 |
| P0-03 | CI pipeline | Platform | Verified | Claude Code | feat/p0-p8 |
| P0-04 | Core utils: Result/failures, logger, clock, UUIDv7 | Platform | Verified | Claude Code | feat/p0-p8 |
| P0-05 | Drift setup + migration harness | Data | Verified | Claude Code | feat/p0-p8 |
| P0-06 | Error boundary + recovery screen | Platform | Implemented, awaiting verification | Claude Code | feat/p0-p8 |
| P0-07 | APK size + cold start on baseline phone | Platform | APK size in CI; cold start Blocked by owner (phone) | Claude Code | feat/p0-p8 |
| P0-08 | README setup section | Platform | Verified | Claude Code | feat/p0-p8 |

## PU Complete UI (Antigravity)

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| U-00…U-21 | Design spec, theme, widgets, all screens, gallery, a11y, RTL, tests | UI | Implemented, awaiting verification | Antigravity | ui |

## P1 Food catalogue

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| P1-01 | Pack JSON Schema | Content | Verified | Claude Code | feat/p0-p8 |
| P1-02 | Validator CLI + tests | Content | Verified | Claude Code | feat/p0-p8 |
| P1-03 | Household measures (draft) | Content | Implemented, awaiting verification (nutritionist) | Claude Code | feat/p0-p8 |
| P1-04 | Pack skeleton | Content | Implemented: 53 foods (blueprint target 150 needs D-05 list) | Claude Code | feat/p0-p8 |
| P1-05 | Nutrition from licensed source | Content | Implemented (USDA SR Legacy); licence record Blocked by owner | Claude Code | feat/p0-p8 |
| P1-06 | Curated combinations | Content | Implemented, awaiting verification (48 combos) | Claude Code | feat/p0-p8 |
| P1-07 | Build step + CI validator | Content | Verified | Claude Code | feat/p0-p8 |
| P1-08 | Alias search test set | Content | Implemented (12 queries in tests; 100-query set needs D-05) | Claude Code | feat/p0-p8 |
| P1-09 | Nutritionist review rounds | Owner | Blocked by owner (D-04) | | |

## P2 Local storage

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| P2-01 | Drift schema | Data | Verified | Claude Code | feat/p0-p8 |
| P2-02 | Pack loader | Data | Verified (in-memory, see DECISIONS) | Claude Code | feat/p0-p8 |
| P2-03 | Repository implementations | Data | Verified | Claude Code | feat/p0-p8 |
| P2-04 | Export / import / delete-all | Data | Verified | Claude Code | feat/p0-p8 |
| P2-05 | Android backup rules | Data | Implemented; choice to confirm by owner | Claude Code | feat/p0-p8 |
| P2-06 | Corrupt data → recovery path | Data | Verified (detection); recovery screen awaiting device check | Claude Code | feat/p0-p8 |
| P2-07 | Crash, reopen, migration, export→wipe→import tests | Data | Verified | Claude Code | feat/p0-p8 |

## P3 Onboarding and target

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| D3-01 | Domain entities + interfaces | Domain | Verified | Claude Code | feat/p0-p8 |
| D3-02 | Unit system | Domain | Verified | Claude Code | feat/p0-p8 |
| D3-03 | Eligibility | Domain | Verified | Claude Code | feat/p0-p8 |
| D3-04 | TargetPolicy v1 (provisional values) | Domain | Verified; values Blocked by nutritionist sign-off | Claude Code | feat/p0-p8 |
| D3-05 | Policy + eligibility tests | Domain | Verified | Claude Code | feat/p0-p8 |
| I3-01 | Onboarding controller | Integration | Verified (flow tests) | Claude Code | feat/p0-p8 |
| I3-02 | Profile edits affect future plans only | Integration | Verified | Claude Code | feat/p0-p8 |

## P4 Planner

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| D4-01…D4-08 | Filter, allocation, combos, portions, family pot, oil, regenerate meal, NoPlanReason, tests | Domain | Verified | Claude Code | feat/p0-p8 |

## P5 Main app wiring

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| I5-01 | Today controller | Integration | Verified (flow tests) | Claude Code | feat/p0-p8 |
| I5-02 | Logging ≤ 2 taps, undo, no duplicates | Integration | Verified (flow tests) | Claude Code | feat/p0-p8 |
| I5-03 | Meal detail edits | Integration | Verified (flow tests) | Claude Code | feat/p0-p8 |
| I5-04 | Foods search, detail, missing-food request | Integration | Implemented, awaiting verification | Claude Code | feat/p0-p8 |
| I5-05 | History | Integration | Implemented, awaiting verification | Claude Code | feat/p0-p8 |
| I5-06 | Settings, privacy, transparency | Integration | Implemented, awaiting verification | Claude Code | feat/p0-p8 |
| I5-07 | Ramadan and manual-only on Today | Integration | Verified (manual-only); Ramadan awaiting device check | Claude Code | feat/p0-p8 |
| I5-08 | Low-intake check-in | Integration | Verified (flow test) | Claude Code | feat/p0-p8 |
| I5-09 | End-to-end flows | Integration | Verified headless in CI; device run awaiting verification | Claude Code | feat/p0-p8 |

## Gate A

| ID | Task | Lane | Status |
|---|---|---|---|
| GA-01…GA-05 | Play account, 30 testers, crash reporting, weekly report, nutritionist sign-off | Owner | Blocked by owner |

## P6 Shopping and progress

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| D6-01 | Ingredient aggregation | Domain | Verified | Claude Code | feat/p0-p8 |
| D6-02 | Progress calculations | Domain | Verified | Claude Code | feat/p0-p8 |
| P6-01 | Shopping persistence | Data | Verified | Claude Code | feat/p0-p8 |
| I6-01 | Shopping screen wiring | Integration | Verified (flow test) | Claude Code | feat/p0-p8 |
| I6-02 | Progress + weights wiring | Integration | Verified (flow test) | Claude Code | feat/p0-p8 |

## P7 Reminders

| ID | Task | Lane | Status | Agent | Branch |
|---|---|---|---|---|---|
| P7-01 | ReminderService over local notifications | Platform | Implemented, awaiting verification (device) | Claude Code | feat/p0-p8 |
| P7-02 | Reschedule on change, reboot, update, timezone; quiet hours | Platform | Logic verified; OS behaviour awaiting device | Claude Code | feat/p0-p8 |
| P7-03 | Ramadan switch | Platform | Verified (schedule tests) | Claude Code | feat/p0-p8 |
| I7-01 | Reminders screen wiring | Integration | Verified (flow test) | Claude Code | feat/p0-p8 |

## P8 Launch

| ID | Task | Lane | Status |
|---|---|---|---|
| P8-01 | Brand, application ID, icon | Owner | Blocked by owner |
| P8-02 | Store assets | UI + owner | Draft listing in `docs/release/store-listing-draft.md` |
| P8-03 | Support email, privacy policy URL, legal review | Owner | Draft policy in `docs/release/privacy-policy-draft.md` |
| P8-04 | Consent-gated analytics | Platform | Interface + consent implemented; provider Blocked by owner |
| P8-05 | Data safety + health declaration | Owner | Draft in `docs/release/play-data-safety-draft.md` |
| P8-06 | Signed release + checklist | Platform + owner | Signing hook ready; key Blocked by owner |
| P8-07 | Internal → closed → staged rollout | Owner | Blocked by owner |

## Handoff requests

| File | From → To | Status |
|---|---|---|
| — (strings to ARB files before Urdu UI) | Integration → UI | Open — follow-up for P9 |
