# V2.14 Unmatched Square Bracket Diagnostics

SpellChecker V2.14 adds a deterministic, local, advisory-only writing rule for literal unmatched square brackets. The rule is intentionally narrower than a parser: it balances `[` and `]` characters in source order and reports square-bracket characters that cannot participate in a matching pair.

## Release identity

- Package target: `2.14.0+19`
- About target: `2.14.0`
- Public class: `UnmatchedSquareBracketRule`
- Stable rule ID: `unmatched-square-bracket`
- Default registry size: nine built-in writing rules
- Eligibility: language code `en`, covering both built-in English packs
- Category: Mechanics through the source-compatible `WritingRule` default
- Severity: warning
- Automatic replacement: none

## Matching contract

The rule scans UTF-16 source offsets from left to right.

- `[` pushes its source index onto an iterative opening stack.
- `]` consumes the most recent unmatched opening when one exists.
- A `]` with no available opening is unmatched immediately.
- Openings left on the stack at the end are unmatched.
- Findings are emitted in ascending source order.
- Nested structures such as `[outer [inner] text]` are accepted.
- Malformed ordering such as `]middle[` produces two findings in source order.
- Parentheses and curly braces are outside this rule's ownership.

The implementation does not recurse. Regression coverage includes 5,000 levels of balanced square-bracket nesting and 5,000 unmatched openings.

## Exact source ownership

Every finding owns exactly one unmatched square-bracket character:

```text
start = square-bracket UTF-16 offset
end   = start + 1
originalText = "[" or "]"
```

This keeps source ownership explicit and stable around non-BMP text. For example, in `😀]` the closing square bracket begins at UTF-16 offset `2` because the emoji occupies two code units.

The V2.13 parenthesis rule and V2.14 square-bracket rule remain independent. A document may therefore contain findings from both structural rules without either rule claiming the other delimiter family.

## Why the rule is advisory-only

An unmatched square bracket does not have one universally safe correction. Depending on intent, the user may need to:

- insert the opposite bracket elsewhere;
- delete the reported character;
- move surrounding text or punctuation;
- rewrite a larger expression.

V2.14 therefore does not guess. `replacement` remains `null` and `hasAutomaticFix` is false. `WritingCorrection.applyAll` skips the finding and records it in the skipped count while still applying independent deterministic fixes from other rules.

The Writing insights **Automatic fixes only** filter excludes advisory square-bracket findings. A document whose only finding is an unmatched square bracket does not show an **Apply all safe fixes** action.

## Preference compatibility

V2.14 does not change the existing writing-rule preference key family or Portable settings format.

- An unset per-language writing-rule preference resolves to the current nine-rule default registry.
- Resetting rules clears the stored override and therefore adopts the current nine-rule defaults.
- An explicit V2.13 eight-rule set remains authoritative and does not silently gain `unmatched-square-bracket`.
- An explicit V2.12 seven-rule set remains authoritative for the same reason.
- An explicit empty set remains an explicit disable-all choice.
- Portable settings preserve an old explicit V2.13 eight-rule override unchanged.
- Portable settings preserve `unmatched-square-bracket` when it is explicitly present in a V2.14 nine-rule override.

This continues the existing forward-compatible distinction between “follow current defaults” and “use this exact explicit rule set.”

## Bounded analysis and exact diagnostics

The new rule participates in existing `WritingAnalyzer` semantics without changing their public result format.

- exact-at-limit results remain complete;
- overflow retains the globally earliest source-ordered prefix;
- `totalIssueCount` counts all observed findings;
- `totalIssueCountByRule['unmatched-square-bracket']` reports the exact whole-document rule total;
- benchmark samples materialize an explicit zero when the rule has no finding;
- privacy-safe diagnostic summaries include only stable rule metadata and counts, never document excerpts.

A bounded mixed-rule regression also verifies that an earlier capitalization or repeated-space finding remains ahead of a later unmatched square bracket when only the first global finding may be retained.

## Benchmark integration

The deterministic benchmark workload identity expands from eight to nine sorted built-in rule IDs and includes `unmatched-square-bracket`.

A focused benchmark regression uses a controlled one-finding square-bracket corpus and asserts exact captured, total, and per-rule counts. Timing values remain observations rather than correctness thresholds.

## Review and editor integration

The rule participates in the existing Writing insights review model rather than introducing a separate workflow.

- Searching for `square bracket` matches the rule and its finding metadata.
- The Mechanics category includes the rule.
- **Automatic fixes only** filters out the advisory finding.
- The rule switch is enabled under unset/default preferences.
- Explicit disable choices persist using the existing per-language preference key.
- An explicit V2.13 eight-rule override displays the V2.14 rule disabled until the user resets to defaults or explicitly enables it.
- Resetting rules clears the override and restores all nine current defaults.

The list remains lazy and scrollable; tests locate controls by build state/visibility rather than relying on a historical catalogue height.

## Deliberate parser limitation

V2.14 is a literal square-bracket balancer, not a language, Markdown, programming-language, URL, citation, mathematical, or domain-specific parser. It does not attempt to infer whether brackets occur inside:

- source-code or Markdown code spans;
- quoted strings;
- escaped syntax;
- URLs;
- citations or reference notation;
- mathematical notation;
- another domain-specific grammar.

That limitation is intentional. Future syntax-aware suppression would require an explicit parsing contract and regression corpus rather than heuristic automatic mutation.

## Privacy and security boundary

The rule runs locally over the supplied in-memory string. V2.14 adds no network request, telemetry, account, cloud grammar service, background upload, document persistence, new storage key, runtime dependency, or hidden clipboard action.

The existing explicit diagnostic-summary copy action continues to exclude editor text and finding excerpts. A dedicated regression verifies that private source surrounding an unmatched square bracket does not appear in the copied diagnostic summary.

## Regression files

V2.14 adds or extends coverage in:

- `test/unmatched_square_bracket_rule_test.dart`
- `test/v214_unmatched_square_bracket_integration_test.dart`
- `test/v214_unmatched_square_bracket_widget_test.dart`
- `test/v214_rule_preference_compatibility_widget_test.dart`
- `test/v214_settings_transfer_rule_compatibility_test.dart`
- `test/v214_writing_diagnostic_summary_test.dart`
- `test/v214_bounded_square_bracket_analysis_test.dart`
- `test/v214_square_bracket_stress_test.dart`
- `test/v214_review_query_square_bracket_test.dart`
- `test/v214_benchmark_square_bracket_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`

Additional release/widget regressions are synchronized before merge as the V2.14 release identity and documentation become permanent.

## Release acceptance boundary

The V2.14 candidate is not accepted solely because focused tests pass. The exact permanent release head must pass:

```text
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
dart run tool/benchmark_large_document.dart \
  --repeats=4 \
  --warmup=0 \
  --iterations=1 \
  --spelling-limit=2 \
  --writing-limit=5 \
  --suggestions=0 \
  --language=en-US \
  --json
flutter build web --release
```

The release gate also verifies package/About identity, the public export and stable rule ID, exactly nine built-in rule constructors, V2.14 focused regression files, release documentation and `what_changed.md`, valid web-manifest JSON, unchanged direct runtime dependencies, generated web output, and zero unexpected disposable V2.14 helper residue.
