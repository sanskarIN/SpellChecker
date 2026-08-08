# Core API

SpellChecker exposes reusable core functionality through:

```dart
import 'package:spellchecker/spell_checker.dart';
```

The public 1.x surface exports edit distance, spell checking, issue models, validated text correction, text statistics, and personal-dictionary import/export helpers. Application UI and storage types remain internal integration details unless explicitly exported.

## Language APIs

Language architecture is exported separately for clarity:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/spell_checker.dart';
```

`SpellLanguageRegistry.builtIns` contains the built-in packs and `defaultPack` remains `en-US`. Select a pack explicitly with `SpellCheckerEngine(languagePack: ...)`.

`SpellLanguagePack` carries language/region identity, dictionary data, frequency ranks, Unicode token/validation patterns, normalization, recognized suffixes, and suggestion-source metadata.

`SpellSuggestion` is returned by `suggestionDetailsFor()` and exposes the candidate, distance, frequency rank, language ID/display name, and source. `suggestionsFor()` remains the backward-compatible string-only API.

`SpellIssue.languageId` identifies the pack that produced an issue and remains optional for source compatibility.

See [LANGUAGE_PACKS.md](LANGUAGE_PACKS.md) for the complete language contract.

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

```dart
final issues = engine.check(
  'Helo world',
  suggestionLimit: 3,
);
```

Each occurrence is returned separately because source offsets are occurrence-specific. Callers must treat offsets as belonging to the exact text snapshot that was checked.

### `isCorrect`

```dart
bool isCorrect(String word)
```

Returns `true` when the normalized word is accepted by:

- The bundled or custom base dictionary.
- The current personal dictionary.
- The current ignored-word set.
- A supported regular apostrophe suffix whose stem is known.

Supported stem-based suffix recognition includes:

```text
n't
're
've
'll
'd
'm
's
```

### `suggestionsFor`

```dart
List<String> suggestionsFor(
  String word, {
  int limit = 5,
})
```

Returns close normalized replacement candidates. Candidate ordering is deterministic:

1. Damerau-Levenshtein edit distance.
2. First-character/prefix agreement.
3. Approximate word-frequency rank.
4. Candidate length.
5. Alphabetical order.

For supported apostrophe suffixes, matching can be performed on the stem and the suffix restored in output.

### Personal and ignored words

```dart
void addToPersonalDictionary(String word)
bool removeFromPersonalDictionary(String word)
void replacePersonalDictionary(Iterable<String> words)
void clearPersonalDictionary()
void ignoreWord(String word)
void clearIgnoredWords()
void resetSession()
Set<String> get personalDictionary
Set<String> get ignoredWords
```

The engine remains storage-agnostic. The Flutter application persists personal words separately and keeps ignored words session-only.

## `TextCorrection`

SpellChecker 1.2 exports validated text-mutation helpers so correction behavior can be reused without Flutter widgets.

### `replaceOne`

```dart
TextCorrectionResult TextCorrection.replaceOne(
  String text,
  SpellIssue issue,
  String suggestion,
)
```

The method replaces exactly one checked occurrence only when all of these remain true:

- `issue.start` is inside the current text.
- `issue.end` is inside the current text.
- The range is non-empty.
- `text.substring(issue.start, issue.end)` still equals `issue.word`.
- The suggestion is non-empty.

If the issue is stale or invalid, the returned result has `replacements == 0` and the original text is preserved.

Example:

```dart
final issue = engine.check('Helo world').first;
final result = TextCorrection.replaceOne(
  'Helo world',
  issue,
  'hello',
);

