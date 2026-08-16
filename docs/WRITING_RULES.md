# Writing Rules

This is the evergreen current-state contract for SpellChecker's deterministic local writing subsystem. Release-specific design and validation records are indexed in [Release history](RELEASE_HISTORY.md).

SpellChecker `2.16.0+21` has exactly **ten** built-in writing rules. All current built-ins declare English (`en`) support, so they are eligible for both built-in language packs, `en-US` and `en-GB`.

## Goals

The writing subsystem is designed to keep analysis local, deterministic, source-range-safe, language-aware, reviewable, and independent from Flutter widgets. A finding may be advisory without being automatically fixable; detection and mutation are intentionally separate decisions.

## Public imports

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';
```

`package:spellchecker/writing.dart` exports all ten built-in rule classes plus the analyzer, issue/correction types, review query/presets, categories, diagnostic summaries, and the `WritingRule` plugin contract.

## Current built-in catalogue

| Rule ID | Display purpose | Category | Severity | Automatic replacement |
| --- | --- | --- | --- | --- |
| `repeated-word` | consecutive repeated word | Clarity | warning | yes |
| `sentence-capitalization` | lowercase sentence start | Mechanics | suggestion | yes |
| `repeated-space` | repeated interior spaces | Mechanics | info | yes |
| `punctuation-spacing` | horizontal whitespace before common punctuation | Mechanics | info | yes |
| `missing-punctuation-space` | missing following space after `, ; ! ?` between words | Mechanics | info | yes |
| `trailing-whitespace` | horizontal whitespace at line/document end | Mechanics | info | yes |
| `repeated-punctuation` | repeated identical `! ? . ,` runs | Mechanics | info | yes |
| `unmatched-parenthesis` | unpaired literal parenthesis | Mechanics | warning | no; advisory |
| `unmatched-square-bracket` | unpaired literal square bracket | Mechanics | warning | no; advisory |
| `unmatched-curly-brace` | unpaired literal curly brace | Mechanics | warning | no; advisory |

`WritingRuleRegistry.builtIns` contains these rules in registry order. `WritingRuleRegistry.defaultEnabledRuleIds` is the set of all current built-in IDs.

## `WritingRule` plugin contract

A custom rule extends `WritingRule`:

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

`category` has a concrete default of `WritingRuleCategory.mechanics`, preserving source compatibility with external rules created before categories existed.

### Rule ID requirements

A rule ID is persistent machine-facing metadata used by preferences, Portable settings, diagnostics, review filtering, and registry lookup. A built-in/custom rule ID should:

- be stable;
- be unique within a `WritingAnalyzer` configuration;
- use a short lowercase identifier such as `example-rule`;
- not be reused for unrelated behavior;
- be treated as a migration problem if it must be renamed.

`WritingAnalyzer` rejects duplicate configured IDs at construction.

### Language eligibility

`supportedLanguageIds` can contain a full pack ID such as `en-US` or a language code such as `en`. `WritingRule.supports(pack)` accepts a rule when either the full ID or the pack's language code is present.

Do not duplicate this matching logic in UI integrations.

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

`WritingIssueSeverity` values are:

```dart
info
suggestion
warning
```

A finding has an automatic fix when `replacement != null`. An empty replacement is valid and represents deletion.

### Source ownership

`start` and `end` are zero-based UTF-16 offsets suitable for Dart `String.substring`/`replaceRange` and Flutter text-editing APIs. `start` is inclusive and `end` is exclusive.

For the source snapshot that produced a finding:

```dart
text.substring(issue.start, issue.end) == issue.originalText
```

Rules must not report an empty source range. Non-BMP characters can occupy two UTF-16 code units, so source offsets are **not** rune/scalar or grapheme-cluster indexes.

### Advisory versus automatic

Use `replacement: null` when a rule can prove a finding but cannot prove the correct mutation. The structural delimiter rules intentionally follow this path: an unmatched delimiter might need insertion, deletion, movement, or a larger rewrite.

The bundled UI exposes individual safe-fix actions only when a replacement is available. **Automatic fixes only** hides advisory findings.

## `WritingAnalyzer`

Default analysis:

```dart
final analyzer = WritingAnalyzer();
final result = analyzer.analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
);
```

Select a subset:

```dart
final result = analyzer.analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
  enabledRuleIds: <String>{
    'repeated-word',
    'sentence-capitalization',
  },
);
```

`enabledRuleIds == null` means run all configured rules that support the selected pack. An empty set means run none.

### Deterministic result ordering

Unbounded results are sorted by:

1. source `start` ascending;
2. severity ordering when starts are equal;
3. `ruleId` as a stable final tie-breaker.

Analyzer-produced results include `analyzedRuleIds`, retained `issues`, exact total finding count, and exact per-rule totals.

### Bounded analysis

`maxIssues` must be positive when supplied:

```dart
final result = analyzer.analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
  maxIssues: 200,
);
```

The bounded collector retains the globally earliest `maxIssues` findings in the same review ordering as an unbounded result. It can displace a retained finding when a later-executed rule yields an earlier source finding.

The analyzer still executes every enabled/supported rule across the supplied text so it can compute exact totals. Therefore `maxIssues` bounds retained finding objects, not total rule runtime or source length.

`isTruncated` becomes true only when at least one finding exists beyond the capture limit; merely reaching the numerical limit is not enough.

Analyzer-produced `WritingAnalysisResult` values provide:

```text
issues
analyzedRuleIds
languageId
issueLimit
isTruncated
isComplete
capturedIssueCount
totalIssueCount
totalIssueCountByRule
hasExactIssueTotals
uncapturedIssueCount
issueCountByRule
```

Exact totals are informational. They do not create correction authority for uncaptured source ranges.

## Bundled Writing insights policy

The application opens Writing insights with a capture limit of 200 findings. When the result is truncated:

- the dialog identifies the limited/captured state;
- exact totals can still be displayed when available;
- search, presets, categories, and automatic-fix filtering operate on captured findings only;
- individual and batch corrections operate on captured findings only;
- the UI does not reconstruct or mutate uncaptured findings from count metadata.

## Rule categories

Public categories are:

```dart
enum WritingRuleCategory {
  mechanics,
  clarity,
}
```

Category is review organization, not severity. The built-in `repeated-word` rule is Clarity; every other current built-in uses Mechanics.

## Review presets

`WritingReviewPreset` defines stable reusable filtering modes:

| ID | Display name | Query meaning |
| --- | --- | --- |
| `all-findings` | All findings | no category/fix-only restriction |
| `mechanics` | Mechanics | Mechanics category |
| `clarity` | Clarity | Clarity category |
| `automatic-fixes` | Automatic fixes | `automaticFixesOnly = true` |

Presets define review scope only. Free-text search remains transient and can be layered onto a preset through `toQuery(search: ...)`.

## `WritingReviewQuery`

A query contains:

```text
search
categories
automaticFixesOnly
```

It can filter both rules and findings. Search is trimmed/lowercased and can match rule IDs/names/descriptions/categories plus finding rule metadata, messages, source text, and replacement text.

`automaticFixesOnly` filters findings, not rule-management switches.

The bundled application keeps search, categories, preset choice, and automatic-fix filter state in memory only for the open dialog. Closing the dialog discards that review query.

## Per-language enabled-rule preferences

The bundled application persists explicit writing-rule IDs separately for each language. There are three distinct states.

### Unset

No key exists. Current registry defaults are used, filtered to rules that support the selected pack.

### Explicit non-empty set

Only the stored supported IDs are enabled. Adding a new built-in rule in a future release does not silently expand that explicit set.

### Explicit empty set

The stored list is empty and intentionally means “all writing rules disabled for this language.” It must not be treated as unset.

### Reset rules to defaults

**Reset rules to defaults** removes the selected language's explicit override. The language then follows current/future registry defaults rather than storing a snapshot of today's default IDs.

Unknown/stale stored IDs are ignored by the effective-rule calculation instead of causing analysis failure.

See [Configuration and local data](CONFIGURATION.md) for persistence and Portable settings semantics.

## Safe individual correction

```dart
final result = WritingCorrection.apply(text, issue);
```

The correction is applied only when:

- `issue.replacement` is non-null;
- the source range is valid/non-empty;
- the current substring still equals `issue.originalText` exactly.

Otherwise the original text is returned with `applied == false`.

## Safe batch correction

```dart
final result = WritingCorrection.applyAll(text, issues);
```

Batch candidates are sorted by:

1. `start` ascending;
2. `end` ascending;
3. `ruleId` ascending.

The batch skips:

- advisory issues;
- stale/invalid source ranges;
- a later candidate that overlaps an already accepted candidate.

Accepted edits are applied from the end of the document toward the beginning so replacement length changes do not invalidate source offsets to the left.

`WritingBatchCorrectionResult` reports:

```text
text
caretOffset
appliedCount
skippedCount
applied
```

The bundled editor records one pre-batch editing value, so one accepted writing batch is one undoable correction.

When review filters are active, the UI sends only currently visible automatic findings to the same `applyAll` algorithm. There is no separate less-safe filtered correction path.

## Diagnostic summaries

`WritingAnalysisDiagnosticSummary.fromResult(...)` converts a result into deterministic metadata suitable for support/benchmark discussion:

```dart
final summary = WritingAnalysisDiagnosticSummary.fromResult(
  result,
  rules: analyzer.rules,
);

