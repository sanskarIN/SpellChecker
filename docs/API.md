# Core API

SpellChecker exposes reusable core functionality through:

```dart
import 'package:spellchecker/spell_checker.dart';
```

## `SpellCheckerEngine`

Create an engine with the bundled dictionary:

```dart
final engine = SpellCheckerEngine();
```

Create an engine with a custom dictionary:

```dart
final engine = SpellCheckerEngine(
  dictionary: {'hello', 'world', 'example'},
);
```

Dictionary entries are normalized to lowercase when the engine is created.

### `check`

```dart
List<SpellIssue> check(String text, {int suggestionLimit = 5})
```

Checks every supported word token and returns unknown occurrences in source order.

Example:

```dart
final issues = engine.check('Helo world');
```

Each occurrence is returned separately because source offsets are occurrence-specific.

### `isCorrect`

```dart
bool isCorrect(String word)
```

Returns true when the normalized word exists in:

- The base dictionary.
- The personal dictionary.
- The ignored-word set.

### `suggestionsFor`

```dart
List<String> suggestionsFor(String word, {int limit = 5})
```

Returns ranked close matches. The method returns an empty list when:

- `limit <= 0`.
- The normalized input is empty.
- The word is already accepted.
- No candidate falls within the current edit-distance threshold.

### `addToPersonalDictionary`

```dart
void addToPersonalDictionary(String word)
```

Adds a normalized word to the in-memory personal dictionary for the lifetime of the engine instance.

### `ignoreWord`

```dart
void ignoreWord(String word)
```

Adds a normalized word to the in-memory ignore set.

### `resetSession`

```dart
void resetSession()
```

Clears personal and ignored words and clears the suggestion cache.

### Read-only session sets

```dart
Set<String> get personalDictionary
Set<String> get ignoredWords
```

Returned sets are unmodifiable snapshots/views intended for inspection.

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
- `suggestions`: ranked normalized replacement candidates.

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

Character count uses Dart string length. Word counting uses the same English-style token pattern as the current editor statistics implementation.

## Stability

The exported names in `lib/spell_checker.dart` are the intended public core surface for version 1.x. Internal files under `lib/features/` and `lib/data/` may evolve more freely.
