# commit-message: docs: record V2.7 final release gate evidence
from pathlib import Path

path = Path('what_changed.md')
text = path.read_text()
marker = '## V2.6 — Deterministic Writing Rule Expansion\n'
if text.count(marker) != 1:
    raise SystemExit('Expected exactly one V2.6 ledger marker.')
heading = '### Final V2.7 release-gate evidence\n'
if heading in text:
    raise SystemExit('Final V2.7 release evidence already exists.')
section = '''### Final V2.7 release-gate evidence

Read-only V2.7 Final Release Gate run `31489335300` validated candidate `a09c1ba18e25ae3afafec346d172de26cd258a41` and passed every configured stage:

- stable Flutter setup and dependency resolution;
- `pubspec.lock` stability in the working tree and against V2.6 `main`;
- canonical formatting and `git diff --check`;
- `flutter analyze`;
- focused `writing_analysis_limit_test.dart`;
- focused `writing_analysis_limit_widget_test.dart`;
- the complete project test suite;
- `flutter build web --release`;
- `2.7.0+12` package and `2.7.0` About identity assertions;
- bounded analyzer/result/dialog/test API markers;
- changelog/README/roadmap/technical/user/accessibility/privacy/security/support/release/PR-template/ledger markers;
- web manifest JSON validity;
- unchanged direct runtime dependency set (`flutter`, `shared_preferences`);
- zero `tools/v27*` or `.github/workflows/v27-*` path in the permanent feature diff.

This evidence was recorded after the successful gate, so the final documentation-complete head must be revalidated before merge. The release may not rely on this earlier SHA alone.

'''
path.write_text(text.replace(marker, section + marker))
