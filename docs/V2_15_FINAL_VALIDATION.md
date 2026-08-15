# V2.15 Final Validation

Release candidate: `2.15.0+20` / About `2.15.0`.

This document records the acceptance boundary and validation evidence for SpellChecker V2.15 — Unmatched Curly Brace Diagnostics. The implementation remains local, deterministic, advisory-only, source-range explicit, backward-compatible with saved V2.14 rule choices, and integrated through the existing writing-analysis architecture.

## Implemented candidate

- Public `UnmatchedCurlyBraceRule` exists at `lib/writing/rules/unmatched_curly_brace_rule.dart`.
- Stable ID is `unmatched-curly-brace`.
- `package:spellchecker/writing.dart` publicly exports the rule.
- `WritingRuleRegistry` contains ten built-in/default writing rules and resolves the new stable ID.
- Literal nested `{` / `}` pairs are balanced iteratively; unmatched characters retain one-character UTF-16 ownership and findings are source ordered.
- Non-BMP source-offset coverage verifies a brace following an astral character uses the correct UTF-16 index.
- Parenthesis, square-bracket, and curly-brace diagnostics remain independent delimiter families.
- The rule is warning-level and advisory-only: it has no replacement; batch correction skips it while independent safe fixes may still apply.
- Unset/reset per-language preferences resolve to the ten-rule current registry.
- Explicit V2.14 nine-rule overrides remain exact and are not silently expanded.
- Portable settings format/version remains unchanged and preserves both explicit V2.14 nine-rule sets and explicit V2.15 ten-rule sets.
- Bounded analysis retains exact total/per-rule counts and global source ordering.
- Diagnostic summaries expose stable metadata/counts but not private editor excerpts.
- Benchmark identity/totals include the tenth rule; focused stress coverage exercises 5,000 balanced and 5,000 unmatched braces.
- Writing insights search, Mechanics filtering, automatic-fix filtering, rule persistence, reset behavior, and advisory presentation cover the new rule.
- The shared Writing insights safe-fix regression no longer evaluates `.first` before a lazily built action exists.
- Package identity is `2.15.0+20`; About identity is `2.15.0`.
- `README.md`, `CHANGELOG.md`, `what_changed.md`, maintained contributor/security/support/documentation surfaces, and web metadata are synchronized with V2.15.
- No runtime dependency, application-network request, telemetry, account behavior, cloud writing service, background upload, document persistence, preference-key family, Portable-settings format version, or correction-engine fork was added.

## Functional CI evidence

Permanent CI run `31876071657` validated the complete functional ten-rule implementation before release synchronization on owner-authored head `d82a8e68a0fce15601f8dfe3ae56a17580e41363`.

Every permanent `.github/workflows/ci.yml` stage passed:

