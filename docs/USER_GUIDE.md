# User Guide


## V2.14 unmatched square bracket workflow

Writing insights includes **Unmatched square bracket** under Mechanics. It reports literal `[` or `]` characters that cannot be paired and is enabled by current defaults. The finding is advisory: there is no automatic replacement because the intended correction may be insertion, deletion, movement, or rewriting. **Automatic fixes only** hides it, while other safe fixes can still be applied. Explicit older rule choices remain unchanged until you enable the rule or use **Reset rules to defaults**.

## V2.13 unmatched parenthesis findings

Writing insights can now report an opening or closing parenthesis that has no matching pair. The finding is advisory: SpellChecker highlights the unmatched character but does not offer **Apply safe fix** because it cannot know whether you intended to insert a partner, delete the character, or rewrite the surrounding text. **Automatic fixes only** hides these findings. You can disable the rule per language like other writing rules.

## V2.12 user note

Writing insights now includes **Missing punctuation space**. For English (US) and English (UK), it can offer a safe fix when a comma, semicolon, exclamation mark, or question mark sits directly before the next word, such as `Hello,world`. The fix inserts one following space. Periods and colons are intentionally not covered. Existing explicit rule choices remain unchanged until the user resets or edits them; an unset/reset language uses the current seven-rule defaults.
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
- **Portable settings** app-bar action.
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

Manual typing invalidates the previous spelling snapshot, so old highlights/results are cleared instead of being painted against changed text. While an input method editor (IME) has an active composing range, Flutter's native composing visualization takes priority over custom spelling highlights so composition remains visible; checked issue styling resumes after composition is committed.

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
- **Copy diagnostic summary** beside the Findings heading for a privacy-safe metadata-only support snapshot.

## Copy diagnostic summary — V2.9

Select **Copy diagnostic summary** in Writing insights when you need reproducible analysis metadata for a bug report, performance investigation, or support discussion. The explicit action copies the deterministic `WritingAnalysisDiagnosticSummary.toPlainText()` output to the local clipboard.

The copied text includes language ID, complete/limited state, capture limit, captured/exact/uncaptured counts when available, and captured/exact per-rule counts. It excludes editor text, source excerpts, finding messages, replacements, and source offsets. The copy occurs only after you select the control; SpellChecker does not automatically place diagnostics on the clipboard or upload them.

## Review search and filters — V2.2

Writing insights can narrow the current review without changing your saved rule choices:

- **Search rules and findings** searches rule metadata plus visible finding text/replacement metadata.
- **Mechanics** and **Clarity** chips filter rules/findings by category.
- **Automatic fixes only** hides advisory findings that have no deterministic replacement.
- **Clear review filters** restores the full enabled-rule review.
- Rule and finding headers show visible/total counts.

These review filters are temporary. Closing the dialog clears them; they are not saved locally and do not travel between languages.

When any filter is active, the batch button reads **Apply visible safe fixes (N)** and applies only currently visible automatic findings using the same V2.1 stale/overlap safety and one-step undo behavior.

## Reset rules to defaults — V2.2

Use **Reset rules to defaults** when you want the selected language to follow the application's built-in default rule set again.

This is different from manually turning every current rule on. Reset removes the saved per-language override key. After a successful reset, future releases can change built-in defaults and that language can receive the new defaults normally.

If local storage cannot clear the override, current-session defaults still become active and SpellChecker reports the persistence problem; the old saved override may return after restart until storage succeeds.

## Review presets — V2.3

Above the V2.2 category controls, Writing insights provides **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes** presets. A preset changes category/automatic-fix review scope but keeps the current free-text search. You can then adjust category chips/toggle manually for a custom temporary combination.

Preset/search/category/automatic-fix state is never saved. Closing the dialog resets that review state; per-language rule switches remain the durable preference.

# Portable settings — V2.3

Select **Portable settings** in the app bar.

### Copy

The dialog shows the current durable selected language, suggestion count, explicit override-language count, and a deterministic JSON document. Choose **Copy settings JSON** to place that JSON on the local clipboard.

### Import

Paste a `spellchecker-settings` version-1 JSON document and choose **Import settings**. A successful import replaces:

- Selected language.
- Suggestion count.
- Complete set of explicit per-language writing-rule overrides.

A missing language in `writingRuleOverrides` means that language returns to built-in defaults. A present empty list means all writing rules are explicitly disabled for that language.

Portable settings do **not** contain personal words or editor text. Existing target-language personal vocabulary remains available after import, and current editor text remains unchanged. The editor clears stale checked/finding/undo state and rechecks non-blank text under the imported language.

If local storage fails mid-import, SpellChecker reports that the import failed and attempts to restore the previous durable portable settings. Because local preference storage is not transactional, restoration is best effort.


## Built-in writing rules

Current rules:

- **Repeated word** — adjacent duplicate words.
- **Sentence capitalization** — lowercase supported sentence starts.
- **Repeated spaces** — repeated interior horizontal spaces.
- **Punctuation spacing** — horizontal whitespace immediately before supported punctuation.
- **Trailing whitespace** — horizontal whitespace before line endings or document end.
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

