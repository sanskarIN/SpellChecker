# Public API


## V2.14 public writing API

`package:spellchecker/writing.dart` now exports `UnmatchedSquareBracketRule` with stable ID `unmatched-square-bracket`. The existing `WritingRule`, `WritingIssue`, `WritingAnalyzer`, bounded-result, diagnostic-summary, review-query, correction, preference, and Portable-settings contracts are unchanged. Analyzer-produced default English results can now include nine built-in rule IDs.

## V2.13 API note

`package:spellchecker/writing.dart` now exports `UnmatchedParenthesisRule`, stable ID `unmatched-parenthesis`. The existing `WritingRule`, `WritingIssue`, `WritingAnalyzer`, `WritingAnalysisResult`, `WritingCorrection`, review-query, persistence, diagnostic-summary, and benchmark result formats are unchanged. The new rule returns warning findings with `replacement == null`, so callers must continue to treat automatic correction as optional.

## V2.12 API note

The public writing API now exports `MissingPunctuationSpaceRule` with stable ID `missing-punctuation-space`. It is part of `WritingRuleRegistry.builtIns` and the default enabled set for supported English packs. Findings own the punctuation-only UTF-16 source range and propose punctuation plus one following space. The analyzer/result/correction method signatures and persistence contracts are unchanged.
SpellChecker 2.10 exposes reusable spelling, language, correction, suggestion-ranking, local writing-review, writing-analysis diagnostic-summary, and portable-settings APIs through three public barrels.

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

The spelling engine delegates tokenization, normalization, dictionary lookup behavior, and suggestion metadata to the selected pack. Pack dictionary, frequency, and recognized-suffix collections are defensive immutable snapshots after construction.

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

A custom dictionary/frequency set can still be supplied where supported by the constructor. Both custom dictionary words and custom frequency keys are normalized through the selected language pack; when multiple frequency keys normalize to the same word, the lowest rank value is retained. Existing `SpellCheckerEngine()` callers remain source-compatible and default to `en-US`.

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

Word counting is Unicode-letter aware and keeps supported internal straight/curly apostrophes and ASCII/Unicode hyphen forms inside the same word token.

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
punctuation-spacing
trailing-whitespace
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

# V2.4 suggestion ranking APIs

## `SpellSuggestionCandidate`

Public immutable metadata for a candidate that already passed engine eligibility and maximum-edit-distance filtering:

```text
word
edit distance
prefixPenalty
frequencyRank
source
```

Rankers cannot use this API to reintroduce a candidate that the engine rejected before ranking.

## `SpellSuggestionRankingContext`

Provides the normalized target stem and active `SpellLanguagePack`. Recognized suffixes are removed before candidate ranking and reattached afterward, matching pre-V2.4 behavior.

## `SpellSuggestionRanker`

Implement `compare(context, a, b)` to order eligible candidates. Implementations should be deterministic and side-effect free. `SpellCheckerEngine` caches ranked results per normalized input word and assumes its ranker remains semantically stable for the engine lifetime.

If a ranker returns zero, the engine compares candidate words lexically. That final tie-break is engine-owned and guarantees deterministic ordering for equal custom scores.

## `DefaultSpellSuggestionRanker`

The default preserves the historical policy:

1. Lower Damerau-Levenshtein edit distance.
2. Lower first-character/prefix penalty.
3. Better (lower) frequency rank.
4. Shorter candidate word.
5. Engine lexical fallback.

## Engine injection

```dart
final engine = SpellCheckerEngine(
  suggestionRanker: const MySuggestionRanker(),
);
```

The new parameter is optional; callers that do not provide a ranker retain pre-V2.4 ordering.


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

# V2.5 bounded spelling-analysis APIs

## `SpellCheckReport`

`SpellCheckReport` is exported through `package:spellchecker/spell_checker.dart` and is an in-memory immutable report value.

```dart
final report = engine.analyze(text, maxIssues: 200);
```

Fields/getters:

```text
issues                 immutable captured SpellIssue list
scannedTokenCount      tokens inspected before completion/truncation proof
truncated              true only when another uncaptured issue is proven
issueLimit             requested positive capture bound, or null
complete               !truncated
capturedIssueCount     issues.length
```

The report does not claim `scannedTokenCount` is the document's total token count when `truncated` is true; analysis returns at the first proven overflow unknown token. The public constructor enforces its consistency invariants at runtime in debug and release builds: non-negative scanned counts, positive optional limits, a declared limit for truncated reports, captured issues not exceeding the limit, and scanned-token counts not smaller than captured issue counts.