```text
flutter pub get
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

Earlier red functional runs were used to isolate a test-harness catalogue-growth regression. The production editor was not failing: `test/writing_widget_test.dart` eagerly created `find.text('Apply safe fix').first` before the lazy list had built a matching action. V2.15 now scrolls with the base finder and selects `.first` only after the action exists. The corrected implementation then passed the complete permanent functional gate above.

## Release synchronization evidence

The first release-sync workflow definition was rejected before any job ran because YAML interpreted colons in one-line shell values as mapping syntax. It wrote no release files.

A corrected block-scalar workflow then ran the guarded synchronizer. Its first execution successfully preflighted and locally committed all permanent release surfaces but stopped during helper cleanup because the synchronizer had been intentionally patched during preflight and `git rm` refused the modified helper; no local commits were pushed.

Final guarded release synchronization run `31876390920` corrected that helper lifecycle with forced removal of the disposable synchronizer after successful preflight. It then:

1. validated the expected V2.14/current V2.15 anchors before release writes;
2. normalized the PR template's top-level heading deliberately;
3. synchronized About source/test, README, changelog, `what_changed.md`, contributor/security/support guides, the maintained docs set, writing-rule catalogue, and web metadata;
4. created a separate commit for each permanent release/documentation surface;
5. removed `docs/V2_15_WORKING_SCOPE.md`;
6. removed `tool/v215_release_sync.py`;
7. removed `.github/workflows/v215-release-sync.yml`;
8. verified the helper-free tree;
9. pushed the synchronized branch successfully.

The permanent `what_changed.md` V2.15 ledger records production behavior, source ownership, advisory safety, compatibility, diagnostics, benchmark/stress coverage, UI integration, the lazy-finder regression and fix, parser limitation, runtime/privacy boundaries, and functional CI evidence.

## Final package-aware formatting evidence

Final formatter workflow run `31876423908` checked the synchronized release candidate after About source/test changes.

It:

1. checked out the synchronized V2.15 branch;
2. resolved Flutter dependencies;
3. ran `dart format lib test tool`;
4. committed any genuine formatter drift if present;
5. immediately reran canonical formatting in check mode;
6. verified no tracked Dart diff remained;
7. removed `.github/workflows/v215-final-format.yml`;
8. pushed helper-free head `f79e566637a33e8ba0ae1c8330103756f4f39027`.

The formatter's apply step, immediate second pass, helper cleanup, and push all passed.

## Permanent synchronized-candidate CI evidence

Permanent pull-request CI run `31876478606` validated owner-authored synchronized candidate head `759834f3d6680f10e8f03a85410a1fb7ca8d8b53`.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

This run established that the fully synchronized `2.15.0+20` candidate remained code-quality clean after release metadata, About, documentation, and web-surface synchronization.

## Independent release-mode evidence

One-time release-gate run `31876609678` independently validated the V2.15 candidate successfully on August 15, 2026.

The gate repeated the permanent checks and then executed the release-only build and repository assertions.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed;
- `flutter build web --release`: passed;
- `git diff --check`: passed;
- package version `2.15.0+20`: verified;
- About version `2.15.0`: verified;
- public `UnmatchedCurlyBraceRule` export: verified;
- `UnmatchedCurlyBraceRule` built-in registration: verified;
- stable rule ID `unmatched-curly-brace`: verified;
- exactly ten built-in writing-rule constructors: verified;
- focused V2.15 regression files: verified;
- explicit V2.14 nine-rule preference compatibility: verified;
- explicit V2.14/V2.15 Portable-settings compatibility: verified;
- `what_changed.md` V2.15 engineering ledger and release identity: verified;
- `CHANGELOG.md` V2.15 release entry: verified;
- README V2.15 current-release identity: verified;
- dedicated V2.15 behavior and validation documentation: verified;
- `web/manifest.json`: parsed successfully and contains the V2.15 advisory diagnostic description;
- direct runtime dependency boundary: verified as only Flutter and `shared_preferences`;
- release web `index.html` and `main.dart.js` outputs: verified;
- superseded V2.15 working-scope document: absent;
- unexpected V2.15 synchronizer, formatter, diagnostic, patch, or workflow helper residue: none found.

The successful gate removed `.github/workflows/v215-release-gate.yml` and pushed cleanup commit `3f00e356685762874cda279e4a24f9deeee3c2d8`. Therefore the permanent candidate does not retain the release-gate helper.

## Final implementation PR and merge evidence

Final permanent PR CI run `31876743735` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on exact final PR #81 head `7a5f851f719f740267c092b5705be8c6b4bba2f6`.

At the implementation merge boundary, PR #81 contained 81 branch commits, 46 permanent changed files, 1,387 additions, and 22 deletions. The permanent diff contained only production source, public API/registry integration, tests, package/About identity, release documentation, web metadata, and the V2.15 engineering ledger; disposable V2.15 formatter, diagnostic, patch, release-sync, release-gate, and working-scope helpers were absent.

PR #81 was merged with a normal merge commit rather than squash or rebase, preserving the complete 81-commit granular branch history. The implementation merge commit is `31450fc9223f3f958c18c887c0a7047cb01a9ac8`.

The final PR tree and implementation merge tree are identical: both are `4554f793c446ae22bcddd6d76776f313bc30950d`. This confirms the default branch received the exact candidate already validated by final PR CI and the independent release-mode gate, with no merge-conflict rewrite.

## Merged-main CI evidence

Permanent default-branch CI run `31876830663` validated implementation merge `31450fc9223f3f958c18c887c0a7047cb01a9ac8` successfully.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

The implementation merge therefore preserved the fully validated V2.15 runtime/test/build tree on `main`.

## Post-merge evidence follow-up

This documentation-only follow-up records facts that were unknowable until PR #81 had actually merged: the exact 81-commit/46-file implementation boundary, merge SHA/tree identity, and merged-main CI run.

Its permanent diff is restricted to this validation record and `what_changed.md`. It changes no Dart source, test logic, dependency, package/About identity, persistence format, web build input, preference behavior, Portable-settings format, or runtime behavior.

The post-merge evidence pull request must itself pass the repository's permanent formatting/analyze/full-test/benchmark CI and merge normally. The resulting final `main` merge must then receive one last green permanent CI run before V2.15 is considered complete.
