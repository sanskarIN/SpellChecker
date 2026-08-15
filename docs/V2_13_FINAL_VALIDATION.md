# V2.13 Final Validation

Release candidate: `2.13.0+18` / About `2.13.0`.

This document records the final acceptance evidence for the SpellChecker V2.13 unmatched-parenthesis release after implementation, compatibility hardening, release synchronization, package-aware formatting, permanent CI, release-mode web validation, normal-history-preserving merge, and merged-main CI.

## Implemented candidate

- Public `UnmatchedParenthesisRule` exists at `lib/writing/rules/unmatched_parenthesis_rule.dart`.
- Stable rule ID is `unmatched-parenthesis`.
- `package:spellchecker/writing.dart` publicly exports the rule.
- `WritingRuleRegistry` contains eight built-in rules and resolves the new rule by stable ID.
- Unset/reset per-language rule preferences resolve to the eight-rule default registry.
- Explicit V2.12 seven-rule overrides remain authoritative and are not silently expanded.
- Portable settings format/version remains unchanged and preserves both old explicit seven-rule sets and new explicit eight-rule sets.
- The rule is warning-level and advisory-only: it has no automatic replacement and batch correction skips it while independent safe fixes may still apply.
- Literal nested parentheses are balanced iteratively; unmatched characters retain one-character UTF-16 source ownership and findings are source ordered.
- Focused regressions cover malformed ordering, non-BMP offsets, 5,000-level nesting, bounded exact totals, review filtering, widget behavior, preference compatibility, Portable settings, private diagnostics, benchmark identity, and correction skipping.
- Package identity is `2.13.0+18`; About identity is `2.13.0`.
- `CHANGELOG.md`, `README.md`, `what_changed.md`, roadmap, writing/API/architecture/development/testing/performance/user/accessibility/troubleshooting/language/privacy/release/security/support/contributor documentation, PR guidance, and web metadata are synchronized with V2.13.
- No runtime dependency, preference-key family, Portable-settings format version, network behavior, telemetry, account behavior, cloud writing service, background upload, document persistence, or hidden clipboard action was added.

## Functional CI evidence

Permanent CI run `31869797175` validated the complete functional eight-rule implementation before release metadata synchronization. It passed package-aware formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke.

The complete suite initially exposed three lazy-list geometry assumptions after the registry grew from seven to eight rules. Those widget tests were repaired to scroll by lazy build state/visibility rather than fixed seven-rule pixel geometry. No production behavior was changed by those repairs. The subsequent functional CI run passed in full.

## Release synchronization and formatting evidence

The guarded release-documentation synchronization completed successfully in workflow run `31870124244`. It committed the permanent release surfaces individually—including the complete V2.13 `what_changed.md` engineering ledger—and removed both its script and workflow from the permanent branch.

The final package-aware formatter completed successfully in workflow run `31870150516`. It resolved dependencies before formatting, applied any real Dart 3.13 formatter output, immediately reran the formatter, verified the tracked Dart tree remained clean, and removed its own workflow before pushing the helper-free branch head.

## Permanent synchronized-candidate CI

Permanent pull-request CI run `31870187663` validated owner commit `009dbb69564b1c500543c1b36563c338c3f31ee1` after all release documentation and the final formatter cleanup were present.

Every permanent `.github/workflows/ci.yml` stage passed:

```text
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
dart run tool/benchmark_large_document.dart \
  --repeats=4 \
  --warmup=0 \
  --iterations=1 \
  --spelling-limit=2 \
  --writing-limit=5 \
  --suggestions=0 \
  --language=en-US \
  --json
```

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- static analysis: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

## Independent release-mode evidence

One-time release-gate run `31870277817` independently validated the V2.13 candidate successfully on August 15, 2026. The gate repeated the permanent validation stages and then executed the release-only build and repository assertions.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed;
- `flutter build web --release`: passed;
- package version `2.13.0+18`: verified;
- About version `2.13.0`: verified;
- public `UnmatchedParenthesisRule` export: verified;
- `UnmatchedParenthesisRule` built-in registration: verified;
- stable rule ID `unmatched-parenthesis`: verified;
- exactly eight built-in writing-rule constructors: verified;
- focused V2.13 regression files: verified;
- `what_changed.md` V2.13 engineering ledger and release identity: verified;
- `CHANGELOG.md` V2.13 release entry: verified;
- README V2.13 current-release identity and section: verified;
- dedicated V2.13 behavior and validation documentation: verified;
- `web/manifest.json`: parsed successfully and contains the V2.13 diagnostic description;
- direct runtime dependency boundary: verified as only Flutter and `shared_preferences`;
- release web `index.html` and `main.dart.js` outputs: verified;
- unexpected V2.13 synchronizer, formatter, patch, diagnostic, tool, or workflow helper residue: none found.

The successful gate removed `.github/workflows/v213-release-gate.yml` and pushed cleanup commit `6dcba69ee737597e0007e5e67d591c8deb99ca2c`. Therefore the permanent candidate does not retain the release-gate helper.

## Final pre-merge evidence-head CI

After release-gate evidence was recorded, permanent CI run `31870395536` validated the exact final PR head `4e68476af57efdea295e9a3488c2df8b335a7ab7` successfully.

The run passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke. No production source, test logic, dependency, package/About identity, web build input, persistence behavior, or runtime behavior changed after that successful run.

## Merge and merged-main evidence

PR #77 was merged using a normal merge commit so its complete granular development history was preserved rather than squashed.

- Final PR head: `4e68476af57efdea295e9a3488c2df8b335a7ab7`.
- PR #77 branch commit count: 65 commits.
- Merge commit on `main`: `fa01826aa084d858e784bed3d09fa3fdcbfa0760`.
- Merge tree: `7ed318aa9bdaa3f0532366b4311305f846daea1d`, identical to the already-green final candidate tree.
- Post-merge `main` CI run: `31870480137`.

Main CI run `31870480137` passed every permanent stage on merge commit `fa01826aa084d858e784bed3d09fa3fdcbfa0760`:

- dependency resolution: passed;
- canonical formatting: passed;
- static analysis: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

This establishes that the repository default branch contains the same validated V2.13 release tree that passed the PR and release-mode gates.

## Post-merge documentation evidence

This post-merge follow-up changes documentation only. It records the actual merge SHA and merged-main CI run after those values existed. It does not alter Dart source, tests, dependencies, package/About identity, web build inputs, persistence formats, runtime behavior, or the V2.13 feature contract.

The post-merge evidence pull request must itself pass the permanent CI gate before merge. After that documentation-only merge, the resulting `main` head must receive one final successful permanent CI run so the repository ends with recorded evidence and a green default branch.

## Release status

V2.13 implementation, compatibility coverage, synchronized documentation, release-mode web validation, granular-history merge, and implementation-merge CI are complete. The only remaining acceptance action for this documentation follow-up is to validate and merge the evidence-only change and confirm the resulting final `main` CI run.
