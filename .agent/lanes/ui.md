# Lane: UI

**Default agent:** Antigravity. **Starts with:** Phase U (`docs/phases/PU-complete-ui.md`), after Phase 0 task P0-01 is done.

## Owns (may edit)

```text
apps/mobile/lib/core/theme/**            design tokens, ThemeData, light + dark
apps/mobile/lib/core/widgets/**          shared widgets (buttons, cards, fields, states, nav)
apps/mobile/lib/features/*/ui/**         screens and feature widgets
apps/mobile/lib/features/*/view_model/** immutable view models the screens render
apps/mobile/lib/fixtures/**              sample view models for previews (never in prod paths)
apps/mobile/lib/l10n/**                  ARB string files
apps/mobile/assets/fonts/**              bundled fonts (with licence file)
apps/mobile/assets/images/ui/**          UI images, portion photo guides
apps/mobile/test/ui/**                   widget and golden tests
design/**                                design concepts and specs
```

## Must not edit

`lib/domain`, `lib/data`, `lib/features/*/controller`, `lib/app`, `pubspec.yaml`, `android/`, CI, `content/`.
Need a package (e.g. a chart lib)? Handoff to Platform.

## How the UI connects without conflicts

- Screens take **view models** (plain immutable classes in `view_model/`) and **callbacks**. They never import domain services, Drift or repositories.
- Until Integration wires real controllers, each screen is driven by fixtures from `lib/fixtures/`.
- Navigation: use route names from `lib/app/routes.dart` (Platform). Need a new route? Handoff to Platform.

## Rules that matter most here

- `.agent/rules/design.md` in full: tokens only, 48 dp targets, 200% text, 360 dp width, RTL-safe, all five screen states.
- Visual direction: `design/ui-concepts/` (style guide: `StyleGuide.html`). Deviations go in `docs/DECISIONS.md`.
- Sample numbers in fixtures are labelled sample; never present them as real nutrition data.

## Checks before handoff

`dart format` (own files) · `flutter analyze` clean · widget tests for each screen state · golden tests at 100% and 200% text.
