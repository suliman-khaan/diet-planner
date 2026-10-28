# P3 — Onboarding and Target (1.5 weeks, Domain + Integration)

Screens come from PU (U-06). This phase builds the logic and wires it.

## Tasks

| ID | Task | Lane | Depends on |
|---|---|---|---|
| D3-01 | Domain entities and value types (freezed) for blueprint §7 + repository/service interfaces (incl. `EntitlementRepository` returning free, no-op `SyncService`, disabled `AnalyticsService`) | Domain | P0-01 |
| D3-02 | Unit system: canonical g/ml/kcal, conversions for display | Domain | D3-01 |
| D3-03 | Eligibility check (18+, pregnancy, breastfeeding, listed conditions, BMI < 18.5 with "lose") → manual-only or maintenance | Domain | D3-01 |
| D3-04 | `TargetPolicy` v1: Mifflin-St Jeor × activity, goal adjustment, floors and rate caps **from config**, policy version; explanation object for "How we calculated this" | Domain | D3-01 |
| D3-05 | Tests: floors, rate caps, BMI guardrail, eligibility edges, property tests over random profiles | Domain | D3-03, D3-04 |
| I3-01 | Onboarding controller: field validation → profile saved → target computed → route to first plan or manual mode | Integration | U-06, D3-04, P2-03 |
| I3-02 | Profile edits affect future plans only unless the user regenerates | Integration | I3-01 |

## Exit criteria (blueprint)

- [ ] Completes without an account
- [ ] Useful field errors
- [ ] Ineligible users routed to manual mode
- [ ] Policy tests cover floors and rate caps
- [ ] Profile changes affect future plans only unless user regenerates
- [ ] Floor/cap values marked as placeholders until nutritionist confirms
