# Writing Rules

SpellChecker 2.x includes an optional local writing-rules subsystem. It is designed for deterministic, explainable checks that can run entirely in memory without transmitting editor text to a remote grammar or rewriting service.

This document is the contributor and integration contract for that subsystem.

## Design goals

The writing-rules layer is designed to:

1. Keep writing analysis independent from Flutter widgets.
2. Keep rules deterministic and testable.
3. Make language eligibility explicit.
4. Keep every finding tied to an exact source range.
5. Distinguish advisory findings from automatic fixes.
6. Refuse stale automatic corrections.
7. Resolve batch-fix overlaps deterministically.
8. Reuse the editor's bounded correction undo history.
9. Keep editor text and analysis results memory-only.
10. Allow users to choose which local rules are enabled for each language.

## Public imports

Reusable writing APIs are exported through:

```dart
import 'package:spellchecker/writing.dart';
```

Language packs are available through:

```dart
import 'package:spellchecker/language.dart';
```

## `WritingRule`

A writing rule implements the public plugin contract:

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

### Stable rule IDs

`id` is a persistent identifier, not only a display label. V2.1 stores enabled rule IDs locally, so changing an existing ID silently would make old preferences stop matching the rule.

Requirements:

- Use a short lowercase hyphenated identifier.
- Keep IDs unique across the built-in registry.
- Do not reuse an old ID for unrelated behavior.
- Treat an ID rename as a preference migration problem.
- Add persistence/migration tests if an ID must change.

Current built-in IDs are:

```text
repeated-word
sentence-capitalization
repeated-space
punctuation-spacing
trailing-whitespace
repeated-punctuation
```

## Language eligibility

Rules declare supported language identifiers through `supportedLanguageIds`.

A rule can target:

- A full pack ID such as `en-US`.
- A language code such as `en`, when the implementation is valid for all registered variants of that language.

`WritingRule.supports(pack)` is the authority for eligibility. UI code should not duplicate language matching logic.

The current built-in English rules use `en`, so they support both built-in `en-US` and `en-GB` packs.

## `WritingIssue`

A rule returns immutable findings containing:

```dart
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

### Source range contract

For a current finding:

```dart
text.substring(issue.start, issue.end) == issue.originalText
```

when the source text has not changed since analysis.

Rules must return:

- Zero-based inclusive `start`.
- Zero-based exclusive `end`.
- A non-empty source range.
- `originalText` copied from exactly that range.
- The language ID of the pack that produced the finding.

Do not make a rule depend on the UI mutating source offsets after analysis.

## Advisory findings versus automatic fixes

A finding is advisory when `replacement == null`.

An automatic fix is available when a deterministic replacement string is present. An empty string is a valid replacement and can represent deletion, such as removing a repeated word suffix.

Rules should provide automatic replacements only when the transformation is sufficiently deterministic for the rule's documented scope.

The UI exposes **Apply safe fix** only for findings with automatic replacements.

## `WritingAnalyzer`

The analyzer owns rule selection and deterministic result ordering:

```dart
final analyzer = WritingAnalyzer();
final result = analyzer.analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
  enabledRuleIds: enabledIds,
);
```

If `enabledRuleIds` is `null`, the analyzer runs every supported rule in its configured registry. If a set is supplied, only supported rules whose IDs are present are analysed.

Findings are sorted by:

1. Source start.
2. Severity ordering used by the implementation when starts match.
3. Rule ID as a deterministic final tie-breaker.

`WritingAnalysisResult` also exposes the set of rule IDs that actually ran and per-rule finding counts.

## Registry defaults

`WritingRuleRegistry.builtIns` contains the built-in rules.

`WritingRuleRegistry.defaultEnabledRuleIds` is the default enablement set for users who have never configured writing rules for the active language.

Changing this default affects only the **unset** preference state. It must not overwrite an explicit stored user choice.

## Per-language rule preferences

V2.1 stores enabled writing-rule IDs through `DictionaryPreferences` using a versioned language-specific key:

```text
spellchecker.writing_rule_ids.v1.<language-id>
```

For example:

```text
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

The storage contract deliberately distinguishes:

### Unset

No key exists.

`loadWritingRuleIds()` returns `null`, and the editor uses `WritingRuleRegistry.defaultEnabledRuleIds` filtered to rules supported by the current language pack.

This is the backward-compatible state for users upgrading from V2.0.

### Explicit non-empty set

The key contains one or more rule IDs.

