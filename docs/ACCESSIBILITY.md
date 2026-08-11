# Accessibility

SpellChecker should remain usable with keyboard navigation, screen readers, text scaling, high-contrast system settings, narrow layouts, and without relying on color alone.

## Current foundations

The application primarily uses standard Flutter Material controls plus explicit semantic wrappers for state that is not obvious from a standard control alone.

Current surfaces include:

- `TextField` for editor and dictionary input.
- `FilledButton`, `OutlinedButton`, and `TextButton` for labeled actions.
- `ActionChip` for spelling replacement suggestions.
- `PopupMenuButton` for spelling replace-all choices.
- `DropdownButton` / `DropdownButtonFormField` for language and suggestion settings.
- `SwitchListTile` for Writing insights rule choices.
- `IconButton` with tooltips for app-bar/navigation controls.
- `Badge` for supplementary counts.
- `AlertDialog` for dictionary, import, confirmation, About, and Writing insights.
- Material light/dark color schemes.
- Progress indicators during preference restoration/writes.
- Semantic containers/live regions for important editor/result/finding/warning states.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Run spelling check |
| `Command+Enter` | Run spelling check on macOS-style keyboards |
| `Ctrl+Shift+Enter` | Open Writing insights |
| `Command+Shift+Enter` | Open Writing insights on macOS-style keyboards |
| `F7` | Move to next spelling issue |
| `Shift+F7` | Move to previous spelling issue |

Visible pointer/touch controls remain available for these workflows. A shortcut must not become the only way to reach an essential action.

## Keyboard checklist

Preserve keyboard access for:

- Editor focus and multiline text entry.
- Language selection.
- Check spelling.
- Clear editor text.
- Undo correction.
- Previous/next spelling issue.
- Issue-card activation.
- Suggestion selection.
- Spelling replace-all menu.
- Save word / Ignore once.
- Personal dictionary manager.
- Personal-word add/remove/clear.
- Suggestion-count dropdown.
- Dictionary import/export.
- Clear ignored session words.
- Writing insights launch.
- Writing-rule switches.
- Individual **Apply safe fix**.
- **Apply all safe fixes (N)**.
- About dialog.

Do not introduce pointer-only, hover-only, or color-only essential actions.

## Language selector

The language selector is a standard dropdown in the Editor header and is wrapped with a semantic label identifying it as the spelling language control.

Requirements:

- Current language remains visibly named.
- Control is keyboard reachable.
- Changing language remains explicit user action.
- Focus should not jump unexpectedly because a language changes.
- Language-specific vocabulary/rule choices must not be communicated only indirectly through changed findings.

## V2.2 review-management controls

Writing insights adds standard accessible controls for review organization:

- Labeled search `TextField`.
- Mechanics/Clarity `FilterChip` controls with selected state.
- Labeled **Automatic fixes only** switch.
- Labeled **Clear review filters** action.
- Visible/total rule and finding counts.
- Category text in rule/finding content and finding semantics.
- Labeled **Reset rules to defaults** action.

Filters must remain keyboard reachable and must not make hidden findings indistinguishable from “no findings at all”; the dialog exposes a dedicated **No matching findings** state when enabled rules have findings that the current review filters hide.

When filters are active, **Apply visible safe fixes (N)** includes the visible automatic-fix count in its label. Resetting rules closes the dialog and reports persistence failure textually if the override could not be cleared.

## Writing insights

Writing insights uses:

- Labeled rule switches.
- Textual findings.
- Exact source ranges.
- Suggested replacement text.
- Labeled individual fix buttons.
- A labeled batch action containing the number of available automatic fixes.
- Semantic finding containers.
- Semantic empty states.

A rule's meaning, enabled state, severity, or fix availability must not depend only on color/icon styling.

### Persisted rule choices

V2.1 rule switches are persisted per language. The visible switch state remains the user-facing authority.

If storage fails, the session choice remains active and the app reports a storage warning. The warning must not imply that editor text was uploaded.

### Batch fixes

**Apply all safe fixes (N)** must remain a normal labeled control.

After a successful batch:

- The complete batch is one undo entry.
- Feedback reports applied/skipped counts in readable text.
- **Undo correction** remains available.

Do not rely on a transient color change to communicate that a batch was applied.

## Inline spelling highlights

Checked spelling issues receive wavy underlines; the active issue receives stronger styling.

Inline styling is supplementary. The same issue is also represented through:

- Results text.
- Issue count.
- Character range.
- Active issue position.
- Semantic labels.
- Editor selection when activated.

Manual edits clear stale highlighting.

## Spelling issue semantics

Each issue card is a semantic container describing:

- Issue index/total.
- Source word.
- Character range.
- Selected state when active.

Changing active issue also selects the corresponding editor range and requests editor focus. Avoid focus loops between Results and editor.

## Writing finding semantics

Each writing finding is a semantic container identifying:

- Finding position/total.
- Rule name.
- Human-readable message.

The visible source range/original text remains available to sighted users; semantic labels should remain concise enough to avoid overwhelming screen-reader output.

## Live regions

Use live regions for important status transitions rather than every visual update.

Appropriate examples:

- Result count.
- Ready/blank/clean states.
- Storage-unavailable warning.
- Writing empty state.

Avoid making each suggestion, switch change, or highlight repaint a live region.

## Storage warnings

A storage warning should:

