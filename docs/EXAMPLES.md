# Library Examples

These examples use the public SpellChecker Dart barrels. They are intentionally small and synthetic so they can be copied into tests, command-line experiments, or Flutter integration code without exposing private documents.

## Imports

Core spelling/correction APIs:

```dart
import 'package:spellchecker/spell_checker.dart';
```

Language-pack APIs:

```dart
import 'package:spellchecker/language.dart';
```

Writing APIs:

```dart
import 'package:spellchecker/writing.dart';
```

For examples that combine language and writing APIs, import both `language.dart` and `writing.dart`.

## Basic spelling check

```dart
import 'package:spellchecker/spell_checker.dart';

void main() {
  final engine = SpellCheckerEngine();
  final issues = engine.check('Helo world');

  for (final issue in issues) {
    print('Unknown: ${issue.word}');
    print('Range: ${issue.start}-${issue.end}');
    print('Suggestions: ${issue.suggestions.join(', ')}');
  }
}
```

`check()` is the compatibility list-returning API and performs an unbounded scan.

## Bounded spelling analysis

Use `analyze()` when you need capture limits and scan metadata:

```dart
final engine = SpellCheckerEngine();
final report = engine.analyze(
  'Zorbax Qwertyx anotherword',
  suggestionLimit: 5,
  maxIssues: 2,
);

print('Captured: ${report.capturedIssueCount}');
print('Scanned tokens: ${report.scannedTokenCount}');
print('Truncated: ${report.truncated}');
print('Complete: ${report.complete}');
```

A report is marked truncated only after at least one additional unknown word is observed beyond the capture limit.

## Select English (UK)

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);

print(engine.isCorrect('colour'));
```

Use `SpellLanguageRegistry.byId('en-GB')` when resolving a persisted/configured ID.

## Check a single word

```dart
final engine = SpellCheckerEngine();

if (!engine.isCorrect('helo')) {
  print(engine.suggestionsFor('helo'));
}
```

## Read detailed suggestion metadata

```dart
final suggestions = SpellCheckerEngine().suggestionDetailsFor(
  'helo',
  limit: 5,
);

for (final suggestion in suggestions) {
  print(
    '${suggestion.word} '
    'distance=${suggestion.distance} '
    'rank=${suggestion.frequencyRank} '
    'language=${suggestion.languageId} '
    'source=${suggestion.source}',
  );
}
```

## Personal dictionary in memory

```dart
final engine = SpellCheckerEngine();
engine.addToPersonalDictionary('Zorbax');

print(engine.isCorrect('Zorbax')); // true
print(engine.personalDictionary);  // immutable snapshot
```

Replace the complete in-memory set:

```dart
engine.replacePersonalDictionary(<String>{
  'Flutter',
  'SpellChecker',
});
```

The engine normalizes and validates words using its active language pack.

## Ignored session words

```dart
final engine = SpellCheckerEngine();
engine.ignoreWord('Zorbax');

print(engine.isCorrect('Zorbax')); // true for this engine/session
print(engine.ignoredWords);

engine.clearIgnoredWords();
```

Ignored words are not persistent by themselves. Persistence belongs to the application/storage layer, not `SpellCheckerEngine`.

## Export a language-aware personal dictionary

```dart
final json = PersonalDictionaryCodec.encodeForLanguage(
  <String>{'Flutter', 'SpellChecker'},
  languagePack: SpellLanguageRegistry.englishUs,
);

print(json);
```

Decode and inspect metadata:

```dart
final document = PersonalDictionaryCodec.decodeDocument(json);

print(document.version);    // 2
print(document.languageId); // en-US
print(document.words);
```

## Decode legacy personal dictionary input

The codec can read plain line/comma input, JSON arrays, and supported JSON object versions:

```dart
final words = PersonalDictionaryCodec.decode(
  'Flutter\nSpellChecker,OpenAI',
  languagePack: SpellLanguageRegistry.englishUs,
);
```

Malformed/invalid entries raise `FormatException` rather than being silently accepted.

## Portable settings document

```dart
final document = SpellCheckerSettingsDocument(
  languageId: 'en-US',
  suggestionLimit: 5,
  writingRuleOverrides: <String, Iterable<String>>{
    'en-US': <String>{
      'repeated-word',
      'sentence-capitalization',
    },
  },
);

final json = SpellCheckerSettingsCodec.encode(document);
print(json);
```

Decode:

```dart
final decoded = SpellCheckerSettingsCodec.decode(json);
print(decoded.languageId);
print(decoded.suggestionLimit);
print(decoded.writingRuleIdsFor('en-US'));
```

Portable settings contain preferences only; they do not carry editor text or personal vocabulary.

## Text statistics

```dart
final stats = TextStatistics.fromText(
  'Hello world! This is another sentence',
);

print('Words: ${stats.words}');
print('Characters: ${stats.characters}');
print('Sentences: ${stats.sentences}');
```

## Replace one spelling issue safely

```dart
final text = 'Helo world';
final issue = SpellCheckerEngine().check(text).first;
final result = TextCorrection.replaceOne(text, issue, 'hello');

print(result.text);         // Hello world
print(result.replacements); // 1
print(result.changed);      // true
```

`TextCorrection.replaceOne` verifies that the issue range still matches `issue.word`. If the source is stale or the suggestion is empty, it returns an unchanged result.

## Replace all represented spelling occurrences

```dart
final text = 'Helo world. HELO again.';
final issues = SpellCheckerEngine().check(text);

final result = TextCorrection.replaceAll(
  text,
  issues,
  'Helo',
  'hello',
);