The editor restores those IDs, intersected with rules that still exist and support the selected language.

Unknown/stale IDs are ignored by the effective-rule calculation rather than causing analysis failure.

### Explicit empty set

The key exists with an empty string list.

This is a real user preference meaning **all writing rules disabled for that language**. It must not be collapsed into the unset/default state.

### Normalization

Stored rule IDs are:

- Trimmed.
- Empty IDs removed.
- Deduplicated.
- Alphabetically sorted before persistence.

## Language switching

When the editor changes from one language pack to another, it restores:

- That language's personal dictionary.
- That language's writing-rule preference set.
- A new language-specific spelling engine/session state.

A writing rule disabled in `en-US` does not become disabled in `en-GB` unless it was separately disabled there.

## Persistence failure behavior

Writing-rule switches change the active in-memory session immediately.

If the local preference write fails:

- The current session choice remains active.
- The application marks local storage unavailable.
- The user receives a readable persistence warning.
- The UI does not falsely claim the choice was durably saved.

Editor text and writing findings are never written to the preference store.

## Individual safe correction

Use:

```dart
final result = WritingCorrection.apply(text, issue);
```

The correction is applied only when:

- The issue has a replacement.
- `start` and `end` are valid for the current text.
- The source range is non-empty.
- The current substring still equals `originalText` exactly.

Otherwise `applied` is false and the original text is returned unchanged.

## Batch safe correction

V2.1 adds:

```dart
final result = WritingCorrection.applyAll(text, issues);
```

The result is a `WritingBatchCorrectionResult` containing:

```dart
text
caretOffset
appliedCount
skippedCount
applied
```

### Batch candidate ordering

Candidates are sorted by:

1. `start` ascending.
2. `end` ascending.
3. `ruleId` ascending.

This ordering defines deterministic overlap resolution.

### Findings that are skipped

A finding is skipped when:

- It has no automatic replacement.
- Its source range is invalid.
- Its current source text no longer equals `originalText`.
- It overlaps a previously accepted automatic fix.

Skipped findings increment `skippedCount`.

### Overlap policy

If two automatic fixes overlap, the earlier deterministic candidate wins. A later overlapping finding is skipped rather than merging transformations or applying an ambiguous order.

This is intentionally conservative. A future richer conflict-resolution system must be explicit and separately tested rather than changing the meaning of V2.1 batch correction silently.

### Application order

Accepted edits are applied from the end of the document toward the beginning. This prevents a replacement with a different length from invalidating the still-to-be-applied source offsets to its left.

### Caret

The returned caret is adjusted to point immediately after the last accepted source occurrence in the resulting text and is clamped to a valid offset.

## Editor batch workflow

Writing insights displays **Apply all safe fixes (N)** when at least one current finding has an automatic replacement.

Selecting it:

1. Returns the current automatic findings to the editor.
2. Runs `WritingCorrection.applyAll` against the current editor text.
3. Refuses the operation when no safe non-overlapping fix remains.
4. Pushes the pre-batch `TextEditingValue` once onto the bounded correction stack.
5. Replaces the editor text with the single final batch result.
6. Refreshes spelling state.
7. Reports the applied and skipped counts.

The whole batch is therefore **one undoable correction**.

## Correction history

Spelling fixes and writing fixes share the editor's bounded in-memory correction history.

The history is not a document persistence system. It is cleared when manual editing starts a new correction history and disappears when the application session ends.

## Keyboard workflow

V2.1 adds:

```text
Ctrl+Shift+Enter     Open Writing insights on Windows/Linux/web keyboards
Command+Shift+Enter  Open Writing insights on macOS keyboards
```

These shortcuts complement the existing spelling-check and F7 navigation shortcuts. The app-bar Writing insights control remains available for pointer/touch and assistive-technology users.

## Built-in rules

### Repeated word

ID: `repeated-word`

Finds the same normalized word repeated consecutively when only whitespace separates the two token matches.

The replacement removes the separator plus the second occurrence represented by the issue range.

### Sentence capitalization

ID: `sentence-capitalization`

Finds supported sentence-start words that begin with a lowercase letter and proposes a deterministic capitalization replacement.

It is intentionally lightweight and not a complete sentence parser.

### Repeated spaces

ID: `repeated-space`

Finds runs of repeated horizontal spaces and proposes a single space. Newline handling remains outside this rule's scope.

### Repeated punctuation

ID: `repeated-punctuation`

