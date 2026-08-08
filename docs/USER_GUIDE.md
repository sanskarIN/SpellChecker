# User Guide

## Opening SpellChecker

Run the Flutter application and open the SpellChecker editor.

The main screen contains:

- Editor panel.
- Explicit language selector.
- **Check spelling** button.
- **Clear** button.
- **Undo correction** button when correction history exists.
- Word/character/sentence statistics.
- Current suggestion-count chip.
- Results panel.
- Previous/next spelling-issue controls.
- **Writing insights** app-bar action.
- Personal-dictionary action with a saved-word badge.
- Clear-ignored-words action with a session-ignore badge.
- About action.

## Choose a language

Use the compact language dropdown in the Editor header. Current built-ins are:

```text
English (US) — en-US
English (UK) — en-GB
```

The selected language is saved locally and restored on later launches.

Changing language:

1. Loads that language's saved personal words.
2. Loads that language's saved writing-rule choices.
3. Builds a fresh language-specific spelling engine/session state.
4. Clears stale issue/correction/session state.
5. Re-checks non-blank editor text with the selected pack.

Common variant example:

```text
English (US): color
English (UK): colour
```

Personal vocabulary and writing-rule choices are isolated by language. A US personal word or disabled rule does not automatically affect UK mode.

SpellChecker does not auto-detect language.

## Check spelling

1. Type or paste text into the editor.
2. Select **Check spelling**, press `Ctrl+Enter`, or press `⌘+Enter`.
3. Review inline underlines and the Results panel.

Each unknown checked occurrence can show:

- Original word.
- Character position.
- Ranked suggestions.
- Occurrence count when the same unknown word repeats.
- **Replace all…** for repeated checked occurrences with suggestions.
- **Save word**.
- **Ignore once**.

Blank input shows **Nothing to check**.

## Inline highlighting

After a spelling check:

- Unknown checked words receive a wavy underline.
- One spelling issue is active and receives stronger styling.
- Selecting/navigating an issue selects its source range in the editor.

Manual typing invalidates the previous spelling snapshot, so old highlights/results are cleared instead of being painted against changed text.

## Navigate spelling issues

Available controls:

- `F7` — next spelling issue.
- `Shift+F7` — previous spelling issue.
- App-bar previous/next buttons.
- Results-header previous/next buttons.
- Select an issue card.

Navigation wraps at both ends. The Results header shows **Issue X of Y**, and the active card scrolls into view when possible.

## Replace one spelling issue

Select a suggestion chip under an issue.

SpellChecker replaces only that checked occurrence and preserves common casing patterns:

```text
helo  -> hello
Helo  -> Hello
HELO  -> HELLO
```

Before mutation, SpellChecker verifies that the checked source range still contains the same issue word. If the source is stale, results are refreshed instead of applying the edit.

## Replace all spelling occurrences

When the same unknown word appears in multiple checked occurrences:

1. Select **Replace all…**.
2. Choose a ranked suggestion.
3. SpellChecker applies the suggestion only to matching occurrences represented by the current checked issue list.
4. Each occurrence preserves its own casing pattern.
5. Replacements are applied from the document end toward the beginning for source-offset safety.
6. The entire operation becomes one correction-history entry.

This is not an unrestricted string-replace operation.

# Writing insights

Open Writing insights by either:

- Selecting the app-bar **Writing insights** action.
- Pressing `Ctrl+Shift+Enter`.
- Pressing `⌘+Shift+Enter` on macOS keyboards.

The dialog displays:

- Selected language.
- A local-only writing-analysis notice.
- Supported rule switches.
- Finding count.
- Finding cards with rule name, message, source range, and original text.
- Suggested replacement for deterministic fixes.
- **Apply safe fix** on individually fixable findings.
- **Apply all safe fixes (N)** when at least one automatic fix is available.

## Built-in writing rules

Current rules:

- **Repeated word** — adjacent duplicate words.
- **Sentence capitalization** — lowercase supported sentence starts.
- **Repeated spaces** — repeated horizontal spaces.
- **Repeated punctuation** — repeated identical supported punctuation.

These are deterministic local helpers, not a full grammar parser.

## Writing-rule preferences — V2.1

Rule switches are stored locally per language.

This means:

- Turning off **Repeated spaces** in English (US) is restored the next time `en-US` is used.
- English (UK) retains its own independent rule choices.
- Disabling every rule is a real persisted choice.
- A user upgrading from V2.0 who has never configured rules receives the current built-in default rule set.

A switch changes the current session immediately. If local storage is unavailable, the current choice stays active for the session but may not survive restart; SpellChecker reports the persistence failure.

## Apply one writing safe fix

Select **Apply safe fix** for a finding with a deterministic replacement.

Before mutation, SpellChecker verifies that the current source range still exactly matches the text that produced the finding. A stale finding is refused and the user should reopen Writing insights for fresh analysis.

A successful writing fix enters the same bounded **Undo correction** history as spelling corrections.

## Apply all safe writing fixes — V2.1

When automatic fixes exist, select **Apply all safe fixes (N)**.

SpellChecker then:

1. Orders candidate findings deterministically by source start, end, then rule ID.
2. Skips findings without an automatic replacement.
3. Skips stale/invalid findings.
4. If two automatic fixes overlap, keeps the earliest deterministic candidate and skips later overlaps.
5. Applies accepted replacements from the end of the document toward the beginning.
6. Reports how many fixes were applied and how many findings were skipped.
7. Stores the complete batch as **one** undo entry.

One **Undo correction** therefore restores the document exactly to its state before the batch.

## Why some findings are skipped in a batch