print(summary.toPlainText());
```

The summary includes language, complete/limited state, capture limit, captured/exact/uncaptured counts when available, and per-rule metadata/counts. It deliberately excludes editor text, source excerpts, messages, replacements, and source offsets.

## Built-in rule details

### `repeated-word`

Finds two consecutive tokens whose normalized words are equal and whose gap contains whitespace only. The finding owns the separator plus second occurrence and uses an empty replacement to remove the duplicate. Category: Clarity. Severity: warning.

### `sentence-capitalization`

Finds a lowercase first word at the beginning of the text or after a lightweight English sentence boundary and proposes a Unicode-scalar-safe capitalization of the first scalar. It recognizes common closing punctuation after a sentence terminator and opening quote/bracket characters before the next word. It is intentionally not a full sentence parser. Severity: suggestion.

### `repeated-space`

Finds runs of two or more literal spaces in interior prose and replaces them with one space. It deliberately avoids ranges immediately before common punctuation or line/document endings because those ranges are owned by specialized spacing rules. Severity: info.

### `punctuation-spacing`

Finds horizontal spaces/tabs immediately before `, . ; : ! ?`. The finding owns only the whitespace run and replaces it with an empty string. Severity: info.

### `missing-punctuation-space`

Finds `,`, `;`, `!`, or `?` between Unicode letter boundaries when the following word begins immediately without horizontal whitespace. The predecessor pattern supports a Unicode letter followed by combining marks. The finding owns only the punctuation mark and replaces it with the same mark plus one space. Periods and colons are intentionally outside this automatic rule. Severity: info.

This source ownership composes safely with `punctuation-spacing`: in `Hello ,world`, the whitespace before the comma and the comma itself are adjacent, non-overlapping findings.

### `trailing-whitespace`

Finds horizontal spaces/tabs immediately before LF/CRLF line endings or the end of the document. Newline characters are not included in the finding range. The replacement removes the trailing horizontal whitespace. Severity: info.

### `repeated-punctuation`

Finds runs of the same `!`, `?`, `.`, or `,` character repeated two or more times and proposes the first mark only. It does not interpret every intentional stylistic punctuation sequence. Severity: info.

### `unmatched-parenthesis`

Balances literal `(` and `)` iteratively, supports nesting, and reports each unmatched parenthesis as a one-character UTF-16 source range. It is warning-level and advisory only.

### `unmatched-square-bracket`

Balances literal `[` and `]` iteratively, supports nesting, and reports each unmatched bracket as a one-character UTF-16 source range. It is warning-level and advisory only.

### `unmatched-curly-brace`

Balances literal `{` and `}` iteratively, supports nesting, and reports each unmatched brace as a one-character UTF-16 source range. It is warning-level and advisory only.

The three structural rules are literal character-balancing checks. They do not parse programming-language syntax, Markdown, template languages, strings/comments, URLs, or other domain-specific grammars.

## Adding a custom rule

Example:

```dart
class ExampleRule extends WritingRule {
  const ExampleRule();

