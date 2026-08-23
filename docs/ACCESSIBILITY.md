# Accessibility

SpellChecker aims to make the bundled editor and review workflow usable with keyboard navigation, assistive technologies, responsive layouts, and system light/dark appearance. This page documents the current `3.2.0+25` V3 cross-platform accessibility contract and known boundaries; it does not claim formal certification against every accessibility standard/platform combination.

## Principles

The UI should preserve:

- visible, labeled controls for actions that also have shortcuts;
- keyboard traversal and shortcut access;
- meaningful semantics for interactive/status elements;
- live announcements for important dynamic result states where implemented;
- readable system light/dark themes;
- responsive layout without removing core functionality;
- deterministic focus behavior around review search/navigation;
- no correction action that depends solely on color.

## Keyboard access

Primary editor shortcuts:

| Action | Windows/Linux-style | macOS-style |
| --- | --- | --- |
| Check spelling | `Ctrl+Enter` | `Command+Enter` |
| Open Writing insights | `Ctrl+Shift+Enter` | `Command+Shift+Enter` |
| Next spelling issue | `F7` | `F7` |
| Previous spelling issue | `Shift+F7` | `Shift+F7` |
| Open keyboard shortcut reference | `F1` | `F1` |

Writing insights:

| Action | Windows/Linux-style | macOS-style |
| --- | --- | --- |
| Focus review search | `Ctrl+F` | `Command+F` |
| Clear active transient query | `Escape` | `Escape` |
| Close when query already empty | `Escape` | `Escape` |

`F1` opens an in-app shortcut reference that lists the primary editor commands and reminds users that visible controls remain available. Visible buttons/fields remain available for users who cannot or do not use shortcuts.

