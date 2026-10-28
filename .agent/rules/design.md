---
trigger: always_on
---

# Design and UX Rules

## Principles

- **Calm, honest, supportive.** Health context: no shaming, no alarm colours for eating more, no "you failed" copy, no streak guilt.
- **Fast to the common action.** Logging a planned meal takes ≤ 2 taps. Primary action is always visible.
- **Clarity over decoration.** One primary action per screen; consistent patterns across screens.
- **Estimates are labelled as estimates** wherever calories or macros appear.

## Design system

- All colours, type sizes, spacing, radii, elevation and motion come from **design tokens** in `core/theme`. No hard-coded colours, font sizes or magic spacing in screens.
- Spacing on a 4 dp grid. Define a small type scale and reuse it.
- Shared widgets (buttons, fields, cards, empty/error/loading states) live in one place; screens compose them.
- Light and dark themes both supported; contrast checked in both.
- Bundle fonts; no runtime font downloads.

## Accessibility (required, not optional)

- Text contrast ≥ 4.5:1 (3:1 for large text and UI components).
- Touch targets ≥ 48×48 dp.
- Layout works at 200% text scale and 360 dp width without clipping or overflow.
- Every interactive element has a semantic label; images have descriptions or are marked decorative.
- Never use colour alone to convey meaning; pair with icon or text.
- Support screen readers, keyboard/D-pad focus order, reduced-motion preference.
- RTL-safe from day one: use start/end, not left/right; no text in images.

## Screen states

Every screen defines: **loading, empty, error (with recovery action), offline, and success**. Destructive actions need confirmation or undo.

## Content and copy

- Plain language, short sentences, no medical claims ("cure", "treat", "diabetes plan").
- Strings live in ARB files; none hard-coded. Roman Urdu is for search aliases, not UI labels.
- Error messages say what happened and what to do next.
- Notifications never contain health details.

## Performance

- Budgets in blueprint §9 apply to UI: lazy lists, const widgets, WebP images, lazy image loading, no work in `build()`.
- Test on a real low-end device before release.

## Review checklist (UI change)

- [ ] Tokens only, no hard-coded values
- [ ] All screen states present
- [ ] 200% text and 360 dp checked
- [ ] Contrast and touch targets checked
- [ ] Strings localised, RTL-safe
- [ ] No health data in logs/analytics

