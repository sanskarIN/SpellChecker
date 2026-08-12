# commit-message: docs: document V2.8 performance and rule diagnostics
from pathlib import Path


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


append_section(
    "docs/PERFORMANCE.md",
    "## V2.8 exact writing-analysis diagnostics",
    r'''
## V2.8 exact writing-analysis diagnostics

V2.8 adds exact deterministic finding counts to analyzer-produced writing results. These counters improve observability of bounded Writing insights without converting the V2.7 finding-retention bound into a CPU or wall-clock limit.

For each enabled/supported rule, the analyzer continues consuming the rule's findings across the supplied text. Every yielded finding increments the overall and per-rule counters. Only the retained result path is bounded by `maxIssues`.

For example, with `maxIssues: 200`, a result can report:

```text
capturedIssueCount: 200
totalIssueCount: 1437
uncapturedIssueCount: 1237
```

The analyzer still retains at most 200 `WritingIssue` objects for the bounded result while counting the remaining 1,237 findings as integers.

### What is bounded

- retained `WritingIssue` objects in the result;
- retained finding list sorting/storage after the bounded collector reaches capacity;
- downstream Writing insights rendering/filtering/fix candidate work over the retained set.

### What is not bounded by V2.8 diagnostics

- characters, tokens, or lines supplied to an arbitrary writing rule;
- rule scan time;
- wall-clock duration;
- CPU usage of third-party/custom rule implementations;
- allocations performed internally by a custom rule;
- number of findings a rule may yield before the analyzer finishes counting them.

Exact totals therefore describe **observed findings**, not a resource budget.

### Benchmarking guidance

When profiling very large documents:

1. use synthetic/non-sensitive generated text;
2. record document size separately from finding count;
3. record active language and enabled rule IDs;
4. record `capturedIssueCount`, `totalIssueCount`, and per-rule exact totals;
5. measure elapsed time externally in a benchmark harness rather than embedding timing telemetry in production results;
6. compare unbounded and bounded retention separately from total rule-scan cost;
7. avoid treating one device/browser measurement as a correctness guarantee.

V2.8 intentionally does not persist benchmark data or document-derived diagnostic totals.
''',
)

append_section(
    "docs/WRITING_RULES.md",
    "## V2.8 exact finding diagnostics",
    r'''
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
''',
)
