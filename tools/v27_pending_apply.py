# commit-message: docs: update V2.7 privacy security and support boundaries
from pathlib import Path

sections = {
    'docs/PRIVACY.md': '''## V2.7 bounded writing-analysis privacy

The optional writing `maxIssues` bound and the built-in 200-finding Writing insights policy do not add storage or transmission. The analyzer reads the supplied text in memory, retains at most the configured finding count when bounded, and returns in-memory metadata describing whether additional findings existed.

Captured findings, uncaptured finding counts, analysis limits, review search/filter state, and correction history are not newly persisted. The application still has no cloud spelling/grammar service, telemetry, analytics, account requirement, advertising, background document upload, or automatic remote rewriting.

A limited result should be treated as potentially containing sensitive source excerpts just like any other `WritingIssue`; application code must not log or export it by default.
''',
    'SECURITY.md': '''## V2.7 bounded writing-analysis security

V2.7 does not introduce remote rule loading, executable plugins, dynamic code evaluation, worker downloads, or network-backed analysis. `maxIssues` constrains retained `WritingIssue` objects but is not a denial-of-service boundary for arbitrary custom rules because every enabled/supported rule is still executed to preserve global result ordering.

Callers that accept untrusted very large documents or untrusted third-party rule implementations must enforce their own input-size, execution-time, isolation, or plugin-trust policies. The built-in local rules remain source-controlled and deterministic.

Automatic mutations continue to use exact-source stale checks and conservative overlap handling; a bounded result does not bypass those protections.
''',
    'SUPPORT.md': '''## V2.7 limited Writing insights reports

When reporting a V2.7 Writing insights problem, include whether the dialog displayed a limited-result notice, the selected language, active review preset/filter state, and whether the issue reproduced after editing/reopening Writing insights. Do not include private document text unless it is necessary and safe to share; a small synthetic reproduction is preferred.

A `200+`-style state means the built-in dialog captured its first 200 findings in review order and observed at least one more. Filters and batch actions then operate on the captured prefix only.
''',
    'CONTRIBUTING.md': '''## V2.7 bounded-analysis contributions

Changes to `WritingAnalyzer` bounds must preserve unbounded source compatibility, positive-limit validation, global deterministic ordering, exact-at-limit completeness, proven-overflow truncation semantics, and immutable result data.

Custom-rule tests used for bounded analysis should include out-of-order yields so implementations cannot accidentally depend on registry order. UI contributions must describe incomplete result sets as captured/limited and must retain stale-source and one-step undo safety.

Do not turn the V2.7 finding-retention bound into a claimed CPU/document-size security limit without a separate design and test contract.
''',
}

for name, section in sections.items():
    path = Path(name)
    if not path.is_file():
        raise SystemExit(f'Missing policy/support file: {name}')
    text = path.read_text()
    marker = next(line for line in section.splitlines() if line.strip())
    if marker in text:
        raise SystemExit(f'V2.7 section already exists in {name}')
    path.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
