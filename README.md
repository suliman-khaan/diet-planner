# Global Diet Planner

Offline-first meal planner built on the food people actually eat. First market: Pakistan. First platform: Android (Flutter).

- Spec: [docs/APP_BLUEPRINT.md](docs/APP_BLUEPRINT.md)
- Working rules for developers and AI agents: [.agent/AGENTS.md](.agent/AGENTS.md)
- Progress: [docs/IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md)
- Decisions: [docs/DECISIONS.md](docs/DECISIONS.md)

## Layout

```text
apps/mobile/            Flutter app
content/pakistan/       Food pack source data
contracts/              Food-pack schema (OpenAPI added in v1.5)
tools/                  Food-pack validator CLI
design/                 UI concepts and design spec
docs/                   Blueprint, phases, work board, handoffs, status, decisions, ADRs
.agent/                 Agent rules and lanes (read by Claude Code and Antigravity)
.github/workflows/      CI
```

`apps/admin`, `services/api`, `services/worker` are created when Phase 10–12 start.

## Setup

Flutter, Dart, JDK and Android SDK are required for `apps/mobile` (not yet installed on this machine). Full setup steps will be added here once the Flutter project exists.

