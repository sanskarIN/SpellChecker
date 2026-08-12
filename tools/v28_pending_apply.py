# commit-message: docs: document V2.8 privacy security and support boundaries
from pathlib import Path


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


append_section(
    "docs/PRIVACY.md",
    "## V2.8 exact diagnostics privacy boundary",
    r'''
## V2.8 exact diagnostics privacy boundary

V2.8 adds exact overall and per-rule finding counts to analyzer-produced writing results. These values are derived from the same in-memory editor text that Writing insights already analyzes locally.

The new diagnostics are **not**:

- written to `shared_preferences`;
- included in Portable settings exports;
- included in personal-dictionary exports;
- uploaded to a service;
- sent to analytics or telemetry;
- written to a remote log;
- retained as background history after the analysis/dialog is discarded.

Exact counts can still reveal limited characteristics about a document, such as how many findings a rule produced. For that reason they should be treated as document-derived data when adding future logging, debugging, crash reporting, clipboard export, synchronization, or diagnostic-report features.

Any future persistence or export of exact finding totals requires explicit privacy review and user-facing documentation. V2.8 itself keeps them local and memory-only.

The Buy Me a Coffee funding link added to repository documentation is a normal external link. SpellChecker does not contact that site from the application runtime, and no editor text or application state is sent to it by SpellChecker.
''',
)

append_section(
    "SECURITY.md",
    "## V2.8 writing diagnostics security boundary",
    r'''
## V2.8 writing diagnostics security boundary

Exact V2.8 finding totals are correctness/observability metadata, not an execution sandbox or denial-of-service control.

The analyzer still consumes findings from every enabled/supported rule across the supplied text so it can preserve global ordering and calculate exact totals. Therefore neither `maxIssues` nor `totalIssueCount` should be represented as bounding:

- arbitrary custom-rule CPU time;
- wall-clock execution time;
- memory allocated internally by a custom rule;
- document length;
- untrusted plugin execution.

Applications embedding SpellChecker with untrusted documents or third-party rule code remain responsible for their own input-size, isolation, timeout, and plugin-trust controls.

Exact totals and per-rule totals are memory-only and are not automatically logged, persisted, uploaded, or exported. A future diagnostic/crash-report feature must treat them as document-derived metadata and must not silently transmit them with user text or source excerpts.

The repository's Buy Me a Coffee link does not change security-reporting priority, disclosure handling, maintainer trust boundaries, or project governance.
''',
)

append_section(
    "SUPPORT.md",
    "## V2.8 exact diagnostics reports",
    r'''
## V2.8 exact diagnostics reports

For a Writing insights count/diagnostics bug, use a minimal synthetic sample and include:

- selected language ID;
- enabled writing-rule IDs;
- configured `maxIssues` when using the public analyzer API;
- retained/captured finding count;
- exact overall total when present;
- exact per-rule totals when present;
- complete/truncated state;
- active review preset/search/category/fix-only filters;
- whether editor text, language, or rule settings changed after the analysis.

For analyzer-produced results, exact per-rule totals should sum to the exact overall total, and an exact truncated result should report at least one uncaptured finding.

Do not attach a private large document simply to prove a count mismatch. Repeated synthetic text or a small custom synthetic rule is preferred.

The `captured/total` badge describes one current local analysis snapshot. Reopen Writing insights after editing or switching languages before comparing totals.
''',
)

append_section(
    "CONTRIBUTING.md",
    "## V2.8 diagnostics contributions",
    r'''
## V2.8 diagnostics contributions

Changes to writing-analysis diagnostics must preserve these contracts unless a deliberately documented breaking release changes them:

- analyzer-produced results expose internally consistent exact overall/per-rule totals;
- direct V2.7-style `WritingAnalysisResult` construction may omit diagnostics;
- exact totals include uncaptured findings;
- the bounded retained list remains the global deterministic review-order prefix;
- exact counting does not require retaining all uncaptured `WritingIssue` objects;
- filters and corrections remain scoped to retained findings when analysis is truncated;
- diagnostic maps remain immutable;
- disabled/unsupported rules do not contribute totals;
- no timing telemetry or persistence is introduced implicitly.

Add focused core tests for result invariants and widget tests for user-visible count semantics. When testing the Writing insights dialog, navigate its real lazy list instead of making production rows eager for test convenience.

Performance experiments must use synthetic/non-sensitive text. Treat exact counts as document-derived metadata if proposing logging, exporting, persistence, or remote diagnostics.
''',
)
