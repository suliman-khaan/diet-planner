# Global Diet Planner — Product & Engineering Blueprint (v2, Final)

File: `docs/APP_BLUEPRINT.md`
Date: 2026-10-20
Status: Approved planning specification (supersedes Blueprint v1 wherever they conflict)
Initial platform: Android (Flutter) · Future platform: iOS
Initial market: Pakistan · Brand: global
Business model: Free core, then monthly and yearly premium subscriptions

---

## 1. Summary and Changes from v1

v1 had strong engineering discipline: offline-first, planned vs consumed separation, nutrition snapshots, deterministic planner, server-verified billing, honest status labels. All of that is kept.

v2 fixes the gaps in product risk, local fit and planning:

| # | Gap in v1 | Change in v2 | Why |
|---|---|---|---|
| 1 | Local JSON files for all user data | SQLite (Drift) for user data from v0.1; JSON only for the bundled food pack and export | Logs grow daily; whole-file rewrites are slow and fragile on low-end phones; sync needs queries, outbox, migrations |
| 2 | No user validation before building | 2-week discovery sprint + private beta gate (Gate A) before v1.0 | A well-built app can still miss how Pakistani families eat |
| 3 | Assumes individual meals | "Family pot" mode: your portion from one shared salan/daal | Most households cook one dish for everyone |
| 4 | No Ramadan support | Ramadan mode: sehri/iftar slots, shifted reminders | Meal timing changes completely for a month every year |
| 5 | Cooking oil/ghee not modelled | Oil level per dish (light / normal / rich) | Oil is the largest hidden calorie source in desi cooking |
| 6 | No safety rules | Age 18+ for auto-plans, calorie floors, loss-rate caps, eating-disorder safeguards | Prevent harm; required for store health-app review |
| 7 | 10,000 downloads triggers premium | Engagement gate (Gate B) | Downloads do not prove willingness to pay |
| 8 | No timeline or cost | Estimates per phase, running-cost guidance | Owner needs to plan time and money |
| 9 | No performance budget | Size, start-up, memory targets on a 2–3 GB RAM phone | Much of the Pakistani Android base is low-end |

### Current implementation status

- No application code exists yet.
- Flutter and Android tooling not yet verified.
- No backend, Firebase project or billing integration exists.
- App name not final; no nutrition dataset verified for public release.

---

## 2. Product Vision and Users

The app gives a Pakistani adult a realistic daily meal plan built from food they already eat — roti, daal, salan, chawal — with honest calorie and macro estimates, free and offline.

**Promise:** "Eat your normal desi food, in the right amounts."

### Primary users (validate in discovery)

| Persona | Situation | First need |
|---|---|---|
| Weight-loss beginner, 22–40 | Wants to lose 5–15 kg; quit generic Western diets | A plan built on ghar ka khana |
| Gym-goer, 18–30 | Needs protein targets; home or hostel food | Protein-aware plans, fast logging |
| Home cook, 28–50 | Cooks one pot for 4–6 people | Portion guidance from the shared dish; shopping list |
| Health-conscious, 35–55 | Wants balance, not dieting | Simple daily balance and reminders |

Out of scope for automated plans: under-18s, pregnancy, breastfeeding, diabetes, kidney disease and other medical diets. These users can still log food manually and see a clear notice.

### Pakistan-specific product requirements

- **Shared cooking:** plan output reads like "1 katori of the family's chicken karahi + 1.5 roti", not a separate recipe.
- **Oil and ghee:** one-time "how rich is your home cooking?" question, with per-dish override; calorie impact shown.
- **Household measures:** katori, pyala, chamach, roti size (small / medium / tandoori), each mapped to grams with a photo guide.
- **Meal times:** late dinners (9–11 pm) and a chai snack slot are normal defaults to offer.
- **Ramadan:** sehri and iftar replace breakfast and lunch on user-chosen dates; reminders switch automatically.
- **Language:** Roman Urdu search is critical ("aloo ki bhujia", "chana chaat"); Urdu UI follows in v1.1.
- **Devices and data:** small download, fully offline core, low memory use.

### Success metrics (first 90 days after v1.0; review after month one)

