# commit-message: docs: update V2.8 release procedure and PR checklist
from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    if old not in text:
        raise SystemExit(f"expected marker not found in {path}: {old[:120]!r}")
    if text.count(old) != 1:
        raise SystemExit(f"expected one marker in {path}, found {text.count(old)}")
    p.write_text(text.replace(old, new, 1))


def append_section(path: str, heading: str, body: str) -> None:
    p = Path(path)
    text = p.read_text()
    if heading in text:
        raise SystemExit(f"section already present in {path}: {heading}")
    p.write_text(text.rstrip() + "\n\n" + body.strip() + "\n")


replace_once(
    "docs/RELEASING.md",
    "Current V2.7 release:\n\n```text\n2.7.0+12\n```",
    "Current V2.8 release candidate:\n\n```text\n2.8.0+13\n```",
)
replace_once(
    "docs/RELEASING.md",
    'git tag -a v2.6.0 -m "SpellChecker v2.6.0"\ngit push origin v2.6.0',
    'git tag -a v2.8.0 -m "SpellChecker v2.8.0"\ngit push origin v2.8.0',
)
replace_once(
    "docs/RELEASING.md",
    "3. Highlight V2.4 suggestion-ranker extensibility/default compatibility, plus the retained V2.3 review-preset/Portable settings and earlier correction-safety foundation.",
    "3. Highlight V2.8 exact local writing-analysis diagnostics and retained V2.7 bounded-review safety, while noting compatibility with earlier writing-rule, Portable settings, ranking, and correction-safety foundations.",
)
replace_once(
    "docs/RELEASING.md",
    "V2.4 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.",
    "V2.8 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.",
)

append_section(
    "docs/RELEASING.md",
    "## V2.8 exact writing-diagnostics release checks",
    r'''
## V2.8 exact writing-diagnostics release checks

Before tagging V2.8:

1. Verify package/About versions are `2.8.0+13` / `2.8.0`.
2. Verify analyzer-produced results expose exact `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`.
3. Verify direct V2.7-style `WritingAnalysisResult` construction can still omit exact diagnostics.
4. Verify an unbounded analyzer result reports exact totals equal to its retained result count.
5. Verify an exact-at-limit bounded result remains complete with zero uncaptured findings.
6. Verify a true overflow result reports an exact total greater than `capturedIssueCount`, a positive exact uncaptured count, and the correct global retained prefix.
7. Verify exact per-rule totals sum to the exact overall total and disabled/unsupported rules do not contribute.
8. Verify Writing insights displays exact first-N-of-total wording and the exact number of findings not retained.
9. Verify the `writing-findings-total-badge` renders the intended captured/total value when limited.
10. Verify enabled rule metadata shows exact `Total findings: N` values and the dialog remains lazy/scrollable without inaccessible controls.
11. Verify limited search/presets/categories/fix-only review and individual/batch fixes remain captured-only.
12. Verify singular/plural uncaptured-finding wording and filtered-empty limited-result wording.
13. Verify one Undo still restores a complete pre-batch document and stale-range/overlap safety remains unchanged.
14. Verify `pubspec.lock` and direct runtime dependencies are unchanged from V2.7 unless an independently reviewed dependency change exists.
15. Verify `.github/FUNDING.yml`, README, `SUPPORT.md`, and `CONTRIBUTING.md` contain `https://buymeacoffee.com/sanskarIN` and that no application runtime code contacts that service.
16. Verify `CHANGELOG.md`, `docs/ROADMAP.md`, API/architecture/performance/writing/development/testing/user/accessibility/troubleshooting/language/privacy/security/support/contribution/releasing docs, README/web metadata, and `what_changed.md` describe V2.8 consistently.
17. Verify no `tools/v28*`, `.github/workflows/v28-*`, or other disposable V2.8 helper/final-gate file is present in the release tree.
18. Run `flutter pub get`, format verification, analyzer, focused V2.8 diagnostics/limited-dialog tests, the complete regression suite, and `flutter build web --release` on the exact intended release SHA.
19. Record the exact final release-gate run and permanent-CI run in the V2.8 PR and engineering ledger without changing the validated SHA.
20. Merge only that exact green feature SHA, then compare the merged `main` tree with the validated feature tree and require zero file differences.

Tag only the verified merged `main` commit:

```bash
git tag -a v2.8.0 <verified-main-sha> -m "SpellChecker 2.8.0"
git push origin v2.8.0
```
''',
)

append_section(
    ".github/pull_request_template.md",
    "## V2.8 exact writing-analysis diagnostics checklist",
    r'''
## V2.8 exact writing-analysis diagnostics checklist

Complete when relevant.

- [ ] Analyzer-produced overall/per-rule exact totals are internally consistent and immutable.
- [ ] Direct V2.7-style result construction remains source-compatible when diagnostics are omitted.
- [ ] Exact totals include uncaptured findings without retaining every uncaptured `WritingIssue` object.
- [ ] The bounded retained list still equals the global deterministic prefix of unbounded analysis.
- [ ] Exact-at-limit completeness and true-overflow semantics are covered by focused tests.
- [ ] Disabled/unsupported rules are excluded from exact totals.
- [ ] Writing insights exact captured/total, first-N-of-total, per-rule totals, and uncaptured wording are tested.
- [ ] Limited filters and corrections remain captured-only, stale-safe, overlap-safe, and one-step undoable.
- [ ] Lazy/scrollable dialog tests navigate real off-screen controls rather than making production content eager.
- [ ] Exact totals remain local/memory-only and are not silently persisted, logged, exported, uploaded, or used as timing telemetry.
- [ ] `docs/PERFORMANCE.md` does not describe finding counts/`maxIssues` as a CPU-time or document-size security bound.
- [ ] `.github/FUNDING.yml` and documented support links remain optional and do not alter governance, support, security, or runtime behavior.
- [ ] `what_changed.md`, changelog, roadmap, README/web, and all affected technical/user/policy/release docs are synchronized.
- [ ] `pubspec.yaml` / About versions and tag instructions match the intended V2.8 release.
- [ ] No `tools/v28*` or disposable `.github/workflows/v28-*` file is included in the permanent release diff.
''',
)
