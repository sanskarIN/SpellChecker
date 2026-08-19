# User Guide

This guide describes the current SpellChecker application workflow. Release-specific history is available through [Release history](RELEASE_HISTORY.md).

## What the application does

SpellChecker provides a local Flutter editor for:

- spelling checks with ranked suggestions;
- thirteen built-in offline spelling packs across English, Hindi, Spanish, French, German, Brazilian Portuguese, Italian, Bengali, Marathi, Tamil, Telugu, and Russian;
- per-language personal dictionaries;
- session-only ignored words;
- deterministic Writing insights rules;
- safe individual and batch corrections;
- bounded correction undo;
- Portable settings transfer;
- personal-dictionary transfer;
- lightweight word/character/sentence statistics.

The application does not upload editor text to a remote spelling/grammar service and does not provide cloud document storage or automatic language detection.

## Main screen

The main application contains an **Editor** panel and a **Results** panel. On wide layouts they are shown side by side; on narrower layouts they stack vertically.

The app bar provides:

- **Writing insights**;
- previous spelling issue;
- next spelling issue;
- **Portable settings**;
- **Manage personal dictionary**, with a badge for saved words;
- **Clear ignored session words**, with a badge for ignored words;
- **About SpellChecker**.

The editor area provides:

- language selection;
- text entry;
- **Check spelling**;
- **Clear**;
- **Undo correction** when correction history is available;
- current suggestion-count information;
- word, character, and sentence statistics;
- storage/loading status where relevant.

## Start a spelling review

1. Enter or paste text.
2. Choose any of the thirteen built-in offline spelling packs from the language selector.
3. Select **Check spelling**, press `Ctrl+Enter`, or press `Command+Enter`.
4. Review inline underlines and the Results panel.

A blank input produces the dedicated **Nothing to check** state. A completed check with no unknown words produces a clean-result state.

The bundled UI captures at most the first 200 spelling issues. When another unknown word proves that more issues exist, the UI reports a limited/truncated result rather than implying that the captured set is complete.

## Language selection

Current built-ins are:

```text
English (US) — en-US
English (UK) — en-GB
Hindi (India) — hi-IN
Spanish (Spain) — es-ES
French (France) — fr-FR
German (Germany) — de-DE
Portuguese (Brazil) — pt-BR
Italian (Italy) — it-IT
Bengali (India) — bn-IN
Marathi (India) — mr-IN
Tamil (India) — ta-IN
Telugu (India) — te-IN
Russian (Russia) — ru-RU
```

`en-US` is the default.

SpellChecker does not auto-detect language. Change the language explicitly when the text uses another supported pack.

Language switching restores that language's saved:

- personal vocabulary;
- writing-rule override, if one exists.

It also creates a fresh language-specific spelling engine, clears stale session/correction state, and rechecks non-blank editor text.

Personal vocabulary and writing-rule choices are isolated by language. Saving a word or disabling a rule in `en-US` does not automatically change `en-GB`.

## Inline spelling highlighting

After a spelling check:

- unknown checked words receive a wavy underline;
- one issue is active and receives stronger visual treatment;
- navigating/activating an issue synchronizes the editor selection with its source range when possible.

Spelling issues belong to the exact text snapshot that was checked. Manual editing invalidates the previous snapshot and clears stale results instead of painting or correcting old ranges against changed text.

During an active input-method-editor composing range, Flutter's composing visualization takes priority so text composition remains usable.

## Navigate spelling issues

Use any of:

- `F7` — next issue;
- `Shift+F7` — previous issue;
- app-bar previous/next actions;
- Results-panel previous/next actions;
- an issue card.

Keyboard navigation wraps at both ends. The Results panel identifies the active issue position, such as **Issue 2 of 5**.

## Review suggestions

Each spelling issue can show:

- original unknown word;
- source position/range context;
- ranked suggestions;
- repeated-occurrence count when applicable;
- **Replace all…** when repeated represented occurrences have suggestions;
- **Save word**;
- **Ignore once**.

Suggestion count is configurable from 1 to 10. The default is 5.

## Replace one occurrence

Choose a suggestion for an issue. SpellChecker verifies that the issue's current source range still contains the same checked word, then applies the suggestion.

Common casing is preserved:

```text
helo  -> hello
Helo  -> Hello
HELO  -> HELLO
```

If the issue has become stale, SpellChecker refuses the unsafe mutation and refreshes results rather than applying to the wrong text.

## Replace all represented occurrences

When the same unknown word appears more than once in the captured spelling result:

1. choose **Replace all…**;
2. select a ranked suggestion;
3. SpellChecker applies the suggestion only to matching current `SpellIssue` ranges represented by the checked result;
4. each occurrence preserves its own common casing pattern;
5. edits are applied from the end of the document toward the beginning;
6. the whole operation becomes one correction-history entry.

