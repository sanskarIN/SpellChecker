# Architecture

## Goals

SpellChecker is designed around seven goals:

1. Keep spelling logic independent from Flutter widgets.
2. Keep correction mutation logic reusable and offset-safe.
3. Keep user text local by default.
4. Keep persistence explicit and limited to user-controlled preferences.
5. Keep the runtime dependency surface small.
6. Make core behavior deterministic and testable.
7. Preserve clear extension points for richer editor behavior and future language packs.

## Layers

### Presentation layer

Location: `lib/features/editor/`

#### `spell_checker_page.dart`

Owns the complete editor interaction state:

- Accept text input.
- Calculate local text statistics.
- Request checks with the configured suggestion limit.
- Synchronize checked issues with inline highlights.
- Track an active issue index.
- Move active issue forward/backward with buttons or shortcuts.
- Select the active issue range in the editor.
- Display ranked suggestions and issue occurrence counts.
- Replace one checked occurrence.
- Replace all checked occurrences of the same word.
- Maintain a bounded spelling-correction undo stack.
- Persist personal words.
- Ignore words for the current session.
- Surface preference-storage failures without disabling session spelling.
- Open the personal-dictionary manager.

#### `spell_check_editing_controller.dart`

Extends `TextEditingController` and owns inline visual rendering of checked issues.

Responsibilities:

- Keep an immutable checked issue list.
- Keep the active issue index.
- Build a styled `TextSpan` for the current editor text.
- Apply wavy underlines to valid current issue ranges.
- Apply stronger background/text styling to the active issue.
- Ignore stale, overlapping, or invalid ranges instead of throwing.
- Clear all issue styling when manual text changes invalidate checked results.

The controller does not perform spelling checks or corrections.

#### `dictionary_manager_dialog.dart`

Owns user-facing dictionary/preferences management:

- Add/remove/clear saved personal words.
- Import vocabulary.
- Copy a versioned dictionary export.
- Change the persisted suggestion count.
- Surface storage errors without silently committing local state.

The presentation layer delegates spelling, distance, normalization, correction safety, and import/export validation to core types.

### Application shell

Locations:

- `lib/main.dart`
- `lib/app.dart`

`main.dart` initializes Flutter and starts `SpellCheckerApp`. `app.dart` defines Material 3 themes and selects the editor page.

### Core layer

Location: `lib/core/`

#### `SpellCheckerEngine`

Responsibilities:

- Tokenize English-style words.
- Normalize case and curly apostrophes.
- Check base, personal, and ignored dictionaries.
- Recognize supported regular apostrophe suffixes from known stems.
- Produce `SpellIssue` objects with source offsets.
- Rank and cache suggestions.
- Manage engine-local personal and ignored-word sets.

The engine has no Flutter storage or widget dependency.

#### `TextCorrection`

V1.2 centralizes source-offset-safe text mutation.

Responsibilities:

- Validate that a `SpellIssue` still identifies the same current source text.
- Replace one issue with case preservation.
- Replace all current checked occurrences of the same word.
- Apply replace-all mutations from the end of the document toward the beginning.
- Return resulting text, caret position, and replacement count.
- Refuse stale corrections without partially mutating text.

This class intentionally does not own undo history. It returns deterministic results so the application can decide how to group edits for undo.

#### `PersonalDictionaryCodec`

Responsibilities:

- Normalize user dictionary entries.
- Encode a stable versioned JSON representation.
- Decode SpellChecker JSON, JSON arrays, and plain word lists.
- Reject malformed entries and unsupported format versions.

#### `SpellIssue`

Immutable value object containing:

- Original source word.
- Start character offset.
- End character offset.
- Ranked suggestions.

Issue offsets are valid only for the checked text snapshot.

#### Edit distance

`damerauLevenshteinDistance` supports insertion, deletion, substitution, and adjacent transposition.

#### Text statistics

`TextStatistics` calculates:

- Character count.
- Word count.
- Sentence count.

### Writing-rules layer

Locations: `lib/writing/` and `lib/writing.dart`.

`WritingRule` plugins analyse text without side effects. `WritingAnalyzer` chooses rules by language eligibility and enabled-rule IDs, combines findings, and sorts them deterministically. `WritingCorrection` is the only reusable automatic-fix mutation primitive and validates stale source ranges before changing text.

