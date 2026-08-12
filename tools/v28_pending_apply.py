# commit-message: docs: document V2.8 development and testing contracts
from pathlib import Path


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


append_section(
    "docs/DEVELOPMENT.md",
    "## V2.8 diagnostics development notes",
    r'''
## V2.8 diagnostics development notes

When changing writing-analysis diagnostics, keep counting, retention, filtering, and correction responsibilities separate.

### Analyzer changes

The analyzer owns exact count collection. A change should preserve these invariants:

- every yielded finding from an enabled/supported rule increments the exact overall count once;
- each finding increments exactly one per-rule total;
- bounded retention still returns the globally earliest review-order prefix;
- exact totals include uncaptured findings;
- uncaptured findings are not retained merely to calculate totals;
- unbounded analysis remains source-compatible;
- direct `WritingAnalysisResult` construction may omit V2.8 diagnostics.

Do not move exact counting into Flutter widgets. Widgets consume result metadata and should not rescan rules.

### UI changes

Writing insights is intentionally lazy/scrollable. Controls that are outside the current viewport may not exist in the widget tree. Tests should scroll/navigate to the real control rather than changing production rendering to keep every row mounted.

Use stable keys only for meaningful interaction/diagnostic surfaces. V2.8 exposes `writing-findings-total-badge` for the captured/total display used in regression tests.

### Performance experiments

Keep correctness metadata deterministic. If adding benchmarks, measure time externally in a benchmark/test harness rather than adding wall-clock fields to production analysis results. Use generated/synthetic text and never commit private documents as fixtures.

### Required checks for diagnostics changes

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/writing_analysis_diagnostics_test.dart --reporter expanded
flutter test test/writing_analysis_limit_widget_test.dart --reporter expanded
flutter test test/writing_analysis_diagnostics_widget_test.dart --reporter expanded
flutter test --reporter expanded
flutter build web --release
```

Release-sensitive changes should also verify that `flutter pub get` leaves `pubspec.lock` unchanged when no dependency change is intended.
''',
)

append_section(
    "docs/TESTING.md",
    "## V2.8 writing-analysis diagnostics coverage",
    r'''
## V2.8 writing-analysis diagnostics coverage

V2.8 adds focused coverage in `test/writing_analysis_diagnostics_test.dart` and `test/writing_analysis_diagnostics_widget_test.dart`, while strengthening `test/writing_analysis_limit_widget_test.dart`.

### Core diagnostics cases

Tests cover:

- exact overall totals for unbounded analyzer results;
- exact overall totals for bounded/truncated results;
- exact `uncapturedIssueCount`;
- exact immutable per-rule totals;
- disabled rule exclusion;
- zero-finding analyzer results;
- source-compatible direct result construction without diagnostics;
- rejection of exact totals smaller than captured counts;
- complete-result exact-total equality;
- truncated-result proof of at least one uncaptured finding;
- per-rule total sum consistency;
- per-rule totals that cannot under-report retained counts for that rule.

### Limited dialog cases

Widget tests prove:

- exact first-N-of-total limited-analysis wording;
- exact additional/uncaptured quantity;
- singular and plural grammar for omitted findings;
- exact enabled-rule total metadata;
- captured-only batch-fix behavior remains unchanged;
- filtered-empty limited-review wording reports the exact uncaptured count;
- the captured/total badge can be inspected through its stable key.

### Lazy list rule

Writing insights uses a lazy list. A finder for an off-screen widget may legitimately return zero widgets until the list is scrolled to that region. Tests must navigate the real scrollable UI before asserting off-screen metadata.

Do not make production lists eager merely to satisfy a fixed test viewport. This is especially important for rule subtitles, limited-analysis notices, findings headers, and bottom actions.

### Regression requirement

Any V2.8 diagnostics defect should receive a focused regression at the lowest layer that reproduces it. If the defect depends on lazy widget lifecycle or viewport position, include the real scroll path in the test instead of replacing the UI with a test-only layout.

The full project suite remains required after focused diagnostics tests so V2.8 cannot regress language state, spelling bounds, review presets, rule persistence, correction safety, keyboard workflows, or prior widget behavior.
''',
)