This is not a raw global string replacement.

## Save a personal word

Choose **Save word** on a spelling issue to add the normalized word to the selected language's local personal dictionary.

When preference storage succeeds:

- the word is accepted in future sessions for that language;
- current spelling results are refreshed;
- the personal-dictionary badge updates.

If storage fails, SpellChecker rolls the in-memory save back and reports that the word could not be saved durably.

## Ignore a word for the session

Choose **Ignore once** to add the normalized word to the current engine's ignored-word set.

Ignored words:

- are accepted for the current session/engine;
- are not persisted;
- are not included in personal-dictionary exports;
- are not included in Portable settings.

Use the app-bar **Clear ignored session words** action to remove them. A language switch creates a fresh engine and therefore also clears the previous language engine's ignored state.

## Manage the personal dictionary

Open **Manage personal dictionary** from the app bar.

The dialog is language-specific and lets you:

- view saved normalized words;
- add one valid word;
- remove a word;
- clear all personal words for the selected language after confirmation;
- choose 1–10 suggestions per spelling issue;
- copy a language-aware personal-dictionary export;
- import supported personal-dictionary data.

Valid personal words can contain supported apostrophes and hyphens according to the selected language pack.

### Personal-dictionary export

Current UI exports use version 2 and include the language ID:

```json
{
  "version": 2,
  "language": "en-US",
  "words": [
    "spellchecker"
  ]
}
```

### Personal-dictionary import

The UI accepts supported versioned JSON, JSON arrays, and compatible plain line/comma word lists. Valid imported words are **merged** with existing personal vocabulary.

A version-2 dictionary for a different language is not merged into the current language. Switch to the document's language first.

See [Configuration](CONFIGURATION.md) for the complete format/validation contract.

# Writing insights

Open Writing insights from the app bar or press:

```text
Ctrl+Shift+Enter
Command+Shift+Enter
```

Writing insights currently runs the ten built-in English writing rules for `en-US` and `en-GB`. The eleven non-English spelling packs do not run those English-specific rules; they continue to provide local spelling, suggestions, and personal dictionaries.

## Current built-in rules

The current default registry contains ten rules:

```text
repeated-word
sentence-capitalization
repeated-space
punctuation-spacing
missing-punctuation-space
trailing-whitespace
repeated-punctuation
unmatched-parenthesis
unmatched-square-bracket
unmatched-curly-brace
```

The first seven can provide deterministic automatic replacements in their documented scope. The three unmatched-delimiter rules are advisory and never guess a mutation.

See [Writing rules](WRITING_RULES.md) for exact behavior.

## Rule switches

Writing insights displays supported rule switches. Toggling a rule changes the current review immediately and, when local storage succeeds, saves the selected language's explicit enabled-rule set.

Rule choices are separate for `en-US` and `en-GB`.

An explicit “all rules off” state is durable and different from **Reset rules to defaults**.

## Reset rules to defaults

Choose **Reset rules to defaults** to remove the selected language's explicit writing-rule override. Current built-in defaults then become active.

This is intentionally different from manually switching every rule off:

- all switches off -> explicit empty override;
- reset -> no override, follow current registry defaults.

If storage cannot clear the saved override, current-session defaults stay active but SpellChecker warns that the change may not survive restart.

## Review presets

Built-in presets are:

- **All findings**;
- **Mechanics**;
- **Clarity**;
- **Automatic fixes**.

Presets affect only the current review scope. They do not change persisted rule enablement.

## Search and filters

Writing insights provides **Search rules and findings**, category chips, and **Automatic fixes only**.

These filters are temporary. Closing the dialog discards them.

`Ctrl+F` / `Command+F` focuses the review search field.

Escape behavior is intentionally two-stage:

1. if search/category/automatic-fix filtering is active, Escape clears the transient review query and keeps the dialog open;
2. if that query is already empty, Escape closes the dialog through the normal result path.

## Findings

A writing finding can show:

- rule name;
- message;
- source range/original text;
- replacement when deterministic;
- severity/category-related review context;
- per-rule total metadata when available.

A finding with no replacement is advisory and does not show an automatic safe-fix action.

## Apply one safe writing fix

Choose **Apply safe fix** on a fixable finding. The editor validates that the finding's source range still equals the original analyzed text before mutation.

If the source is stale, the mutation is refused.

## Apply a batch of safe fixes

When automatic findings are available, Writing insights can return a batch to the editor.

Without review filters, the control applies all captured safe fixes. With filters active, the control applies only currently visible automatic findings.

The same correction engine is used in both cases. It:

- skips advisory findings;
- skips stale/invalid ranges;
- resolves overlaps deterministically by source ordering;
- applies accepted edits from document end to beginning;
- reports applied/skipped counts.

