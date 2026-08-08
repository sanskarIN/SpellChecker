# Architecture

## Goals

SpellChecker is designed around six goals:

1. Keep spelling logic independent from Flutter widgets.
2. Keep user text local by default.
3. Keep persistence explicit and limited to user-controlled preferences.
4. Keep the dependency surface small.
5. Make core behavior deterministic and testable.
6. Leave clear extension points for richer editor and language-pack work.

## Layers

### Presentation layer

Location: `lib/features/editor/`

`spell_checker_page.dart` owns the editor workflow:

- Accept text input.
- Calculate local text statistics.
- Request a spelling check with the configured suggestion limit.
- Display issues and ranked suggestions.
- Replace a selected occurrence safely.
- Persist a personal word.
- Ignore a word for the current session.
- Clear session-only ignored words.
- Open the personal-dictionary manager.

`dictionary_manager_dialog.dart` owns user-facing dictionary/preferences management:

- Add/remove/clear saved personal words.
- Import vocabulary.
- Copy a versioned dictionary export.
- Change the persisted suggestion count.
- Surface storage errors without mutating engine state silently.

The presentation layer does not implement edit distance or dictionary ranking.

### Application shell

Locations:

- `lib/main.dart`
- `lib/app.dart`

`main.dart` initializes Flutter and starts `SpellCheckerApp`. `app.dart` defines Material 3 themes and selects the editor page.

### Core spelling layer

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

The engine has no dependency on Flutter storage APIs. Persistence is injected from the application layer by restoring personal words into the engine.

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

#### Edit distance

`damerauLevenshteinDistance` supports insertion, deletion, substitution, and adjacent transposition. Adjacent transposition covers common typing errors such as `teh` → `the`.

#### Text statistics

`TextStatistics` calculates:

- Character count.
- Word count.
- Sentence count.

### Data layer

Location: `lib/data/`

The bundled English data is split into:

- `english_dictionary.dart`: original base vocabulary.
- `english_dictionary_extension.dart`: expanded curated V1.1 vocabulary.
- `english_word_frequencies.dart`: compact approximate frequency ranks used as a deterministic suggestion tie-breaker.

The engine loads these as in-memory Dart data and does not perform runtime file or network reads.

### Persistence layer

Location: `lib/storage/`

`DictionaryPreferences` uses Flutter `shared_preferences` to persist only:

- Personal dictionary words.
- Suggestion-count preference.

It deliberately does not persist:

- Editor text.
- Spelling results.
- Ignored words.
- Suggestion cache state.

The storage keys are versioned so future migrations can be explicit.

## Public library surface

`lib/spell_checker.dart` exports reusable core APIs. Consumers should prefer:

```dart
import 'package:spellchecker/spell_checker.dart';
```

The persistence implementation is application-internal and is not currently exported as part of the stable core API.

## Data flow

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
          │ user text
          ▼
TextStatistics.fromText
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
                                      │
                                      ▼
                                Results panel
```

Saving a personal word follows a separate durability-first path:

```text
Save word
   │
   ├── update engine candidate set
   ├── write normalized set to DictionaryPreferences
   └── on storage failure, restore the previous engine set
```

Dictionary-manager changes write preferences before replacing the editor engine's personal set.

## Tokenization

Current tokenization uses:

```text
[A-Za-z]+(?:['’-][A-Za-z]+)*
```

This supports Latin alphabet words plus internal apostrophes and hyphens. Numbers and most punctuation are not spell-checkable tokens.

The tokenizer remains intentionally English-focused. V1.3 is reserved for language-aware Unicode tokenization rather than extending this expression indefinitely.

## Contraction and possessive handling

After direct dictionary lookup fails, the engine can recognize a known stem with these suffixes:

```text
n't
're
've
'll
'd
'm
's
```

This handles many regular forms without requiring a duplicate dictionary entry for every contraction or possessive. Irregular forms may still exist directly in the dictionary.

When an unknown word contains a recognized suffix, suggestion matching is performed against the stem and the suffix is restored in the output candidate.

## Suggestion ranking

For an unknown normalized target:

1. Select a maximum edit distance based on target length.
2. Skip candidates whose length difference already exceeds the threshold.
3. Compute Damerau-Levenshtein distance.
4. Prefer smaller distance.
5. Prefer first-character agreement when distance ties.
6. Prefer lower approximate frequency rank.
7. Prefer shorter candidates when still tied.
8. Use alphabetical order as the final deterministic tie-breaker.
9. Cache the complete candidate list for repeated checks.

The suggestion cache is cleared whenever the personal dictionary changes.

## Personal versus ignored words

SpellChecker V1.1 intentionally separates two concepts:

- **Personal words** are user-approved vocabulary persisted through `shared_preferences` and restored on later launches.
- **Ignored words** are temporary exceptions held only by the active engine instance.

Clearing ignored words does not delete the persistent personal dictionary.

The public `resetSession()` engine method still clears both mutable engine sets for callers that explicitly want a full in-memory reset. The Flutter UI uses `clearIgnoredWords()` for its temporary reset action.

## Import/export boundary

The versioned dictionary codec belongs to the core layer because its format is reusable without Flutter widgets or storage. Clipboard interaction belongs to the presentation layer.

Import merges decoded words with the existing saved set. Export serializes a normalized, deduplicated, alphabetically sorted set.

## Replacement safety

The UI stores source offsets from the most recent check. Before replacing text, it verifies that:

- Offsets are valid for the current text.
- Text at those offsets still matches the issue word.

If either check fails, the editor performs a fresh spelling check instead of applying a stale replacement.

## Current extension points

V1.2 should preserve these layer boundaries while adding editor behavior such as:

- Inline issue highlighting.
- Keyboard issue navigation.
- Replace-all.
- Undo-friendly edit operations.
- Stronger accessibility semantics.

V1.3 can then add language abstractions around tokenization, normalization, and dictionary selection.

## Non-goals in version 1.1

Version 1.1 does not attempt to provide:

- Grammar checking.
- Cloud AI rewriting.
- Automatic language detection.
- Cloud dictionary synchronization.
- Account-backed preferences.
- Full linguistic morphology.
- Production-scale dictionary coverage comparable to a dedicated linguistic database.
