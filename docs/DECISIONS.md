# Decision Log

Format: date · decision · why · status. Larger decisions get an ADR in `docs/adr/`.
"Owner" = needs the owner's explicit approval before release.

## Product and safety

| Date | Decision | Why | Status |
|---|---|---|---|
| 2026-10-20 | ADR-001: SQLite (Drift) for user data from v0.1; JSON only for food pack and export | Blueprint §6 | **Implemented** (P2). Owner approval still to be recorded |
| 2026-10-20 | Safety values (calorie floors 1,200/1,500, loss ≤ 0.5 kg/wk default, cap 0.75 kg or 1 % body weight, gain 0.25 kg/wk, BMI 18.5) live in `TargetPolicyConfig.v1Provisional` | Blueprint §3; never hard-coded in UI or planner | Implemented. **Owner/nutritionist sign-off required** (Gate A) |
| 2026-10-29 | Birth year only (no birth date). Eligibility uses the *lowest* possible age (year difference − 1), so anyone who might be 17 gets manual mode | Never let a minor through; birth date not needed for anything else | Accepted |
| 2026-10-29 | Low-intake check-in: 3 consecutive **fully logged** days under 800 kcal | Partly logged days undercount; threshold is a placeholder like the other safety values | Implemented. **Nutritionist to confirm** |
| 2026-10-29 | Help link in the check-in points to WHO healthy-diet guidance until a local resource is chosen | A link is required (blueprint §3 rule 6) | Placeholder. **Owner to choose** a Pakistan resource (P8) |
| 2026-10-29 | Support email `support@example.invalid` placeholder in `AppConfig` | Feedback and missing-food requests open the user's email app | Placeholder. **Owner to set** (P8-03) |
| 2026-10-29 | Quick add records energy only; macros stay 0 rather than guessed | Never invent nutrition values | Accepted |
| 2026-10-29 | Shopping list = raw ingredients for the user's own portions in today's plan, with a note that the family pot needs more | Blueprint: daily list is free; quantities from recipe yields and portions | Accepted |

## Food data (P1)

| Date | Decision | Why | Status |
|---|---|---|---|
| 2026-10-29 | Ingredient nutrition from **USDA FoodData Central SR Legacy** (public domain, CC0 1.0), imported by `tools/food-pack/import-usda.js`, never typed by hand | Licensed source; owner approved in chat 2026-10-29 | Accepted. **Owner to record licence check** (P1-05) |
| 2026-10-29 | Desi dishes are recipes (raw grams + cooked yield) calculated from USDA ingredients. Recipe proportions, yields, servings and oil levels were drafted by an AI agent | Blueprint allows recipe-based calculation; proportions need review | **All 53 foods `status: draft`** until a named reviewer signs off |
| 2026-10-29 | Added cooking oil is not a recipe ingredient; each food has `oilPer100g` light/normal/rich and the app adds oil once | Oil is the largest hidden calorie source; avoids double counting | Accepted |
| 2026-10-29 | Allergen status `derived` (from ingredients) vs `reviewed`. Users with allergies only get foods whose status is trusted: `reviewed` in release builds; `derived` accepted **only in dev builds** | Unknown/unreviewed allergen status is never treated as safe in production | Accepted |
| 2026-10-29 | Draft foods are auto-planned **only in the dev flavor**, with a visible "draft data" label. Release builds return "no plan" until foods are reviewed | Blueprint §3 / Phase 1 exit: unverified entries never used in public auto-planning | Accepted |
| 2026-10-29 | The pack is parsed into memory at start-up (validated), not copied into SQLite tables | 53–2,000 foods fit easily in memory; the pure planner needs the whole pack; search over 2,000 items in memory is far under 150 ms. Deviation from blueprint §6 storage table | Accepted; revisit if packs grow past ~5,000 foods |
| 2026-10-29 | Katori = 180 g, roti small/medium/tandoori 40/55/120 g, plate of rice 200 g | Working values for portions | Draft. **Nutritionist to confirm** (P1-03) |

## Engineering

| Date | Decision | Why | Status |
|---|---|---|---|
| 2026-10-20 | Single agent working agreement in `AGENTS.md`; `CLAUDE.md` points to it | One source of rules for all tools | Accepted |
| 2026-10-29 | Owner allowed Claude Code to edit UI-lane files while wiring P5 (lane exception) | UI built with fixtures needed callbacks, real values and safety fixes | Accepted by owner in chat 2026-10-29 |
| 2026-10-29 | No `freezed` / `json_serializable` / `riverpod_generator`; hand-written immutable classes and plain Riverpod providers. Only Drift uses code generation | No local Flutter toolchain; fewer generated files to keep in sync | Accepted |
| 2026-10-29 | CI is the build and test machine (Flutter 3.47.8 stable). CI formats code and uploads the result; warnings fail the build | Owner has no local Flutter | Accepted |
| 2026-10-29 | `android/` generated once by CI with Flutter 3.47.8 and committed; dev/prod flavors (`.dev` application-id suffix); release signing from `android/key.properties` (never committed), debug signing fallback for CI builds | Needed for notification receivers, desugaring and flavors | Accepted |
| 2026-10-29 | Android backup includes the database and settings, excludes exported files | Avoids losing logs on a phone change; Android 12+ backups are end-to-end encrypted with a screen lock | **Owner to confirm** (privacy choice) |
| 2026-10-29 | Permissions: `POST_NOTIFICATIONS` (meal reminders, asked only when the user turns them on), `RECEIVE_BOOT_COMPLETED` (restore reminders after restart). **No exact-alarm permission** | Blueprint Phase 7 | Accepted |
| 2026-10-29 | Analytics behind `AnalyticsService` with a no-op sink until Firebase is set up; only enum names, booleans and small integers can be sent | Consent-gated; no health data can leak | Implemented; provider choice is an owner decision (P8) |
| 2026-10-29 | Plan seed = hash of the date; regenerating adds 1. Same date + same inputs → same plan after restart | Determinism (blueprint §7) | Accepted |

## Dependencies

All pub packages are BSD-3 or MIT unless noted. Sizes are small Dart packages unless noted.

| Package | Why | Licence |
|---|---|---|
| flutter_riverpod 2.x | State and DI | MIT |
| go_router 14.x | Navigation, deep links | BSD-3 |
| drift 2.x + drift_dev, sqlite3_flutter_libs | SQLite with migrations and transactions; bundles SQLite (~1 MB per ABI) | MIT |
| path_provider, path, shared_preferences | App directories, file paths | BSD-3 |
| intl | Dates and number formatting | BSD-3 |
| uuid 4.x | UUIDv7 ids | MIT |
| flutter_local_notifications 19.x, timezone, flutter_timezone | Local reminders in the user's timezone | BSD-3 / BSD-2 / Apache-2.0 |
| share_plus 10.x, file_picker 8.x | Export (share sheet) and import (file picker) | BSD-3 / MIT |
| url_launcher 6.x | Email app for feedback; help link | BSD-3 |

## Open owner decisions

| Decision | Needed before |
|---|---|
| Approve ADR-001 (already implemented) | Gate A |
| Nutritionist review of foods, measures, safety values | Gate A |
| Brand name and application ID (currently `dev.placeholder.dietplanner.mobile`) | P8 |
| Support email, privacy policy URL, help resource, legal review | P8 |
| Analytics / crash reporting provider (Firebase) and owner-held accounts | P8 |
| Release signing key (owner-held) | P8 |
| Pakistan legal review outcome | v1.0 |