The editor records the complete accepted batch as one undoable correction.

## Large Writing insights results

The bundled dialog captures at most 200 writing findings. When more exist:

- the dialog identifies the limited result;
- `WritingAnalyzer` exact totals can show the complete count/per-rule totals;
- search/presets/categories/fix filtering operate only on captured findings;
- individual/batch correction operates only on captured findings;
- uncaptured findings are not reconstructed from total-count metadata.

The 200-finding limit bounds retained dialog/result objects; it is not a CPU-time or maximum-document-size guarantee because enabled rules still scan the supplied text to produce exact totals.

## Copy diagnostic summary

Choose **Copy diagnostic summary** to copy a deterministic metadata-only support report.

The summary can include:

- language ID;
- complete/limited state;
- capture limit;
- captured finding count;
- exact total/uncaptured count when available;
- per-rule captured/exact counts.

It excludes:

- editor text;
- finding excerpts;
- finding messages;
- replacements;
- source offsets;
- personal vocabulary;
- ignored words;
- correction history.

Copying happens only after you choose the control.

# Portable settings

Open **Portable settings** from the app bar after local preferences finish loading.

The dialog can copy a versioned preferences JSON document and import one.

Portable settings contains only:

- selected language;
- suggestion count;
- explicit per-language writing-rule overrides.

It does **not** contain personal vocabulary. Use the personal-dictionary workflow separately for vocabulary backup/transfer.

It also excludes editor text, ignored words, findings, correction history, and transient Writing insights filters/presets.

Import replaces the durable selected language, suggestion count, and complete set of explicit per-language writing-rule overrides represented by the document. Missing override keys mean that language returns to built-in defaults.

See [Configuration](CONFIGURATION.md) for exact JSON semantics.

# Undo corrections

Spelling and writing corrections share a bounded in-memory correction history. The current editor stores up to 20 pre-correction editing values.

A replace-all spelling operation or accepted writing-fix batch is pushed as one correction entry. **Undo correction** restores the preceding editing value and refreshes relevant result state.

Correction history is not document version control and is not durable across app restarts. Manual editing can start a new correction-history path.

# Text statistics

The editor reports:

- words;
- characters;
- sentences.

Character count uses Dart string length (UTF-16 code units). Word detection uses Unicode letter/combining-mark rules with supported apostrophe/hyphen forms. Sentence counting recognizes common terminal punctuation/closing quotes and counts a remaining non-empty trailing sentence fragment.

# Storage and startup

SpellChecker restores saved preferences asynchronously at startup. Controls that depend on durable settings can remain disabled while preferences load.

If preference loading fails, the application reports that saved dictionary preferences could not be loaded and continues with session-mode spelling functionality where possible.

If a write fails, the application marks storage unavailable and does not falsely report the change as durable.

Before clearing browser/site/application data, export personal vocabulary and copy Portable settings if you want backups.

# Responsive layout and accessibility

SpellChecker uses Material 3 and follows the system light/dark theme selection.

The UI includes focus traversal, semantics labels, and live-region announcements for important review/result states. Wide/narrow layouts keep both editor and results usable without changing the underlying workflow.

Keyboard shortcuts can be intercepted by a browser, operating system, assistive technology, or extension; visible controls remain available.

See [Accessibility](ACCESSIBILITY.md) and [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

# Privacy expectations

Editor text is analyzed locally in memory by the bundled spelling/writing implementation. SpellChecker does not require a network spelling API, grammar model, account, analytics SDK, or cloud synchronization.

Local durable preferences are limited to configuration/personal vocabulary described in [Configuration](CONFIGURATION.md). The application does not persist editor documents, findings, ignored words, or correction history as preferences.

See [Privacy](PRIVACY.md) and [Security](../SECURITY.md).

# Troubleshooting and support

If results look unexpected:

1. verify the selected language;
2. re-run the spelling check after editing;
3. reopen Writing insights after significant text/language/rule changes;
4. check whether a Writing insights filter/preset is active;
5. check for a limited first-200 result;
6. verify local storage warnings before assuming settings were saved;
7. use a minimal synthetic reproducer.

Read [Troubleshooting](TROUBLESHOOTING.md) and [Support](../SUPPORT.md) before opening a public issue. Do not post private documents when synthetic text is sufficient.

# Quick keyboard reference

| Action | Shortcut |
| --- | --- |
| Check spelling | `Ctrl+Enter` / `Command+Enter` |
| Open Writing insights | `Ctrl+Shift+Enter` / `Command+Shift+Enter` |
| Next spelling issue | `F7` |
| Previous spelling issue | `Shift+F7` |
| Focus Writing insights search | `Ctrl+F` / `Command+F` |
| Clear transient review query / close Writing insights | `Escape` |

For the compact reference and host-interception notes, see [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).
