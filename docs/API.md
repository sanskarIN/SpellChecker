# Public API

This is the evergreen public Dart API reference for SpellChecker `3.3.0+26`. Historical API additions are indexed in [Release history](RELEASE_HISTORY.md).

## Public libraries

SpellChecker exposes three supported public barrels.

Core spelling, correction, codecs, and statistics:

```dart
import 'package:spellchecker/spell_checker.dart';
```

Language-pack APIs:

```dart
import 'package:spellchecker/language.dart';
```

Writing-analysis APIs:

```dart
import 'package:spellchecker/writing.dart';
```

Flutter application widgets, `DictionaryPreferences`, and other storage/UI adapters are internal integration details unless explicitly exported by one of these barrels.

## Coordinate model

Public spelling and writing issue ranges are **UTF-16 code-unit offsets** because they are designed for Dart `String.substring`/`replaceRange` and Flutter text-editing APIs.

Unicode-scalar operations are used where appropriate for edit distance, suggestion eligibility, and selected casing logic. Do not interpret `start`/`end` issue values as rune/scalar indexes or grapheme-cluster indexes.

# Core spelling API

## `damerauLevenshteinDistance`

```dart
int damerauLevenshteinDistance(String source, String target)
```

Computes unrestricted Damerau-Levenshtein distance over Unicode scalar values. Insertions, deletions, substitutions, and transpositions participate in the distance model.

Examples:

```dart
print(damerauLevenshteinDistance('form', 'from'));
print(damerauLevenshteinDistance('café', 'cafe'));
```

## `SpellCheckerEngine`

Construct with the default English (US) pack:

```dart
final engine = SpellCheckerEngine();
```

Select a pack:

```dart
final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);
```

The factory also accepts optional custom dictionary/frequency data and an injectable `SpellSuggestionRanker`:

```dart
final engine = SpellCheckerEngine(
  dictionary: customDictionary,
  wordFrequencies: customRanks,
  languagePack: pack,
  suggestionRanker: const DefaultSpellSuggestionRanker(),
);
```

Custom dictionary words and frequency keys are normalized through the selected language pack. When multiple frequency entries normalize to the same word, the lowest rank value is retained.

### `languagePack`

```dart
final SpellLanguagePack languagePack;
```

The pack controlling tokenization, normalization, dictionary behavior, recognized affixes, suggestion metadata, and suggestion-distance policy.

### `suggestionRanker`

```dart
final SpellSuggestionRanker suggestionRanker;
```

The strategy used to order already-eligible suggestion candidates. It should remain deterministic for the engine lifetime because suggestion results are cached.

### `personalDictionary`

```dart
Set<String> get personalDictionary
```

Returns an immutable snapshot of normalized personal words currently active in the engine.

### `ignoredWords`

```dart
Set<String> get ignoredWords
```

Returns an immutable snapshot of normalized session ignored words.

### `check`

```dart
List<SpellIssue> check(
  String text, {
  int suggestionLimit = 5,
})
```

Runs an unbounded spelling analysis and returns occurrence-specific issues in source order. This is the compatibility list-returning API.

### `analyze`

```dart
SpellCheckReport analyze(
  String text, {
  int suggestionLimit = 5,
  int? maxIssues,
})
```

Runs spelling analysis with optional bounded issue capture. `maxIssues`, when supplied, must be greater than zero.

After the issue limit is reached, the engine scans only until the source ends or it sees one additional unknown word. It does not generate suggestions for the overflow issue. This lets the report distinguish “exactly at the cap but complete” from “more issues exist.”

### `isCorrect`

```dart
bool isCorrect(String word)
```

Returns true when the normalized word is accepted by the base dictionary, personal dictionary, ignored-word set, or a recognized affix form whose stem is known.

Current built-in English suffixes are:

```text
n't
're
've
'll
'd
'm
's
```

French and Italian packs also expose reviewed recognized-prefix handling for apostrophe elision. See [Language packs](LANGUAGE_PACKS.md) for current built-in pack details.

### `suggestionsFor`

```dart
List<String> suggestionsFor(
  String word, {
  int limit = 5,
})
```

Returns only suggestion words. A non-positive limit returns an empty list.

### `suggestionDetailsFor`

```dart
List<SpellSuggestion> suggestionDetailsFor(
  String word, {
  int limit = 5,
})
```

Returns detailed language/source/ranking metadata. Recognized affixes are handled according to the active language pack when the engine resolves candidates.

### Personal dictionary mutation

