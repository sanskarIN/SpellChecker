# commit-message: docs: document V2.7 bounded writing analysis contracts
from pathlib import Path

def append_section(path_name: str, title: str, section: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if not text.startswith(title):
        raise SystemExit(f'Unexpected title for {path_name}')
    marker = section.splitlines()[0]
    if marker in text:
        raise SystemExit(f'V2.7 section already exists in {path_name}')
    path.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')

append_section('docs/WRITING_RULES.md', '# Writing Rules', '''
## V2.7 bounded writing analysis

`WritingAnalyzer.analyze()` accepts an optional positive `maxIssues` argument. Omitting it preserves the historical unbounded contract.

A bounded `WritingAnalysisResult` exposes `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`. Reaching the numerical limit alone does not make a result truncated: truncation is reported only after an additional finding is observed.

The bounded collector keeps at most `maxIssues` finding objects while preserving the same globally sorted prefix produced by unbounded analysis. Rules are still allowed to yield findings in arbitrary source order, and later rules may yield an earlier source range, so the collector can displace a worse retained finding rather than simply stopping after the first N yielded values.

The analyzer still invokes every enabled and supported rule across the supplied text. This is a finding-retention bound, not a rule-runtime, character-count, or document-length bound.

The built-in Writing insights dialog requests at most 200 captured findings. When overflow is proven, filters operate on captured findings only, and batch actions use **Apply captured safe fixes** or **Apply visible captured safe fixes** wording. The existing stale-source, advisory-skip, overlap-resolution, end-to-start mutation, and one-step undo contracts remain unchanged.
''')

append_section('docs/PERFORMANCE.md', '# Performance and large-document behavior', '''
## V2.7 bounded Writing insights analysis

Writing analysis now supports an optional retained-finding bound:

```dart
final result = analyzer.analyze(
  text,
  languagePack: pack,
  enabledRuleIds: enabledIds,
  maxIssues: 200,
);
```

`null` preserves unbounded finding capture. A supplied bound must be positive.

The collector stores at most the requested number of `WritingIssue` objects and maintains the analyzer's global review ordering: source start, severity ordering, then rule ID. If a later rule yields an earlier finding, that finding can replace a worse retained item. This keeps bounded results equal to the first N items of the corresponding unbounded sorted result.

The analyzer does **not** stop running rules after N findings. It must inspect all enabled/supported rule streams to know whether a later rule contributes an earlier result and to distinguish an exact-N complete result from a genuinely truncated result. Therefore `maxIssues` is a retained-finding memory/UI bound. It is not a CPU-time, rule-invocation, character, line, or document-size bound.

The built-in Writing insights policy is 200 captured findings. A `200+`-style limited state appears only when another finding beyond the cap has actually been observed. Search, presets, category filters, automatic-fix filtering, and batch actions operate only on the captured prefix when the analysis is truncated.

For profiling, measure writing-rule execution and bounded-result maintenance separately. Synthetic workloads should cover many findings from one rule, many enabled rules, out-of-order custom-rule yields, exact-at-limit documents, and true overflow. Avoid wall-clock correctness thresholds unless the runner environment is explicitly controlled.
''')

append_section('docs/API.md', '# API Reference', '''
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
''')

append_section('docs/ARCHITECTURE.md', '# Architecture', '''
## V2.7 bounded writing-result architecture

The writing analyzer now separates rule execution from retained-result storage. Unbounded calls append all findings and sort once. Bounded calls stream findings into a private ordered collector capped at `maxIssues`.

The collector uses the same comparison contract as the public analysis result: source start first, then severity ordering, then rule ID. It performs ordered insertion and drops the current worst retained finding when a better later finding arrives after the cap is full. This matters because rule registration order and rule-yield order are not the global review order.

`isTruncated` means at least one finding existed outside the retained prefix. The architecture deliberately keeps full enabled-rule scanning, so the bound controls retained finding objects and downstream dialog rendering rather than claiming a hard compute budget.

The editor remains a consumer of the public analyzer API. Writing insights supplies its 200-finding policy through `maxIssues`; the core analyzer does not hard-code an editor-specific cap.
''')

append_section('docs/DEVELOPMENT.md', '# Development Guide', '''
## V2.7 bounded-analysis development checks

When modifying writing analysis, test both unbounded and bounded paths. A custom rule test should not assume findings are yielded in source order; bounded results must still match the prefix of the fully sorted unbounded result.

New result metadata must preserve these invariants: limits are positive, exact-at-limit results can remain complete, truncation requires a proven overflow finding, and captured lists remain immutable.

UI work must not describe a truncated captured set as the complete document finding set. Filters and batch actions must clearly state captured-only behavior while stale-range and one-step undo protections remain active.
''')

append_section('docs/TESTING.md', '# Testing', '''
## V2.7 bounded writing-analysis coverage

Focused tests cover unbounded compatibility, positive-limit validation, exact-at-limit completeness, proven overflow, immutable captured lists, captured per-rule counts, and globally ordered prefix retention when custom rules yield findings out of order.

Widget tests use a deliberately small capture limit to exercise the limited state without huge fixtures. They verify the accessible overflow explanation, captured-safe-fix wording, returned captured issue ranges, and the filtered empty state that warns additional uncaptured findings may exist.

The complete regression suite must continue protecting V2.6 rule behavior, V2.5 spelling bounds, V2.4 ranking extensibility, Portable settings, persisted rule choices, correction safety, and keyboard/editor workflows.
''')