The editor's Writing insights dialog is presentation-only: it displays supported rules/findings and returns a selected issue to the page. The page then validates/applies the fix and stores the pre-fix `TextEditingValue` in the existing bounded correction stack. Rule switches remain session-only.

This layer deliberately has no storage/network dependency.

### Language layer

Location: `lib/core/spell_language_pack.dart` plus language-specific data under `lib/data/`.

`SpellLanguagePack` is the boundary between language-independent engine/editor behavior and language-specific tokenization, normalization, dictionaries, suffix rules, frequency metadata, and suggestion source labels.

`SpellLanguageRegistry` currently supplies `en-US` and `en-GB`. The editor stores one selected pack ID and constructs a fresh engine when the selection changes, which clears temporary ignored/suggestion-cache state and loads only that pack's personal words.

Built-in English packs use Unicode letter-property tokenization, normalize curly apostrophes/common Unicode hyphens, and deliberately differ on common US/UK spellings.

Detailed suggestions carry pack identity through `SpellSuggestion`; issues carry optional `languageId`.

### Data layer

Location: `lib/data/`

Bundled English data is split into:

- `english_dictionary.dart`: original base vocabulary.
- `english_dictionary_extension.dart`: expanded curated V1.1 vocabulary.
- `english_word_frequencies.dart`: compact approximate frequency ranks used as a deterministic suggestion tie-breaker.

The engine loads these as in-memory Dart data and performs no runtime file/network reads.

### Persistence layer

Location: `lib/storage/`

`DictionaryPreferences` uses Flutter `shared_preferences` to persist only:

- Personal dictionary words.
- Suggestion-count preference.

It deliberately does not persist:

- Editor text.
- Checked issue lists.
- Active issue index.
- Ignored words.
- Suggestion cache state.
- V1.2 correction undo history.

Storage keys are versioned so future migrations can be explicit.

## Public library surface

`lib/spell_checker.dart` exports reusable core APIs:

```dart
import 'package:spellchecker/spell_checker.dart';
```

V1.2 adds `TextCorrection` and `TextCorrectionResult` to this public core surface. UI controllers and persistence adapters remain internal integration types.

## Startup flow

```text
Application startup
   │
   ▼
DictionaryPreferences
   ├── saved personal words
   └── suggestion-count preference
          │
          ▼
SpellCheckerPage ─────► SpellCheckerEngine.replacePersonalDictionary
          │
          ▼
Ready editor state
```

If preference restoration fails, the page records storage as unavailable, displays a visible/semantic warning, and still permits local session spelling.

## Spelling-check flow

```text
Editor text
   │
   ├────────────► TextStatistics.fromText
   │
   └────────────► SpellCheckerEngine.check
                        │
                        ├── tokenize
                        ├── normalize
                        ├── dictionary lookup
                        ├── suffix recognition
                        └── suggestion ranking
                                │
                                ▼
                           List<SpellIssue>
                             │         │
                             │         └────► Results panel
                             │
                             └──────────────► SpellCheckEditingController
                                                │
                                                └── inline issue spans
```

The page chooses an active issue after each check. When a preferred source offset is available (for example after a correction), it selects the first issue at or after that offset, falling back to the final remaining issue.

## Active issue navigation

V1.2 treats the active issue as shared presentation state.

Navigation inputs include:

- `F7`: next issue.
- `Shift+F7`: previous issue.
- App-bar previous/next controls.
- Results-header previous/next controls.
- Selecting an issue card.

Changing the active issue:

1. Updates `_activeIssueIndex`.
2. Updates the editing controller's active issue style.
3. Selects that source range in the editor.
4. Requests editor focus.
5. Allows the Results panel to scroll the active card into view using `Scrollable.ensureVisible`.

Navigation wraps at both ends.

## Keyboard spelling check

`CallbackShortcuts` maps:

- `Ctrl+Enter` to spelling check.
- `Command+Enter` to spelling check.

The shortcut layer wraps the page so checking remains available while keyboard focus is within the editor workflow.

## Single correction flow

```text
Suggestion selected
   │
   ▼
TextCorrection.replaceOne
   │
   ├── validate source range
   ├── match capitalization
   └── return TextCorrectionResult
           │
           ├── unchanged ──► refresh check (stale issue)
           │
           └── changed
                 │
                 ├── push old TextEditingValue to correction undo stack
                 ├── apply new TextEditingValue
                 └── re-check around returned caret offset
```

## Replace-all flow

