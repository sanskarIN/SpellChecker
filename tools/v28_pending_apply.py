# commit-message: docs: publish V2.8 README and web metadata
from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"expected marker not found in {path}: {old[:120]!r}")
    if text.count(old) != 1:
        raise SystemExit(f"expected one marker in {path}, found {text.count(old)}")
    p.write_text(text.replace(old, new, 1))


replace_once(
    "README.md",
    "- Bounded Writing insights analysis with an explicit first-200 finding policy and captured-only limited-review wording.",
    "- Bounded Writing insights analysis with an explicit first-200 finding policy, exact observed/per-rule totals, captured/total diagnostics, and captured-only limited-review/fix semantics.",
)
replace_once(
    "README.md",
    """## Current release

`2.7.0+12`

Version 2.7 is the **Bounded Writing Analysis & Large-Document Review Safety** release. It keeps the V2.6 six-rule catalogue, V2.5 bounded spelling behavior, and every existing persistence/correction contract while adding optional bounded writing-result capture and a truthful 200-finding Writing insights policy. Limited review filters and batch actions operate on captured findings only. No persistence format, network behavior, or runtime dependency changes in V2.7.

## Large-document Writing insights — V2.7
""",
    """## Current release

`2.8.0+13`

Version 2.8 is the **Writing Analysis Diagnostics & Exact Limited Counts** release. It keeps the V2.7 200-finding retained-review safety contract while adding exact whole-analysis and per-rule finding counts to analyzer-produced results. Writing insights can now distinguish `200 captured of 1437 total` from an unknown `200+` state without retaining every uncaptured `WritingIssue`. Filters and corrections remain captured-only for limited results, and V2.8 adds no persistence format, runtime dependency, analytics, telemetry, or application network behavior.

## Exact Writing insights diagnostics — V2.8

`WritingAnalysisResult` now exposes exact diagnostics for analyzer-produced results: `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`. Direct V2.7-style construction can omit these fields for source compatibility.

With `maxIssues: 200`, the analyzer still retains only the globally earliest 200 findings, but it counts every finding observed during the full enabled/supported rule scan. Writing insights can therefore show exact text such as **Showing the first 200 of 1437 findings in review order**, an exact omitted count, per-rule **Total findings: N** metadata, and a `200/1437` captured/total badge.

Exact counts are informational. Search, presets, category filters, automatic-fix filtering, individual fixes, and batch fixes remain scoped to retained findings when a result is truncated. Exact diagnostics do not authorize mutation of uncaptured ranges and do not replace stale-source/overlap/one-step-undo protections.

The diagnostics are local, in-memory, and deterministic. They are not saved in Portable settings or preferences, sent to telemetry, logged remotely, or treated as a CPU-time/document-size security bound. See [API](docs/API.md), [Performance](docs/PERFORMANCE.md), and [Writing rules](docs/WRITING_RULES.md).

## Large-document Writing insights — V2.7
""",
)
replace_once(
    "README.md",
    """final analysis = analyzer.analyze(
  'hello  world!!',
  languagePack: pack,
);

final corrected = WritingCorrection.applyAll(
""",
    """final analysis = analyzer.analyze(
  'hello  world!!',
  languagePack: pack,
  maxIssues: 200,
);

print(analysis.capturedIssueCount);
print(analysis.totalIssueCount); // exact analyzer-produced total in V2.8

final corrected = WritingCorrection.applyAll(
""",
)
replace_once(
    "README.md",
    """│   ├── writing_correction_test.dart
│   ├── writing_preferences_test.dart
""",
    """│   ├── writing_analysis_diagnostics_test.dart
│   ├── writing_analysis_diagnostics_widget_test.dart
│   ├── writing_analysis_limit_test.dart
│   ├── writing_analysis_limit_widget_test.dart
│   ├── writing_correction_test.dart
│   ├── writing_preferences_test.dart
""",
)
replace_once(
    "README.md",
    """- [Testing](docs/TESTING.md)
- [Accessibility](docs/ACCESSIBILITY.md)
""",
    """- [Testing](docs/TESTING.md)
- [Performance and large-document behavior](docs/PERFORMANCE.md)
- [Accessibility](docs/ACCESSIBILITY.md)
""",
)
replace_once(
    "README.md",
    """- [Changelog](CHANGELOG.md)

## Contributing
""",
    """- [Changelog](CHANGELOG.md)
- [Detailed engineering change ledger](what_changed.md)

## Contributing
""",
)

index = Path("web/index.html")
index_text = index.read_text()
old_index_desc = 'content="SpellChecker - a privacy-first open-source writing utility with local spelling, explicit English language packs, Unicode-aware checking, persistent per-language vocabulary and writing-rule choices, Writing insights review presets plus expanded punctuation/trailing-whitespace rules, portable non-document preferences, bounded large-document spelling and Writing insights results, captured-aware filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and one-step undo."'
new_index_desc = 'content="SpellChecker - a privacy-first open-source writing utility with local spelling, explicit English language packs, Unicode-aware checking, persistent per-language vocabulary and writing-rule choices, bounded large-document spelling and Writing insights, exact local writing-analysis and per-rule finding diagnostics, captured-aware filtered batch-safe fixes, portable non-document preferences, keyboard workflows, and one-step undo."'
if old_index_desc not in index_text:
    raise SystemExit("web/index.html description marker not found")
index.write_text(index_text.replace(old_index_desc, new_index_desc, 1))

manifest = Path("web/manifest.json")
manifest_text = manifest.read_text()
old_manifest_desc = '"description": "A privacy-first open-source writing utility with explicit English language packs, Unicode-aware local spelling, persistent per-language vocabulary and writing-rule choices, Writing insights review presets plus expanded punctuation/trailing-whitespace rules, portable non-document preferences, bounded large-document spelling and Writing insights results, captured-aware filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and undo-friendly corrections."'
new_manifest_desc = '"description": "A privacy-first open-source writing utility with explicit English language packs, Unicode-aware local spelling, persistent per-language vocabulary and writing-rule choices, bounded large-document spelling and Writing insights, exact local writing-analysis and per-rule finding diagnostics, captured-aware filtered batch-safe fixes, portable non-document preferences, keyboard workflows, and undo-friendly corrections."'
if old_manifest_desc not in manifest_text:
    raise SystemExit("web/manifest.json description marker not found")
manifest.write_text(manifest_text.replace(old_manifest_desc, new_manifest_desc, 1))
