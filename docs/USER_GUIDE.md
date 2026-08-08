# User Guide

## Opening SpellChecker

Run the Flutter application and open the SpellChecker editor.

The main screen contains:

- Editor panel.
- Check spelling button.
- Clear button.
- Undo correction button.
- Word/character/sentence statistics.
- Current suggestion-count chip.
- Results panel.
- Previous/next issue controls.
- Personal-dictionary action with a saved-word badge.
- Clear-ignored-words action with a session-ignore badge.
- About action.

## Choose a language

Use the language dropdown above the editor. Version 1.3 includes **English (US)** and **English (UK)**.

The selected language is saved locally. Switching language re-checks non-blank text with the new dictionary and starts a separate temporary ignored-word state.

Examples:

```text
English (US): color
English (UK): colour
```

Saved personal words are per-language. A US personal word is not automatically accepted in UK mode. Version-2 dictionary exports include their language; switch to the matching language before importing a tagged export.

SpellChecker does not auto-detect language in V1.3.

## Writing insights

Select **Writing insights** in the app bar when you want optional local writing-rule feedback. The dialog shows supported rules for the selected language and lets you switch each rule on/off for the current session.

V2.0 built-ins:

- Repeated word.
- Sentence capitalization.
- Repeated spaces.
- Repeated punctuation.

Findings show rule name, message, source range, original text, and a suggested replacement when available. Select **Apply safe fix** to close the dialog and apply that one validated fix.

A writing fix enters the same **Undo correction** history used by spelling corrections. If the document changed after analysis, the safe fix is refused and the dialog should be reopened to refresh findings.

Rule switches are intentionally not persisted in V2.0.

## Check text

1. Type or paste text into the Editor panel.
2. Select **Check spelling**, press `Ctrl+Enter`, or press `⌘+Enter`.
3. Review inline underlines and the Results panel.

Each unknown checked occurrence is underlined inside the editable text and also appears in Results with:

- Original word.
- Character position.
- Ranked suggestions when available.
- Occurrence count when the same unknown word appears repeatedly.
- **Replace all…** when repeated occurrences and suggestions are available.
- **Save word** action.
- **Ignore once** action.

If the editor is empty, checking shows **Nothing to check** instead of treating a blank document as a successful spelling result.

## Inline highlighting

After a spelling check:

- Unknown checked words receive a wavy underline in the editor.
- One issue is active and receives stronger visual styling.
- Selecting an issue card or navigating issues selects the corresponding source range in the editor.

Manual typing invalidates the previous check. SpellChecker clears old inline issue styling/results immediately rather than leaving stale highlights attached to changed text.

## Navigate spelling issues

Use any of these methods:

- `F7` — next issue.
- `Shift+F7` — previous issue.
- App-bar previous/next issue buttons.
- Results-header previous/next buttons.
- Select an issue card.

Navigation wraps at the beginning/end of the issue list.

The Results header displays **Issue X of Y**. When possible, the active result card automatically scrolls into view.

## Replace one word

Select a suggestion chip under an issue. SpellChecker replaces only that checked occurrence and then runs the check again.

Replacement preserves common capitalization patterns:

- `helo` → `hello`
- `Helo` → `Hello`
- `HELO` → `HELLO`

For supported apostrophe suffixes, the engine can calculate a suggestion from the stem and restore the suffix, such as `helo's` → `hello's` when appropriate.

Before any replacement, SpellChecker verifies that the checked source range still contains the same issue word. If the text changed after checking, results are refreshed instead of applying a stale edit.

## Replace all repeated occurrences

When the same unknown word appears in more than one checked occurrence, the issue card shows an occurrence-count chip and **Replace all…**.

1. Select **Replace all…**.
2. Choose one of the ranked suggestions.
3. SpellChecker replaces every current checked occurrence of that same unknown word.
4. Each occurrence preserves its own capitalization pattern.
5. The entire replace-all operation becomes one spelling-correction undo step.

Only occurrences represented by the current checked issue list are replaced. SpellChecker does not perform an unrestricted string search across unvalidated text.

## Undo a spelling correction

After a successful single or replace-all correction:

- A snackbar displays an **Undo** action.
- **Undo correction** becomes available below the editor.

Selecting either control restores the document snapshot from immediately before the most recent spelling correction and runs the spelling check again.

SpellChecker keeps a bounded in-memory history of spelling corrections (currently up to 20 entries). Manual user text editing clears this spelling-specific correction stack so old programmatic edits are not mixed into a new manual editing sequence.

This correction history is not saved across application restarts.

## Save a personal word

Select **Save word** when a legitimate word is missing from the bundled dictionary.

