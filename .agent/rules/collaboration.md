---
trigger: always_on
---

# Multi-Agent Collaboration Rules

Several agents (Claude Code, Antigravity, humans) work on this repo at the same time.
These rules exist so they never overwrite each other. They apply to **every** agent.

**Start of every task, in this order:** `.agent/AGENTS.md` (working agreement) → this file →
your lane file in `.agent/lanes/` → `docs/WORKBOARD.md` → the phase file for your task in `docs/phases/`.

## 1. Know your lane before you touch anything

Every agent works in exactly one **lane** per task. Lanes and the paths they own are in
`.agent/lanes/`. Read your lane file at the start of every task.

| Lane | File | Owns (summary) |
|---|---|---|
| UI | `.agent/lanes/ui.md` | theme, shared widgets, screens, view models, UI fixtures, ARB strings, fonts/UI images |
| Domain | `.agent/lanes/domain.md` | pure Dart models, TargetPolicy, planner, repository interfaces |
| Data | `.agent/lanes/data.md` | Drift database, repository implementations, export/import |
| Content | `.agent/lanes/content.md` | food pack data, pack schema, validator CLI |
| Platform | `.agent/lanes/platform.md` | project setup, pubspec, Android config, CI, app shell, router, DI root, core utils |
| Integration | `.agent/lanes/integration.md` | controllers wiring domain/data to view models, end-to-end tests |

If the owner did not name your lane, take the lane of the task you claimed on the work board.

## 2. Claim before you start

1. Open `docs/WORKBOARD.md`.
2. Pick an `Open` task in your lane whose dependencies are `Done`.
3. Set it to `In progress`, write your agent name and branch, save. One task per agent at a time.
4. If someone else already claimed it, pick another. Never take over a claimed task unless the owner says so.

## 3. Only edit files your lane owns

- Writing outside your lane is not allowed, even for a one-line fix.
- Need something from another lane (new string, dependency, interface change, bug fix)?
  Write a request file `docs/handoffs/<yyyy-mm-dd>-<from>-to-<to>-<topic>.md`
  (what you need, why, proposed shape) and add a task to the work board for that lane.
  Work around it with a local stub inside your own lane until it lands.
- Read-only access to the whole repo is always fine.

## 4. Shared contracts change carefully

- Public types other lanes depend on (domain interfaces and models, view models, pack schema) are **contracts**.
- Changing a contract = handoff request first, then the owning lane changes it, then consumers update.
- Additive changes (new optional field, new method with default) are preferred over breaking ones.

## 5. Git hygiene

- One branch per task: `<lane>/<task-id>-<short-name>` (e.g. `ui/U-03-today-screen`).
- Prefer a separate git worktree per agent so working copies never collide.
- Small commits, Conventional Commit messages; never force-push, never rewrite others' commits.
- Rebase on `main` before opening a PR; resolve conflicts only inside your lane's files.
  A conflict in another lane's file means you edited outside your lane: undo that part.
- Never run a repo-wide formatter, codemod or "fix all" on files outside your lane.

## 6. Finish properly

- Run the checks for your lane (see your lane file).
- Update your task on `docs/WORKBOARD.md` (`Implemented, awaiting verification` or `Verified`),
  and the phase file's checklist in `docs/phases/`.
- Write the handoff note (AGENTS.md §6) in the PR description.
- Release your claim if you stop without finishing; say what is left.

## 7. When rules conflict

Safety and data rules (`data-and-safety.md`, `security.md`) win over everything.
Then the owner's chat instructions. Then this file. Then lane files.
