# User Guide

## Opening SpellChecker

Run the Flutter application and open the SpellChecker editor.

The main screen contains:

- Editor panel.
- Check spelling button.
- Clear button.
- Word/character/sentence statistics.
- Current suggestion-count chip.
- Results panel.
- Personal-dictionary action with a saved-word badge.
- Clear-ignored-words action with a session-ignore badge.
- About action.

## Check text

1. Type or paste text into the Editor panel.
2. Select **Check spelling**.
3. Review the Results panel.

Each unknown occurrence shows:

- Original word.
- Character position.
- Ranked suggestions when available.
- **Save word** action.
- **Ignore once** action.

## Replace a word

Select a suggestion chip under an issue. SpellChecker replaces only that checked occurrence and then runs the check again.

Replacement preserves common capitalization patterns:

- `helo` → `hello`
- `Helo` → `Hello`
- `HELO` → `HELLO`

For supported apostrophe suffixes, the engine can calculate a suggestion from the stem and restore the suffix, such as `helo's` → `hello's` when appropriate.

## Save a personal word

Select **Save word** when a legitimate word is missing from the bundled dictionary.

SpellChecker V1.1:

1. Normalizes the word.
2. Adds it to the engine's personal dictionary.
3. Saves the complete personal dictionary through local application preferences.
4. Runs the spelling check again.

Saved personal words survive normal application restarts on the same device/browser profile.

If persistence fails, the editor restores the previous in-memory personal dictionary and reports the failure instead of pretending that the word was saved.

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

The preference is saved locally and restored on future launches. If text has already been checked, changing the value refreshes the current results.

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

Select **Clear** to empty the editor and reset displayed results/statistics.

This does not remove personal dictionary entries, ignored session words, or preferences.

## Statistics

SpellChecker displays:

- Word count.
- Character count.
- Sentence count.

These are lightweight writing statistics rather than full linguistic analysis.

## Contractions and possessives

V1.1 can recognize many regular apostrophe forms from known stems, including suffixes such as:

```text
n't
're
've
'll
'd
'm
's
```

This improves common forms such as `teacher's`, `we're`, and `couldn't`. Irregular forms may still depend on direct dictionary coverage.

## Privacy

Spelling analysis runs locally. Editor text is not persisted by SpellChecker.

V1.1 stores only:

- Saved personal words.
- Suggestion-count preference.

Ignored words remain memory-only. No analytics, advertising, authentication, telemetry, or cloud spelling API is included.

See [PRIVACY.md](PRIVACY.md) for details.

## Dictionary limitations

V1.1 expands the bundled English vocabulary but it is still not a complete linguistic database. Correct uncommon words can still be reported as unknown.

You can save legitimate vocabulary locally or contribute curated dictionary improvements to the project.

SpellChecker does not currently provide grammar checking, automatic language detection, or cloud synchronization.