Replace-all is offered only when the checked issue list contains more than one case-insensitive occurrence of the same unknown word and the issue has suggestions.

```text
Replace all with <suggestion>
   │
   ▼
TextCorrection.replaceAll
   │
   ├── filter same-word current issues
   ├── validate each current range
   ├── sort ranges descending by start offset
   ├── case-match each occurrence
   └── produce one resulting text value
           │
           ▼
one correction undo entry
```

Because mutations proceed from the document end backward, earlier issue offsets are not invalidated by a later replacement that changes length.

## Correction undo model

The page keeps a bounded list of `TextEditingValue` snapshots for spelling corrections only. The current maximum is 20 entries.

Properties:

- Single replacement pushes one pre-correction snapshot.
- Replace-all pushes one pre-bulk-replacement snapshot.
- Snackbar **Undo** and toolbar **Undo correction** restore the latest snapshot.
- Restoring a snapshot triggers a new spelling check and chooses an issue near the restored caret.
- Manual user text input clears this spelling-specific stack to avoid mixing stale programmatic corrections with a new manual editing sequence.
- The stack is not persisted.

This is intentionally narrower than a full document-editor history system.

## Inline highlight safety

`SpellCheckEditingController.buildTextSpan` validates every issue against its current text before styling it. Invalid or stale ranges are skipped.

Manual text edits call `clearIssues()` immediately, so highlights from an old check do not remain painted against changed text.

## Language switch flow

```text
Language selector
   │
   ├── load per-language personal words
   ├── persist selected language ID
   ├── construct SpellCheckerEngine(selected pack)
   ├── restore only selected-pack personal words
   ├── clear correction/highlight/ignored session state
   └── re-check non-blank editor text
```

A failed preference read/write surfaces storage-unavailable state but does not introduce a remote fallback or prevent session spelling.

Legacy `spellchecker.personal_words.v1` values are interpreted as `en-US` and migrated to the V2 US namespace on first load.

## Tokenization

Current tokenization uses:

```text
[A-Za-z]+(?:['’-][A-Za-z]+)*
```

This supports Latin alphabet words plus internal apostrophes and hyphens. V1.3 is reserved for language-aware Unicode tokenization rather than indefinitely extending this English-specific expression.

## Suggestion ranking

For an unknown normalized target:

1. Select maximum edit distance based on target length.
2. Skip candidates whose length difference already exceeds the threshold.
3. Compute Damerau-Levenshtein distance.
4. Prefer smaller distance.
5. Prefer first-character agreement.
6. Prefer lower approximate frequency rank.
7. Prefer shorter candidates.
8. Use alphabetical order as final deterministic tie-breaker.
9. Cache the complete candidate list.

The cache is cleared whenever personal vocabulary changes.

## Personal versus ignored words

- **Personal words** are persisted through `shared_preferences` and restored on later launches.
- **Ignored words** are temporary exceptions held only by the active engine instance.

The UI uses `clearIgnoredWords()` for temporary reset behavior rather than clearing saved personal vocabulary.

## Import/export boundary

The versioned dictionary codec belongs to the core layer because its format is reusable without Flutter. Clipboard interaction belongs to the presentation layer.

Import merges decoded words with the existing saved set. Export serializes a normalized, deduplicated, alphabetically sorted set.

## Accessibility state model

V1.2 adds semantics around the same active/result state rather than maintaining a second accessibility-only state model.

- The editor semantic label explains that checked issues are underlined.
- Result count uses a live region.
- Empty/clean states use live regions.
- Storage failure warning uses a live region.
- Each issue tile is a semantic container with issue position, word, character range, and selected state.
- Keyboard controls provide non-pointer navigation.

Visual underlines, active background color, and badges are supplementary rather than the sole communication channel.

## Current extension points

V1.3 can build language abstractions around:

- Tokenization.
- Normalization.
- Dictionary selection.
- Frequency metadata.
- Language-specific suggestion behavior.

The editor should consume language-selected `SpellIssue` values without duplicating language logic in widgets.

## Non-goals in version 1.2

V1.2 does not attempt to provide:

- Full document history beyond spelling-correction undo.
- Grammar checking.
- Cloud AI rewriting.
- Automatic language detection.
- Cloud dictionary synchronization.
- Account-backed preferences.
- Full linguistic morphology.
- Production-scale dictionary coverage comparable to a dedicated linguistic database.