| Metric | Definition | Target |
|---|---|---|
| Activation | Installs that finish onboarding and see a first plan | ≥ 60% |
| Day-7 retention | Users opening the app on day 7 | ≥ 20% |
| Day-30 retention | Users opening the app on day 30 | ≥ 10% |
| Logging habit | Weekly actives logging ≥ 3 days | ≥ 35% |
| Crash-free users | Crash reporting | ≥ 99.5% |
| Store rating | Google Play | ≥ 4.3 |

---

## 3. Product Rules and Nutrition Safety

### Core rules

1. Global brand; Pakistan is the first food catalogue.
2. Basic daily planning is free forever.
3. Core use needs no registration.
4. Installed food packs and existing plans work offline.
5. Show calories, protein, carbohydrates, fat and fibre.
6. Label all nutrition values and targets as estimates.
7. Never silently ignore allergies or exclusions.
8. Preserve user data across upgrades.
9. Business logic stays outside UI widgets.
10. Accounts exist for cloud features only, never to open the app.
11. No privileged server credentials in the mobile app.
12. Premium is introduced through a deliberate release.
13. Never remove promised free features to create premium.

### Safety rules

1. **Eligibility:** automated plans require age 18+. Under-18s, pregnancy and listed medical conditions get manual logging only, with an explanation.
2. **Energy formula:** Mifflin-St Jeor resting energy × activity factor, then goal adjustment. All in one versioned `TargetPolicy` service with unit tests.
3. **Calorie floor:** never generate below a reviewed floor (starting proposal: 1,500 kcal/day men, 1,200 kcal/day women).
4. **Rate caps:** loss deficit capped (starting proposal: about 0.5–0.75 kg/week, never above 1% of body weight per week); gain surplus capped similarly.
5. **BMI guardrail:** goal "lose" with BMI below 18.5 → no loss plan; offer maintenance and suggest professional advice.
6. **Eating-disorder safeguards:** no streak shaming, no "you failed" copy, no red warnings for eating more. Very low logged intake for 3+ consecutive days → gentle check-in with a help link.
7. **Allergens:** unknown status is never treated as safe; every allergy screen states that ingredient filtering cannot rule out kitchen cross-contact.
8. **No medical claims** in the app or store listing ("cure", "treat", "diabetes plan").
9. **Transparency:** a "How we calculated this" screen shows formula, inputs and policy version.

Values in rules 3 and 4 are engineering placeholders, stored as configuration, and must be confirmed by a nutrition professional before public automated planning.

---

## 4. Release Roadmap

Estimates assume one full-time experienced Flutter developer with part-time design and nutrition review.

| Release | Timing | Content |
|---|---|---|
| v0.1 Private build | Months 1–4 | Discovery, foundation, food catalogue, SQLite storage, onboarding, planner, main app |
| **Gate A — Private beta** | 3 weeks | 30 testers; ≥ 40% still logging in week 3; nutritionist sign-off; no data-loss bugs |
| v1.0 Free Android launch | Months 5–6 | Shopping list, progress, local reminders incl. Ramadan mode, store launch |
| v1.1 Growth | Month 7 | Urdu UI, better Roman Urdu search, sharing, favourites, regional foods |
| v1.5 Server foundation | Months 8–10 | Backend, accounts, cloud sync, admin app, downloadable packs |
| **Gate B — Premium review** | — | See section 11 |
| v2.0 Premium | Months 11–12 | Play Billing with server verification, weekly/monthly plans, family planning |
| v2.1 Expansion | After v2.0 | Push campaigns, additional country packs, reporting |
| v3.0 iOS | After v2.1 | iPhone app, Apple purchases, cross-platform accounts |

Each gate must pass before the next release starts. Backend foundations precede premium so purchases have a trusted server.

---

## 5. Free vs Premium Contract

| Capability | Free | Premium |
|---|---|---|
| Pakistan core catalogue, daily plan, logging, history | Yes | Yes |
| Portions, replacements, nutrition totals | Yes | Yes |
| Weight tracking, daily shopping list, local reminders | Yes | Yes |
| Family pot mode | Yes | Yes |
| Ramadan mode | Yes | Yes |
| Oil level setting | Yes | Yes |
| Basic sharing, data export, account + basic backup | Yes | Yes |
| Weekly / monthly automated plans | — | Yes |
| Family planning for several people + shared shopping list | — | Yes |
| Templates, advanced macros, meal-prep schedules | — | Yes |
| Multi-day shopping lists, advanced reports and exports | — | Yes |
| Extra country packs, premium recipe collections | Preview | Yes |

