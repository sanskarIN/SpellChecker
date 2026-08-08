# Accessibility

SpellChecker should remain usable with keyboard navigation, screen readers, text scaling, high-contrast system settings, and narrow layouts.

## Current accessibility foundations

Version 1.1 uses standard Flutter Material controls for the main interaction surfaces:

- `TextField` for editor and dictionary input.
- `FilledButton` and `OutlinedButton` for primary actions.
- `ActionChip` for replacement suggestions.
- `TextButton` for save/ignore and dialog actions.
- `DropdownButtonFormField` for suggestion-count preference.
- `IconButton` with tooltips for app-bar actions.
- `Badge` for saved/ignored-word counts.
- `AlertDialog` for dictionary management, import, confirmation, and About content.
- Material theming that follows system light/dark mode.
- Progress indicators while persisted preferences or dictionary mutations are being processed.

Using standard controls lets Flutter provide platform semantics and focus behavior without requiring gesture-only custom widgets.

## Keyboard behavior

Contributors should preserve keyboard access for:

- Editor focus and multiline text entry.
- Check spelling.
- Clear editor text.
- Suggestion selection.
- Save word.
- Ignore once.
- Personal-dictionary manager.
- Personal-word add/remove/clear actions.
- Suggestion-count dropdown.
- Import dialog text entry and confirmation.
- Copy export.
- Clear ignored session words.
- About dialog.

The personal-word text field uses a `done` text-input action so submitting the field can add the word without requiring a pointer.

Do not make an essential action available only through pointer hover, color, or a custom gesture.

## Screen readers

When adding or changing widgets:

- Prefer controls that already expose semantic roles.
- Give icon-only controls meaningful tooltips or semantic labels.
- Make visible button text describe the action outcome.
- Avoid duplicated labels that cause repetitive announcements.
- Keep error/result messages descriptive rather than color-only.
- Announce persistent versus temporary behavior in wording where the distinction matters.

V1.1 deliberately uses **Save word** for persistent personal vocabulary and **Ignore once** for session-only suppression so the consequence is understandable without relying on icons or color.

## Badges and counts

Saved-word and ignored-word counts appear in `Badge` widgets on app-bar actions. The badge is supplementary; the tooltip identifies the underlying control.

Do not make badge presence the only way users can understand state. The personal-dictionary dialog also shows the saved-word count and list, while ignored words can be cleared through a labeled tooltip action.

## Loading and disabled states

Personal-dictionary controls remain unavailable until saved preferences finish loading. The editor displays a small progress indicator during initial restoration.

Dictionary-manager mutations disable conflicting controls while a write is in progress and display a linear progress indicator.

When changing asynchronous flows:

- Avoid leaving focus trapped on a permanently disabled control.
- Restore an actionable state after success or failure.
- Surface storage failures with readable text.
- Do not indicate success before persistence actually completes.

## Dialog accessibility

The personal-dictionary manager contains scrollable content so increased text size or smaller viewports do not require fixed-height text clipping.

Nested import and clear-confirmation dialogs should retain:

- Descriptive titles.
- Clearly labeled cancel/confirm actions.
- Keyboard focusable fields/buttons.
- Scrollable or flexible content where necessary.

## Color and contrast

SpellChecker uses Material color schemes instead of fixed foreground/background pairs for most UI elements.

Contributors should:

- Avoid conveying spelling status through color alone.
- Check light and dark themes.
- Avoid low-contrast custom colors.
- Preserve visible focus indicators.
- Ensure error-colored words also have textual context such as position/actions.

## Text scaling

Layouts should tolerate increased system text scale.

- Avoid fixed-height text containers when content can wrap.
- Use flexible layouts and scroll views for results/dialog content.
- Ensure button labels remain readable or wrap appropriately.
- Check dictionary word lists and long imported/error messages under larger text scales.

## Narrow layouts

The editor switches from a side-by-side layout to stacked panels below the wide-layout breakpoint. New controls should continue to fit narrow mobile/web windows without horizontal clipping.

The dictionary manager uses a bounded width but remains inside a dialog/scroll view; contributors should manually test narrow viewports for overflow whenever that dialog changes.

## Accessibility testing checklist

For significant UI changes, manually check when practical:

1. Keyboard-only navigation through editor, results, app-bar actions, and dictionary dialogs.
2. Screen-reader labels for icon-only controls.
3. Clear distinction between **Save word** and **Ignore once**.
4. Light and dark themes.
5. Increased system text size.
6. Narrow viewport layout.
7. Dialog scrolling and focus behavior.
8. Loading/disabled states during preference writes.
9. No essential state/action depends on color or badges alone.
10. Error messages remain readable and actionable.

Automated widget/semantics tests should be added for accessibility regressions that can be expressed deterministically.

## Future V1.2 improvements

The roadmap reserves stronger editor accessibility work for V1.2, including:

- Keyboard shortcuts for checking and issue navigation.
- Focus movement between spelling issues.
- Stronger semantic descriptions for replacement suggestions.
- Inline-highlight semantics that do not create noisy screen-reader output.
- Automated semantics tests.
- Dedicated high-contrast review.
- Undo/replace-all flows that expose understandable announcements and focus behavior.
