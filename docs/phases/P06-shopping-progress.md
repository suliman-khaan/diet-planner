# P6 — Shopping and Progress (1.5 weeks)

## Tasks

| ID | Task | Lane | Depends on |
|---|---|---|---|
| D6-01 | Ingredient quantities from recipe yields and portions; aggregate matching IDs + compatible units; keep incompatible units separate; raw vs ready-made | Domain | D4-04 |
| D6-02 | Progress calculations: weight trends, nutrition history from snapshots; not-logged days never 0 kcal | Domain | D3-01 |
| P6-01 | Shopping list persistence; purchased status preserved on recalculation; manual items | Data | P2-01 |
| I6-01 | Wire shopping list screen | Integration | U-14, D6-01, P6-01 |
| I6-02 | Wire progress screen + weight add/edit/delete | Integration | U-13, D6-02 |

## Exit criteria (blueprint)

- [ ] Correct recipe scaling
- [ ] Missed days show "not logged", never 0 kcal
- [ ] Planned meals never assumed eaten
- [ ] History matches snapshots
