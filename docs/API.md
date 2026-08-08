# Public API

SpellChecker 2.3 exposes reusable spelling, language, correction, local writing-review, and portable-settings APIs through three public barrels.

## Imports

Core spelling and correction APIs:

```dart
import 'package:spellchecker/spell_checker.dart';
```

Language-pack APIs:

```dart
import 'package:spellchecker/language.dart';
```

Writing-rule APIs:

```dart
import 'package:spellchecker/writing.dart';
```

Application UI and storage adapters remain internal integration details unless explicitly exported.

# Language APIs

## `SpellLanguageRegistry`

`SpellLanguageRegistry.builtIns` contains the built-in packs. `defaultPack` remains English (US), `en-US`.

Current built-ins:

```text
en-US  English (US)
en-GB  English (UK)
```

Use `SpellLanguageRegistry.byId(id)` to resolve an explicit pack and `contains(id)` to validate persisted IDs.

## `SpellLanguagePack`

A pack contains:

- Stable language/region ID.
- Language and region codes.
- Display name.
- Dictionary data.
- Approximate frequency ranks.
- Unicode token pattern.
- Valid personal-word pattern.
- Word normalizer.
- Recognized suffixes.
- Suggestion-source metadata.
- Suggestion edit-distance policy.

The spelling engine delegates tokenization, normalization, dictionary lookup behavior, and suggestion metadata to the selected pack.

See [LANGUAGE_PACKS.md](LANGUAGE_PACKS.md).

# `SpellCheckerEngine`

Create an engine using the default US pack:

```dart
final engine = SpellCheckerEngine();
```

Select a language explicitly:

```dart
final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);
```

A custom dictionary/frequency set can still be supplied where supported by the constructor. Existing `SpellCheckerEngine()` callers remain source-compatible and default to `en-US`.

## `check`

```dart
List<SpellIssue> check(
  String text, {
  int suggestionLimit = 5,
})
```

Tokenizes text with the selected language pack and returns unknown occurrences in source order.

Each issue is occurrence-specific and belongs to the exact source snapshot that was checked.

## `isCorrect`

```dart
bool isCorrect(String word)
```

Returns `true` when the normalized word is accepted by:

- The selected base dictionary.
- The current engine's personal dictionary.
- The current engine's ignored-word set.
- A recognized regular suffix whose stem is known.

Current English suffix handling includes:

```text
n't
're
've
'll
'd
'm
's
```

## `suggestionsFor`

```dart
List<String> suggestionsFor(
  String word, {
  int limit = 5,
})
```

Returns backward-compatible string candidates.

Candidate ordering is deterministic and considers:

1. Damerau-Levenshtein distance.
2. First-character/prefix agreement.
3. Approximate word-frequency rank.
4. Candidate length.
5. Alphabetical order.

## `suggestionDetailsFor`

Detailed suggestions expose language/source metadata:

```dart
final suggestions = engine.suggestionDetailsFor('helo');
```

`SpellSuggestion` includes:

```text
word
distance
frequencyRank
languageId
languageDisplayName
source
```

## Personal and ignored words

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

The engine itself remains storage-agnostic. The Flutter application persists personal words in language-specific namespaces and keeps ignored words session-only.

# `SpellIssue`

A spelling issue contains:

```dart
const SpellIssue({
  required String word,
  required int start,
  required int end,
  List<String> suggestions = const <String>[],
  String? languageId,
})
```

A fresh issue satisfies:

```dart
text.substring(issue.start, issue.end) == issue.word
```

`languageId` identifies the producing pack when available.

# `TextCorrection`

`TextCorrection` provides validated spelling-text mutation independent from Flutter widgets.

## `replaceOne`

```dart
TextCorrectionResult TextCorrection.replaceOne(
  String text,
  SpellIssue issue,
  String suggestion,
)
```

A replacement is performed only while the checked source range is still current. Stale/invalid issues return the unchanged text with zero replacements.

## `replaceAll`

```dart
TextCorrectionResult TextCorrection.replaceAll(
  String text,
  Iterable<SpellIssue> issues,
  String sourceWord,
  String suggestion,
)
```

Replaces every still-current checked matching occurrence, applying replacements from the end toward the beginning so source offsets remain valid.

Only occurrences represented by the supplied issue list are eligible.

## `matchCase`

```dart
String TextCorrection.matchCase(
  String original,
  String suggestion,
)
```

Preserves common casing patterns such as lowercase, title case, and uppercase.

## `TextCorrectionResult`

```dart
const TextCorrectionResult({
  required String text,
  required int caretOffset,
  required int replacements,
})
```

`changed` is true when one or more replacements were applied.

# Personal dictionary codec

## Version-2 language-aware documents

Use:

```dart
final encoded = PersonalDictionaryCodec.encodeForLanguage(
  words,
  languagePack: pack,
);
```

