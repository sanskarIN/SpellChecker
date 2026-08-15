# V2.15 Unmatched Curly Brace Diagnostics

SpellChecker V2.15 adds a tenth built-in deterministic writing rule: `UnmatchedCurlyBraceRule`, stable ID `unmatched-curly-brace`.

The rule is intentionally local, literal, deterministic, and advisory-only. It reports unmatched `{` and `}` characters but does not guess an automatic correction.

## Public API

The rule is exported through `package:spellchecker/writing.dart` and participates in `WritingRuleRegistry.builtIns`.

```dart
const rule = UnmatchedCurlyBraceRule();
```

Its stable metadata is:

- ID: `unmatched-curly-brace`
- display name: `Unmatched curly brace`
- category: Mechanics through the source-compatible `WritingRule` default
- severity: warning
- automatic replacement: none
- supported language code: `en`, covering the built-in `en-US` and `en-GB` packs

## Literal balancing algorithm

The scanner walks UTF-16 code-unit indexes from left to right.

- `{` pushes its source index onto an opening stack.
- `}` consumes the most recent opening when one exists.
- A `}` encountered with an empty opening stack is immediately unmatched.
- Openings left on the stack after the scan are unmatched.
- All unmatched indexes are sorted before issues are emitted.

The implementation is iterative rather than recursive. Focused stress tests cover 5,000 balanced nesting levels and 5,000 unmatched openings.

## Exact source ownership

Every finding owns exactly one ASCII curly-brace character:

- `start` is the brace's UTF-16 source offset;
- `end == start + 1`;
- `originalText` is `{` or `}`.

Because Dart string indexes are UTF-16 code-unit offsets, a non-BMP predecessor is handled correctly. For example, the closing brace in `😀}` starts at offset 2.

The rule does not claim parentheses or square brackets. `UnmatchedParenthesisRule`, `UnmatchedSquareBracketRule`, and `UnmatchedCurlyBraceRule` are independent delimiter families and may all report findings in the same document.

## Advisory-only safety boundary

An unmatched curly brace can require multiple plausible edits: inserting an opposite brace, deleting the reported brace, moving text, or rewriting a larger expression. A literal balancer cannot infer which edit is intended safely.

Therefore the issue has no replacement and `hasAutomaticFix` is false.

Consequences:

- **Automatic fixes only** excludes curly-brace findings.
- A document containing only curly-brace findings does not expose an apply-all action.
- `WritingCorrection.applyAll` skips the advisory issue.
- Independent deterministic fixes in the same batch can still be applied.

## Default-rule and persistence compatibility

V2.15 expands the built-in/default writing-rule catalogue from nine rules to ten.

The existing preference key family remains unchanged:

`spellchecker.writing_rule_ids.v1.<language>`

Semantics remain deliberately distinct:

- no stored override means use the current registry defaults, now ten rules;
- **Reset rules to defaults** clears the stored override and therefore adopts the current ten-rule defaults;
- an explicit V2.14 nine-rule override remains exactly nine rules and does not silently gain `unmatched-curly-brace`;
- explicit empty/disable-all and older explicit sets remain authoritative.

No preference migration is required.

## Portable settings compatibility

Portable settings format/version is unchanged.

Focused regressions verify that:

- a V2.14 explicit nine-rule override round-trips unchanged and excludes `unmatched-curly-brace`;
- an explicit V2.15 ten-rule override preserves `unmatched-curly-brace`;
- an unset override remains unset so it continues to mean current defaults rather than a frozen explicit list.

## Bounded analysis and exact diagnostics

The rule uses the existing `WritingAnalyzer` result model.

- Exactly-at-limit curly-brace results remain complete.
- Truncation is reported only when another finding actually exists.
- The retained bounded list remains the globally earliest source-ordered prefix across all enabled rules.
- `totalIssueCount` remains exact.
- `totalIssueCountByRule['unmatched-curly-brace']` remains exact even when some findings are not retained.

No additional uncaptured `WritingIssue` objects are retained solely for diagnostics.

## Privacy-safe diagnostic summaries

`WritingAnalysisDiagnosticSummary` may report the stable rule name, ID, captured count, and exact total. It does not copy the private editor source that produced the finding.

V2.15 regression coverage verifies that surrounding source phrases do not appear in the plain-text diagnostic summary.

## Review and editor integration

The new rule participates in the existing Writing insights workflow:

- default rule switch;
- Mechanics filtering;
- text search such as `curly brace`;
- exact visible/captured/total counts;
- explicit per-language rule persistence;
- reset-to-defaults behavior;
- Portable settings;
- advisory-only presentation;
- automatic-fix filtering.

No new modal, correction engine, persistence subsystem, or network workflow is introduced.

## Benchmark integration

The deterministic benchmark writing-rule identity expands to ten stable IDs. Clean benchmark samples materialize a zero count for `unmatched-curly-brace`, and a focused controlled corpus asserts an exact count of one.

Benchmark elapsed times remain observational machine/toolchain measurements and are not correctness thresholds.

## Deliberate parser limitation

`UnmatchedCurlyBraceRule` is a literal delimiter balancer. It is not a programming-language, template-language, Markdown, mathematical, URL, citation, quotation, or domain-specific parser.

V2.15 does not suppress braces merely because they appear inside code-like or template-like text. Syntax-aware exclusions require a future explicit parser contract, corpus, ownership model, and compatibility review rather than heuristic mutation.

## Privacy, dependency, and format boundary

V2.15 adds no runtime dependency, application-network request, telemetry, account behavior, cloud writing service, background upload, document persistence, hidden clipboard action, new preference-key family, Portable-settings format revision, diagnostic-summary format revision, or correction-engine fork.