Basic preparation information stays free; premium recipes are additional content. No ads in the roadmap; any future ads need a recorded decision and must never use health data.

**On expiry:** history and saved plans stay readable; creation of new premium plans and access to new premium content stops.

### Monetization in Pakistan

- PKR pricing via Play local pricing; yearly plan typically priced at 6–8 months of monthly. Owner sets final prices.
- Before premium, confirm which payment methods Google Play currently supports in Pakistan (e.g. carrier billing, local wallets) and test them in sandbox.
- One 7-day free trial through Play's trial feature, handled as a normal server entitlement.

---

## 6. Architecture and Technology

### Storage decision (ADR-001, supersedes v1 "no database")

| Data | Storage | Notes |
|---|---|---|
| Bundled Pakistan food pack | Versioned JSON asset → loaded into read-only SQLite tables on first run / pack update | JSON stays the authoring and transport format |
| Profile, plans, logs, weights, shopping lists, outbox | SQLite via Drift | Transactions, migrations, indexed queries, reactive streams |
| Lightweight settings | Shared Preferences | Theme, onboarding flags |
| Auth tokens (v1.5+) | flutter_secure_storage | Android Keystore backed |

There is still no database **server** before v1.5. User export/import uses a JSON file.

### Mobile stack

| Concern | Choice |
|---|---|
| Framework | Flutter stable, Dart 3; pin versions, commit `pubspec.lock` |
| State / DI | Riverpod (with code generation) |
| Navigation | GoRouter, deep-link ready from v0.1 |
| Models | `freezed` + `json_serializable` |
| Database | Drift (SQLite) |
| Notifications | flutter_local_notifications + timezone |
| Localization | `intl` / ARB; English first, Urdu (RTL) in v1.1 |
| Crash/analytics | Firebase Crashlytics + Analytics behind consent and `AnalyticsService` |

### Backend stack (from v1.5)

| Concern | Choice |
|---|---|
| Runtime / API | Node.js LTS, TypeScript, Fastify, OpenAPI-first |
| Validation | Zod or TypeBox, shared with OpenAPI |
| Database | Managed PostgreSQL + migrations (Drizzle or Prisma Migrate) |
| Jobs | PostgreSQL-backed queue (e.g. pg-boss) before adding Redis |
| Identity | Firebase Authentication, tokens verified at the API |
| Storage | S3-compatible object storage + CDN for packs and images |
| Push | Firebase Cloud Messaging, server-side only |
| Mobile client | Dart client generated from OpenAPI |
| Hosting | One region close to Pakistan users; confirm data-residency needs first |

Bun may replace Node only after full compatibility tests; one runtime only.

### Layering

```text
Flutter screens
      ↓
Riverpod controllers
      ↓
Domain services + repository interfaces
      ↓
Bundled pack / SQLite / remote API (v1.5+)
```

Screens never import Firebase, Drift or HTTP packages directly.

Repository interfaces: `FoodRepository`, `RecipeRepository`, `ProfileRepository`, `PlanRepository`, `FoodLogRepository`, `ProgressRepository`, `ShoppingListRepository`, `ReminderService`, `EntitlementRepository` (returns free initially), `AnalyticsService` (disabled until consent), `SyncService` (no-op until v1.5).

### Repository layout (monorepo)

```text
apps/mobile/            Flutter app
apps/admin/             Admin web app (v1.5)
services/api/           API (v1.5)
services/worker/        Background jobs (v1.5)
contracts/openapi/
contracts/food-pack-schema/
content/pakistan/       Food pack source data
tools/                  Food-pack validator CLI
docs/
  APP_BLUEPRINT.md
  IMPLEMENTATION_STATUS.md
  DECISIONS.md
  RELEASE_CHECKLIST.md
```

Create backend and admin folders only when their phase starts.

---

## 7. Domain Model and Data Contracts

### Conventions

- IDs: UUIDv7 generated on device (stable through offline use and sync).
- Canonical units: grams, millilitres, kcal; nutrition per 100 g; conversion only in the UI.
- Every user record: `createdAt`, `updatedAt` (UTC), `deletedAt` (tombstone), `revision` (server-assigned from v1.5).
- Plans and logs use a local calendar date (`2026-10-20`) plus timezone, so an 11 pm dinner stays on the right day.

