# Work Board

How to use: `.agent/rules/collaboration.md` §2. Claim a task by setting **Status**, **Agent** and **Branch**.
One task per agent at a time. Task details are in `docs/phases/`.

Status: `Open` · `In progress` · `Implemented, awaiting verification` · `Verified` · `Blocked by <x>`

## Ready now or next

| ID | Task | Lane | Depends on | Status | Agent | Branch |
|---|---|---|---|---|---|---|
| P0-00 | Install Flutter/SDK/JDK, test phone, `git init` + first commit | Owner | — | In progress | owner | main |
| P0-01 | Flutter project + full lane folder skeleton + routes + pinned packages | Platform | P0-00 | Open | | |
| P0-02 | Strict analysis options, format script | Platform | P0-01 | Open | | |
| P0-03 | CI pipeline | Platform | P0-01 | Open | | |
| P0-04 | Core utils: Result/failures, logger, clock, UUIDv7 | Platform | P0-01 | Open | | |
| P0-05 | Drift setup + migration harness | Data | P0-01 | Open | | |
| P0-06 | Error boundary + crash-safe startup | Platform | P0-04 | Open | | |
| P0-07 | Baseline APK size + cold start | Platform | P0-03 | Open | | |
| P0-08 | README setup section | Platform | P0-01 | Open | | |
| U-00 | Design spec from `design/ui-concepts` (no code) | UI | — | Implemented, awaiting verification | Antigravity | ui |
| U-01 | Tokens + theme + bundled fonts | UI | P0-01 | Implemented, awaiting verification | Antigravity | ui |
| U-02 | Shared widgets | UI | U-01 | Implemented, awaiting verification | Antigravity | ui |
| U-03 | State widgets | UI | U-02 | Implemented, awaiting verification | Antigravity | ui |
| U-04 | Bottom nav + scaffold | UI | U-02 | Implemented, awaiting verification | Antigravity | ui |
| U-05 | Dev Screen Gallery | UI | U-04 | Implemented, awaiting verification | Antigravity | ui |
| U-06 | Onboarding screens | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-07 | Today (all modes) | UI | U-04 | Implemented, awaiting verification | Antigravity | ui |
| U-08 | Meal detail | UI | U-02 | Implemented, awaiting verification | Antigravity | ui |
| U-09 | Portion picker + guides | UI | U-02 | Implemented, awaiting verification | Antigravity | ui |
| U-10 | Foods search + detail | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-11 | Add / replace / quick-add sheets | UI | U-10 | Implemented, awaiting verification | Antigravity | ui |
| U-12 | History | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-13 | Progress | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-14 | Shopping list | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-15 | Reminders | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-16 | More + settings | UI | U-04 | Implemented, awaiting verification | Antigravity | ui |
| U-17 | Privacy & data | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-18 | Transparency + check-in | UI | U-03 | Implemented, awaiting verification | Antigravity | ui |
| U-19 | Accessibility pass | UI | U-06…U-18 | Implemented, awaiting verification | Antigravity | ui |
| U-20 | RTL readiness | UI | U-19 | Implemented, awaiting verification | Antigravity | ui |
| U-21 | Golden + widget tests | UI | U-19 | Implemented, awaiting verification | Antigravity | ui |
| P1-01 | Pack JSON Schema | Content | — | Open | | |
| P1-02 | Validator CLI + tests | Content | P1-01 | Open | | |
| P1-03 | Household measures (draft) | Content | P1-01 | Open | | |
| D3-01 | Domain entities + interfaces | Domain | P0-01 | Open | | |
| D3-02 | Unit system | Domain | D3-01 | Open | | |
| D3-03 | Eligibility | Domain | D3-01 | Open | | |
| D3-04 | TargetPolicy v1 | Domain | D3-01 | Open | | |
| D3-05 | Policy + eligibility tests | Domain | D3-03, D3-04 | Open | | |

Later tasks (P1-04 onwards, P2, P4, P5, P6, P7, P8) are listed in their phase files; add them here when their dependencies are close to done.

## Handoff requests

Open requests live in `docs/handoffs/`. List new ones here:

| File | From → To | Status |
|---|---|---|
| — | — | — |