```dart
void addToPersonalDictionary(String word)
bool removeFromPersonalDictionary(String word)
void replacePersonalDictionary(Iterable<String> words)
void clearPersonalDictionary()
```

Words are normalized and validated by the engine's language pack. Personal-dictionary changes clear the suggestion cache where required.

These methods are in-memory engine operations. The public engine does not persist them by itself.

### Ignored/session mutation

```dart
void ignoreWord(String word)
void clearIgnoredWords()
void resetSession()
```

`resetSession()` clears personal words, ignored words, and suggestion cache for that engine. Application persistence/restoration is a separate layer.

## `SpellIssue`

```dart
class SpellIssue {
  final String word;
  final int start;
  final int end;
  final List<String> suggestions;
  final String? languageId;
}
```

An issue represents one unknown occurrence from one checked source snapshot.

`start` is inclusive and `end` is exclusive in UTF-16 code units. `languageId` remains optional for source compatibility with manually constructed/test issues from earlier APIs; engine-produced issues include the selected pack ID.

`SpellIssue` implements value equality/hash code including suggestions and language metadata.

## `SpellCheckReport`

```dart
class SpellCheckReport {
  final List<SpellIssue> issues;
  final int scannedTokenCount;
  final bool truncated;
  final int? issueLimit;

  bool get complete;
  int get capturedIssueCount;
}
```

The constructor validates:

- non-negative token count;
- positive `issueLimit` when present;
- a truncated report must declare a limit;
- captured issue count cannot exceed the limit;
- scanned token count cannot be smaller than captured issue count.

`issues` is immutable.

## `SpellSuggestion`

```dart
class SpellSuggestion {
  final String word;
  final int distance;
  final int frequencyRank;
  final String languageId;
  final String languageDisplayName;
  final String source;
}
```

Detailed suggestion metadata produced by `suggestionDetailsFor`. It implements value equality/hash code.

## Suggestion ranking API

### `SpellSuggestionCandidate`

```dart
class SpellSuggestionCandidate {
  final String word;
  final int distance;
  final int prefixPenalty;
  final int frequencyRank;
  final String source;
}
```

Metadata supplied to a ranker after eligibility/edit-distance filtering.

### `SpellSuggestionRankingContext`

```dart
class SpellSuggestionRankingContext {
  final String target;
  final SpellLanguagePack languagePack;
}
```

`target` is the normalized form being ranked after any supported affix handling used by the engine.

### `SpellSuggestionRanker`

```dart
abstract interface class SpellSuggestionRanker {
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  );
}
```

Implementations should be deterministic and side-effect-free. When a custom ranker returns zero, the engine applies a final lexical word tie-break so equal custom scores remain stable.

### `DefaultSpellSuggestionRanker`

The default comparator orders by:

1. edit distance;
2. prefix/first-character penalty;
3. frequency rank;
4. Unicode-scalar candidate length;
5. engine lexical tie-break.

## `TextCorrection`

Correction helpers operate only on supplied issue ranges and validate stale source ownership before mutation.

### `replaceOne`

```dart
static TextCorrectionResult replaceOne(
  String text,
  SpellIssue issue,
  String suggestion,
)
```

Applies one suggestion when the issue range is valid, still equals `issue.word`, and the suggestion is non-empty. The replacement is adjusted through `matchCase`.

### `replaceAll`

```dart
static TextCorrectionResult replaceAll(
  String text,
  Iterable<SpellIssue> issues,
  String sourceWord,
  String suggestion,
)
```

Applies the suggestion only to supplied current issues whose word matches `sourceWord` case-insensitively. Matching ranges are applied from the end toward the beginning. This is not an unrestricted global string replacement.

### `matchCase`

```dart
static String matchCase(String original, String suggestion)
```

Preserves common all-uppercase and initial-uppercase casing patterns. First-scalar handling is Unicode-scalar-safe and uncased scripts are not forced into an uppercase interpretation.

## `TextCorrectionResult`

```dart
class TextCorrectionResult {
  final String text;
  final int caretOffset;
  final int replacements;

  bool get changed;
}
```

`changed` is true when at least one replacement was applied.

## `TextStatistics`

```dart
class TextStatistics {
  final int characters;
  final int words;
  final int sentences;

  factory TextStatistics.fromText(String text);
}
```

`characters` uses Dart string length (UTF-16 code units). Word counting uses the current Unicode letter/combining-mark/apostrophe/hyphen/join-control token model. Sentence counting recognizes `. ! ?` runs with common closing quotes/brackets and counts a remaining non-empty trailing sentence fragment.

