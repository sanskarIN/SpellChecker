# V2.14 Final Validation

Release candidate: `2.14.0+19` / About `2.14.0`.

This document records the final acceptance boundary and evidence for the SpellChecker V2.14 unmatched-square-bracket release. The implementation remains local, deterministic, and advisory-only, and the validation sequence deliberately separates functional evidence, release synchronization, package-aware formatting, permanent CI, independent release-mode validation, merge evidence, and final default-branch validation.

## Implemented candidate

- Public `UnmatchedSquareBracketRule` exists at `lib/writing/rules/unmatched_square_bracket_rule.dart`.
- Stable rule ID is `unmatched-square-bracket`.
- `package:spellchecker/writing.dart` publicly exports the rule.
- `WritingRuleRegistry` contains nine built-in rules and resolves the new rule by stable ID.
- Unset/reset per-language rule preferences resolve to the nine-rule default registry.
- Explicit V2.13 eight-rule overrides remain authoritative and are not silently expanded.
- Portable settings format/version remains unchanged and preserves both old explicit eight-rule sets and explicit V2.14 nine-rule sets.
- The rule is warning-level and advisory-only: it has no automatic replacement and batch correction skips it while independent safe fixes may still apply.
- Literal nested square brackets are balanced iteratively; unmatched characters retain one-character UTF-16 source ownership and findings are source ordered.
- Parenthesis and square-bracket diagnostics remain independent delimiter families.
- Focused regressions cover malformed ordering, non-BMP offsets, 5,000-level nesting, bounded exact totals, review filtering, widget behavior, V2.13 preference compatibility, Portable settings, private diagnostics, benchmark identity, and correction skipping.
- The core Writing insights widget suite no longer relies on a fixed `-1400` findings-list drag; it builds the exact action under test.
- Package identity is `2.14.0+19`; About identity is `2.14.0`.
- `CHANGELOG.md`, `README.md`, `what_changed.md`, roadmap, writing/API/architecture/development/testing/performance/user/accessibility/troubleshooting/language/privacy/release/security/support/contributor documentation, PR guidance, and web metadata are synchronized with V2.14.
- No runtime dependency, preference-key family, Portable-settings format version, network behavior, telemetry, account behavior, cloud writing service, background upload, document persistence, or hidden clipboard action was added.

## Functional CI evidence

Permanent CI run `31872367596` validated the complete functional nine-rule implementation before release metadata synchronization.

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

The first V2.14 PR run had stopped at formatting before analyzer/tests because three new test files needed Dart 3.13 canonical wrapping. A package-aware one-time formatter resolved dependencies first, committed only real formatter output, verified a clean second pass, and removed itself. The later functional CI run above then passed the complete implementation.

## Release synchronization evidence

Guarded release synchronization completed successfully in workflow run `31872544618`.

Before writing any release file, the synchronizer preflighted exact anchors for the About source, About regression, README, changelog, `what_changed.md`, documentation set, and web metadata. It then committed each permanent release surface separately, including the complete V2.14 engineering ledger requested in `what_changed.md`.

The workflow removed:

- `tool/v214_release_sync.py`;
- `.github/workflows/v214-release-sync.yml`;
- the superseded `docs/V2_14_WORKING_SCOPE.md` development-only scope file.

None of those helper files remains in the permanent PR diff.

## Final package-aware formatting evidence

Final formatter workflow run `31872582067` validated the synchronized release Dart tree after the About source/test changes.

It:

1. checked out the exact V2.14 branch;
2. resolved Flutter dependencies;
3. ran `dart format lib test tool`;
4. committed any real Dart 3.13 formatting drift;
5. immediately ran the formatter again;
6. verified no tracked Dart diff remained;
7. removed `.github/workflows/v214-final-format.yml`;
8. pushed the helper-free candidate.

The helper-free branch after that run contained 44 permanent changed files relative to the V2.13 base and no V2.14 formatter or release-sync helper.

## Permanent synchronized-candidate CI requirement

This documentation-only evidence commit is owner-authored so the exact synchronized/helper-free release candidate receives the permanent pull-request CI gate.

The exact head must pass:

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

A formatting, analyzer, complete-suite, or benchmark failure remains a release blocker even though this commit itself changes only documentation.

## Independent release-mode gate

After the permanent synchronized-candidate CI is green, an independent one-time release gate must repeat the permanent checks and additionally verify:

- `flutter build web --release` succeeds;
- package version is exactly `2.14.0+19`;
- About version is exactly `2.14.0`;
- `UnmatchedSquareBracketRule` is registered and publicly exported;
- stable rule ID `unmatched-square-bracket` is present;
- the built-in/default writing catalogue has exactly nine stable rule IDs;
- focused V2.14 regression files exist;
- explicit V2.13 eight-rule preference compatibility is covered;
- `what_changed.md`, `CHANGELOG.md`, README current-release identity, and V2.14 behavior/validation documentation are present;
- `web/manifest.json` parses as valid JSON and describes the V2.14 advisory diagnostic;
- direct runtime dependencies remain only Flutter and `shared_preferences`;
- release web `index.html` and `main.dart.js` outputs exist;
- no unexpected tracked V2.14 formatter, synchronizer, diagnostic, patch, release-gate, or working-scope helper remains in the permanent candidate.

The one-time release gate must delete itself after successful validation. Its cleanup commit must be followed by an owner-authored evidence update and another successful permanent CI run before merge.

## Merge policy

PR #79 must remain mergeable and its permanent diff must remain helper-free. The final implementation merge must use a normal merge commit rather than squash so the deliberately granular implementation, regression, release, documentation, validation, and cleanup history is preserved.

Only the exact final green candidate may be merged to `main`. After merge, the resulting `main` commit must receive its own successful permanent CI run. A documentation-only post-merge evidence follow-up must then record the actual PR head/commit count, implementation merge SHA, release-gate run, and merged-main CI in this document and `what_changed.md`; that follow-up must itself pass CI, merge normally, and leave a final green `main` before V2.14 is considered complete.
