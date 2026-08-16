# Keyboard Shortcuts

SpellChecker is designed to support keyboard-first spelling review and Writing insights navigation. The bundled UI registers both Control and Meta variants for primary actions so Windows/Linux-style and macOS-style keyboards have equivalent commands.

## Main editor

| Action | Windows/Linux-style | macOS-style | Notes |
| --- | --- | --- | --- |
| Check spelling | `Ctrl+Enter` | `Command+Enter` | Runs a fresh spelling check on the current editor text. |
| Open Writing insights | `Ctrl+Shift+Enter` | `Command+Shift+Enter` | Opens local writing analysis for the current text and language. |
| Next spelling issue | `F7` | `F7` | Wraps from the last issue to the first. |
| Previous spelling issue | `Shift+F7` | `Shift+F7` | Wraps from the first issue to the last. |

The app bar also exposes buttons for Writing insights and previous/next spelling issue navigation.

## Writing insights

| Action | Windows/Linux-style | macOS-style | Notes |
| --- | --- | --- | --- |
| Focus review search | `Ctrl+F` | `Command+F` | Moves focus to **Search rules and findings**. |
| Clear transient review query | `Escape` | `Escape` | When search/category/automatic-fix filtering is active, clears it and keeps the dialog open. |
| Close Writing insights | `Escape` | `Escape` | When the transient review query is already empty, closes the dialog normally. |

Escape is intentionally state-dependent. If a filter is active, the first Escape clears filters; a subsequent Escape closes the dialog.

## Focus and selection behavior

When a spelling issue becomes active through F7 navigation or a results-card action, SpellChecker synchronizes the editor selection with that issue's source range when possible.

The application uses Flutter focus traversal and a focus anchor around shortcut scopes so the registered shortcuts remain available while focus moves among controls inside the relevant surface.

## Browser and operating-system interception

A host browser, desktop environment, assistive technology, or operating system may reserve or intercept some key combinations. In particular:

- browsers often have their own `Ctrl+F` / `Command+F` search command;
- function keys can be mapped to hardware/media functions;
- browser extensions may register shortcuts;
- screen readers can use navigation key combinations.

Writing insights deliberately registers its own search shortcut while the dialog is active. If the host prevents delivery of a shortcut to Flutter, use the visible UI control instead.

## Keyboard review workflow

A typical keyboard-first spelling session is:

1. enter or paste text;
2. press `Ctrl+Enter` / `Command+Enter`;
3. use `F7` and `Shift+F7` to move through spelling issues;
4. use Tab/Shift+Tab to move among visible controls and suggestion actions;
5. press `Ctrl+Shift+Enter` / `Command+Shift+Enter` to open Writing insights;
6. press `Ctrl+F` / `Command+F` to focus writing-review search;
7. use Escape to clear review filters, then Escape again to close when appropriate.

## Accessibility

Keyboard support is only one part of the accessibility contract. SpellChecker also uses semantics labels, live-region announcements for important result states, visible focus/focus traversal behavior, responsive layouts, and system light/dark theme selection.

See [Accessibility](ACCESSIBILITY.md) for the complete contract and known limitations.

## Source of truth

The primary editor shortcuts are defined in `lib/features/editor/spell_checker_page.dart`. Writing insights shortcuts are defined in `lib/features/editor/writing_insights_dialog.dart`. When adding or changing a shortcut, update this page, the user guide, accessibility documentation, tooltips where relevant, and widget tests in the same change.
