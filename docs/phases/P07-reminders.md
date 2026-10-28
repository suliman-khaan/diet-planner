# P7 — Local Reminders (1.5 weeks)

## Tasks

| ID | Task | Lane | Depends on |
|---|---|---|---|
| P7-01 | `ReminderService` adapter over flutter_local_notifications + timezone; per-slot channels; date-specific IDs; no exact-alarm permission | Platform | P0-01 |
| P7-02 | Reschedule on time change, reboot, app update, timezone change; quiet hours | Platform | P7-01 |
| P7-03 | Ramadan schedule switch on start/end dates | Platform | P7-01, D4-02 |
| I7-01 | Wire reminders screen; permission on enable; cancel on meal logged; tap opens right date/meal | Integration | U-15, P7-01 |

Notification text never contains health details.

## Exit criteria (blueprint)

- [ ] Tested: permission granted/denied, app closed, reboot, timezone change, meal edited/completed
- [x] Repeated scheduling without duplicates *(CI, 2026-10-29)*
- [ ] Cold-start tap opens the right screen
- [x] Ramadan start/end switch *(CI, 2026-10-29)*