SpellChecker:

1. Normalizes the word.
2. Adds it to the engine's personal dictionary.
3. Saves the complete personal dictionary through local application preferences.
4. Runs the spelling check again.

Saved personal words survive normal application restarts on the same device/browser profile.

If persistence fails, the editor restores the previous in-memory personal dictionary and reports the failure instead of pretending that the word was saved.

## Local storage warning

If saved preferences cannot be loaded or written, SpellChecker displays a warning explaining that local dictionary storage is unavailable.

Session spelling continues to work. However, personal-word/preference changes may not persist until platform storage becomes available again.

The warning does not mean editor text was uploaded or moved elsewhere.

## Ignore once

Select **Ignore once** for temporary names, codes, or vocabulary that should not be saved permanently.

Ignored words:

- Stop being reported during the active application session.
- Are not written to persistent preferences.
- Can be cleared independently from saved personal words.

## Clear ignored session words

Select the visibility/ignored-words action in the app bar.

This clears only temporary ignored words. It does not delete:

- Editor text.
- Saved personal dictionary entries.
- Suggestion-count preference.
- Correction undo history.

## Manage the personal dictionary

Select **Manage personal dictionary** in the app bar.

The dialog lets you:

- View saved personal words.
- Add a word manually.
- Remove one saved word.
- Clear all saved words after confirmation.
- Choose 1–10 suggestions per spelling issue.
- Import personal vocabulary.
- Copy a dictionary export to the clipboard.

The saved-word count is displayed as a badge on the dictionary action when the personal dictionary is not empty.

## Suggestion-count preference

Use the dropdown inside **Personal dictionary** to choose between 1 and 10 suggestions per issue.

The preference is saved locally and restored on future launches. If text has already been checked, changing the value refreshes current results and inline issue data.

## Import personal words

Select **Import** in the personal-dictionary manager and paste one of these forms.

### SpellChecker JSON

```json
{
  "version": 1,
  "words": [
    "flutter",
    "open-source"
  ]
}
```

### JSON array

```json
["flutter", "open-source"]
```

### Plain text

```text
flutter
open-source
writer's
```

Commas can also separate plain-text entries.

Imported words are merged with existing saved words. Duplicates are removed. Words are normalized to lowercase and curly apostrophes are converted to straight apostrophes.

Invalid entries produce an error instead of being silently stored.

## Export personal words

Select **Copy export**.

SpellChecker copies a versioned JSON document to the clipboard. The export is:

- Alphabetically sorted.
- Lowercase-normalized.
- Deduplicated.
- Suitable for importing into another SpellChecker installation/profile.

The application does not upload the export anywhere.

## Clear text

Select **Clear** to empty the editor and reset displayed results/statistics/highlights.

This does not remove personal dictionary entries, ignored session words, or saved preferences. Clearing the document also clears the spelling-specific correction undo stack because the current document history has been discarded.

## Statistics

SpellChecker displays:

- Word count.
- Character count.
- Sentence count.

These are lightweight writing statistics rather than full linguistic analysis.

## Contractions and possessives

SpellChecker recognizes many regular apostrophe forms from known stems, including:

```text
n't
're
've
'll
'd
'm
's
```

This improves forms such as `teacher's`, `we're`, and `couldn't`. Irregular forms may still depend on direct dictionary coverage.

## Accessibility and keyboard use

V1.2 uses standard Flutter controls plus explicit semantics for important editor/result states.

- Issue cards expose issue number, total count, word, character range, and selected state.
- Result counts and important empty/warning states are semantic live regions.
- Icon-only controls have tooltips.
- Keyboard navigation is available without pointer-only interaction.
- Inline underline color is supplementary; Results text and semantic labels communicate the issue independently.

See [ACCESSIBILITY.md](ACCESSIBILITY.md) for the full checklist.

## Privacy

Spelling analysis runs locally. Editor text is not persisted by SpellChecker.

Persisted data remains limited to:

- Saved personal words.
- Suggestion-count preference.

Memory-only session data includes:

- Ignored words.
- Checked issue list.
- Active issue state.
- Correction undo snapshots.

No analytics, advertising, authentication, telemetry, or cloud spelling API is included.

See [PRIVACY.md](PRIVACY.md) for details.

## Dictionary limitations

The bundled English vocabulary is intentionally curated rather than a complete linguistic database. Correct uncommon words can still be reported as unknown.

You can save legitimate vocabulary locally or contribute curated dictionary improvements to the project.

SpellChecker does not currently provide grammar checking, automatic language detection, cloud synchronization, or multi-language selection. Language architecture is planned for V1.3.