Finds supported repeated identical punctuation runs and proposes one punctuation mark.

It does not attempt stylistic interpretation of every punctuation sequence.

## Adding a new rule

A new built-in rule should include all of the following:

1. A stable unique rule ID.
2. User-readable display name and description.
3. Explicit language eligibility.
4. Deterministic source ranges.
5. Exact `originalText` values.
6. Automatic replacement only when safe for the documented scope.
7. Unit tests for positive cases.
8. Unit tests for non-matching/edge cases.
9. Analyzer/ordering tests when interaction with other rules matters.
10. Batch-overlap tests when its ranges can overlap another automatic rule.
11. User documentation.
12. Changelog/release notes when shipped.

## Rule interaction review

Before adding a rule, test interaction with every built-in automatic rule on representative synthetic text.

Pay particular attention to:

- Identical start offsets.
- Nested ranges.
- Partially overlapping ranges.
- Replacements that change text length.
- Empty-string replacements.
- Unicode source text.
- Language-pack normalization.

## V2.2 rule categories

`WritingRuleCategory` is public review metadata:

```dart
enum WritingRuleCategory {
  mechanics('Mechanics'),
  clarity('Clarity');
}
```

`WritingRule.category` has a concrete default of `WritingRuleCategory.mechanics`. This is intentionally source-compatible with 2.0/2.1 external rule implementations that implemented the original abstract contract before categories existed.

Rules should override the getter only when another category is a clearer user-facing fit. The built-in `repeated-word` rule is categorized as **Clarity**; the other current built-ins inherit **Mechanics**.

Category names are review organization, not severity. `WritingIssueSeverity` remains a separate finding property.

## V2.2 reusable review query

`WritingReviewQuery` keeps review filtering outside Flutter widgets:

```dart
final query = WritingReviewQuery(
  search: 'clarity',
  categories: <WritingRuleCategory>{WritingRuleCategory.clarity},
  automaticFixesOnly: true,
);

final visibleRules = query.filterRules(analyzer.rules);
final visibleIssues = query.filterIssues(
  analysis.issues,
  rules: analyzer.rules,
);
```

Search is trimmed/lowercased and can match rule ID/name/description/category plus finding rule metadata, message, exact finding source text, and suggested replacement.

When a category filter is active, a finding whose rule is unavailable in the supplied rule collection is excluded instead of being guessed into a category. Writing insights passes its actual analyzer's supported rule set so custom analyzers retain their own category metadata.

`automaticFixesOnly` filters findings only; it does not hide rule switches. Users can still manage rule enablement while reviewing only automatically fixable findings.

## V2.2 transient review state

Writing insights review filters are intentionally not application preferences:

```text
search text                memory-only dialog state
selected categories        memory-only dialog state
automatic-fixes-only       memory-only dialog state
visible counts/results     derived memory-only state
```

Closing Writing insights discards these filters. Only enabled writing-rule IDs remain persisted per language.

## Filtered batch correction

When review filters are inactive, Writing insights displays **Apply all safe fixes (N)**. When any review filter is active it displays **Apply visible safe fixes (N)** and sends only visible automatic findings to `WritingCorrection.applyAll`.

This does not create a second correction algorithm. V2.1 batch invariants remain authoritative: current-source validation, advisory skipping, deterministic overlap handling, end-to-start accepted mutation, applied/skipped counts, and one-step undo.

A hidden finding is simply not part of that user-requested filtered batch. Reopen/clear filters to review or apply other findings.

## Reset rules to defaults — V2.2

Writing insights can return `resetRulePreferences: true`. The page then:

1. Resolves current registry defaults for the selected language.
2. Activates those defaults for the current session.
3. Calls `DictionaryPreferences.clearWritingRuleIds(languageId: ...)`.
4. Leaves the language in the **missing key / registry defaults** state after a successful clear.
5. Does not apply an individual/batch finding as part of the reset action.

This is deliberately different from storing today's default rule IDs. A future release can evolve `WritingRuleRegistry.defaultEnabledRuleIds`, and a user who chose Reset will receive that new default because no explicit override remains.

If clearing fails, the current-session defaults remain active but the application reports that the saved override could not be removed; the old override may return on restart.

## V2.3 review presets

`WritingReviewPreset` is public review-organization metadata layered on `WritingReviewQuery`. Stable built-ins are:

```text
all-findings      -> no category/fix-only filter
mechanics         -> Mechanics category
clarity           -> Clarity category
automatic-fixes   -> automaticFixesOnly = true
```