# Language API

## `SpellWordNormalizer`

```dart
typedef SpellWordNormalizer = String Function(String word);
```

Normalizer callback used by a language pack.

## `SpellLanguagePack`

Constructor fields define the language-specific spelling contract:

```text
id
languageCode
regionCode
displayName
dictionary
wordFrequencies
tokenPattern
validWordPattern
normalizer
recognizedPrefixes
recognizedSuffixes
suggestionSource
```

Dictionary, frequency, prefix, and suffix collections are captured as immutable snapshots by the constructor.

### Methods

```dart
String normalizeWord(String word)
Iterable<RegExpMatch> tokenize(String text)
bool isValidWord(String word)
int maximumSuggestionDistance(int wordLength)
```

The default suggestion-distance policy is:

```text
length <= 4  -> 1
length <= 8  -> 2
otherwise    -> 3
```

Callers can create custom `SpellLanguagePack` instances with a different token/validation/normalization/dictionary/affix contract, but `maximumSuggestionDistance` is currently concrete rather than injectable through constructor data.

Pack equality/hash code are based on stable `id`.

## `SpellLanguageRegistry`

Current built-ins:

```text
en-US  English (US)
en-GB  English (UK)
hi-IN  Hindi (India)
es-ES  Spanish (Spain)
fr-FR  French (France)
de-DE  German (Germany)
pt-BR  Portuguese (Brazil)
it-IT  Italian (Italy)
bn-IN  Bengali (India)
mr-IN  Marathi (India)
ta-IN  Tamil (India)
te-IN  Telugu (India)
ru-RU  Russian (Russia)
```

Public named packs and helpers:

```dart
static final SpellLanguagePack englishUs
static final SpellLanguagePack englishGb
static final SpellLanguagePack hindiIndia
static final SpellLanguagePack spanishSpain
static final SpellLanguagePack frenchFrance
static final SpellLanguagePack germanGermany
static final SpellLanguagePack portugueseBrazil
static final SpellLanguagePack italianItaly
static final SpellLanguagePack bengaliIndia
static final SpellLanguagePack marathiIndia
static final SpellLanguagePack tamilIndia
static final SpellLanguagePack teluguIndia
static final SpellLanguagePack russianRussia
static List<SpellLanguagePack> get builtIns
static SpellLanguagePack get defaultPack
static SpellLanguagePack byId(String? id)
static bool contains(String id)
```

`defaultPack` is `englishUs`.

`byId` is deliberately fallback-oriented: null, empty, or unsupported IDs resolve to the default pack. Use `contains(id)` when strict validation is required before resolution.

The built-in Unicode normalizer trims, lowercases, normalizes supported apostrophe/hyphen variants, and composes a defined set of common decomposed Latin sequences used by bundled vocabulary. Tokenization keeps in-word U+200C ZERO WIDTH NON-JOINER and U+200D ZERO WIDTH JOINER when they connect letter clusters.

See [Language packs](LANGUAGE_PACKS.md) for extension guidance and starter-lexicon boundaries.

# Personal dictionary transfer API

## `PersonalDictionaryDocument`

```dart
class PersonalDictionaryDocument {
  final int version;
  final String languageId;
  final Set<String> words;
}
```

`words` is immutable.

## `PersonalDictionaryCodec`

Constants:

```dart
static const int legacyVersion = 1;
static const int currentVersion = 2;
```

### `encode`

```dart
static String encode(Iterable<String> words)
```

Produces the legacy version-1 object for the default language context. Retained for compatibility.

### `encodeForLanguage`

```dart
static String encodeForLanguage(
  Iterable<String> words, {
  required SpellLanguagePack languagePack,
})
```

Produces current version-2 JSON with explicit language metadata.

### `decode`

```dart
static Set<String> decode(
  String source, {
  SpellLanguagePack? languagePack,
})
```

Returns only decoded words.

### `decodeDocument`

```dart
static PersonalDictionaryDocument decodeDocument(
  String source, {
  SpellLanguagePack? languagePack,
})
```

Accepts supported versioned JSON objects, JSON arrays, and compatible plain line/comma lists. Empty input produces an empty current document using the supplied/default pack.

Version-2 objects must include a supported registered language ID. Invalid format/version/entries raise `FormatException`.

### `normalizeWord`

```dart
static String normalizeWord(
  Object? value, {
  SpellLanguagePack? languagePack,
})
```

Returns a valid normalized word or the empty string when the supplied value is not a valid word for the pack.

