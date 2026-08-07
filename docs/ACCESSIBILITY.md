# Accessibility

SpellChecker should remain usable with keyboard navigation, screen readers, text scaling, and high-contrast system settings.

## Current accessibility foundations

Version 1.0 uses standard Flutter Material controls for the main interaction surfaces:

- `TextField` for editor input.
- `FilledButton` and `OutlinedButton` for primary actions.
- `ActionChip` for replacement suggestions.
- `TextButton` for add/ignore actions.
- Tooltips on app-bar icon actions.
- Material theming that follows system light/dark mode.

Using standard controls allows Flutter to provide platform semantics and focus behavior without custom gesture-only interactions.

## Keyboard behavior

Contributors should preserve keyboard access for:

- Editor focus.
- Check spelling.
- Clear.
- Suggestion selection.
- Add word.
- Ignore.
- Session reset.
- About dialog.

Do not make essential actions available only through pointer hover or gestures.

## Screen readers

When adding custom widgets:

- Prefer widgets that already expose semantic roles.
- Add `Semantics` only when native semantics are insufficient.
- Give icon-only controls a tooltip or semantic label.
- Avoid duplicating labels in a way that causes repetitive announcements.
- Keep error/result wording descriptive rather than color-only.

## Color and contrast

SpellChecker uses Material color schemes instead of fixed foreground/background pairs for most UI elements. Contributors should:

- Avoid conveying spelling status through color alone.
- Check light and dark themes.
- Avoid low-contrast custom colors.
- Preserve visible focus indicators.

## Text scaling

Layouts should tolerate increased system text scale. Avoid fixed-height text containers when the content can wrap. Use flexible layouts and scroll views for result content.

## Accessibility testing checklist

For significant UI changes, manually check when practical:

1. Keyboard-only navigation.
2. Screen-reader labels for icon-only controls.
3. Light and dark themes.
4. Increased text size.
5. Narrow viewport layout.
6. No action depends on color alone.

Automated widget tests should be added for accessibility regressions that can be expressed deterministically.

## Future improvements

Planned accessibility work includes:

- Keyboard shortcuts for checking and issue navigation.
- Focus movement between spelling issues.
- Stronger semantic descriptions for replacement suggestions.
- Automated semantics tests.
- Dedicated high-contrast review.
