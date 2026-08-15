# V2.13 Unmatched Parenthesis Diagnostics

SpellChecker V2.13 adds a deterministic, local, advisory-only writing rule for literal unmatched parentheses. The rule is intentionally narrower than a parser: it balances `(` and `)` characters in source order and reports characters that cannot participate in a matching pair.

## Release identity

- Package: `2.13.0+18`
- About: `2.13.0`
- Public class: `UnmatchedParenthesisRule`
- Stable rule ID: `unmatched-parenthesis`
- Default registry size: eight built-in writing rules
- Eligibility: language code `en`, covering both built-in English packs
- Category: Mechanics through the source-compatible `WritingRule` default
- Severity: warning
- Automatic replacement: none

## Matching contract

The rule scans UTF-16 source offsets from left to right.

- `(` pushes its source index onto an iterative opening stack.
- `)` consumes the most recent unmatched opening when one exists.
- A `)` with no available opening is unmatched immediately.
- Openings left on the stack at the end are unmatched.
- Findings are emitted in ascending source order.
- Nested structures such as `(outer (inner) text)` are accepted.
- Malformed ordering such as `)middle(` produces two findings in source order.
- Square brackets and curly braces are outside V2.13 scope.

The implementation does not recurse, and regression coverage includes 5,000 levels of balanced nesting plus 5,000 unmatched openings.

## Exact source ownership

Every finding owns exactly the unmatched parenthesis character:

```text
start = parenthesis UTF-16 offset
end   = start + 1
originalText = "(" or ")"
```

This keeps source ownership explicit and makes diagnostics stable around non-BMP text. For example, in `😀)` the closing parenthesis begins at UTF-16 offset `2` because the emoji occupies two code units.

## Why the rule is advisory-only

An unmatched parenthesis does not have one universally safe correction. Depending on intent, the user may need to:

- insert the opposite parenthesis elsewhere;
- delete the reported character;
- move punctuation or surrounding text;
- rewrite a larger phrase.

V2.13 therefore does not guess. `replacement` remains `null` and `hasAutomaticFix` is false. `WritingCorrection.applyAll` skips the finding and records it in the skipped count while still applying independent safe fixes from other rules.

The Writing insights **Automatic fixes only** filter hides these advisory findings. A document whose only finding is an unmatched parenthesis does not show an **Apply all safe fixes** action.

## Preference compatibility

No preference key or Portable settings version changes.

- An unset per-language writing-rule preference resolves to the current eight-rule default registry.
- Resetting rules clears the stored override and therefore adopts the eight-rule defaults.
- An explicit V2.12 seven-rule set remains authoritative and does not silently gain `unmatched-parenthesis`.
- An explicit empty set remains an explicit disable-all choice.
- Portable settings preserve both old explicit seven-rule overrides and new explicit eight-rule overrides.

This follows the existing forward-compatible default/override model rather than introducing a migration that rewrites user choices.

## Bounded analysis and diagnostics

The new rule participates in existing `WritingAnalyzer` semantics without changing their format:

- exact-at-limit results remain complete;
- overflow retains the globally earliest source-ordered prefix;
- `totalIssueCount` counts all observed findings;
- `totalIssueCountByRule['unmatched-parenthesis']` reports the exact rule total;
- benchmark samples materialize an explicit zero when the rule has no finding;
- privacy-safe diagnostic summaries include only the stable rule name/ID and counts, never document excerpts.

## Benchmark integration

The deterministic benchmark workload identity now contains eight sorted built-in rule IDs, including `unmatched-parenthesis`. A focused benchmark regression uses a controlled unmatched-parenthesis corpus and asserts exact captured/per-rule totals. Timing values remain observations rather than correctness thresholds.

## Deliberate limitations

V2.13 is a literal parenthesis balancer, not a language or markup parser. It does not attempt to understand whether parentheses occur inside:

- source-code or Markdown code spans;
- quoted strings;
- escaped syntax;
- URLs;
- mathematical notation;
- another domain-specific grammar.

That limitation is intentional. Future syntax-aware suppression would require an explicit parsing contract and regression corpus rather than heuristic automatic mutation.

## Privacy and security boundary

The rule runs locally over the supplied in-memory string. V2.13 adds no network request, telemetry, account, cloud grammar service, background upload, document persistence, new storage key, runtime dependency, or hidden clipboard action. The existing explicit diagnostic-summary copy action continues to exclude editor text and finding excerpts.

## Regression files

V2.13 adds or extends coverage in:

- `test/unmatched_parenthesis_rule_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_unmatched_parenthesis_widget_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/v213_settings_transfer_rule_compatibility_test.dart`
- `test/v213_writing_diagnostic_summary_test.dart`
- `test/v213_bounded_parenthesis_analysis_test.dart`
- `test/v213_parenthesis_stress_test.dart`
- `test/v213_review_query_parenthesis_test.dart`
- `test/v213_benchmark_parenthesis_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`

The release gate remains canonical formatting, static analysis, the complete Flutter test suite, deterministic benchmark smoke, a release-mode web build, release-identity assertions, manifest/dependency checks, and zero disposable V2.13 helper residue in the permanent tree.