See [Configuration](CONFIGURATION.md) for application import/merge behavior.

# Portable settings API

## `SpellCheckerSettingsDocument`

```dart
class SpellCheckerSettingsDocument {
  final String languageId;
  final int suggestionLimit;
  final Map<String, Set<String>> writingRuleOverrides;

  bool hasWritingRuleOverride(String languageId);
  Set<String>? writingRuleIdsFor(String languageId);
}
```

`writingRuleOverrides` is an immutable map of immutable sets.

An absent language key means “unset; use registry defaults.” A present empty set means “explicitly disable all writing rules.” An explicit older non-empty set remains explicit when a later release adds another built-in rule.

## `SpellCheckerSettingsCodec`

Constants:

```dart
static const String format = 'spellchecker-settings';
static const int version = 1;
static const int minSuggestionLimit = 1;
static const int maxSuggestionLimit = 10;
```

### `encode`

```dart
static String encode(SpellCheckerSettingsDocument document)
```

Validates the document and produces deterministic indented JSON with sorted language keys and rule IDs.

### `decode`

```dart
static SpellCheckerSettingsDocument decode(String source)
```

Strictly validates the format identifier/version, registered language IDs, suggestion bound, override object shape, rule-ID syntax, and duplicate rule IDs. Invalid documents raise `FormatException`.

The codec intentionally carries preferences only; it does not serialize editor text, personal vocabulary, ignored words, findings, or correction history.

# Writing API

## `WritingIssueSeverity`

```dart
enum WritingIssueSeverity {
  info,
  suggestion,
  warning,
}
```

## `WritingIssue`

```dart
class WritingIssue {
  final String ruleId;
  final String ruleName;
  final String message;
  final int start;
  final int end;
  final String originalText;
  final String? replacement;
  final String languageId;
  final WritingIssueSeverity severity;

  bool get hasAutomaticFix;
}
```

`replacement == null` means advisory. An empty replacement is still an automatic fix. The class implements value equality/hash code.

## `WritingRuleCategory`

Current public review categories are Mechanics and Clarity. Category is independent from issue severity.

## `WritingRule`

```dart
abstract class WritingRule {
  String get id;
  String get displayName;
  String get description;
  Set<String> get supportedLanguageIds;
  WritingRuleCategory get category;

  bool supports(SpellLanguagePack languagePack);

  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  );
}
```

`category` defaults to Mechanics for source compatibility with earlier external rules.

## Built-in rule classes

`package:spellchecker/writing.dart` exports:

```text
RepeatedWordRule
SentenceCapitalizationRule
RepeatedSpaceRule
PunctuationSpacingRule
MissingPunctuationSpaceRule
MissingColonSpaceRule
TrailingWhitespaceRule
RepeatedPunctuationRule
UnmatchedParenthesisRule
UnmatchedSquareBracketRule
UnmatchedCurlyBraceRule
```

See [Writing rules](WRITING_RULES.md) for exact rule IDs/source scopes/correction behavior.

## `WritingRuleRegistry`

```dart
static const List<WritingRule> builtIns
static WritingRule? byId(String id)
static Set<String> get defaultEnabledRuleIds
```

The current built-in/default registry contains eleven stable rule IDs. `byId` returns null for an unknown ID.

All current built-in writing rules declare English (`en`) support. They are therefore eligible for `en-US` and `en-GB`, not for the eleven non-English starter spelling packs.

## `WritingAnalyzer`

```dart
WritingAnalyzer({Iterable<WritingRule>? rules})

List<WritingRule> get rules

WritingAnalysisResult analyze(
  String text, {
  required SpellLanguagePack languagePack,
  Set<String>? enabledRuleIds,
  int? maxIssues,
})
```

The configured rule list is validated for duplicate IDs and exposed as an immutable snapshot.

`enabledRuleIds == null` runs every configured rule that supports the pack. An explicit set runs only matching supported IDs. `maxIssues`, when supplied, must be positive.

Analyzer-produced results always include exact overall/per-rule totals even when retained findings are bounded.

## `WritingAnalysisResult`

Core fields/getters:

```text
issues
analyzedRuleIds
languageId
issueLimit
isTruncated
totalIssueCount
totalIssueCountByRule
isClean
isComplete
capturedIssueCount
hasExactIssueTotals
uncapturedIssueCount
issueCountByRule
```

`issues`, analyzed IDs, and exact-per-rule totals are immutable snapshots.

