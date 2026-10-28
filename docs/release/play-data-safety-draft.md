# Google Play Data safety form — DRAFT answers

> Prepared from the code in version 0.1 (2026-10-29). The owner fills in the Play Console. **Re-check on every release**:
> this must match actual SDK behaviour (blueprint §10). If Firebase Analytics/Crashlytics is added, these answers change.

## Current build (no analytics provider connected)

| Question | Answer | Why |
|---|---|---|
| Does your app collect or share any of the required user data types? | **No** | All data stays on the device; the analytics sink is a no-op; no network calls |
| Is all of the user data collected by your app encrypted in transit? | Not applicable | Nothing is sent |
| Do you provide a way for users to request that their data is deleted? | Yes — in-app "Delete all data" | Privacy & data screen |

Note: Google treats data processed only on the device and never sent off it as not "collected".

## If the owner connects Firebase Analytics + Crashlytics (P8-04)

| Data type | Collected | Shared | Optional | Purpose |
|---|---|---|---|---|
| App interactions (events listed in blueprint §11, no health values) | Yes | No | Yes (consent) | Analytics |
| Crash logs, diagnostics | Yes | No | Yes (consent) | App functionality / stability |
| Device or other IDs (Firebase installation ID) | Yes | No | Yes (consent) | Analytics |
| Health and fitness | **No** | No | — | Never sent off the device |

## Health apps declaration

- Category: nutrition / diet tracking. Not a medical device. No medical claims in the app or listing.
- Automated plans are restricted to adults (18+), and to users who are not pregnant, breastfeeding or on a medical diet.

## Permissions

| Permission | Why |
|---|---|
| POST_NOTIFICATIONS | Meal reminders, requested only when the user turns reminders on |
| RECEIVE_BOOT_COMPLETED | Restore scheduled reminders after the phone restarts |

No exact-alarm, location, contacts, camera or storage permissions.