Preset IDs are stable public metadata and require compatibility/release review before renaming or semantic reuse. A preset does not persist search text or rule choices. `toQuery(search: ...)` accepts the current transient search so preset changes can retain the user's local search context.

Writing insights can still create custom combinations by using the category chips and automatic-fix switch directly. That custom transient state does not require or synthesize a new preset ID.

Preset changes select review scope only. Individual/batch correction authority remains `WritingCorrection.apply`/`applyAll`, including stale-range validation, overlap handling, end-to-start application, applied/skipped counts, and one-step undo.


## Tests

Relevant test files include:

```text
test/writing_review_preset_test.dart
test/writing_review_query_test.dart
test/writing_rules_test.dart
test/writing_correction_test.dart
test/writing_preferences_test.dart
test/writing_widget_test.dart
```

V2.1 regression coverage includes:

- Built-in rule behavior.
- Analyzer enable/disable filtering.
- Language eligibility.
- Individual current/stale corrections.
- Multiple safe batch fixes.
- Advisory/stale batch skipping.
- Deterministic overlap handling.
- All-unsafe batch input.
- Unset/default rule preference semantics.
- Explicit empty rule preference semantics.
- Per-language preference isolation.
- Startup restoration.
- Dialog switch persistence.
- Batch apply plus one-step undo.
- Writing insights keyboard shortcut.

## Privacy boundary

Writing analysis receives the current editor text in memory only when invoked by the application workflow.

SpellChecker does not persist:

- Editor documents.
- Writing findings.
- Rule messages.
- Finding source snippets.
- Batch correction plans.
- Correction undo snapshots.

V2.1 newly persists only **writing-rule identifiers**, namespaced by language.

No cloud grammar API, AI rewriting service, analytics SDK, advertising SDK, telemetry pipeline, remote logger, or account system is required by the writing-rules subsystem.

## Security boundary

The current built-in registry contains source-controlled Dart rules. V2.1 does not dynamically download or execute third-party rule code.

Any future external plugin-loading design must define trusted code boundaries, signing/origin expectations, update behavior, permission scope, and privacy implications before implementation.

## Non-goals

The current subsystem does not claim to provide:

- Full grammar parsing.
- Automatic semantic rewriting.
- Style scoring.
- AI-generated prose.
- Remote model inference.
- Automatic language detection.
- Untrusted dynamic plugin execution.
- Background document monitoring.

The intended foundation is deterministic, local, inspectable rule execution that can be extended without weakening correction safety or privacy.

## V2.6 deterministic spacing rules

V2.6 expands `WritingRuleRegistry.builtIns` with two English Mechanics rules:

```text
punctuation-spacing
trailing-whitespace
```

### Punctuation spacing

`PunctuationSpacingRule` matches one or more horizontal spaces/tabs immediately before `, . ; : ! ?`. Its `originalText` is exactly the whitespace run and its deterministic automatic replacement is the empty string. It does not rewrite the punctuation itself.

### Trailing whitespace

`TrailingWhitespaceRule` matches horizontal spaces/tabs immediately before LF/CRLF line endings or at the document end. Newline characters are not part of the issue range; the automatic replacement removes only the trailing horizontal whitespace.

### Non-overlapping ownership

`RepeatedSpaceRule` now matches repeated **interior** spaces only. It deliberately excludes repeated runs immediately before common punctuation and before line/document endings. Those source ranges belong to the V2.6 specialized rules. The separation prevents a batch from receiving both “collapse to one space” and “remove all whitespace” candidates for the same range.

This does not change `WritingCorrection.applyAll` overlap semantics. Start/end/rule-ID ordering and conservative overlap skipping remain the global safety contract for genuinely overlapping findings from independent rules.

### Preference compatibility

The two new IDs are members of `WritingRuleRegistry.defaultEnabledRuleIds`. Therefore:

```text
unset preference      -> current six-rule defaults, including V2.6 rules
explicit non-empty    -> exactly the stored supported IDs; no silent expansion
explicit empty list   -> all rules disabled; no silent expansion
Reset rules           -> clears override -> current six-rule defaults
```

The existing `spellchecker.writing_rule_ids.v1.<language-id>` key meaning and storage format do not change. Both rules declare `en`, so they support the built-in `en-US` and `en-GB` packs.

### V2.6 regression requirements