### Food content

Every food: stable ID and revision; English name, optional Urdu name, aliases (`aliases.romanUrdu[]` with several spellings); country/region tags; category; raw/prepared state; nutrition per 100 g; named servings with grams and `photoRef`; dietary tags; allergens + review status; preparation description; `oilProfile` (oil grams per serving at light/normal/rich); `isSharedDish`; `mealSlotFit[]` (sehri, breakfast, lunch, chai, iftar, dinner); `source`, `license`, `reviewedBy`, `reviewedAt`, `status` (draft / reviewed / published).

Recipes additionally: ingredient IDs and quantities, cooked yield, servings, steps, nutrition provenance, reviewed substitutions. Prepared dishes must separate recipe/yield from raw ingredient weights so nutrition is never double-counted.

Nutrition sources to evaluate (confirm licence before use): USDA FoodData Central, Pakistan food composition tables, recipe-based calculation from reviewed ingredients.

### User data entities

| Entity | Key fields |
|---|---|
| `UserProfile` | goal, birthYear, sex, height, weight, activity, `eligibilityStatus`, `cookingRichness` |
| `DietaryPreferences` | vegetarian flag, allergies, excluded ingredients |
| `MealSchedule` | slots (3–6), times, `mode` (normal/ramadan), `ramadanStart`, `ramadanEnd` |
| `DailyPlan` / `Meal` / `PlanItem` | `PlanItem`: foodId, `foodRevision`, `portionGrams`, `oilLevel`, `fromSharedDish` |
| `FoodLogEntry` | nullable `planItemId`, `source` (planned/manual/quick-add), quantity, nutrition snapshot, timestamp |
| `DayLogStatus` | complete / partial / not_logged |
| `WeightEntry`, `ShoppingList`, `ReminderPreference`, `SavedTemplate`, `Entitlement` | as named |
| `OutboxOperation` | table reserved now, used from v1.5 |

**Planned vs consumed:** planned = intention; consumed = recorded eating. Marking a meal eaten creates log entries with snapshots. Editing future plans or correcting the catalogue never changes past logs.

### Planner contract

```text
generatePlan(profile, target, pack, schedule, restrictions, date, seed) → PlanResult
```

Pure Dart: no I/O, no clock, no randomness except the seed. `PlanResult` = meals, totals, deviation from target, warnings, or a `NoPlanReason`.

---

## 8. Build Plan by Phase

A phase is complete only when its exit criteria are verified and recorded in `IMPLEMENTATION_STATUS.md`.

### Phase D — Discovery (2 weeks)
**Work:** 15–20 user interviews (Rawalpindi/Islamabad, Lahore, Karachi); review 5 competing apps; paper prototype of onboarding and Today screen; engage a nutritionist.
**Exit:** top 3 user problems documented; 150-food list ranked by eating frequency; nutritionist engaged.

### Phase 0 — Foundation (1.5 weeks)
**Work:** verify Flutter, Dart, Android SDK, Java, emulator, baseline low-end phone; create project with dev/prod flavors; provisional internal name; formatting, analysis, tests, CI; design tokens (type, colour, spacing, buttons, fields, accessible navigation); bundled fonts; error handling and logging; Drift setup; docs files.
**Exit:** debug and release builds compile and run on emulator and physical phone; CI runs analysis, tests and build; release APK ≤ 25 MB; cold start ≤ 2.5 s on baseline phone; no secrets committed.

### Phase 1 — Food Catalogue (3–4 weeks, parallel with 0–3)
**Work:** pack schema; validator CLI; ~150 foods across breads/grains, rice, daal/legumes, meat/poultry/fish/eggs, vegetables/salads, dairy, fruit, drinks, snacks/desserts; oil profiles, servings, photos, English/Urdu/Roman Urdu aliases; curated meal combinations.
**Validator rejects:** duplicate IDs, missing source metadata, invalid references, negative or non-finite nutrition, zero/negative serving weights, recipes without yields, missing allergen-review status.
**Exit:** loads in airplane mode; alias search works; validator runs in CI and blocks bad data; unverified entries cannot appear as verified; ≥ 80% reviewed before beta (100% of entries used in public auto-planning).