Current format:

```json
{
  "version": 2,
  "language": "en-US",
  "words": ["example", "flutter"]
}
```

`decodeDocument()` returns a `PersonalDictionaryDocument` containing:

```text
version
languageId
words
```

Version-2 documents carry explicit language identity so the application can reject accidental cross-language imports.

## Legacy compatibility

`PersonalDictionaryCodec.encode(words)` remains version-1-compatible.

Accepted legacy import forms include:

- Version-1 SpellChecker objects.
- JSON arrays.
- Plain newline/comma-separated word lists.

Legacy forms inherit the caller/selected language because they contain no language metadata.

## Normalization

Personal-word normalization is language-pack aware when a pack is supplied. Curly apostrophes and supported Unicode hyphen variants are normalized according to the selected pack.

Malformed entries and unsupported document versions throw `FormatException` rather than being guessed.

# Edit distance

```dart
int damerauLevenshteinDistance(String source, String target)
```

Supports insertion, deletion, substitution, and adjacent transposition under the implementation's distance model.

# Text statistics

```dart
final stats = TextStatistics.fromText('Hello world.');
```

Fields:

```text
characters
words
sentences
```

# Writing-rule API

## `WritingRule`

A writing rule defines:

```dart
abstract class WritingRule {
  String get id;
  String get displayName;
  String get description;
  Set<String> get supportedLanguageIds;

  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  );
}
```

Rule IDs are stable persisted identifiers in V2.1. They must not be renamed casually.

## `WritingRuleRegistry`

`WritingRuleRegistry.builtIns` contains the built-in rules.

Current IDs:

```text
repeated-word
sentence-capitalization
repeated-space
repeated-punctuation
```

`WritingRuleRegistry.defaultEnabledRuleIds` is used when no writing-rule preference exists for the active language.

## `WritingAnalyzer`

```dart
final result = WritingAnalyzer().analyze(
  text,
  languagePack: pack,
  enabledRuleIds: enabledIds,
);
```

The analyzer:

- Runs only rules supporting the selected pack.
- Applies optional rule-ID filtering.
- Returns immutable findings sorted deterministically.
- Reports which rule IDs actually ran.
- Exposes per-rule issue counts.

`enabledRuleIds == null` means run all supported rules configured in that analyzer. The Flutter application normally passes its resolved persisted/default set explicitly.

## `WritingIssue`

A finding contains:

```text
ruleId
ruleName
message
start
end
originalText
replacement
languageId
severity
```

`replacement == null` means advisory-only. An empty replacement string is still a valid automatic fix and can represent deletion.

For a current issue:

```dart
text.substring(issue.start, issue.end) == issue.originalText
```

## `WritingCorrection.apply`

```dart
WritingCorrectionResult WritingCorrection.apply(
  String text,
  WritingIssue issue,
)
```

Applies one automatic fix only when the current source range still equals `originalText`.

Result fields:

```text
text
caretOffset
applied
```

## `WritingCorrection.applyAll` — V2.1

```dart
WritingBatchCorrectionResult WritingCorrection.applyAll(
  String text,
  Iterable<WritingIssue> issues,
)
```

Batch safety contract:

1. Sort candidates by `start`, then `end`, then `ruleId`.
2. Skip advisory findings without replacements.
3. Skip invalid/stale findings.
4. When findings overlap, keep the earliest deterministic candidate and skip later overlaps.
5. Apply accepted replacements from the document end toward the beginning.
6. Return the single final document text and counts.

### `WritingBatchCorrectionResult`

```dart
const WritingBatchCorrectionResult({
  required String text,
  required int caretOffset,
  required int appliedCount,
  required int skippedCount,
})
```

Convenience getter:

```dart
bool get applied
```

`applied` is true when `appliedCount > 0`.

The Flutter editor records one successful `applyAll` result as one correction-history entry, making a complete writing batch one-step undoable.

See [WRITING_RULES.md](WRITING_RULES.md) for the full rule and batch-correction specification.

# V2.2 writing review APIs

## `WritingRuleCategory`

Public review categories currently include:

```dart
WritingRuleCategory.mechanics
WritingRuleCategory.clarity
```

Each category exposes `displayName`.

`WritingRule.category` is a concrete getter defaulting to Mechanics so rules written against the original V2.0 contract remain source-compatible. Rules can override the getter.

## `WritingReviewQuery`

```dart
final query = WritingReviewQuery(
  search: 'space',
  categories: <WritingRuleCategory>{WritingRuleCategory.mechanics},
  automaticFixesOnly: true,
);
```

Public fields:

```text
search
categories
automaticFixesOnly
isEmpty
```

Methods:

```dart
List<WritingRule> filterRules(Iterable<WritingRule> rules)

List<WritingIssue> filterIssues(
  Iterable<WritingIssue> issues, {
  required Iterable<WritingRule> rules,
})
```

