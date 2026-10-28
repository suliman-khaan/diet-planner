# Handoff Requests

Use when you need a change in a lane you don't own (`.agent/rules/collaboration.md` §3).

File name: `<yyyy-mm-dd>-<from-lane>-to-<to-lane>-<topic>.md`

```markdown
# <topic>

From: <lane / agent> · To: <lane> · Task: <your task ID> · Status: Open | Accepted | Done | Declined

## Need
What you need, in one or two sentences.

## Why
Which task is blocked and how.

## Proposed shape
Interface, string keys, package name + version, route name — whatever makes it concrete.

## Workaround meanwhile
The local stub you are using inside your own lane.
```

The receiving lane updates **Status** and links its PR. Add the request to the table in `docs/WORKBOARD.md`.