### Phase 2 — Local Storage (1 week)
**Work:** Drift schema, migrations, repositories, JSON export/import, delete-all; explicit Android backup rules.
**Exit:** data survives process kill; mid-transaction crash leaves last valid state; migration tests from every shipped schema; export → wipe → import restores everything; corrupt data never silently resets the app.

### Phase 3 — Onboarding and Target (1.5 weeks)
**Work:** goal, age, height, weight, sex, activity, veg/non-veg, allergies, exclusions, meal times, 3–6 slots (default breakfast, lunch, dinner, one snack), cooking richness; eligibility check; `TargetPolicy`; "How we calculated this". Metric units first, conversion infrastructure ready.
**Exit:** completes without account; useful field errors; ineligible users routed to manual mode; policy tests cover floors and rate caps; profile changes affect future plans only unless user regenerates.

### Phase 4 — Planner Engine (2.5 weeks)
**Work:** filter restrictions first; allocate calories across slots; select curated combos; adjust portions within practical bounds; family pot portions; oil adjustment; reduce repetition; regenerate one meal without touching completed ones.
**Exit:** same inputs + seed + pack version = same plan; ≥ 95% of 1,000 generated test profiles within ±10% of target; zero exclusion violations in property tests; no-match returns a clear explanation, never forced portions; no double-counting of recipe ingredients.

### Phase 5 — Main App (3 weeks)
**Navigation:** Today · Foods · Progress · More.
**Screens:** welcome/onboarding, Today dashboard, plan and meal detail, food search/detail, replace/add, consumption log, saved plans/history, weight progress, shopping list, reminders, profile, feedback, privacy and data controls.
**Dashboard:** planned vs consumed calories, macros and fibre, next meal, meal status, remaining target, quick log/edit actions.
**Exit:** first plan works offline; add/replace/remove/resize items; logging a planned meal ≤ 2 taps; no accidental duplicate logs; usable at 200% text and 360 dp width; every screen has empty, error and recovery states.

### Gate A — Private Beta (3 weeks)
30 testers through Play closed testing.
**Pass:** ≥ 40% still logging in week 3; no data-loss bugs; nutritionist sign-off on data and policy.

### Phase 6 — Shopping and Progress (1.5 weeks)
**Work:** ingredient quantities from recipe yields and portions; aggregate matching IDs and compatible units; keep incompatible units separate; ready-made vs raw items; manual items; purchased status preserved on recalculation. Weight add/edit/delete, trends, nutrition history.
**Exit:** correct recipe scaling; missed days show "not logged", never 0 kcal; planned meals never assumed eaten; history matches snapshots.

### Phase 7 — Local Reminders (1.5 weeks)
**Work:** permission on enable; per-slot categories; date-specific notification IDs; tap opens the right date/meal; cancel on meal logged; reschedule on time change, reboot, update, timezone change; quiet hours; Ramadan schedule switch. No exact-alarm permission by default; explain possible OS delays.
**Exit:** tested with permission granted/denied, app closed, reboot, timezone change, meal edited/completed, repeated scheduling without duplicates, cold-start tap, Ramadan start/end switch.

### Phase 8 — Free Android Launch (2 weeks)
**Work:** final brand, application ID, icon, store assets (name availability checked); support email and privacy policy; consent-gated analytics and crash reporting; feedback via user's email app; internal → closed → staged production (10% → 50% → 100%).
**Exit:** core flows work with network blocked; nutrition review complete; Data safety form matches SDK behaviour; signed release and checklist ready; crash-free ≥ 99.5% at each rollout step.

### Phase 9 — Growth, v1.1 (4 weeks)
**Work:** regional foods; Urdu UI with RTL testing; improved Roman Urdu search; daily-plan sharing (no private data by default); favourites; plan duplication (free); onboarding fixes from data; rating prompt after success; low-end performance work.
**Exit:** correct food in top 3 for ≥ 90% of a 100-query test set; D30 measured before and after; all free features intact.

### Phase 10 — Backend Foundation (4 weeks)
**Work:** modules for identity, catalogue, pack publishing, sync, entitlements, devices, feedback, admin audit. One API + one worker. Staging and production; managed PostgreSQL; object storage; TLS; secret management; automated migrations; health checks; structured logs with request IDs; rate limiting; backups; idempotent retried jobs.