# Large documents and limited spelling results — V2.5

SpellChecker can accept long editor text, but the built-in Results panel intentionally captures at most the first 200 spelling issues per check.

If more unknown words exist, the badge shows **200+** and the Results panel explains that later issues were not captured. Inline underlines and F7/Shift+F7 navigation then cover the captured issues only.

You can still:

- Apply a single suggestion.
- Save a captured word to the personal dictionary.
- Ignore a captured word for the current session.
- Re-run spelling after edits.

**Replace all** is intentionally unavailable while results are limited. A partial checked issue list does not contain every matching source range, so presenting a partial mutation as “all” would be misleading. Work on a smaller section or apply single fixes, then check again.

A result that happens to contain exactly 200 issues is not automatically labeled limited. The `200+` state appears only after SpellChecker proves that another unknown word exists.

## V2.6 punctuation and trailing-whitespace checks

Writing insights includes **Punctuation spacing** and **Trailing whitespace** for English (US) and English (UK). Punctuation spacing removes spaces/tabs immediately before common punctuation such as commas, periods, colons, semicolons, question marks, and exclamation marks. Trailing whitespace removes spaces/tabs at line endings or at the end of the document without removing newline characters.

Both are normal per-language writing-rule switches. If you have never customized rule choices, they are enabled with the current defaults. If you previously saved an explicit rule list, SpellChecker preserves that list instead of silently adding new rules; use **Reset rules to defaults** if you want the current complete default catalogue.

## V2.7 large-document Writing insights

Writing insights captures at most 200 findings in the built-in editor. If more findings exist, the dialog shows a limited-result notice and a `200+`-style count rather than presenting the captured count as the complete document total.

When analysis is limited, search, review presets, Mechanics/Clarity filters, and Automatic fixes only operate on the captured findings. The dialog says this explicitly. A filtered empty state means no **captured** finding matched; it does not claim later uncaptured findings were searched.

Batch buttons also use captured wording in the limited state: **Apply captured safe fixes** when no review filter is active and **Apply visible captured safe fixes** when filters are active. The same stale-source and overlap safety rules apply, and one Undo restores the entire accepted batch.

The 200-finding policy is not a maximum document size. Rules still analyse the supplied text so SpellChecker can retain the correct earliest findings in review order.

## V2.8 exact Writing insights totals

When Writing insights has more findings than its built-in 200-finding capture limit, V2.8 can show the exact relationship between the retained review set and all findings observed during the local analysis.

For example:

```text
Showing the first 200 of 1437 findings in review order.
1237 additional findings are not retained by the 200-finding capture limit.
```

The findings badge can display `200/1437`, meaning 200 findings are retained for review while 1,437 findings were observed in total.

### Per-rule totals

Enabled rule rows can also show `Total findings: N`. This is the exact number of findings produced by that enabled/supported rule during the current analysis, even when only some of those findings fit in the retained 200-finding review set.

A rule's total is informational. It is not a button and does not mean all of that rule's findings are currently available for correction.

### Filters and fixes remain captured-only

Search, review presets, category filters, automatic-fixes-only review, individual safe fixes, and batch safe fixes still operate on retained findings when analysis is limited.

Exact totals do not cause SpellChecker to reconstruct or modify findings that were not retained. This preserves the same stale-range and batch-correction safety contract as V2.7.

If filters hide every retained finding while the analysis is limited, the empty state reports the exact uncaptured quantity, for example:

```text
17 uncaptured findings were not searched.
```

### Re-run after editing or changing language

Diagnostics describe one analysis snapshot. After changing editor text, language, or enabled writing rules, reopen/re-run Writing insights to obtain current totals. Do not treat an old total as describing the modified document.

## V2.10 developer benchmark note

V2.10's large-document benchmark is repository developer tooling, not an editor feature. Regular SpellChecker use does not require running it and no benchmark control appears in the application UI. Maintainers/contributors who need controlled synthetic performance comparisons should use `tool/benchmark_large_document.dart` and the dedicated [V2.10 benchmark guide](V2_10_BENCHMARK.md). The command does not read the current editor document.

## V2.11 keyboard-first Writing insights review

Open Writing insights with the app-bar action or `Ctrl/Command+Shift+Enter`. While the dialog is open:

- Press `Ctrl+F` (or `Command+F`) to move directly to **Search rules and findings**.
- If review search, category filters, or **Automatic fixes only** is active, press Escape once to clear those temporary filters and keep the dialog open.
- Press Escape when no temporary review filter is active to close Writing insights.

After the first Escape clears filters, focus returns to review search so you can type a new query immediately. Enabled writing-rule switches are separate persistent per-language settings and are not cleared by this shortcut.

Rule and finding count changes are exposed as live accessibility state. For limited analysis, the announcement distinguishes visible findings from the captured prefix and exact total when available. Filters and fixes still operate only on captured findings; live totals do not authorize fixes to uncaptured content.