print(result.text); // Hello world
print(result.replacements); // 1
```

### `replaceAll`

```dart
TextCorrectionResult TextCorrection.replaceAll(
  String text,
  Iterable<SpellIssue> issues,
  String sourceWord,
  String suggestion,
)
```

Replaces every still-current checked issue whose source word matches `sourceWord` case-insensitively. Matching ranges are applied from the end of the document toward the beginning so earlier offsets remain valid while replacements can change string length.

Important contract details:

- Only occurrences represented by the supplied checked issue list are eligible.
- Stale or unrelated issue ranges are skipped.
- Case is matched independently for each original occurrence.
- `replacements` reports the number of actual mutations.
- A replace-all operation can be treated as one higher-level undoable edit by the caller.

### `matchCase`

```dart
String TextCorrection.matchCase(
  String original,
  String suggestion,
)
```

Preserves common capitalization patterns:

```text
helo  + hello -> hello
Helo  + hello -> Hello
HELO  + hello -> HELLO
```

### `TextCorrectionResult`

```dart
const TextCorrectionResult({
  required String text,
  required int caretOffset,
  required int replacements,
})
```

Fields:

- `text`: resulting document text.
- `caretOffset`: safe suggested caret position in the resulting text.
- `replacements`: number of mutations that were applied.

Convenience getter:

```dart
bool get changed
```

`changed` is `true` when `replacements > 0`.

### Language-aware dictionary documents

`PersonalDictionaryCodec.encodeForLanguage(words, languagePack: pack)` writes format version 2 with a `language` field. `decodeDocument()` returns a `PersonalDictionaryDocument` containing `version`, `languageId`, and normalized words.

Legacy `encode()` remains version-1-compatible. Version-1 objects, JSON arrays, and plain word lists inherit the caller/selected language because they contain no language metadata.

## `PersonalDictionaryCodec`

SpellChecker exports a versioned import/export helper.

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

Invalid entries or unsupported JSON versions throw `FormatException`.

### `normalizeWord`

```dart
String PersonalDictionaryCodec.normalizeWord(Object? value)
```

Returns a lowercase normalized word or an empty string for invalid input. Curly apostrophes are converted to straight apostrophes. Accepted word syntax supports letters with internal apostrophes or hyphens.

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

A fresh issue satisfies:

```dart
text.substring(issue.start, issue.end) == issue.word
```

Callers that mutate text must not assume old offsets remain current. `TextCorrection` performs this validation for correction operations.

## `damerauLevenshteinDistance`

```dart
int damerauLevenshteinDistance(String source, String target)
```

Returns the number of insertions, deletions, substitutions, and adjacent transpositions required to transform one string into the other under the implementation's distance model.

```dart
damerauLevenshteinDistance('spell', 'spell'); // 0
damerauLevenshteinDistance('spel', 'spell');  // 1
damerauLevenshteinDistance('teh', 'the');     // 1
```

## `TextStatistics`

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

## UI integration types

`SpellCheckEditingController` lives under `lib/features/editor/` and is not currently exported from the public package barrel. It extends `TextEditingController` and renders checked issues with inline styles while validating ranges against its current text.

Application-level behavior built on top of public core APIs includes:

- Active issue selection.
- F7 / Shift+F7 navigation.
- Ctrl/Command+Enter checking.
- Replace-all menus.
- A bounded correction undo stack.
- Results auto-scroll.
- Accessibility live regions and selected-state semantics.

These are UI integration contracts rather than public core API promises.

## Persistence boundary

`DictionaryPreferences` remains an application integration class under `lib/storage/`. It is intentionally not exported from `package:spellchecker/spell_checker.dart` because storage implementations may evolve independently from the reusable core.

The Flutter application persists:

- Personal words.
- Suggestion-count preference.

The Flutter application does not persist:

- Editor text.
- Ignored words.
- Checked issue lists.
- Active issue index.
- V1.2 correction undo snapshots.

## Writing rules API (2.0)

Import the writing subsystem with:

```dart
import 'package:spellchecker/writing.dart';
```

`WritingRule` defines stable ID/name/description/language eligibility plus a side-effect-free `analyze(text, languagePack)` contract. `WritingAnalyzer` runs supported/enabled rules and returns a sorted immutable `WritingAnalysisResult`.

`WritingIssue` carries rule identity, explanation, exact source range/original text, optional replacement, language ID, and severity.

`WritingCorrection.apply(text, issue)` applies a fix only when the current range still equals `issue.originalText`; otherwise it returns the unchanged text with `applied == false`.

See [WRITING_RULES.md](WRITING_RULES.md) for built-in rule behavior and plugin requirements.

## Stability

The names exported by `lib/spell_checker.dart` are the intended reusable core surface for version 1.x. Internal files under `lib/features/`, `lib/data/`, and `lib/storage/` can evolve more freely as long as documented user behavior remains compatible or the release notes identify changes.
