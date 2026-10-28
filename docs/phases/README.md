# Phases

Built from `docs/APP_BLUEPRINT.md` §4 and §8. Blueprint numbers are kept so status lines up.
Each phase file lists its tasks (with lane and dependencies) and its exit criteria.
Live task status lives in `docs/WORKBOARD.md`; the phase file's checklist is ticked when a task is done.

## Lanes (who works where)

Each agent works in one lane and only edits that lane's paths. See `.agent/rules/collaboration.md` and `.agent/lanes/`.

| Lane | Default agent | First phase |
|---|---|---|
| Platform | Claude Code | P0 Foundation |
| UI | **Antigravity** | PU Complete UI |
| Content | any | P1 Food catalogue |
| Domain | Claude Code | P3 Target, P4 Planner |
| Data | any | P2 Local storage |
| Integration | Claude Code | P5 Main app wiring |

## Order and parallel work (to v1.0)

```text
PD Discovery (owner, people work) ───────────────────────────────┐
                                                                 │ feeds content + UX fixes
P0 Foundation (Platform) ──► P0-01 project skeleton done ──┬─► PU Complete UI (UI)  ──────┐
                                                           ├─► P2 Local storage (Data)    │
                                                           ├─► P3 Target + P4 Planner     ├─► P5 Main app wiring (Integration)
P1 Food catalogue (Content) ── can start now ──────────────┘    (Domain)                  │
                                                                                          ▼
                                       Gate A Private beta ─► P6 Shopping/Progress ─► P7 Reminders ─► P8 Launch
```

- **Everyone waits for P0-01** (Flutter project + folder skeleton), except Content and Discovery.
- After P0-01, UI, Data, Domain and Content run in parallel with no shared files.
- Integration starts screen by screen once both the UI screen and its domain/data pieces exist.

## Files

| Phase | File | Lanes |
|---|---|---|
| PD Discovery | `PD-discovery.md` | Owner |
| P0 Foundation | `P00-foundation.md` | Platform, Data |
| PU Complete UI | `PU-complete-ui.md` | UI |
| P1 Food catalogue | `P01-food-catalogue.md` | Content |
| P2 Local storage | `P02-local-storage.md` | Data |
| P3 Onboarding and target | `P03-onboarding-target.md` | Domain, Integration |
| P4 Planner engine | `P04-planner.md` | Domain |
| P5 Main app wiring | `P05-main-app.md` | Integration |
| Gate A Private beta | `GA-private-beta.md` | Owner, all |
| P6 Shopping and progress | `P06-shopping-progress.md` | Domain, Data, Integration |
| P7 Local reminders | `P07-reminders.md` | Platform, Integration |
| P8 Free Android launch | `P08-launch.md` | Platform, owner |
| P9–P17 | `P09-P17-after-launch.md` | Detailed when each starts |

## Phase rules

- A phase is done only when its exit criteria are verified and recorded in `docs/IMPLEMENTATION_STATUS.md`.
- A gate must pass before the next release starts.
- Task IDs are stable: `<phase>-<nn>` (e.g. `U-05`, `P2-03`). Never reuse an ID.