## `SpellCheckerEngine.analyze`

```dart
SpellCheckReport analyze(
  String text, {
  int suggestionLimit = 5,
  int? maxIssues,
})
```

`maxIssues == null` performs unbounded issue capture. A supplied value must be greater than zero or `ArgumentError` is thrown.

The engine captures issues in source order. Once the cap is full it continues token inspection without materializing further issues until it reaches the end or sees one more unknown token. That overflow token proves truncation and causes immediate return without suggestion generation for the overflow issue.

## `check()` compatibility

```dart
List<SpellIssue> check(String text, {int suggestionLimit = 5})
```

The historical method remains public and unbounded. It delegates to `analyze()` with no issue cap and returns the report's immutable issue list. Existing call sites do not need to opt into V2.5 bounds.

## Safety boundary

`maxIssues` does not weaken language normalization, known-word checks, source offsets, suggestion ranking, edit-distance thresholds, stale correction protection, or personal/ignored dictionary behavior. It controls issue capture/suggestion work only.

## V2.6 writing-rule API additions

`package:spellchecker/writing.dart` now exports `PunctuationSpacingRule` and `TrailingWhitespaceRule`. Their stable IDs are `punctuation-spacing` and `trailing-whitespace` respectively. Both implement the existing `WritingRule` contract; no abstract interface member was added, so external rule implementations remain source-compatible.

Both rules return exact, non-empty source ranges and deterministic empty-string replacements. `WritingRuleRegistry.builtIns` and `defaultEnabledRuleIds` now contain six built-ins. Existing explicit per-language stored rule-ID sets remain explicit and are intersected with supported registered IDs as before.

`RepeatedSpaceRule` retains its public ID/API but narrows its matching responsibility to repeated interior spaces, delegating punctuation-adjacent and terminal whitespace ranges to the specialized V2.6 rules.

## V2.7 writing-analysis bounds

`WritingAnalyzer.analyze()` adds the optional named parameter `int? maxIssues`. Existing callers remain source-compatible because the parameter is optional and defaults to unbounded behavior.

`WritingAnalysisResult` adds:

```text
issueLimit          requested positive capture limit, or null
isTruncated         true only after an additional finding exists
isComplete          convenience inverse of isTruncated
capturedIssueCount  number of retained findings
```

`issues` remains immutable. In bounded mode it contains the globally earliest findings according to the analyzer's existing deterministic comparator. `issueCountByRule` describes retained findings only when a result is truncated.

Passing zero or a negative `maxIssues` throws `ArgumentError`. Constructing inconsistent result metadata, such as a non-positive `issueLimit` or `isTruncated == true` without a limit, also throws `ArgumentError`.

## V2.8 writing-analysis diagnostics

Analyzer-produced `WritingAnalysisResult` values now expose exact deterministic finding totals in addition to the V2.7 retained-result metadata.

### `WritingAnalysisResult.totalIssueCount`

```dart
int? get totalIssueCount;
```

For values returned by `WritingAnalyzer.analyze()`, this is the exact number of findings yielded by all enabled, supported rules for the supplied analysis input. It includes findings that were observed but not retained because `maxIssues` limited the captured list.

Direct construction remains source-compatible with V2.7: callers may omit the diagnostic total, in which case `totalIssueCount` is `null` and the result must not be presented as having exact whole-analysis totals.

### `WritingAnalysisResult.totalIssueCountByRule`

```dart
Map<String, int>? get totalIssueCountByRule;
```

Analyzer-produced results expose an immutable map from analyzed rule ID to the exact number of findings produced by that rule. Disabled or unsupported rules are not counted. Enabled/supported rules that produce no findings may appear with a zero count according to the analyzer's result construction.

The map describes the same whole-analysis observation pass as `totalIssueCount`; it is not limited to `issues` when the result is truncated.

### `WritingAnalysisResult.hasExactIssueTotals`

```dart
bool get hasExactIssueTotals;
```

This is true when exact overall diagnostics are available. Analyzer-produced results return true. Direct V2.7-style result construction may return false.

### `WritingAnalysisResult.uncapturedIssueCount`

```dart
int? get uncapturedIssueCount;
```

When exact totals are present this equals:

```text
totalIssueCount - capturedIssueCount
```

For complete analyzer results the value is zero. For a genuinely truncated result it is positive. When exact totals are unavailable it is `null`.

### Result consistency requirements