A skipped finding does not mean the application silently failed. It means the finding was not safe for the batch under the V2.1 contract.

Common reasons:

- Advisory-only finding.
- Text changed since analysis.
- Invalid source range.
- Overlap with an earlier accepted fix.

Reopen Writing insights after the batch if you want to analyse the resulting text again.

# Correction undo

After a successful spelling or writing correction:

- A snackbar can expose **Undo**.
- **Undo correction** becomes available below the editor.

The correction history is bounded (currently 20 entries) and memory-only.

One history entry is created for:

- One spelling replacement.
- One spelling replace-all.
- One individual writing safe fix.
- One Writing insights batch safe-fix operation.

Manual typing clears the programmatic correction stack because the document has entered a new manual editing sequence.

Correction history is not saved across application restarts.

# Personal vocabulary

## Save a personal word

Select **Save word** when a legitimate word is missing from the selected bundled dictionary.

SpellChecker:

1. Normalizes the word using the selected language pack.
2. Adds it to the current engine personal dictionary.
3. Saves the language-specific complete personal-word set locally.
4. Re-runs the spelling check.

If persistence fails, SpellChecker restores the previous in-memory personal dictionary rather than claiming the save succeeded.

## Ignore once

Use **Ignore once** for a temporary name/code/word that should not be saved.

Ignored words:

- Are session-only.
- Are not persisted.
- Belong to the current language engine/session.
- Can be cleared independently from personal vocabulary.

## Clear ignored session words

Use the dedicated app-bar action.

This does not delete:

- Editor text.
- Personal dictionary entries.
- Suggestion-count preference.
- Writing-rule preferences.

# Personal dictionary manager

Select **Manage personal dictionary**.

The dialog is language-qualified and allows you to:

- View saved words for the selected language.
- Add a word manually.
- Remove one saved word.
- Clear all saved words for that language after confirmation.
- Select 1–10 suggestions per spelling issue.
- Import vocabulary.
- Copy a dictionary export.

## Suggestion-count preference

The selected 1–10 suggestion count is stored locally and restored later. Changing it refreshes current spelling results when text has already been checked.

## Import personal words

### Version-2 language-aware SpellChecker JSON

```json
{
  "version": 2,
  "language": "en-US",
  "words": [
    "flutter",
    "open-source"
  ]
}
```

A tagged export must match a supported language context; the application does not silently reinterpret another language's tagged dictionary.

### Legacy version-1 SpellChecker JSON

```json
{
  "version": 1,
  "words": [
    "flutter",
    "open-source"
  ]
}
```

Version-1 objects contain no language metadata, so imported words use the currently selected language.

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

Imported words are normalized through the relevant language pack, merged with existing saved words, and deduplicated. Invalid entries are rejected instead of stored silently.

## Export personal words

Select **Copy export**.

SpellChecker copies versioned JSON to the local clipboard. Current application exports include language identity, normalized sorted words, and no surrounding editor text.

Nothing is uploaded by SpellChecker during export.

# Clear text

Select **Clear** to empty editor text and reset displayed spelling/results/statistics/highlights.

This does not remove:

- Saved language selection.
- Personal dictionary entries.
- Suggestion-count preference.
- Writing-rule preferences.

It does clear the current correction history because the document itself has been discarded.

# Statistics

SpellChecker displays lightweight:

- Word count.
- Character count.
- Sentence count.

These are not a full linguistic parser.

# Contractions and possessives

Current English packs recognize several regular apostrophe suffixes from known stems:

```text
n't
're
've
'll
'd
'm
's
```

Irregular forms may still depend on direct dictionary coverage.

# Local storage warning

If local preferences cannot be loaded/written, SpellChecker displays a warning.

Session spelling and writing analysis remain local and usable. The warning means settings may not persist; it does not mean editor text was uploaded or transferred elsewhere.

# Accessibility and keyboard use

SpellChecker uses standard Material controls plus explicit semantics for important editor/result/finding states.

- Icon-only controls have tooltips.
- Issue cards expose issue position/range and selected state.
- Result counts and important empty/warning states use semantic live regions.
- Writing findings expose rule/message semantics.
- **Apply all safe fixes (N)** includes a visible count.
- Keyboard workflows supplement normal pointer/touch controls.
- Inline underline/color/badges are not the sole communication mechanism.

Keyboard shortcuts:

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Check spelling |
| `⌘+Enter` | Check spelling on macOS |
| `Ctrl+Shift+Enter` | Open Writing insights |
| `⌘+Shift+Enter` | Open Writing insights on macOS |
| `F7` | Next spelling issue |
| `Shift+F7` | Previous spelling issue |

See [ACCESSIBILITY.md](ACCESSIBILITY.md).

# Privacy

Runtime spelling and writing analysis remains local.

Persisted application preferences are limited to:

- Selected language ID.
- Personal words per language.
- Suggestion count.
- Enabled writing-rule IDs per language.

SpellChecker does **not** persist:

- Editor documents.
- Writing findings or messages.
- Finding source excerpts.
- Checked spelling issues.
- Ignored words.
- Correction undo snapshots.

No cloud spelling/grammar API, analytics, advertising, account system, telemetry, or remote document logging is included.

See [PRIVACY.md](PRIVACY.md).

# Limitations

The bundled dictionaries and writing rules are intentionally curated/deterministic rather than complete linguistic databases.

SpellChecker currently does not provide:

- Full grammar parsing.
- AI prose rewriting.
- Automatic language detection.
- Cloud synchronization.
- Account-backed preferences.
- Background document monitoring.
- Untrusted dynamic rule plugins.

See [ROADMAP.md](ROADMAP.md) for future direction.