| Prefix | Responsibility |
|---|---|
| `/v1/me` | Account and profile |
| `/v1/food-packs` | Manifests and downloads |
| `/v1/sync` | User-data sync |
| `/v1/entitlements` | Server-verified access |
| `/v1/billing` | Purchase verification |
| `/v1/devices` | Push tokens |
| `/v1/feedback` | Feedback |
| `/v1/admin` | Admin operations |

OpenAPI contracts, pagination, explicit error codes, UTC timestamps, resource revisions.
**Exit:** contract and authorization tests pass; no cross-user access; reproducible staging deploy; restore drill succeeds; no production secrets in the app.

### Phase 11 — Accounts and Sync (4 weeks)
**Accounts:** guest mode kept; email/password and Google sign-in; tokens verified at the API; account required only for sync and premium; in-app and web account deletion; data export.
**Guest migration:** ask before upload; keep local backup; upload stable IDs; idempotent retries; show which account receives data.
**Sync:** durable outbox; unique operation IDs; server revisions; cursor-based pull; tombstones; backoff retries; UI usable offline.
**Conflicts:** distinct logs/weights merge by ID; stale same-record edits return conflict; conflicting plan edits keep a second copy for user choice; profile conflicts prompt; server revision order, never device clocks. Sign-out separates account cache from guest data.
**Exit:** two-device tests preserve records; no duplicates on retry; offline edits sync on reconnect; deletions don't reappear; account switching never leaks data.

### Phase 12 — Admin and Downloadable Packs (3 weeks)
**Roles:** owner, content editor, nutrition reviewer, support (SSO + 2FA).
**Workflow:** Draft → Review → Approved → Published → Retired.
**Capabilities:** manage foods, recipes, servings, translations, sources, allergens; validate and preview; publish versioned packs; rollback; review feedback; view subscription state (no manual payment changes); audit log.
**Delivery:** baseline pack always bundled; download to temp; integrity + schema check; activate only after validation; keep last valid pack; progress and retry.
**Exit:** reviewer approval required to publish; interrupted downloads keep working pack; invalid packs never activate; historical logs unchanged.

### Gate B — Premium Review
See section 11.

### Phase 13 — Premium, v2.0 (4 weeks)
**Billing:** monthly and yearly; store-localized prices; clear renewal/cancel info; restore purchases; server verification and acknowledgement; pending, renewal, grace, cancel, expiry, refund handling; idempotent store notifications.
**Entitlements:** server decides; feature flags control availability, not payment; bounded offline cache; revalidate on reconnect; never unlock from a client preference.
**Features:** weekly/monthly plans, family planning, templates, advanced macros (within reviewed bounds), multi-day lists, meal-prep schedules, premium recipes and country packs, reports and exports.
**Exit:** all sandbox lifecycle scenarios pass; refunds remove future access; restore after reinstall; duplicate notifications don't duplicate entitlements; free features work during billing outages.

### Phase 14 — Push Campaigns, v2.1 (2 weeks)
New packs, product updates, opt-in education, optional re-engagement. Token registration/rotation/removal; marketing consent separate from reminders; quiet hours; deep links; expiry; dedupe; no health data in text; sending credentials server-only.
**Exit:** foreground/background/cold-start navigation; logout detaches targeting; opt-out stops campaigns within one send cycle; no duplicate of local reminders; token failures don't affect planning or sync.

### Phase 15 — More Countries (per country)
Country packs via the content pipeline; localized servings and aliases; cuisine preference separate from residence; metric/imperial display; mixed-country plans from accessible packs.
**Exit:** new pack with no planner code change; missing translations fall back to English; conversions don't change canonical nutrition; Pakistan users keep the core catalogue.

### Phase 16 — iOS, v3.0 (5–6 weeks)
Xcode/Apple setup, signing, navigation adaptations, Sign in with Apple, StoreKit purchases with server verification mapped to the same premium tier, APNs, notifications and deep links, TestFlight.
**Exit:** offline core on iPhone; cross-platform sync and entitlements; Apple purchase lifecycle tests; accessibility tests; Android regression suite green.