`WritingAnalysisResult` validates exact diagnostics together with the existing V2.7 bounded metadata:

- an exact total cannot be smaller than the retained issue count;
- a complete result with exact totals must report an exact total equal to the retained count;
- a truncated result with exact totals must prove at least one uncaptured finding;
- captured findings must belong to a rule listed in `analyzedRuleIds`;
- captured findings must use the same `languageId` as the result;
- per-rule exact totals must be non-negative and may contain only analyzed rule IDs;
- the per-rule exact-total map must sum to the exact overall total;
- a per-rule exact total cannot under-report the retained count for that rule;
- exact diagnostic maps are exposed immutably.

### Analyzer behavior

```dart
final result = analyzer.analyze(
  text,
  languagePack: pack,
  maxIssues: 200,
);

print(result.capturedIssueCount);   // retained findings, at most 200
print(result.totalIssueCount);      // exact findings observed across the full analysis
print(result.uncapturedIssueCount); // exact omitted count when diagnostics are available
```

V2.8 does not change the meaning of `maxIssues`. The bound controls retained `WritingIssue` objects and downstream review workload. Enabled/supported rules are still scanned across the supplied text so the analyzer can preserve the correct global review-order prefix and compute exact diagnostics.

The diagnostics are count metadata only. They do not imply a CPU-time limit, wall-clock guarantee, document-size guarantee, network telemetry, or persistence behavior.

# V2.9 writing-analysis diagnostic summary

`package:spellchecker/writing.dart` exports `WritingAnalysisDiagnosticSummary` and `WritingRuleDiagnosticSummary`.

```dart
final result = WritingAnalyzer().analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
  maxIssues: 200,
);
final summary = WritingAnalysisDiagnosticSummary.fromResult(
  result,
  rules: WritingRuleRegistry.builtIns,
);
final reportText = summary.toPlainText();
```

`fromResult` snapshots only analysis metadata. Rule rows are ordered lexically by stable rule ID regardless of iterable/set insertion order. If a direct compatibility result omits V2.8 exact totals, the summary preserves that uncertainty and renders exact total/uncaptured values as unavailable rather than guessing.

`WritingAnalysisDiagnosticSummary` exposes language ID, captured count, optional exact total, optional capture limit, truncation state, immutable rule rows, `hasExactIssueTotals`, `uncapturedIssueCount`, and format version `1`. Each `WritingRuleDiagnosticSummary` contains rule ID/display name plus captured and optional exact total counts.

The formatter does not read or serialize editor text, source excerpts, finding messages, replacements, source offsets, personal vocabulary, ignored words, review filters, correction history, timestamps, device identifiers, telemetry, or network metadata. Constructing/formatting the summary has no persistence, clipboard, or network side effect.

# V2.10 developer benchmark API boundary

V2.10 adds developer tooling under `tool/benchmark/` and the `tool/benchmark_large_document.dart` command. These benchmark scenario/result/runner/options/reporter/command types are intentionally **not** exported from `package:spellchecker/spell_checker.dart`, `package:spellchecker/language.dart`, or `package:spellchecker/writing.dart`.

The benchmark composes the existing public spelling/language/writing APIs from outside the application runtime. V2.10 therefore adds no supported runtime package API surface, no application timing field on `SpellCheckReport` or `WritingAnalysisResult`, and no timing telemetry contract. Consumers that need performance measurements should treat the `tool/` implementation as repository developer tooling rather than a semver-stable library API.

See [V2.10 benchmark](V2_10_BENCHMARK.md) and [Performance](PERFORMANCE.md).

## V2.11 runtime and benchmark invariant hardening

`WritingInsightsDialog` remains an editor-feature widget rather than a new exported writing-model API, but its existing `maxIssues` constructor parameter is now validated at runtime. Values less than or equal to zero throw `ArgumentError` in release and debug builds. The default remains 200.

V2.11 does not change `WritingAnalyzer.analyze()`, `WritingAnalysisResult`, `WritingIssue`, writing-rule IDs, correction APIs, language packs, persistence keys, or diagnostic-summary format. Review keyboard shortcuts and semantic labels operate over the existing analysis/query models.

The developer benchmark under `tool/` strengthens its internal sample invariant: `writingTotalIssueCountByRule` must contain exactly one non-negative entry for every analyzed writing rule and no other rule. The runner materializes explicit zero values for analyzed rules that produced no findings before constructing a sample. This benchmark tooling remains outside the public package barrels and keeps JSON format version 1.
