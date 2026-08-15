from pathlib import Path

path = Path('what_changed.md')
text = path.read_text()
marker = '### Final V2.16 implementation merge, release-gate, and cleanup evidence\n'
if marker in text:
    raise SystemExit('final V2.16 evidence already present')
anchor = '\n\n## V2.15 — Unmatched Curly Brace Diagnostics'
if text.count(anchor) != 1:
    raise SystemExit(f'expected one V2.15 anchor, found {text.count(anchor)}')
section = '''

### Final V2.16 implementation merge, release-gate, and cleanup evidence
- Permanent synchronized-candidate CI run `31880290563` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter suite, and benchmark smoke on owner head `b96a5a390ccf010d45d9f9e18046c871b3097acc`.
- Initial independent release-gate run `31880458485` independently passed formatting, analysis, the complete suite, benchmark, `flutter build web --release`, and `git diff --check`. Its final helper-residue assertion was a gate false positive: the repository-wide filename scan incorrectly treated permanent regression `test/v216_startup_preference_sync_widget_test.dart` as a disposable helper because its filename contains `sync`.
- The helper-residue assertion was narrowed to disposable locations only. Corrected independent release-gate run `31880650266` then passed every stage and exact release/audit assertion, including package `2.16.0+21`, About `2.16.0`, exactly ten writing rules, unrestricted/scalar edit-distance regressions, decomposed-Unicode coverage, strict import validation, failed-persistence regressions, startup synchronization, Unicode-safe correction casing, documentation/web metadata, direct dependency boundary, release web outputs, absent working scope, and zero unexpected disposable V2.16 helpers. The corrected gate self-removed in branch cleanup commit `e5ad4f78f3921ef1f5ae578c70a1193092ceba82`.
- PR #83 was normally merged while that corrected gate rerun was still executing. Its exact implementation boundary preserved **89 granular branch commits**, **45 changed files**, **996 additions**, and **64 deletions** at head `c89e799a420246e94071a7c6a811ebde400af399`.
- The implementation merge commit is `262859ac5f2058fc6dc71141e7edb26650e1385a`; its tree is `52b7cb9359da883e637428ad503b8eb4fc090fe4`.
- Post-implementation-merge `main` CI run `31880508903` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and benchmark smoke on that exact merge.
- Because PR #83 merged before release-gate cleanup existed, the merge temporarily retained `.github/workflows/v216-release-gate.yml`. This is repository-hygiene residue only; it does not alter runtime code, tests, dependencies, formats, release identity, or application behavior.
- Final branch `v2.16-post-merge-validation-2026-08-15` starts directly from implementation merge `262859ac5f2058fc6dc71141e7edb26650e1385a`. Its permanent diff removes that disposable gate and updates only this engineering ledger plus `docs/V2_16_FINAL_VALIDATION.md` with actual post-merge evidence.
- Git tags and GitHub Releases remain empty. V2.16 deliberately does not invent the repository's first publication convention.
- This final cleanup/evidence change must pass permanent CI, merge normally, and leave one final green, helper-free `main` before the V2.16 project endpoint is accepted.
'''
text = text.replace(anchor, section + anchor, 1)
path.write_text(text)
