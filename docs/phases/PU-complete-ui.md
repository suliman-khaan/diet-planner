# PU — Complete UI (Antigravity, UI lane) · ~4–5 weeks

Goal: **every v1.0 screen built in Flutter**, pixel-ready, accessible, with all states, driven by
sample fixtures. No business logic, no database. Integration later swaps fixtures for real data
without changing screens.

Read first: `.agent/rules/collaboration.md`, `.agent/lanes/ui.md`, `.agent/rules/design.md`.
Visual reference: `design/ui-concepts/` (open `index.html`; tokens in `StyleGuide.html`).
Depends on: **P0-01** (project skeleton). Until it exists, only U-00 can be done.

## Contract with Integration

- Each screen: `XScreen({required XViewModel vm, required callbacks...})` — stateless where possible.
- View models: immutable classes in `features/<f>/view_model/`, plain types only (String, num, enums, lists of view models). No domain types.
- Every view model has fixtures in `lib/fixtures/` covering: success, empty, loading, error, offline, and edge cases (long names, 200% text, Urdu text).
- Fixtures are visibly sample data; never ship them in a prod code path.

## Every screen needs

Loading · empty · error with recovery action · offline (where relevant) · success.
48 dp targets · 4.5:1 contrast · 200% text at 360 dp width · RTL-safe · semantic labels · strings in ARB · light + dark.

## Tasks

| ID | Task | Depends on |
|---|---|---|
| U-00 | Design spec: turn `design/ui-concepts` into `design/spec.md` (tokens table, components list, screen list below with states). Add dark-theme colours. No code. | — |
| U-01 | Tokens + theme: colours (light/dark), type scale, spacing, radii, elevation, motion; bundle Plus Jakarta Sans (OFL licence file) + Noto Nastaliq Urdu for Urdu food names | P0-01 |
| U-02 | Shared widgets: buttons (primary/secondary/text/icon), cards, list rows, chips, steppers, segmented control, text fields with errors, bottom sheet, dialogs, snackbar/undo, estimate badge, status badges (eaten/planned/not logged, reviewed/not reviewed, family pot), macro bars, progress bar | U-01 |
| U-03 | State widgets: loading skeletons, empty, error + retry, offline banner, recovery screen for corrupt data | U-02 |
| U-04 | Bottom navigation + app scaffold widget (Today · Foods · Progress · More) | U-02 |
| U-05 | Dev-only **Screen Gallery**: list of every screen × every fixture state (route requested from Platform; dev flavor only) | U-04 |
| U-06 | Onboarding: welcome; privacy/consent choice; goal; about you (birth year, sex, height, weight); activity; eligibility result (incl. manual-only explanation for under-18, pregnancy, listed conditions); veg/non-veg; allergies + exclusions (cross-contact notice); meal times + 3–6 slots (late dinner, chai); cooking richness; target summary with "How we calculated this" link; first plan loading/ready | U-03 |
| U-07 | Today: normal; Ramadan mode; manual-only mode; no plan yet; `NoPlanReason` explanation; day with "not logged" meals; date switcher; quick log (≤ 2 taps) with undo | U-04 |
| U-08 | Meal detail: items, family pot portion, oil level, portion steppers, regenerate this meal, mark eaten, remove item with undo | U-02 |
| U-09 | Portion picker + guides: katori / pyala / chamach / roti size with photo placeholders; "my katori" calibration | U-02 |
| U-10 | Foods: search (English + Roman Urdu hint), filters, results, no results + "tell us what's missing"; food detail (servings, nutrition per serving, allergens with review status, oil profile, reviewed/not reviewed, estimate label) | U-03 |
| U-11 | Add / replace / quick-add sheets (quick-add = manual kcal entry with validation) | U-10 |
| U-12 | History: saved plans and past days list; day log view with snapshots | U-03 |
| U-13 | Progress: weight chart, add/edit/delete weight sheet, nutrition history, logged-days summary (not logged ≠ 0 kcal) | U-03 |
| U-14 | Shopping list: aggregated items, raw vs ready-made, units kept separate, purchased toggle, manual items, empty state | U-03 |
| U-15 | Reminders: per-slot toggles and times, quiet hours, permission denied/explain state, Ramadan switch note, "OS may delay" note | U-03 |
| U-16 | More + settings: profile & targets edit ("affects future plans" notice + regenerate option), dietary preferences, meal schedule + Ramadan dates, cooking richness, units, language (English now, Urdu later), about/legal/disclaimer | U-04 |
| U-17 | Privacy & data: consent toggles, export, import (with confirm), delete all (two-step confirm), feedback via email app | U-03 |
| U-18 | Transparency: "How we calculated this" (formula, inputs, policy version); low-intake gentle check-in sheet with help link (no shaming copy) | U-03 |
| U-19 | Accessibility pass: screen reader labels, focus order, 200% text, 360 dp, contrast in light + dark; fix findings | U-06…U-18 |
| U-20 | RTL readiness: run every screen under an RTL pseudo-locale; fix any left/right assumptions | U-19 |
| U-21 | Golden tests: key screens at 100% / 200% text, light / dark; widget tests per state | U-19 |

## Exit criteria

- [ ] Every screen above exists, reachable from the Screen Gallery, in all its states
- [ ] No hard-coded colours, sizes or strings in screens (tokens + ARB only)
- [ ] Usable at 200% text and 360 dp width; contrast checked light + dark
- [ ] RTL pseudo-locale renders without broken layouts
- [ ] Widget + golden tests pass; `flutter analyze` clean
- [ ] No imports from `domain/`, `data/`, Drift, Firebase or HTTP in UI lane files
- [ ] Owner reviewed the gallery and approved the look
