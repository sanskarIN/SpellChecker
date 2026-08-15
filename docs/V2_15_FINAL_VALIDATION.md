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

## Permanent synchronized-candidate CI requirement

This final-validation file is an owner-authored documentation-only commit so the exact synchronized/helper-free V2.15 release candidate receives the repository's permanent pull-request CI gate.

The exact head must pass canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke. A failure remains a release blocker even though this evidence commit itself changes only documentation.

## Independent release-mode gate requirement

After synchronized-candidate permanent CI is green, an independent one-time release gate must repeat the permanent checks and additionally verify:

- `flutter build web --release` succeeds;
- `git diff --check` succeeds;
- package version is exactly `2.15.0+20`;
- About version is exactly `2.15.0`;
- `UnmatchedCurlyBraceRule` is registered and publicly exported;
- stable rule ID `unmatched-curly-brace` is present;
- the built-in/default catalogue has exactly ten rule constructors and ten stable IDs;
- focused V2.15 regression files exist;
- explicit V2.14 nine-rule preference and Portable-settings compatibility are covered;
- `what_changed.md`, `CHANGELOG.md`, README current-release identity, V2.15 behavior documentation, and this validation record are present;
- `web/manifest.json` parses successfully and describes the curly-brace diagnostic;
- direct runtime dependencies remain only Flutter and `shared_preferences`;
- release web `index.html` and `main.dart.js` outputs exist;
- `docs/V2_15_WORKING_SCOPE.md` is absent;
- no unexpected tracked V2.15 synchronizer, formatter, diagnostic, patch, release-gate, or other disposable helper remains.

The one-time gate must delete itself after successful validation. Its cleanup commit must be followed by an owner-authored evidence update and another green permanent CI run before merge.

## Merge policy

PR #81 must remain mergeable and its permanent diff must remain helper-free. The implementation merge must use a normal merge commit rather than squash/rebase so the deliberately granular production, regression, debugging, release, documentation, validation, and cleanup history is preserved.

Only the exact final green candidate may merge to `main`. The implementation merge must then receive its own permanent default-branch CI run. A documentation-only post-merge follow-up must record the actual PR head/commit count, implementation merge SHA, release-gate evidence, and merged-main CI in this document and `what_changed.md`; that follow-up must itself pass CI, merge normally, and leave a final green `main` before V2.15 is considered complete.
