---
trigger: always_on
---

# Workflow, Git and Release Rules

## Git

- Trunk-based: short-lived branches off `main` (`feat/…`, `fix/…`, `chore/…`, `docs/…`).
- Conventional Commits: `feat(planner): …`, `fix(db): …`. One logical change per commit.
- Pull requests are small, describe *what and why*, list tests run, and link the phase/issue.
- `main` is always releasable. No direct pushes, no force-push to shared branches, no `--no-verify`.
- Never commit generated build output, secrets, local config or large binaries (assets go through reviewed paths).

## Review

- Every PR gets a review against the relevant checklist (`design.md`, `security.md`, `testing.md`).
- Reviewers check: correctness, tests, safety rules untouched, no scope creep, docs updated.
- AI-generated changes are reviewed with the same standard as human ones.

## Documentation

- `docs/IMPLEMENTATION_STATUS.md`: current phase, per-item status, last verified date.
- `docs/DECISIONS.md`: dated decision log (what, why, who approved). Larger decisions get `docs/adr/NNNN-title.md`.
- `docs/RELEASE_CHECKLIST.md`: updated whenever a release step changes.
- Setup instructions must let a new developer build and test from the docs alone.

## Releases

- Follow the roadmap and gates in the blueprint; a gate must pass before the next release starts.
- Staged rollout (10% → 50% → 100%) with crash-free ≥ 99.5% at each step.
- Publishing, pricing, billing and campaigns are **owner actions**, never routine agent work.
- Re-verify store policy checklist every release.

## Scope control

- Work only on the current phase unless the owner redirects.
- Out-of-scope discoveries go to the status doc as follow-ups, not into the current change.
- Backend and admin folders are created only when their phase starts.