print(result.text); // Hello world. HELLO again.
```

Replace-all is constrained to matching current `SpellIssue` ranges supplied by the caller. It is not an unrestricted global string replacement.

## Match replacement casing

```dart
print(TextCorrection.matchCase('helo', 'hello')); // hello
print(TextCorrection.matchCase('Helo', 'hello')); // Hello
print(TextCorrection.matchCase('HELO', 'hello')); // HELLO
```

Case handling is Unicode-scalar-safe for the first cased scalar.

## Run all built-in writing rules

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

final analyzer = WritingAnalyzer();
final result = analyzer.analyze(
  'hello  world!!',
  languagePack: SpellLanguageRegistry.englishUs,
);

for (final issue in result.issues) {
  print(
    '${issue.ruleId} '
    '${issue.start}-${issue.end} '
    '${issue.message} '
    'replacement=${issue.replacement}',
  );
}
```

## Run a selected set of writing rules

```dart
final result = WritingAnalyzer().analyze(
  'hello  world',
  languagePack: SpellLanguageRegistry.englishUs,
  enabledRuleIds: <String>{
    'sentence-capitalization',
    'repeated-space',
  },
);
```

An empty `enabledRuleIds` set means run no rules. `null` means run all supported rules in the analyzer's configured registry.

## Bounded writing analysis with exact totals

```dart
final result = WritingAnalyzer().analyze(
  'word  word  word  word',
  languagePack: SpellLanguageRegistry.englishUs,
  maxIssues: 2,
);

print('Captured: ${result.capturedIssueCount}');
print('Total: ${result.totalIssueCount}');
print('Uncaptured: ${result.uncapturedIssueCount}');
print('Truncated: ${result.isTruncated}');
print(result.totalIssueCountByRule);
```

Analyzer-produced results provide exact overall and per-rule totals even when only the globally earliest bounded prefix is retained.

## Apply one writing fix

```dart
final text = 'hello  world';
final analysis = WritingAnalyzer().analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
);

final fixable = analysis.issues.firstWhere(
  (issue) => issue.hasAutomaticFix,
);
final corrected = WritingCorrection.apply(text, fixable);

print(corrected.applied);
print(corrected.text);
```

Advisory findings with `replacement == null` are never automatically applied.

## Apply all safe non-overlapping writing fixes

```dart
final text = 'hello  world!!';
final analysis = WritingAnalyzer().analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
);

final corrected = WritingCorrection.applyAll(text, analysis.issues);

print('Applied: ${corrected.appliedCount}');
print('Skipped: ${corrected.skippedCount}');
print(corrected.text);
```

Batch correction sorts candidates deterministically, skips stale/advisory/overlapping findings, and applies accepted edits from the end of the source toward the beginning.

## Produce a privacy-safe diagnostic summary

```dart
final analyzer = WritingAnalyzer();
final result = analyzer.analyze(
  'hello  world!!',
  languagePack: SpellLanguageRegistry.englishUs,
  maxIssues: 200,
);

final summary = WritingAnalysisDiagnosticSummary.fromResult(
  result,
  rules: analyzer.rules,
);

print(summary.toPlainText());
```

The summary contains counts and rule metadata only. It excludes editor text, finding excerpts, replacements, and source offsets.

## Filter writing rules/findings with a review query

```dart
final analyzer = WritingAnalyzer();
final result = analyzer.analyze(
  'hello  world',
  languagePack: SpellLanguageRegistry.englishUs,
);

final query = WritingReviewQuery(
  search: 'space',
  automaticFixesOnly: true,
);

final rules = query.filterRules(analyzer.rules);
final issues = query.filterIssues(
  result.issues,
  rules: analyzer.rules,
);

print(rules.map((rule) => rule.id));
print(issues.map((issue) => issue.ruleId));
```

Review-query objects are pure filtering helpers; the bundled application chooses not to persist transient query state.

## Implement a custom suggestion ranker

```dart
class ShorterFirstRanker implements SpellSuggestionRanker {
  const ShorterFirstRanker();

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    final byLength = a.word.runes.length.compareTo(b.word.runes.length);
    if (byLength != 0) {
      return byLength;
    }
    return a.distance.compareTo(b.distance);
  }
}

final engine = SpellCheckerEngine(
  suggestionRanker: const ShorterFirstRanker(),
);
```

Custom rankers should be deterministic and side-effect-free. The engine applies a final lexical word tie-break when the ranker returns zero.

## Implement a custom writing rule

```dart
class ExampleRule extends WritingRule {
  const ExampleRule();

  @override
  String get id => 'example-rule';

  @override
  String get displayName => 'Example rule';

  @override
  String get description => 'Finds the exact token TODO in English text.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in RegExp(r'\bTODO\b').allMatches(text)) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Review this placeholder.',
        start: match.start,
        end: match.end,
        originalText: match.group(0)!,
        replacement: null,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}

final analyzer = WritingAnalyzer(
  rules: const <WritingRule>[ExampleRule()],
);
```

A rule ID must be unique within one `WritingAnalyzer`. Duplicate IDs are rejected.

## Source offset warning

Dart `String` indexing and Flutter text editing use UTF-16 offsets. `SpellIssue.start/end` and `WritingIssue.start/end` therefore refer to UTF-16 code-unit positions, not Unicode scalar indexes or user-perceived grapheme indexes.

Always use the source range against the same text snapshot that produced the issue. The correction helpers verify source ownership before mutation.

## Testing examples

For unit tests, prefer small synthetic inputs and make source ownership explicit:

```dart
expect(text.substring(issue.start, issue.end), issue.originalText);
```

When testing non-BMP characters, verify UTF-16 ranges deliberately. When testing decomposed characters, keep combining-mark sequences intact in the test input.

See [Testing](TESTING.md), [Public API](API.md), [Writing rules](WRITING_RULES.md), and [Language packs](LANGUAGE_PACKS.md) for the full contracts.
