# Accessibility

SpellChecker should remain usable with keyboard navigation, screen readers, text scaling, high-contrast system settings, narrow layouts, and without relying on color alone.

## Current accessibility foundations

Version 1.2 uses standard Flutter Material controls plus explicit semantics for editor/result state:

- `TextField` for editor and dictionary input.
- `FilledButton` / `OutlinedButton` for primary actions.
- `ActionChip` for single replacement suggestions.
- `PopupMenuButton` for replace-all choices.
- `TextButton` for save/ignore/dialog actions.
- `DropdownButtonFormField` for suggestion-count preference.
- `IconButton` with tooltips for app-bar and navigation actions.
- `Badge` for saved/ignored/result counts.
- `AlertDialog` for dictionary/import/confirmation/About content.
- Material theming following system light/dark mode.
- Progress indicators for preference restoration and dictionary writes.
- `Semantics` containers/live regions for editor context, issue state, result counts, empty states, and storage warnings.

Using standard controls lets Flutter provide platform roles/focus behavior while explicit semantic wrappers communicate V1.2 state that a visual underline alone cannot describe.

## Keyboard shortcuts

V1.2 defines these editor shortcuts:

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Run spelling check |
| `Command+Enter` | Run spelling check on macOS-style keyboards |
| `F7` | Move to next spelling issue |
| `Shift+F7` | Move to previous spelling issue |

Issue navigation wraps at both ends.

Equivalent pointer-accessible previous/next controls remain in the app bar and Results header. Do not remove visible controls solely because a shortcut exists.

## Keyboard behavior checklist

Preserve keyboard access for:

- Editor focus and multiline text entry.
- Check spelling.
- Clear editor text.
- Undo correction.
- Previous/next issue navigation.
- Issue-card activation.
- Suggestion selection.
- Replace-all menu opening/selection.
- Save word.
- Ignore once.
- Personal-dictionary manager.
- Personal-word add/remove/clear actions.
- Suggestion-count dropdown.
- Import dialog text entry/confirmation.
- Copy export.
- Clear ignored session words.
- About dialog.

Do not create essential pointer-only, hover-only, or color-only actions.

## Inline issue highlighting

Checked spelling issues receive a wavy underline inside the editable text. The active issue receives stronger background/text styling.

Inline styling is supplementary. Users can also identify issues through:

- Results list text.
- Issue count.
- Character range.
- Active issue position (`Issue X of Y`).
- Semantic issue labels.
- Editor selection when an issue is activated.

This prevents color/underline perception from being the sole mechanism for understanding spelling state.

Manual edits clear old checked highlighting so stale ranges are not visually presented as current issues.

## Active issue semantics

Each issue card is a semantic container with:

- Issue index and total issue count.
- Original issue word.
- Character range.
- Selected state when active.

Changing active issue also selects its source range in the editor and requests editor focus. Results automatically attempt to scroll the selected card into view.

When changing this behavior, avoid focus loops where Results and editor repeatedly steal focus from one another.

## Live regions

V1.2 uses live-region semantics for important status states:

- Result count after checking.
- **Ready to check** / **Nothing to check** / **No issues found** states.
- Local storage unavailable warning.

Keep live announcements short enough to be useful. Do not mark every suggestion chip or every visual change as a live region; that would create excessive screen-reader noise.

## Storage warning accessibility

If preference storage cannot load/write, SpellChecker shows visible warning text plus a live-region semantic label. Session spelling remains usable.

The warning must:

- Explain that local dictionary/preferences may not persist.
- Not imply editor text was uploaded.
- Remain readable in light/dark themes.
- Avoid relying only on warning color/icon.

## Correction and undo accessibility

After a spelling correction:

- A snackbar explains what changed and offers **Undo**.
- **Undo correction** remains available near the editor while correction history exists.

Replace-all is represented by a labeled control/menu rather than requiring a hidden gesture.

If future work adds richer announcements for replacement counts, avoid announcing both snackbar and redundant live regions simultaneously unless testing shows it is beneficial.

## Screen readers

When adding/changing widgets:

- Prefer controls that already expose semantic roles.
- Give icon-only controls meaningful tooltips/labels.
- Make visible button text describe outcomes.
- Avoid duplicate semantics that cause repeated announcements.
- Keep errors/results descriptive rather than color-only.
- Preserve the **Save word** vs **Ignore once** distinction.
- Ensure active/selected issue state is discoverable without inspecting visual background color.

The editor semantic label states that checked spelling issues are underlined after a check.

## Badges and counts

Badges are supplementary:

- Saved-word badge supplements the dictionary manager/list.
- Ignored-word badge supplements the clear-ignored action.
- Result-count badge supplements the Results header/live label.

Do not make badge visibility the only source of state.

## Loading and disabled states

Personal-dictionary controls remain unavailable until preferences finish loading. The editor displays a small progress indicator during restoration.

Dictionary-manager writes disable conflicting controls and show a progress indicator.

When changing async flows:

- Avoid permanently disabled focus targets.
- Restore actionable state after success/failure.
- Surface failures as readable text.
- Do not indicate success before persistence completes.
- Preserve session spelling even if preference storage fails.

## Dialog accessibility

Dictionary/import/confirmation dialogs should retain:

- Descriptive titles.
- Clear cancel/confirm actions.
- Keyboard-focusable controls.
- Scrollable/flexible content for text scaling/small viewports.
- No essential information encoded solely in icons.

## Color and contrast

Contributors should:

- Check light and dark themes.
- Avoid low-contrast custom colors.
- Preserve visible focus indicators.
- Ensure active error-container foreground/background uses the Material color scheme.
- Keep textual result information alongside inline error styling.

## Text scaling

Layouts should tolerate increased system text scale:

- Avoid fixed-height text containers for wrapping content.
- Keep results/dialogs scrollable.
- Let action labels wrap or reflow via `Wrap` where practical.
- Check repeated-occurrence chips, Replace all, storage warning, and keyboard hint text at larger scales.

## Narrow layouts

Below the wide-layout breakpoint the editor/results stack vertically. New controls must remain reachable through scrolling without horizontal clipping.

Issue cards can grow vertically because of suggestion/action content; that is acceptable when their parent list remains scrollable.

## Automated accessibility testing

V1.2 adds semantic structure but not exhaustive semantic-node assertions yet. Future regression tests should use Flutter semantics testing where stable to protect:

- Selected issue state.
- Result count announcement.
- Blank/clean status labels.
- Storage-warning label.
- Editor semantic label.
- Tooltips/labels for icon-only navigation controls.

Do not replace useful manual screen-reader/keyboard checks with automated tests alone.

## Manual accessibility checklist

For significant UI changes, verify when practical:

1. Keyboard-only editor/check/navigation/correction workflow.
2. F7 and Shift+F7 navigation wraps correctly.
3. Ctrl/Command+Enter runs a check without breaking multiline entry behavior.
4. Active issue is understandable without color alone.
5. Screen-reader labels for icon-only controls.
6. Result/empty/storage states produce understandable announcements.
7. Replace-all and Undo are keyboard reachable.
8. Light and dark themes.
9. Increased text size.
10. Narrow viewport layout and scrolling.
11. Dialog scrolling/focus behavior.
12. Loading/disabled states during preference writes.
13. No essential action depends on hover, color, underline, or badges alone.

## Future accessibility work

V1.2 establishes keyboard/navigation/semantic foundations. Future improvements can include:

- Dedicated semantics regression tests.
- High-contrast review on supported platforms.
- User-configurable shortcut support if needed.
- More precise announcements after replace-all/undo.
- Language-selection semantics when V1.3 adds language packs.
