# commit-message: docs: document V2.8 diagnostics API and architecture
from pathlib import Path


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


append_section(
    "docs/API.md",
    "## V2.8 writing-analysis diagnostics",
    r'''
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
- per-rule exact totals must be non-negative;
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
''',
)

append_section(
    "docs/ARCHITECTURE.md",
    "## V2.8 exact writing-analysis diagnostics",
    r'''
## V2.8 exact writing-analysis diagnostics

V2.8 extends the V2.7 bounded writing-analysis pipeline with deterministic whole-analysis counters while keeping the retained finding set bounded.

### Analysis flow

For each enabled rule that supports the active language pack, `WritingAnalyzer` now performs two independent responsibilities during the same local rule scan:

1. increment exact overall and per-rule finding counters for every yielded `WritingIssue`;
2. pass each finding through the existing deterministic retained-result path, which stores either every issue in unbounded mode or only the globally earliest `maxIssues` prefix in bounded mode.

The exact counters therefore account for uncaptured findings without requiring the analyzer to retain those `WritingIssue` objects.

### Ordering remains authoritative

The V2.7 review comparator remains the source of truth for retained ordering. Exact diagnostics do not create a second ordering path and do not change which findings survive the bound.

A later rule can still displace a worse retained finding when it yields an earlier globally ordered result. The exact counters are independent of that displacement: every yielded finding is counted exactly once even when its issue object is discarded from the bounded collector.

### Result model boundary

`WritingAnalysisResult` owns immutable analysis metadata:

- retained `issues`;
- analyzed rule IDs;
- language ID;
- V2.7 limit/truncation/completeness metadata;
- V2.8 exact overall/per-rule totals when available.

Direct construction may omit V2.8 diagnostics for compatibility, while `WritingAnalyzer` always populates them.

### Writing insights integration

`WritingInsightsDialog` consumes, but does not recompute, analyzer diagnostics. When exact totals exist it can render the exact relationship between retained and observed findings, per-rule totals, and the exact uncaptured count. Review search, presets, categories, and safe-fix actions still operate only on retained findings.

A stable `ValueKey<String>('writing-findings-total-badge')` exists for regression tests of the exact captured/total badge. This key is a widget-test integration detail, not a public package API.

The dialog remains lazy/scrollable. Tests navigate the real lazy list instead of forcing normally off-screen rule metadata or findings headers to remain eagerly mounted.

### Privacy and persistence boundary

The exact counters are computed from the same in-memory local analysis that already produces writing findings. They are not written to `shared_preferences`, exported through Portable settings, logged remotely, uploaded, or retained after the dialog/result is discarded.

No network service, analytics pipeline, background job, account system, or runtime dependency was added for V2.8 diagnostics.
''',
)
