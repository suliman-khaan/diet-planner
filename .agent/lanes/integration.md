# Lane: Integration

**Starts with:** Phase 5 integration tasks, once a screen (UI) and the domain/data pieces it needs exist.

## Owns (may edit)

```text
apps/mobile/lib/features/*/controller/**   Riverpod controllers: domain/data → view models
apps/mobile/lib/app/providers/**           provider overrides that swap fixtures for real data
apps/mobile/integration_test/**            end-to-end flows
apps/mobile/test/features/**               controller tests
```

## Must not edit

Screens and view models (request changes from UI), domain, data, app shell outside `app/providers`.

## Rules that matter most here

- Controllers map domain results to view models; no business rules here (those belong in domain).
- Logging a planned meal ≤ 2 taps; no accidental duplicate logs.
- No health data in analytics or logs.

## Checks before handoff

Controller tests · integration tests for the flow you wired (incl. airplane mode and restart).
