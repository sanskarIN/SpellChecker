# Architecture

## Goals

SpellChecker is designed around five goals:

1. Keep spelling logic independent from Flutter widgets.
2. Keep user text local by default.
3. Keep the dependency surface small.
4. Make core behavior deterministic and testable.
5. Leave clear extension points for better dictionaries and future language packs.

## Layers

### Presentation layer

Location: `lib/features/editor/`

`spell_checker_page.dart` owns the current editor workflow:

- Accept text input.
- Calculate local text statistics.
- Request a spelling check.
- Display issues and ranked suggestions.
- Replace a selected occurrence.
- Add a word to the session dictionary.
- Ignore a word for the session.
- Reset session-specific words.

The UI does not implement edit distance or dictionary matching itself.

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
- Produce `SpellIssue` objects with source offsets.
- Rank suggestions.
- Manage in-memory session dictionary state.

#### `SpellIssue`

Immutable value object containing:

- Original source word.
- Start character offset.
- End character offset.
- Ranked suggestions.

#### Edit distance

`damerauLevenshteinDistance` supports insertion, deletion, substitution, and adjacent transposition. Adjacent transposition is important for common typing errors such as `teh` → `the`.

#### Text statistics

`TextStatistics` calculates:

- Character count.
- Word count.
- Sentence count.

### Data layer

Location: `lib/data/`

`EnglishDictionary.words` is a bundled starter word set. It is intentionally represented as plain Dart data so the engine has no file I/O or network requirement.

## Public library surface

`lib/spell_checker.dart` exports the reusable core APIs. Consumers should prefer importing:

```dart
import 'package:spellchecker/spell_checker.dart';
```

rather than internal files when they only need core spelling behavior.

## Data flow

```text
User text
   │
   ▼
SpellCheckerPage
   │
   ├── TextStatistics.fromText
   │
   └── SpellCheckerEngine.check
           │
           ├── Tokenize
           ├── Normalize
           ├── Dictionary lookup
           └── Suggestion ranking
                   │
                   ▼
              List<SpellIssue>
                   │
                   ▼
             Results panel
```

## Tokenization

Current tokenization uses:

```text
[A-Za-z]+(?:['’-][A-Za-z]+)*
```

This supports plain Latin alphabet words plus internal apostrophes and hyphens. Numbers and most punctuation are not treated as spell-checkable words.

This is intentionally English-focused. Multilingual tokenization should be implemented as a separate language-aware abstraction instead of stretching this expression indefinitely.

## Suggestion ranking

For an unknown normalized word:

1. Select a maximum edit distance based on input length.
2. Skip dictionary candidates whose length difference already exceeds the threshold.
3. Compute Damerau-Levenshtein distance.
4. Prefer smaller distance.
5. Prefer matching first letters when distances tie.
6. Prefer shorter candidates when still tied.
7. Use alphabetic order as the final stable tie-breaker.
8. Cache computed candidate lists for repeated checks.

The cache is cleared when the personal dictionary changes.

## Session dictionaries

Two mutable sets exist inside an engine instance:

- Personal dictionary: words explicitly accepted by the user.
- Ignored words: words temporarily excluded from checking.

Both are in-memory only in version 1.0.

## Replacement safety

The UI stores source offsets from the most recent check. Before replacing text, it verifies that:

- The offsets are valid for the current text.
- The text at those offsets still matches the issue word.

If either check fails, the UI performs a fresh spelling check instead of applying a stale replacement.

## Extension points

Future features should preserve layer separation.

Recommended additions:

- `DictionaryRepository` abstraction for persistent dictionaries.
- Language-aware tokenizers.
- Language-pack registry.
- Frequency data for stronger suggestion ranking.
- Persistent user preferences.
- Import/export for personal dictionaries.
- Highlighted rich-text editor implementation.

## Non-goals in version 1.0

Version 1.0 does not attempt to provide:

- Grammar checking.
- Cloud AI rewriting.
- Automatic language detection.
- Persistent personal dictionaries.
- Full linguistic morphology.
- Production-scale dictionary coverage.
