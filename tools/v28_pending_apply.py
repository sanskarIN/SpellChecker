# commit-message: docs: record V2.8 diagnostics release and roadmap
from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"expected marker not found in {path}: {old[:80]!r}")
    if text.count(old) != 1:
        raise SystemExit(f"expected one marker in {path}, found {text.count(old)}")
    p.write_text(text.replace(old, new, 1))


changelog_marker = "## [2.7.0] - 2026-08-11\n"
changelog_entry = """## [2.8.0] - 2026-08-12

### Added

- Exact deterministic writing-analysis diagnostics on analyzer-produced `WritingAnalysisResult` values: `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`.
- Exact whole-analysis finding counts while bounded mode continues retaining only the globally earliest configured finding prefix.
- Per-enabled-rule total finding metadata in Writing insights.
- Exact captured/total findings badge and accessible limited-analysis wording in Writing insights.
- Stable `writing-findings-total-badge` widget key for diagnostics regression coverage without depending on tooltip lifecycle.
- Dedicated core and widget diagnostics coverage for exact totals, per-rule totals, uncaptured counts, result invariants, immutability, disabled-rule exclusion, lazy dialog rendering, and singular/plural limited-result wording.

### Changed

- Package version advances to `2.8.0+13`; About version advances to `2.8.0`.
- A limited Writing insights review can now report the exact relationship between captured and observed findings, for example `200/1437`, instead of only an unknown `200+` state when analyzer diagnostics are available.
- The limited-analysis notice reports **the first N of M findings** and the exact number of findings not retained by the capture limit.
- Enabled rule metadata reports exact total findings contributed by each enabled/supported rule during the current analysis.
- Filtered-empty limited-review copy reports the exact uncaptured quantity and uses grammatically correct singular/plural wording.
- Widget tests navigate the real lazy Writing insights list rather than forcing normally off-screen controls to remain eagerly mounted.

### Compatibility, performance, security, and privacy

- The V2.7 `maxIssues` capture contract is unchanged: bounded analysis still retains only the globally earliest review-order prefix and filters/fixes remain captured-only when results are incomplete.
- Analyzer-produced results always provide exact diagnostics; direct V2.7-style construction of `WritingAnalysisResult` may omit them for source compatibility.
- Exact diagnostic totals count rule findings during the normal full enabled-rule scan without retaining uncaptured `WritingIssue` objects.
- V2.8 does not claim a CPU-time, wall-clock-time, or maximum-document-size bound. It adds deterministic count diagnostics rather than timing telemetry.
- Existing writing-rule IDs/defaults/preferences, review presets/query behavior, correction safety, overlap resolution, one-step undo, V2.5 spelling bounds, V2.4 ranking, and Portable settings remain compatible.
- V2.8 adds no persistence format, preference key, runtime dependency, network request, account behavior, cloud writing service, telemetry, background upload, or persisted editor/finding data.

"""
replace_once("CHANGELOG.md", changelog_marker, changelog_entry + changelog_marker)

future_marker = """## Future 2.x direction

Possible future work includes:

- Richer deterministic writing-rule catalogues.
- Additional language-specific writing rules.
- Additional review presets/categories driven by demonstrated workflows.
- Additional portable non-document preferences with explicit compatibility/version review.
- Additional built-in ranker implementations driven by demonstrated ranking needs.
- Trusted plugin-loading designs with explicit security boundaries.
- Cross-platform packaging and signing automation.
- Performance profiling for very large documents.

Privacy-first local behavior remains a design requirement unless a future optional network feature is explicitly documented, reviewed, and user-controlled.
"""
roadmap_replacement = """## 2.8 — Writing analysis diagnostics and exact limited counts

Status: implemented.

- [x] Exact analyzer-produced overall finding totals.
- [x] Exact immutable per-rule finding totals for enabled/supported rules.
- [x] Exact uncaptured finding count derived from total and retained findings.
- [x] Backward-compatible direct `WritingAnalysisResult` construction without diagnostics.
- [x] Consistency validation for overall totals, per-rule totals, captured counts, completeness, and truncation.
- [x] Bounded analysis still retains only the globally earliest `maxIssues` findings.
- [x] No extra uncaptured `WritingIssue` retention solely to calculate diagnostics.
- [x] Writing insights exact `captured/total` badge for limited results.
- [x] Exact first-N-of-total limited-analysis notice and omitted-count explanation.
- [x] Exact enabled-rule finding totals in rule metadata.
- [x] Exact filtered-empty uncaptured count with singular/plural wording.
- [x] Stable diagnostics widget key and lazy-list-safe widget regression coverage.
- [x] No elapsed-time telemetry, persistence, network, or runtime-dependency expansion.

## Future 2.x direction

Possible future work includes:

- V2.9 large-document analysis diagnostics UX, including optional user-facing per-rule diagnostic summaries and deterministic export/copy of non-document diagnostic summaries if a concrete workflow justifies it.
- Richer deterministic writing-rule catalogues with explicit source-range ownership tests.
- Additional language-specific writing rules and language-pack coverage beyond the two built-in English variants.
- Additional review presets/categories driven by demonstrated workflows.
- Additional portable non-document preferences with explicit compatibility/version review.
- Additional built-in ranker implementations driven by demonstrated ranking needs.
- Trusted plugin-loading designs with explicit security boundaries.
- Cross-platform desktop/mobile packaging, signing, and release automation.
- Repeatable performance benchmarking for very large documents, kept separate from correctness metadata and without persisted document content.
- Broader accessibility regression coverage for large limited-result dialogs and keyboard-only review.

Privacy-first local behavior remains a design requirement unless a future optional network feature is explicitly documented, reviewed, and user-controlled.
"""
replace_once("docs/ROADMAP.md", future_marker, roadmap_replacement)