### Phase 17 — Operations (ongoing)
Monitor crash-free rate, activation, retention, plan failures, content gaps, API latency/errors, sync failures, conversion and churn, opt-outs, cost per active user, support volume. Maintain dependencies, food corrections, restore drills, store-policy reviews, migration and performance tests. Scale based on measured demand; monthly ops review recorded.

**Totals:** about 5–6 months to v1.0 and 10–12 months to premium for one developer. A second developer mainly shortens phases 9–13.

---

## 9. Quality, Performance and Testing

No release ships with a known data-loss bug, wrong totals, or broken exclusion filtering.

### Performance budgets (baseline: 2–3 GB RAM phone, Android 10+)

| Budget | Target |
|---|---|
| Play download size (arm64) | ≤ 25 MB |
| Cold start to Today | ≤ 2.5 s |
| Search per keystroke (2,000 foods) | ≤ 150 ms |
| One-day plan generation | ≤ 500 ms |
| Memory while browsing | ≤ 200 MB |
| Scrolling | No jank on Today and Foods in profile mode |

Use App Bundles, WebP images, lazy image loading.

### Test layers

| Layer | Covers | Tooling |
|---|---|---|
| Domain unit | Target policy, portions, oil maths, aggregation, recipe scaling, unit conversion | `dart test` |
| Property-based | Random profiles × restrictions never break exclusions or floors; seed determinism | Seeded generated inputs |
| Golden data | 20 reference profiles' plans unchanged unless policy version changes | Snapshot files |
| Database | Migrations, crash mid-transaction, export/import, outbox replay | Drift test utilities |
| Widget / golden UI | Key screens at 100%/200% text, English/Urdu | Flutter tests |
| Integration | Onboarding → plan → log → restart; airplane mode; permission denial; upgrade from previous release; notification cold start | `integration_test` |
| Backend | OpenAPI contracts, authorization, guest migration, webhook replay, pack rollback, token rotation, account deletion, backup restore | API test suite |

### CI

Every pull request: format check, `flutter analyze`, unit + widget tests, food-pack validator, release build. Main branch: integration tests + internal-testing upload. Domain-layer coverage ≥ 90%.

---

## 10. Security, Privacy and Compliance

Body measurements, allergies and food logs are sensitive health data: on-device by default, never in analytics, uploaded only when the user chooses sync.

### Privacy

- Guest mode fully local; no network needed to plan or log.
- Analytics carry no weight, height, age, allergies, foods or free text.
- Consent before analytics/crash reporting; app works fully if declined.
- Export and delete-all from v0.1; account deletion in-app and web from v1.5.
- Notifications never contain health details.
- Shared plans exclude profile data by default.

### Security

- No server secrets in the app; client API keys restricted.
- Obfuscated release builds; logs strip personal data.
- From v1.5: TLS, token verification on every request, ownership checks, rate limits, admin audit log, managed secrets, daily backups, quarterly restore drills.
- Dependency and secret scanning in CI.

### Google Play checklist (re-verify every release)

- New personal developer accounts need a closed test with a minimum tester count and duration before production (12 testers for 14 days at last check); Gate A covers this.
- Data safety form matches all SDK behaviour.
- Health apps declaration; no medical claims.
- Current target API level requirement met.
- Account deletion in-app and on the web.
- Subscription price, period, trial and cancellation shown before purchase.

### Pakistan legal

Short local legal review before v1.0: privacy policy, consumer-protection wording, current status of personal data protection legislation. Record outcome in `DECISIONS.md`.

---

## 11. Metrics and the Premium Gate

### Gate B — start premium when all are true (owner may adjust)

| Signal | Threshold | Source |
|---|---|---|
| Weekly active users | ≥ 3,000 for 4 consecutive weeks | Analytics |
| Day-30 retention | ≥ 10% for last two monthly cohorts | Analytics |
| Demand | ≥ 15% of surveyed actives would pay for weekly plans or family planning | In-app survey |
| Stability | Crash-free ≥ 99.5%; no open data-loss bugs | Crashlytics, tracker |
| Backend | Phases 10–12 verified | `IMPLEMENTATION_STATUS.md` |
| Unit economics | Cost per active user known | Billing dashboards |

10,000 downloads is only a review checkpoint.

### Core analytics events (consent-gated, no health values)