Changes to either spacing rule must keep tests for exact source ranges, LF/CRLF/document-end handling, punctuation adjacency, interior-space ownership, English pack support, default registry membership, safe batch composition, Writing insights visibility, and one-step undo.

## V2.7 bounded writing analysis

`WritingAnalyzer.analyze()` accepts an optional positive `maxIssues` argument. Omitting it preserves the historical unbounded contract.

A bounded `WritingAnalysisResult` exposes `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`. Reaching the numerical limit alone does not make a result truncated: truncation is reported only after an additional finding is observed.

The bounded collector keeps at most `maxIssues` finding objects while preserving the same globally sorted prefix produced by unbounded analysis. Rules may yield findings in arbitrary source order, and later rules may yield an earlier source range, so the collector can displace a worse retained finding rather than simply stopping after the first N yielded values.

The analyzer still invokes every enabled and supported rule across the supplied text. This is a finding-retention bound, not a rule-runtime, character-count, or document-length bound.

The built-in Writing insights dialog requests at most 200 captured findings. When overflow is proven, filters operate on captured findings only, and batch actions use **Apply captured safe fixes** or **Apply visible captured safe fixes** wording. Existing stale-source, advisory-skip, overlap-resolution, end-to-start mutation, and one-step undo contracts remain unchanged.

## V2.8 exact finding diagnostics

Writing rules still implement the same `WritingRule.analyze()` contract. V2.8 does not add a required rule member or change a shipped rule ID.

The analyzer now counts every `WritingIssue` yielded by each enabled/supported rule while building the retained result. This creates two distinct per-rule views:

- retained count — how many findings from that rule are present in `WritingAnalysisResult.issues`;
- exact total count — how many findings that rule yielded during the whole analyzer pass when V2.8 diagnostics are available.

A truncated result may therefore report, for example:

```text
repeated-space retained findings: 31
repeated-space total findings:    420
```

The retained list still contains the globally earliest findings across all rules, not the first N matches from each rule independently.

### Custom rule requirements remain unchanged

A custom rule should continue to:

- be deterministic for a given text/language/configuration;
- yield exact source ranges and `originalText`;
- declare stable ID/display metadata;
- avoid side effects;
- provide automatic replacements only when deterministic;
- document expensive behavior if it scans or allocates unusually large structures.

V2.8 exact counters assume each yielded finding represents one logical finding. Rules should not intentionally yield duplicate equivalent findings merely to communicate metadata.

### Diagnostics and correction scope

Exact total counts are informational. They do not authorize correction of uncaptured findings. In a truncated Writing insights result, search, review presets/categories, individual fixes, and batch fixes continue to operate only on retained findings.

A future feature that wants to mutate uncaptured ranges must obtain a complete/current correction-safe issue set rather than reconstructing edits from count metadata.

### Language and preference behavior

Exact per-rule totals are computed only for rules that are enabled and support the active language pack. Per-language persisted rule preferences therefore continue to determine which rules participate. V2.8 adds no preference key and does not persist diagnostic counts.

## V2.9 analyzer/result hardening and diagnostic summaries

`WritingAnalyzer` now rejects duplicate configured rule IDs at construction. A stable rule ID identifies persistence, filtering, totals, and diagnostic rows; allowing two configured rules to share it would make those contracts ambiguous.

`WritingAnalysisResult` additionally validates that every captured issue belongs to an analyzed rule and uses the result language, and that exact per-rule total keys belong to analyzed rules. These are runtime public-value invariants, not debug-only assertions.

V2.9 also exports `WritingAnalysisDiagnosticSummary` / `WritingRuleDiagnosticSummary`. The summary derives deterministic count/rule metadata from a result, sorts rows by stable rule ID, represents missing V2.8 exact totals as unavailable, and deliberately omits document text, excerpts, messages, replacements, and source offsets. See [V2_9_DIAGNOSTIC_SUMMARY.md](V2_9_DIAGNOSTIC_SUMMARY.md).

## V2.10 benchmark interaction with writing rules

The V2.10 benchmark constructs the normal `WritingAnalyzer()` and therefore exercises the current built-in deterministic registry against generated synthetic text. It does not add, remove, rename, enable, persist, or dynamically load a writing rule. All six existing stable IDs/defaults and their source-range/correction contracts remain unchanged.

The benchmark records only captured/exact-total/truncated writing outcome metadata and elapsed time. It does not serialize `WritingIssue` source text/messages into the benchmark report and does not convert writing `maxIssues` into a CPU-time guarantee.
