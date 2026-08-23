# Keyboard Shortcuts

SpellChecker is designed to support keyboard-first spelling review and Writing insights navigation. The bundled UI registers both Control and Meta variants for primary actions so Windows/Linux-style and macOS-style keyboards have equivalent commands. Press `F1` while the main SpellChecker surface has focus to open the in-app shortcut reference.

## Main editor

| Action | Windows/Linux-style | macOS-style | Notes |
| --- | --- | --- | --- |
| Check spelling | `Ctrl+Enter` | `Command+Enter` | Runs a fresh spelling check on the current editor text. |
| Open Writing insights | `Ctrl+Shift+Enter` | `Command+Shift+Enter` | Opens local writing analysis for the current text and language. |
| Next spelling issue | `F7` | `F7` | Wraps from the last issue to the first. |
| Previous spelling issue | `Shift+F7` | `Shift+F7` | Wraps from the first issue to the last. |
| Open keyboard shortcut reference | `F1` | `F1` | Opens the in-app list of primary editor commands. |

The app bar also exposes buttons for Writing insights and previous/next spelling issue navigation. The shortcut reference explicitly reminds users that the visible controls remain available, so primary workflows do not require keyboard use.

## Writing insights

| Action | Windows/Linux-style | macOS-style | Notes |
| --- | --- | --- | --- |
| Focus review search | `Ctrl+F` | `Command+F` | Moves focus to **Search rules and findings**. |
| Clear transient review query | `Escape` | `Escape` | When search/category/automatic-fix filtering is active, clears it and keeps the dialog open. |
| Close Writing insights | `Escape` | `Escape` | When the transient review query is already empty, closes the dialog normally. |

Escape is intentionally state-dependent. If a filter is active, the first Escape clears filters; a subsequent Escape closes the dialog.

## Shortcut reference

Press `F1` on the main application surface to open **Keyboard shortcuts**. The dialog lists:

- Check spelling;
- Open Writing insights;
- next and previous spelling issue navigation;
- the `F1` help command itself.

Each shortcut row has an explicit semantic label that pairs the action name with the key combination. Close the dialog with its visible **Close** action.

## Focus and selection behavior

When a spelling issue becomes active through F7 navigation or a results-card action, SpellChecker synchronizes the editor selection with that issue's source range when possible.

The application uses Flutter focus traversal and focus anchors around shortcut scopes so registered shortcuts remain available while focus moves among controls inside the relevant surface. The application-level shortcut scope owns `F1`; editor and Writing insights scopes own their feature-specific commands.

## Browser and operating-system interception

A host browser, desktop environment, assistive technology, or operating system may reserve or intercept some key combinations. In particular:

- browsers often have their own `Ctrl+F` / `Command+F` search command;
- `F1` may open browser/host help;
- function keys can be mapped to hardware/media functions;
- browser extensions may register shortcuts;
- screen readers can use navigation key combinations.

Writing insights deliberately registers its own search shortcut while the dialog is active. If the host prevents delivery of a shortcut to Flutter, use the visible UI controls for the underlying workflow instead.

## Keyboard review workflow

A typical keyboard-first spelling session is:

1. optionally press `F1` to review available commands;
2. enter or paste text;
3. press `Ctrl+Enter` / `Command+Enter`;
4. use `F7` and `Shift+F7` to move through spelling issues;
5. use Tab/Shift+Tab to move among visible controls and suggestion actions;
6. press `Ctrl+Shift+Enter` / `Command+Shift+Enter` to open Writing insights;
7. press `Ctrl+F` / `Command+F` to focus writing-review search;
8. use Escape to clear review filters, then Escape again to close when appropriate.

## Accessibility

Keyboard support is only one part of the accessibility contract. SpellChecker also uses semantics labels, live-region announcements for important result states, visible focus/focus traversal behavior, responsive layouts, and system light/dark theme selection.

See [Accessibility](ACCESSIBILITY.md) for the complete contract and known limitations.

## Source of truth

The application-level `F1` shortcut and its in-app reference are defined in `lib/app.dart`. Primary editor shortcuts are defined in `lib/features/editor/spell_checker_page.dart`. Writing insights shortcuts are defined in `lib/features/editor/writing_insights_dialog.dart`.

When adding or changing a shortcut, update this page, the user guide, accessibility documentation, tooltips/semantics where relevant, and widget tests in the same change.
