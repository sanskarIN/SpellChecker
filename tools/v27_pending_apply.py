# commit-message: docs: add V2.7 release and review gates
from pathlib import Path

releasing = Path('docs/RELEASING.md')
text = releasing.read_text()
old = '''Current V2.6 release:

```text
2.6.0+11
```'''
new = '''Current V2.7 release:

```text
2.7.0+12
```'''
if text.count(old) != 1:
    raise SystemExit('Expected exactly one current V2.6 release block.')
text = text.replace(old, new)
section = '''
## V2.7 bounded Writing insights release checks

Before tagging V2.7:

1. Verify `WritingAnalyzer.analyze()` remains unbounded when `maxIssues` is omitted.
2. Verify zero/negative `maxIssues` values are rejected.
3. Verify an exact-limit result is complete when no additional finding exists.
4. Verify a true overflow result exposes `isTruncated == true`, `isComplete == false`, and the configured `issueLimit`.
5. Verify bounded results equal the globally sorted prefix of unbounded results even when custom rules yield findings out of order.
6. Verify Writing insights uses a 200-finding limit and only shows limited-state wording after overflow is proven.
7. Verify search/presets/category/fix-only filters operate on captured findings in a limited result.
8. Verify limited batch labels say **captured** and one Undo restores the complete pre-batch editor text.
9. Verify `pubspec.lock` and direct runtime dependencies are unchanged unless a separately reviewed dependency change is intended.
10. Verify `what_changed.md`, README, changelog, roadmap, API/performance/writing/user/accessibility/privacy/security/support docs, and web metadata describe V2.7 consistently.
11. Verify no `tools/v27*` or `.github/workflows/v27-*` helper/gate artifact is present in the release tree.
12. Run formatting, analyzer, the complete test suite, and `flutter build web --release` on the exact intended release SHA.

Tag the verified release only from the exact merged `main` commit:

```bash
git tag -a v2.7.0 <verified-main-sha> -m "SpellChecker 2.7.0"
git push origin v2.7.0
```
'''
if '## V2.7 bounded Writing insights release checks' in text:
    raise SystemExit('V2.7 release checks already exist.')
releasing.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')

template = Path('.github/pull_request_template.md')
pt = template.read_text()
checklist = '''
## V2.7 bounded writing-analysis checklist

- [ ] Optional `maxIssues` behavior preserves unbounded compatibility and positive-limit validation.
- [ ] Bounded findings preserve the globally sorted unbounded prefix and exact-at-limit completeness.
- [ ] Limited Writing insights wording describes captured findings/filters/batch actions truthfully.
- [ ] Focused bounded-analysis and limited-dialog tests are included or remain green.
- [ ] No persistence format, runtime dependency, network, privacy, or security boundary changed unintentionally.
- [ ] `what_changed.md` and release documentation are synchronized with the implementation.
- [ ] No V2.7 helper or disposable workflow is included in the permanent release diff.
'''
if '## V2.7 bounded writing-analysis checklist' in pt:
    raise SystemExit('V2.7 PR checklist already exists.')
template.write_text(pt.rstrip() + '\n\n' + checklist.strip() + '\n')
