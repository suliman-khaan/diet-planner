# P9–P17 — After Launch

Each phase gets its own detailed file (tasks, lanes, dependencies) **when it starts**, following the
same format as P0–P8. Scope and exit criteria are in `docs/APP_BLUEPRINT.md` §8. New lanes
(Backend, Admin) are added to `.agent/lanes/` when P10 starts.

| Phase | Release | Main lanes | Scope in one line |
|---|---|---|---|
| P9 Growth | v1.1 | UI, Content, Integration | Urdu UI + RTL, better Roman Urdu search, sharing, favourites, regional foods |
| P10 Backend foundation | v1.5 | Backend (new), Platform | API + worker, PostgreSQL, storage, auth verification, OpenAPI |
| P11 Accounts and sync | v1.5 | Backend, Data, Integration | Optional accounts, guest migration, outbox sync, conflicts |
| P12 Admin and packs | v1.5 | Admin (new), Content, Backend | Review workflow, versioned pack publishing, rollback |
| Gate B Premium review | — | Owner | Engagement thresholds in blueprint §11 |
| P13 Premium | v2.0 | Backend, Integration, UI | Play Billing with server verification, premium features |
| P14 Push campaigns | v2.1 | Backend, Platform | Opt-in FCM campaigns, separate from reminders |
| P15 More countries | per country | Content | New packs with no planner code change |
| P16 iOS | v3.0 | Platform, UI, Integration | iPhone app, StoreKit, APNs, Sign in with Apple |
| P17 Operations | ongoing | All | Monitoring, restore drills, dependency and policy upkeep |
