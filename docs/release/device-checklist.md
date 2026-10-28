# Device checklist (owner, baseline 2–3 GB RAM phone, Android 10+)

CI cannot run these. Install the **dev APK** from the latest CI run (Actions → run → Artifacts → `apks` →
`app-dev-debug.apk`). Tick each item and record the date and phone model in `docs/IMPLEMENTATION_STATUS.md`.

## Start-up and storage (P0, P2)
- [ ] Fresh install opens onboarding; cold start to first screen ≤ 2.5 s
- [ ] Release APK size noted from the CI summary (budget ≤ 25 MB arm64)
- [ ] Force-stop the app after logging a meal → reopen → the log is still there
- [ ] Export → Delete all → Import the file → everything is back

## Onboarding and safety (P3)
- [ ] Birth year 16 years ago → "manual logging only" message, no calorie target, food can still be logged
- [ ] Ticking "Pregnant" → manual mode
- [ ] Height 175 cm, weight 54 kg, goal "lose" → maintenance message instead of a loss plan
- [ ] "How we calculated this" shows your numbers and "provisional"

## Today and meals (P5)
- [ ] Today shows four meals and the "draft data" label (dev build)
- [ ] Tap **Log** on a meal → logged in one tap; **Undo** restores it; tapping Log again does not double it
- [ ] Meal detail: katori +/−, oil Light/Normal/Rich, remove a side (Undo works), Replace dish, Mark as eaten
- [ ] "Log other food" → search "chana chat" → Chana chaat is in the top 3 → add → appears on Today
- [ ] Quick add 150 kcal → appears on Today
- [ ] Previous/next day arrows; past days show "not logged" meals, never 0 kcal
- [ ] More → Diet & allergies → Vegetarian → today's plan has no meat, fish or egg
- [ ] More → Meal times & Ramadan → set Ramadan dates including today → Today shows sehri / iftar / dinner
- [ ] Settings text at 200 % font size and on a 360 dp-wide screen: nothing cut off

## Shopping and progress (P6)
- [ ] Shopping list shows ingredients; ticks stay after leaving and coming back; add your own item
- [ ] Add weight → Progress updates; missed days show as outlines

## Reminders (P7)
- [ ] Turn reminders on → Android asks for notification permission once
- [ ] Deny permission → the screen explains how to turn it on; reminders stay off
- [ ] A reminder arrives near meal time (a few minutes late is OK); text has no health details
- [ ] Tapping the reminder opens Today for that date (also when the app was closed)
- [ ] Log the meal before its time → that reminder does not arrive
- [ ] Restart the phone → the next reminder still arrives
- [ ] Change the phone's timezone → reopen app → reminders follow the new local time

## Performance (blueprint §9)
- [ ] Food search feels instant while typing
- [ ] Scrolling Today and Foods is smooth