- Explain that local settings may not persist.
- Remain readable in light/dark themes.
- Not imply document upload.
- Avoid color-only communication.
- Leave session spelling/writing controls usable when possible.

## Correction and undo

After a correction:

- Snackbar feedback can expose **Undo**.
- **Undo correction** remains available while history exists.

One undo entry represents one user-visible automatic operation:

- Single spelling replacement.
- Spelling replace-all.
- Individual writing safe fix.
- V2.1 writing batch safe fix.

This grouping makes bulk actions predictable for keyboard/screen-reader users.

## Screen readers

When adding/changing widgets:

- Prefer controls with native semantic roles.
- Give icon-only controls meaningful tooltips/labels.
- Use action-oriented visible labels.
- Avoid duplicate semantic labels that create repeated announcements.
- Keep errors/results textual, not color-only.
- Preserve **Save word** vs **Ignore once** wording.
- Keep selected issue state discoverable without visual background inspection.
- Do not announce sensitive editor text more broadly than necessary.

## Badges/counts

Badges are supplementary only.

Examples:

- Saved-word badge supplements the personal dictionary list.
- Ignored-word badge supplements the clear-ignored action.
- Result-count badge supplements visible/semantic result text.

## Loading and disabled states

Preference-dependent controls can be disabled while initial restoration runs.

Async flows must:

- Avoid permanent disabled focus targets.
- Restore actionable state after success/failure.
- Surface failures as readable text.
- Avoid claiming persistence success before a write succeeds.
- Preserve session functionality on storage failure where safe.

## Dialog accessibility

Dialogs should retain:

- Descriptive titles.
- Clear close/cancel/confirm actions.
- Keyboard-focusable controls.
- Scrollable/flexible content for narrow viewports and larger text.
- No essential information encoded solely in icons.

Writing insights intentionally uses a scrollable/lazy findings list; every action must remain reachable through normal scrolling/focus traversal.

## Color and contrast

Contributors should:

- Check light and dark themes.
- Avoid low-contrast custom colors.
- Preserve visible focus indicators.
- Keep textual issue/finding descriptions alongside visual emphasis.
- Never make underline/background color the sole error/finding signal.

## Text scaling

Layouts should tolerate increased text scale.

- Avoid fixed-height wrapping text containers.
- Keep results/dialogs scrollable.
- Let action labels wrap/reflow where practical.
- Test language names, storage warnings, batch-fix labels/counts, and rule descriptions at increased scales.

## Narrow layouts

Below the wide-layout breakpoint editor/results stack vertically. Controls must remain reachable by scrolling without horizontal clipping.

The language selector was intentionally placed in the existing Editor header as a dense control so it does not add unnecessary fixed vertical height to common 800×600 layouts.

## Automated accessibility testing

Add targeted semantics tests where stable for the supported Flutter version.

Important contracts include:

- Selected spelling issue state.
- Result-count/empty-state announcements.
- Storage-warning live region.
- Editor semantic label.
- Language selector semantic label.
- Writing finding semantic label.
- Tooltips for icon-only controls.
- Reachability of Writing insights batch and individual actions.

Automated tests complement rather than replace manual screen-reader/keyboard testing.

## Manual checklist

For significant UI changes verify when practical:

1. Keyboard-only editor/spelling workflow.
2. `F7` / `Shift+F7` wrapping navigation.
3. `Ctrl/Command+Enter` spelling check.
4. `Ctrl/Command+Shift+Enter` Writing insights.
5. Language selector keyboard use/current label.
6. Writing-rule switch keyboard use.
7. Individual and batch writing fixes.
8. One-step undo after a writing batch.
9. Screen-reader labels for icon-only controls.
10. Understandable issue/finding status without color alone.
11. Light/dark themes.
12. Increased text size.
13. Narrow viewport/scrolling.
14. Dialog scrolling/focus behavior.
15. Loading/disabled states during preference reads/writes.
16. Storage failure messaging.

## Future work

Potential improvements include:

- Dedicated semantics regression coverage.
- High-contrast platform review.
- Optional shortcut customization.
- Refined non-duplicative announcements after bulk fixes/undo.
- Additional accessible rule categories/filtering if the writing-rule catalogue grows.

## V2.3 review presets and portable settings

Review presets use standard Material `ChoiceChip` controls with visible text labels; category filters and the automatic-fixes switch remain independently available. Portable settings uses labeled copy/import controls, a labeled multiline import field, selectable export text, and semantic live-region status/error messages. The visible Portable settings app-bar action has a tooltip, so the workflow is not shortcut-only. Tests scroll lazy dialogs to real controls instead of depending on a fixed viewport.

## V2.5 limited-result accessibility

The limited spelling-result state must not rely on the `+` badge alone.

When results are truncated, the Results panel provides a live-region semantic message and visible explanatory text stating that only the first 200 spelling issues were captured and that Replace all is unavailable. Repeated-word chips use “captured occurrences” wording so screen-reader and visual users receive the same incompleteness signal.

Keyboard issue navigation remains available across captured issues. Do not expose a keyboard-only bulk action that bypasses the limited-result Replace all restriction.

## V2.6 Writing insights accessibility

The two new rules appear as the same labeled `SwitchListTile` controls used by existing writing rules, so they remain keyboard/focus/assistive-technology reachable. Their findings use the existing semantic finding-card and safe-fix controls. Expanded catalogue tests intentionally scroll the real lazy dialog so narrow/small viewports remain part of the supported interaction model.