The constructor enforces consistency between issue rule/language metadata, capture limits, complete/truncated state, exact totals, and per-rule totals.

`totalIssueCount`/`totalIssueCountByRule` remain nullable so callers that directly construct compatibility-style results can omit exact diagnostics. Results returned by `WritingAnalyzer.analyze()` provide them.

## `WritingCorrection`

### `apply`

```dart
static WritingCorrectionResult apply(
  String text,
  WritingIssue issue,
)
```

Applies one current automatic replacement. Advisory/stale/invalid findings return unchanged text with `applied == false`.

### `applyAll`

```dart
static WritingBatchCorrectionResult applyAll(
  String text,
  Iterable<WritingIssue> issues,
)
```

Sorts candidates by start/end/rule ID, skips advisory/stale/overlapping candidates, accepts deterministic non-overlapping fixes, and mutates from end to start.

The V3.3 `missing-colon-space` rule owns only the colon, allowing it to compose with `punctuation-spacing` for `Label :value` without overlapping ranges.

## `WritingCorrectionResult`

```dart
class WritingCorrectionResult {
  final String text;
  final int caretOffset;
  final bool applied;
}
```

## `WritingBatchCorrectionResult`

```dart
class WritingBatchCorrectionResult {
  final String text;
  final int caretOffset;
  final int appliedCount;
  final int skippedCount;

  bool get applied;
}
```

## `WritingReviewQuery`

```dart
WritingReviewQuery({
  String search = '',
  Iterable<WritingRuleCategory> categories = const [],
  bool automaticFixesOnly = false,
})
```

Public state/helpers:

```text
search
categories
automaticFixesOnly
isEmpty
filterRules(...)
filterIssues(...)
matchesRule(...)
```

Search is normalized to trimmed lowercase. Categories are stored as an immutable set.

## `WritingReviewPreset`

Fields:

```text
id
displayName
description
categories
automaticFixesOnly
isAllFindings
```

Helpers:

```dart
WritingReviewQuery toQuery({String search = ''})
static WritingReviewPreset byId(String? id)
```

Stable built-ins:

```text
all-findings
mechanics
clarity
automatic-fixes
```

`values` exposes all built-in presets. Unknown/null IDs resolve to `allFindings`.

## Diagnostic summary API

### `WritingRuleDiagnosticSummary`

Contains stable per-rule metadata:

```text
ruleId
displayName
capturedIssueCount
totalIssueCount
```

### `WritingAnalysisDiagnosticSummary`

Build with:

```dart
final summary = WritingAnalysisDiagnosticSummary.fromResult(
  result,
  rules: analyzer.rules,
);
```

Important members:

```text
formatVersion
languageId
capturedIssueCount
totalIssueCount
issueLimit
isTruncated
rules
hasExactIssueTotals
uncapturedIssueCount
toPlainText()
```

Rule rows are sorted lexically by rule ID for deterministic output. The plain-text summary contains count/rule metadata only and intentionally excludes editor text, source excerpts, finding messages, replacements, and source offsets.

# API stability and validation principles

## Immutable snapshots

Public result/metadata collections are generally exposed as unmodifiable snapshots so callers cannot mutate analyzer/engine result ownership indirectly.

## Runtime validation

Invalid public values that would create ambiguous result semantics are rejected with `ArgumentError`, `FormatException`, or related runtime failures rather than relying solely on debug assertions.

## Determinism

Suggestion ranking, writing result ordering, bounded retention, batch conflict selection, codecs, and diagnostic-summary ordering are designed to be deterministic for the same source/configuration.

## Privacy

Public analysis/model types do not perform network requests. Clipboard and persistence actions belong to application integration code, not the core analyzer/issue types.

## Source compatibility

Several nullable/defaulted fields preserve compatibility with earlier API shapes, including optional `SpellIssue.languageId`, concrete default `WritingRule.category`, and nullable exact-total metadata on directly constructed `WritingAnalysisResult` values.

Explicit writing-rule override sets are also preserved across registry growth: adding a built-in rule changes current defaults, not a user's previously stored explicit set.

# Examples and integration guidance

Use [Library examples](EXAMPLES.md) for copyable code and [Architecture](ARCHITECTURE.md) for layer boundaries.

For specific topics:

- [Language packs](LANGUAGE_PACKS.md)
- [Writing rules](WRITING_RULES.md)
- [Configuration and transfer formats](CONFIGURATION.md)
- [Performance and bounded analysis](PERFORMANCE.md)
- [Testing](TESTING.md)
- [Glossary](GLOSSARY.md)
