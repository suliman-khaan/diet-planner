---
trigger: always_on
---

# Security and Privacy Rules

Body measurements, allergies and food logs are **sensitive health data**.

## Secrets

- No secrets, tokens, keystores, service-account files or `.env` in git. Use `.gitignore`, CI secret stores and managed secret services.
- Client API keys are restricted (package name + signature / referrer). Privileged credentials never ship in the app.
- If a secret leaks: rotate first, then clean history, then record the incident.
- Secret scanning and dependency scanning run in CI and block merges.

## Data handling

- Guest mode is fully local; no network needed to plan or log.
- Data leaves the device only through explicit user action (sync, export, feedback).
- Analytics and crash reporting require consent; the app works fully if declined. Events carry no weight, height, age, allergies, foods or free text.
- Logs, crash reports and error messages strip personal data.
- Sensitive local values (auth tokens) live in platform secure storage (Android Keystore / iOS Keychain), not in plain preferences or files.
- Android backup rules are explicit about what is included.
- Export and delete-all are always available; account deletion works in-app and on the web.

## Input and output

- Treat all external input as hostile: food packs, imported JSON, deep links, notification payloads, API responses. Validate schema, ranges and sizes before use.
- Downloaded packs: verify integrity and schema in a temp location; activate only after validation; keep the last valid pack.
- Deep links carry IDs only, never health data; verify the target exists and is the user's.
- No dynamic code execution, no `eval`-style parsing of data, no unsafe deserialization.

## Network (from v1.5)

- TLS everywhere; no cleartext traffic.
- Verify tokens on every request; check ownership on every resource (no cross-user access).
- Rate-limit and size-limit endpoints; idempotency keys for retried mutations.
- Entitlements decided by the server, never by a client flag. Purchases verified server-side.
- Admin: SSO + 2FA, role-based access, audit log for every change.
- Least privilege for service accounts, database users and storage buckets.

## Build and release

- Release builds are obfuscated and signed with keys the owner controls.
- Minimal permissions; each one justified in `DECISIONS.md`. No exact-alarm permission by default.
- Data Safety / privacy declarations must match actual SDK behaviour; re-verify each release.

## Review checklist

- [ ] No secrets or personal data in the diff, logs, fixtures or screenshots
- [ ] New inputs validated at the boundary
- [ ] New permissions/SDKs justified and declared
- [ ] Ownership/authorization tested (backend)
- [ ] Failure paths don't leak internals