| Event | Properties |
|---|---|
| `onboarding_completed` | goal type, eligible, slot count |
| `plan_generated` | source (auto/regenerate/copy), success or no-plan reason |
| `meal_logged` | source (planned/manual/quick-add), slot |
| `item_replaced` | slot |
| `family_pot_used` | — |
| `ramadan_mode_enabled` | — |
| `reminder_enabled` | slot |
| `search_no_result` | query length bucket (never query text) |
| `paywall_viewed` / `purchase_started` / `purchase_verified` | product, period (v2.0) |

Users can send "food missing" requests; this drives catalogue growth. Use Play Console for install counts.

---

## 12. Risk Register

| Risk | Early warning | Mitigation |
|---|---|---|
| Wrong or unlicensed nutrition data | Reviewer disagreement; odd-total reports | Recipe-based calculation, licence checks, estimate labels, correction workflow |
| Users stop logging | D7 < 15% in beta | Two-tap logging, quick-add, family pot, gentle reminders; tested at Gate A |
| Portions too hard to estimate | Frequent manual portion edits | Photo guides, roti sizes, one-time "my katori" calibration |
| Harm to vulnerable users | Very low intake logs; complaints | Eligibility, floors, rate caps, safe copy, help link |
| Allergy incident | Any report | Unknown = unsafe, cross-contact notice, pack hotfix process |
| Low-end performance | Slow-start reviews | Budgets enforced on a real device each release |
| Users can't pay | Low purchase completion | Local payment methods checked early; PKR pricing; yearly plan |
| Play rejection or delay | Review feedback | Section 10 checklist; early closed testing |
| Solo-developer bottleneck | Phases > 50% over estimate | Strict scope, docs-first handoff, contract help for admin |
| Backend cost outpaces revenue | Rising cost per user | Offline-first; sync opt-in; monthly cost review |
| Brand conflict | Trademark or Play clash | Name search before public branding |

---

## 13. Owner Decisions, Handoff and Done

### Owner decisions

| Decision | Needed before |
|---|---|
| Approve ADR-001 (SQLite) | Phase 0 |
| Contract a nutritionist | Phase 1 |
| Play developer account type (personal/organisation) and signing ownership | Gate A |
| Brand name and application ID | Phase 8 |
| Support email, privacy URL, legal review | Phase 8 |
| Firebase and hosting ownership (owner's company accounts) | Phase 8 / 10 |
| Premium prices, products, trial length | Phase 13 |
| Apple developer account | Phase 16 |

Until decided, use clearly labelled development placeholders and sandbox configuration.

### Running costs (planning guidance)

Before v1.5: one-time Play developer fee, domain and email, free-tier Firebase crash reporting/analytics. From v1.5: managed PostgreSQL, container hosting, object storage/CDN and backups — typically low hundreds of US dollars per month at early scale. Confirm with provider quotes in Phase 10.

### Handoff rules for developers and AI agents

1. Read this blueprint, `IMPLEMENTATION_STATUS.md` and `DECISIONS.md`.
2. Inspect existing code and uncommitted changes.
3. Pick the earliest incomplete phase; implement a reviewable slice.
4. Run the relevant checks.
5. Record: behaviour built, files changed, tests and results, known limits, external setup needed, next step.

**Status labels:** Not started · In progress · Implemented, awaiting verification · Verified · Blocked by (named dependency). A mockup, placeholder API or simulated success is never "Verified".

**Never:** add login to the guest flow; invent nutrition values and mark them reviewed; relax exclusions or safety floors; change prices; publish apps, charge users or send campaigns as routine work.

### Definition of done (whole product)

- Android and iOS released through testing and production tracks.
- Guests plan and log offline, including family pot and Ramadan modes.
- Food data reviewed, licensed, versioned and published via admin.
- Accounts sync reliably; data exportable and deletable.
- Premium verified by the server on both stores.
- Local reminders and opt-in push work.
- New countries added through content, not code.
- Monitoring, backups, restore drills and release procedures documented.
- A new developer can build, test and continue from repository docs alone.

### Immediate next steps

- [ ] Approve or reject ADR-001 (SQLite)
- [ ] Install and verify Flutter, Android SDK and a baseline low-end phone
- [ ] Book 15–20 discovery interviews
- [ ] Shortlist two nutritionists
- [ ] Draft the 150-food list ranked by eating frequency