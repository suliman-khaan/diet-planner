# Lane: Content

**Starts with:** Phase 1 (`docs/phases/P01-food-catalogue.md`). Does not need Flutter; can start now.

## Owns (may edit)

```text
content/**                       food pack source data (Pakistan first)
contracts/food-pack-schema/**    JSON Schema for packs
tools/**                         food-pack validator CLI
apps/mobile/assets/packs/**      built pack copied into the app
```

## Must not edit

Anything under `apps/mobile/lib`, pubspec, CI (request a CI step from Platform).

## Rules that matter most here

- `.agent/rules/data-and-safety.md` → Nutrition content, in full.
- **Never invent nutrition values.** An agent may create structure, aliases, servings and draft entries with `status: draft` and empty or sourced values only. Only a named human reviewer sets `reviewed`.

## Checks before handoff

Validator passes on all packs · validator's own tests pass · schema and sample pack in sync.