See [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

## Escape behavior in Writing insights

Escape intentionally avoids discarding an active filtered review without first clearing it.

When the review query contains search text, selected categories, or Automatic fixes only:

1. Escape clears the transient query;
2. search focus returns/remains available;
3. the dialog stays open.

When the query is already empty, Escape closes Writing insights through its normal result path so current rule-switch choices can still be returned/persisted by the page.

## Focus management

The editor and Writing insights use Flutter focus/shortcut scopes so keyboard commands can remain available while focus moves among controls. The application-level focus scope also keeps the `F1` shortcut reference available while the main SpellChecker surface is active.

Writing insights owns a dedicated search `FocusNode`. Ctrl/Command+F requests focus on that search field rather than relying on browser page search.

When a spelling issue becomes active, the application attempts to synchronize the editor selection with its source range so keyboard navigation has a concrete text location.

Dialog/list content can be lazy/off-screen. Users may need to scroll to reach later findings/rules; automated tests should likewise scroll/ensure visibility rather than assuming all controls are mounted simultaneously.

## Semantics and announcements

SpellChecker uses Flutter semantics for important application states/controls. Dynamic status/error messages in dialogs use live-region semantics where appropriate so assistive technology can announce changes without requiring manual focus movement.

The keyboard shortcut reference gives each shortcut row an explicit semantic label pairing the action with its key combination rather than relying only on visual alignment.

Writing insights count/result summaries distinguish captured/total/limited state instead of relying on visual badge styling alone.

Spelling result state also has textual labels such as ready/nothing-to-check/no-issues/issue-position rather than communicating state only through underline color.

## Inline spelling visualization

Unknown checked words use wavy underlines and an active issue receives stronger visual emphasis. This presentation supplements, rather than replaces, the Results panel's text/action controls.

The editor preserves current input-method composing-range styling with priority so IME composition remains understandable/usable while issue decoration is active.

## Color and theme

`SpellCheckerApp` uses Material 3 `ColorScheme.fromSeed` for light and dark themes and follows `ThemeMode.system`.

Do not hard-code a visual state using only a color that may become low-contrast across themes. New status/error/finding presentation should combine text, iconography, semantics, or structure as appropriate.

This documentation does not claim that every third-party browser/device/theme override has been manually WCAG-certified. Contributors should test actual target combinations when making contrast-sensitive changes.

## Responsive layout

The editor/result presentation adapts between wide and narrow arrangements. Core actions should remain available in both layouts.

Responsive changes must not:

- hide a required correction/review action with no alternative;
- create keyboard-inaccessible overflow controls;
- reorder content so semantics/focus order becomes misleading;
- require horizontal scrolling for ordinary text/actions when avoidable.

## Touch/pointer alternatives

Keyboard shortcuts are enhancements, not the only interaction path. App-bar buttons, dialog controls, chips, suggestion actions, and editor/results controls remain available for pointer/touch/assistive workflows.

## Writing insights filters

Search, category chips, presets, and Automatic fixes only change the visible review set. The UI communicates visible/captured/total counts textually so users can understand that a filtered or limited list is not necessarily the complete document finding set.

When filtering a truncated analysis, correction actions remain scoped to captured/visible findings. The UI should not imply that “apply visible” means “fix entire document.”

## Advisory findings

The three unmatched-delimiter rules provide findings without automatic replacements. They are not represented as disabled/broken fix buttons; their absence of automatic correction is a semantic property of the finding.

Review text should explain the condition rather than requiring a user to infer meaning from button availability/color.

## Loading and storage state

Preference loading/storage failures are communicated using readable text/status states. Controls that require loaded durable preferences can be disabled while loading instead of accepting an action whose persistence behavior is not ready.

A storage error should not be conveyed solely with a color/icon.

## Clipboard actions

Copy actions have explicit labeled controls, such as dictionary/settings/diagnostic copying. The application should announce/report success/failure through visible status messaging when implemented.

Host browser/OS clipboard permissions can still block behavior outside Flutter's control.

## Platform/browser shortcut conflicts

Browsers, operating systems, hardware function-key modes, extensions, and assistive technologies can intercept shortcuts before Flutter receives them.

Examples:

- `Ctrl+F` / `Command+F` is commonly browser search;
- `F1` can open host/browser help;
- F-keys can be mapped to media/system functions;
- screen readers can reserve navigation combinations.

Because visible controls remain available, host interception should not make a core workflow shortcut-only. If `F1` itself is intercepted, the primary commands listed by the reference are still exposed through their normal visible controls and tooltips.

## Text zoom and browser scaling

Flutter web rendering participates in host/browser window sizing and platform accessibility settings, but exact zoom/text-scaling behavior can vary with Flutter/browser versions.

When changing layouts, test increased text scale and constrained viewport sizes. Avoid fixed-height content that clips essential labels/actions when text grows.

## Screen reader test expectations

For accessibility-sensitive changes, use Flutter semantics/widget tests where possible and manually inspect target behavior for important flows.

Recommended scenarios:

- startup/loading status;
- editor language selector and text field;
- Check spelling state changes;
- F7 active issue navigation;
- F1 shortcut-reference dialog labels and close behavior;
- suggestion/correction controls;
- personal dictionary dialog success/error states;
- Writing insights search/filter counts;
- Ctrl/Command+F focus;
- first Escape clearing filters;
- second Escape closing;
- limited-result announcement;
- storage warning;
- copied diagnostic/settings status.

## Keyboard regression expectations

Changes to shortcut/focus code should keep automated coverage for:

```text
Ctrl+Enter / Command+Enter
Ctrl+Shift+Enter / Command+Shift+Enter
F7
Shift+F7
F1 shortcut reference
Ctrl+F / Command+F inside Writing insights
Escape transient-query clear/close behavior
```

Update [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md), [User guide](USER_GUIDE.md), and tooltips/semantics in the same change.

## Motion

SpellChecker does not rely on decorative animation for understanding spelling/writing results. New animation should not become the sole way to communicate state and should respect Flutter/platform reduced-motion behavior where relevant.

## Language/readability

Labels/messages should be concise, specific, and avoid requiring knowledge of internal class names or rule IDs for ordinary use. Technical IDs belong in diagnostics/developer contexts; user-facing rule names/messages should remain readable.

## Error messaging

Error text should state what failed and whether the current session can continue. Avoid exposing stack traces, raw storage internals, or private source text in user-facing errors.

## Known boundaries

Current repository validation is primarily Flutter widget/semantics testing on the CI environment plus project-specific accessibility regressions. It does not claim exhaustive manual testing across every browser, screen reader, mobile accessibility service, keyboard layout, or native platform.

Official Flutter runners are committed and release-built for Android, iOS, Linux, macOS, Web, and Windows. That build coverage proves platform integration and packaging, not an exhaustive assistive-technology certification matrix. Native screen-reader/service testing remains an important manual expansion area.

See [Platform support](PLATFORM_SUPPORT.md).

## Reporting accessibility problems

A useful report includes:

- SpellChecker version/commit;
- browser/platform/Flutter version if known;
- assistive technology and version when relevant;
- exact control/workflow;
- keyboard focus position;
- expected versus observed behavior;
- a synthetic/non-sensitive text sample when analysis results matter;
- whether the issue is wide/narrow layout or text-scale dependent.

Do not include private documents when synthetic text is sufficient.

Use [Support](../SUPPORT.md) for normal reports. Security-sensitive accessibility issues involving data disclosure should follow [Security](../SECURITY.md).

## Contributor checklist

Before merging an accessibility-sensitive UI change, review:

- visible labels/tooltips;
- semantics labels/roles/value where relevant;
- live announcements for dynamic critical state;
- keyboard traversal;
- shortcut alternatives;
- focus after dialogs/filter clear/correction;
- light/dark contrast;
- non-color state communication;
- wide/narrow layouts;
- increased text scale;
- lazy scroll visibility;
- storage/error messaging;
- widget/semantics regression tests;
- docs updates.

## Related documentation

- [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md)
- [User guide](USER_GUIDE.md)
- [Testing](TESTING.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [V2.11 historical accessibility record](V2_11_ACCESSIBILITY.md)