Search is case-insensitive after trimming/lowercasing and covers rule/finding metadata. Category filtering requires a matching supplied rule. `automaticFixesOnly` affects findings and leaves the rule list available for management.

Review queries have no persistence/network behavior. The Flutter dialog stores search/categories/automatic-only state in memory only.

## Reset-to-default application contract

`WritingInsightsDialog` is internal UI, but its V2.2 user-visible contract is documented: **Reset rules to defaults** clears the selected language's stored rule-ID override through `DictionaryPreferences.clearWritingRuleIds` and resolves current registry defaults instead of storing a concrete default list.

This preserves the application persistence distinction between missing/unset and explicit stored values.

# V2.3 review preset and portable-settings APIs

## `WritingReviewPreset`

`package:spellchecker/writing.dart` exports immutable reusable review presets. Current stable IDs are:

```text
all-findings
automatic-fixes
clarity
mechanics
```

`WritingReviewPreset.values` exposes the built-ins; `WritingReviewPreset.byId(id)` falls back to `allFindings` for an unknown/null ID. `preset.toQuery(search: ...)` returns the corresponding `WritingReviewQuery`. Search is caller-supplied/transient and is not stored in the preset.

Preset IDs are compatibility-sensitive metadata. Do not silently reuse an existing ID for different semantics.

## `SpellCheckerSettingsDocument`

`package:spellchecker/spell_checker.dart` exports the versioned portable preference document:

```dart
final document = SpellCheckerSettingsDocument(
  languageId: 'en-US',
  suggestionLimit: 5,
  writingRuleOverrides: <String, Iterable<String>>{
    'en-US': <String>{'sentence-capitalization'},
    'en-GB': const <String>[],
  },
);
```

`writingRuleOverrides` contains **explicit overrides only**. `hasWritingRuleOverride(languageId) == false` means unset/use current registry defaults. A present empty set means explicit disable-all.

## `SpellCheckerSettingsCodec`

Current constants:

```text
format = spellchecker-settings
version = 1
minSuggestionLimit = 1
maxSuggestionLimit = 10
```

`encode(document)` validates language IDs, suggestion limits, and rule IDs and emits deterministic indented JSON with sorted language keys/rule IDs.

`decode(source)` rejects malformed JSON, unsupported format/version, unsupported language IDs, invalid override structures, malformed rule IDs, and suggestion limits outside 1–10. Well-formed unknown future rule IDs are preserved instead of being discarded by the codec.

The codec is intentionally storage/network agnostic and never carries editor text, personal vocabulary, ignored words, findings, or correction history.

## Internal `SettingsTransferService`

The Flutter application uses an internal storage service to project `SpellCheckerSettingsDocument` onto `DictionaryPreferences`. It is not part of the public barrel guarantee. The service snapshots prior portable preferences and performs best-effort rollback if a multi-key import write fails; `shared_preferences` does not provide transactional writes.


# Application persistence boundary

`DictionaryPreferences` is an application-internal adapter under `lib/storage/`; it is intentionally not exported from the public core/writing barrels.

V2.1 persists:

- Selected language ID.
- Personal words per language.
- Suggestion-count preference.
- Enabled writing-rule IDs per language.

Writing-rule preference keys use:

```text
spellchecker.writing_rule_ids.v1.<language-id>
```

The application distinguishes:

- Missing key → use current registry defaults.
- Non-empty stored list → use those supported IDs.
- Empty stored list → explicitly disable all rules for that language.

The application does not persist:

- Editor text.
- Spelling results.
- Writing findings.
- Ignored words.
- Active issue position.
- Correction undo snapshots.
- Batch correction plans.

# UI integration types

`SpellCheckEditingController`, `SpellCheckerPage`, `DictionaryManagerDialog`, and `WritingInsightsDialog` live under `lib/features/` and are not currently part of the reusable public API guarantee.

Application-level behavior includes:

- Inline spelling highlighting.
- Active issue navigation and selection.
- `F7` / `Shift+F7` spelling navigation.
- `Ctrl/Command+Enter` spelling check.
- `Ctrl/Command+Shift+Enter` Writing insights.
- Spelling replace-all.
- Writing individual safe fix.
- Writing **Apply all safe fixes**.
- Shared bounded correction undo.
- Per-language saved word and writing-rule preferences.
- Accessibility live regions and semantic labels.

# Stability

`lib/spell_checker.dart`, `lib/language.dart`, and `lib/writing.dart` are the intended reusable public API barrels for the 2.x line.

Internal files under `lib/features/`, `lib/data/`, and `lib/storage/` can evolve more freely, but documented data formats, persisted preference semantics, correction-safety behavior, and public exported APIs require compatibility review and release notes when changed.