  @override
  String get id => 'example-rule';

  @override
  String get displayName => 'Example rule';

  @override
  String get description => 'Finds TODO placeholders.';

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
        languageId: languagePack.id,
        replacement: null,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
```

Configure an analyzer with custom rules:

```dart
final analyzer = WritingAnalyzer(
  rules: const <WritingRule>[ExampleRule()],
);
```

## Built-in rule change checklist

A new or modified built-in rule should be reviewed for:

- stable/unique rule ID;
- user-facing name and description;
- category and severity;
- explicit language eligibility;
- exact UTF-16 source ownership;
- Unicode scalar/combining-mark behavior where relevant;
- advisory versus deterministic replacement choice;
- interaction with every automatic built-in rule;
- stale-source behavior;
- deterministic batch overlap behavior;
- bounded-result exact totals;
- preference/default compatibility;
- Portable settings compatibility;
- review search/category/fix-only behavior;
- diagnostic-summary totals;
- widget workflow and one-step undo;
- stress coverage for structural/iterative algorithms;
- benchmark identity/load implications.

Do not add a replacement merely to make a rule “fixable” when the correct edit is ambiguous.

## Privacy and security boundary

Writing rules receive source text in memory from the caller. The built-in application does not persist editor text or writing findings to preference storage and does not require a cloud grammar API, generative rewriting service, analytics SDK, telemetry pipeline, remote logger, or account system.

The built-in registry contains source-controlled Dart rules. SpellChecker does not dynamically download or execute third-party rule code. Any future external plugin-loading system would need an explicit trust/signing/update/permission/privacy design before implementation.

## Non-goals

The current writing subsystem does not claim:

- full grammar parsing;
- semantic correctness checking;
- generative rewriting;
- style scoring;
- automatic language detection;
- syntax-aware source-code/template parsing;
- untrusted dynamic plugin execution;
- background document monitoring.

Its purpose is deterministic, explainable, local rule execution with conservative correction safety.

## Historical design records

Detailed release records remain available for the major writing-system milestones:

- [V2.9 diagnostic summary](V2_9_DIAGNOSTIC_SUMMARY.md)
- [V2.11 accessibility](V2_11_ACCESSIBILITY.md)
- [V2.12 missing punctuation spacing](V2_12_MISSING_PUNCTUATION_SPACING.md)
- [V2.13 unmatched parenthesis](V2_13_UNMATCHED_PARENTHESIS.md)
- [V2.14 unmatched square bracket](V2_14_UNMATCHED_SQUARE_BRACKET.md)
- [V2.15 unmatched curly brace](V2_15_UNMATCHED_CURLY_BRACE.md)
- [V2.16 bug audit](V2_16_BUG_AUDIT.md)
- [Post-V2.16 audit](POST_V216_AUDIT_2026_08_16.md)

Use those files for historical migration/validation context and this page for current behavior.

## Related documentation

- [Feature reference](FEATURES.md)
- [User guide](USER_GUIDE.md)
- [Examples](EXAMPLES.md)
- [Public API](API.md)
- [Configuration](CONFIGURATION.md)
- [Performance](PERFORMANCE.md)
- [Testing](TESTING.md)
- [Glossary](GLOSSARY.md)
