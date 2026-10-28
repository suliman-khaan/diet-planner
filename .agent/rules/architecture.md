---
trigger: always_on
---

# Architecture and Code Rules

## Layering (see blueprint §6)

```text
Screens → Riverpod controllers → Domain services + repository interfaces → Pack / SQLite / API
```

- Screens contain no business logic and never import Drift, Firebase or HTTP packages.
- Domain code is pure Dart: no Flutter imports, no I/O, no `DateTime.now()`, no unseeded randomness. Inject clock, IDs and random seed.
- Depend on repository **interfaces**; implementations live in the data layer and are swapped in providers.
- Feature-first folders inside `apps/mobile/lib/`: `core/` (theme, errors, logging, utils), `domain/`, `data/`, `features/<name>/{ui,controller}`.
- Third-party SDKs (analytics, crash, billing, notifications) sit behind our own interface so they can be disabled, mocked or replaced.

## Code style

- Follow the language's official style; formatter output is final. Lints are errors in CI.
- Immutable models (`freezed`); no mutable global state; no singletons outside DI.
- Small functions, explicit types on public APIs, no `dynamic`, no unchecked casts.
- Names say what, comments say why. Do not narrate the obvious.
- Errors: typed failures (sealed classes / `Result`) across layer boundaries; never swallow exceptions; never show raw exception text to users.
- Logging: structured, levelled, **no personal or health data**.
- Time: store UTC instants plus local calendar date and timezone where day-attribution matters.
- Units: canonical grams / ml / kcal in storage and logic; convert only at the UI edge.
- IDs: UUIDv7 generated on device.

## Data and persistence

- Every schema change = a Drift migration + a migration test from every shipped version.
- Writes that span tables use transactions.
- Corrupt or unreadable data must surface a recovery path, never silently reset.
- User records carry `createdAt`, `updatedAt`, `deletedAt` (tombstone), and `revision` (server-assigned later).
- Past logs store nutrition **snapshots**; catalogue edits never rewrite history.

## Dependencies

- Prefer the standard library and existing dependencies. A new dependency needs: a reason, licence check, maintenance check, size impact. Record it in `DECISIONS.md`.
- Pin versions; commit lockfiles.

## API and contracts (from v1.5)

- OpenAPI-first; generate clients, don't hand-write them.
- Validate all input at the boundary; explicit error codes; UTC timestamps; pagination on lists; idempotency keys for mutating retries.

