# commit-message: docs: mark bounded writing analysis V2.7 implemented
from pathlib import Path

path = Path('docs/ROADMAP.md')
text = path.read_text()
marker = '## Future 2.x direction\n'
if text.count(marker) != 1:
    raise SystemExit('Expected exactly one future-roadmap marker.')
section = '''## 2.7 — Bounded writing analysis and large-document review safety

Status: implemented.

- [x] Optional positive `maxIssues` bound on `WritingAnalyzer.analyze()`.
- [x] Backward-compatible unbounded analysis when no limit is supplied.
- [x] Immutable writing result metadata for issue limit, truncation, completeness, and captured count.
- [x] Globally ordered bounded collector preserving the unbounded review-order prefix.
- [x] Exactly-at-limit results remain complete unless another finding exists.
- [x] Full enabled-rule/full-document scanning retained for global ordering correctness.
- [x] Built-in Writing insights cap of 200 captured findings.
- [x] Accessible limited-analysis notice and truthful captured-finding counts.
- [x] Captured-only review filter and batch-fix wording for incomplete result sets.
- [x] Core and widget regression coverage for bounds, ordering, filtering, fixes, and immutability.
- [x] No persistence/network/runtime-dependency expansion.

'''
text = text.replace(marker, section + marker)
path.write_text(text)
