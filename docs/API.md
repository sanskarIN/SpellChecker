# Core API

SpellChecker exposes reusable core functionality through:

```dart
import 'package:spellchecker/spell_checker.dart';
```

The public 1.x surface currently exports edit distance, spell checking, issue models, text statistics, and personal-dictionary import/export helpers. Application storage under `lib/storage/` is intentionally not part of the public core API.

## `SpellCheckerEngine`

Create an engine with the bundled dictionaries and default frequency data:

```dart
final engine = SpellCheckerEngine();
```

Create an engine with a custom dictionary:

```dart
final engine = SpellCheckerEngine(
  dictionary: <String>{'hello', 'world', 'example'},
);
```

Create an engine with custom suggestion-frequency ranks:

```dart
final engine = SpellCheckerEngine(
  dictionary: <String>{'cat', 'cut'},
  wordFrequencies: <String, int>{
    'cut': 1,
    'cat': 100,
  },
);
```

Lower frequency-rank numbers are preferred when candidates are otherwise equivalent. Dictionary entries are normalized to lowercase when the engine is created.

### `check`

```dart
List<SpellIssue> check(
  String text, {
  int suggestionLimit = 5,
})
```

Checks supported English-style word tokens and returns unknown occurrences in source order.

Example:

```dart
final issues = engine.check(
  'Helo world',
  suggestionLimit: 3,
);
```

Each occurrence is returned separately because source offsets are occurrence-specific.

### `isCorrect`

```dart
bool isCorrect(String word)
```

Returns `true` when the normalized word is accepted by:

- The bundled or custom base dictionary.
- The current personal dictionary.
- The current ignored-word set.
- A supported regular apostrophe suffix whose stem is known.

Supported stem-based suffix recognition currently includes:

```text
n't
're
've
'll
'd
'm
's
```

This improves handling for forms such as `teacher's`, `we're`, and `couldn't`. Irregular forms can still be included directly in a dictionary.

### `suggestionsFor`

```dart
List<String> suggestionsFor(
  String word, {
  int limit = 5,
})
```

Returns close normalized replacement candidates. The method returns an empty list when:

- `limit <= 0`.
- The normalized input is empty.
- The word is already accepted.
- No candidate falls inside the current edit-distance threshold.

Suggestion candidates are ordered by:

1. Damerau-Levenshtein edit distance.
2. First-character/prefix agreement.
3. Approximate word-frequency rank.
4. Candidate length.
5. Alphabetical order.

For supported apostrophe suffixes, suggestions are calculated from the stem and the suffix is added back to candidate output. For example, an unknown `helo's` can produce `hello's` when `hello` is known.

### `addToPersonalDictionary`

```dart
void addToPersonalDictionary(String word)
```

Adds a normalized word to the engine's personal dictionary.

The core engine itself is storage-agnostic. The Flutter application persists this set separately through `DictionaryPreferences` in `lib/storage/`.

### `removeFromPersonalDictionary`

```dart
bool removeFromPersonalDictionary(String word)
```

Removes a normalized personal word and returns whether an entry was removed. The suggestion cache is invalidated when the set changes.

### `replacePersonalDictionary`

```dart
void replacePersonalDictionary(Iterable<String> words)
```

Replaces the full personal dictionary with normalized entries. The application uses this when restoring persisted words or applying an imported dictionary.

### `clearPersonalDictionary`

```dart
void clearPersonalDictionary()
```

Clears personal words from the engine instance and invalidates cached suggestions.

### `ignoreWord`

```dart
void ignoreWord(String word)
```

Adds a normalized word to the in-memory ignore set.

### `clearIgnoredWords`

```dart
void clearIgnoredWords()
```

Clears only ignored words. It does not remove personal dictionary entries.

### `resetSession`

```dart
void resetSession()
```

Clears personal words, ignored words, and suggestion cache state from the engine instance. Applications that persist personal words should generally use `clearIgnoredWords()` when they only intend to reset temporary ignores.

### Read-only sets

```dart
Set<String> get personalDictionary
Set<String> get ignoredWords
```

Returned sets are unmodifiable snapshots/views intended for inspection.

## `PersonalDictionaryCodec`

SpellChecker 1.1 exports a versioned import/export helper.

### `encode`

```dart
String PersonalDictionaryCodec.encode(Iterable<String> words)
```

Returns sorted, normalized, indented JSON:

```json
{
  "version": 1,
  "words": [
    "flutter",
    "open-source"
  ]
}
```

### `decode`

```dart
Set<String> PersonalDictionaryCodec.decode(String source)
```

Accepted input forms:

- SpellChecker JSON object containing `version` and `words`.
- JSON array of words.
- Plain text separated by line breaks and/or commas.

The decoder removes duplicates and normalizes accepted words. Invalid entries or unsupported JSON versions throw `FormatException`.

### `normalizeWord`

```dart
String PersonalDictionaryCodec.normalizeWord(Object? value)
```

Returns a lowercase normalized word or an empty string for invalid input. Curly apostrophes are converted to straight apostrophes. Current accepted word syntax supports letters with internal apostrophes or hyphens.

## `SpellIssue`

```dart
const SpellIssue({
  required String word,
  required int start,
  required int end,
  List<String> suggestions = const <String>[],
})
```

Fields:

- `word`: exact source spelling.
- `start`: zero-based inclusive source offset.
- `end`: zero-based exclusive source offset.
- `suggestions`: ranked replacement candidates.

The source occurrence is equivalent to:

```dart
text.substring(issue.start, issue.end)
```

when the text has not changed since the check.

## `damerauLevenshteinDistance`

```dart
int damerauLevenshteinDistance(String source, String target)
```

Returns the number of insertions, deletions, substitutions, and adjacent transpositions required to transform one string into the other under the implementation's distance model.

Examples:

```dart
damerauLevenshteinDistance('spell', 'spell'); // 0
damerauLevenshteinDistance('spel', 'spell');  // 1
damerauLevenshteinDistance('teh', 'the');     // 1
```

## `TextStatistics`

Create statistics from text:

```dart
final stats = TextStatistics.fromText('Hello world.');
```

Fields:

```dart
stats.characters
stats.words
stats.sentences
```

Character count uses Dart string length. Word counting uses the current English-style token pattern.

## Persistence boundary

`DictionaryPreferences` is an application integration class under `lib/storage/`. It is not exported from `package:spellchecker/spell_checker.dart` because storage implementations may evolve independently from the reusable spelling engine.

The current Flutter application persists:

- Personal words.
- Suggestion-count preference.

Ignored words and editor text are not persisted by SpellChecker.

## Stability

The exported names in `lib/spell_checker.dart` are the intended public core surface for version 1.x. Internal files under `lib/features/`, `lib/data/`, and `lib/storage/` may evolve more freely.
