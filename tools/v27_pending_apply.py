# commit-message: docs: add V2.7 changelog entry
from pathlib import Path

path = Path('CHANGELOG.md')
text = path.read_text()
marker = '## [2.6.0] - 2026-08-10\n'
if text.count(marker) != 1:
    raise SystemExit('Expected exactly one V2.6 changelog marker.')
section = '''## [2.7.0] - 2026-08-11

### Added

- Optional positive `maxIssues` capture bound for `WritingAnalyzer.analyze()` while preserving `null` as the historical unbounded behavior.
- Bounded writing-analysis metadata on `WritingAnalysisResult`: `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`.
- A globally ordered bounded collector that retains the same earliest finding prefix as unbounded analysis without retaining the complete finding set.
- Built-in Writing insights capture policy of 200 findings with accessible limited-result explanation.
- Focused core and widget coverage for exact-at-limit completeness, proven overflow, out-of-order rule streams, captured batch fixes, filtering, and immutable result lists.

### Changed

- Package version advances to `2.7.0+12`; About version advances to `2.7.0`.
- Writing insights displays a `200+`-style limited count only when an additional finding beyond the capture limit is actually observed.
- Limited-result review filters operate on captured findings only and say so explicitly.
- Limited-result batch actions use **Apply captured safe fixes** / **Apply visible captured safe fixes** wording rather than implying every whole-document finding is represented.
- Bounded analysis continues to run every enabled/supported rule over the supplied text so the retained set is the correct global review-order prefix even when a later rule yields an earlier finding.

### Compatibility, performance, security, and privacy

- Existing callers that omit `maxIssues` receive the same unbounded analysis contract as V2.6 and earlier.
- Reaching the numerical limit alone does not imply truncation; `isTruncated` becomes true only after at least one additional finding is observed.
- The V2.7 bound limits retained finding objects, not document length, rule CPU time, or the total number of rule matches that may be scanned.
- Existing rule IDs, per-language rule preferences, review presets/filters, Portable settings, correction safety, one-step undo, V2.5 spelling bounds, and V2.4 suggestion ranking remain compatible.
- V2.7 changes no persistence format or preference key and adds no runtime dependency, network request, telemetry, cloud writing service, account behavior, or background document processing.

'''
text = text.replace(marker, section + marker)
path.write_text(text)
