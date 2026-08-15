# V2.14 Final Validation

Release candidate: `2.14.0+19` / About `2.14.0`.

This document records the final acceptance evidence for the SpellChecker V2.14 unmatched-square-bracket release after implementation, compatibility hardening, release synchronization, package-aware formatting, permanent CI, and independent release-mode web validation.

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

Permanent CI run `31872367596` validated the complete functional nine-rule implementation before release metadata synchronization. It passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke.

The first V2.14 PR run stopped at formatting before analyzer/tests because three new test files needed Dart 3.13 canonical wrapping. A package-aware one-time formatter resolved dependencies first, committed only real formatter output, verified a clean second pass, and removed itself. The subsequent functional run above passed the complete implementation.

## Release synchronization and formatting evidence

Guarded release synchronization completed successfully in workflow run `31872544618`. Before writing any release file, the synchronizer preflighted exact anchors for the About source, About regression, README, changelog, `what_changed.md`, permanent documentation set, and web metadata. It committed each permanent release surface separately, including the complete V2.14 engineering ledger in `what_changed.md`.

The release-sync workflow removed `tool/v214_release_sync.py`, `.github/workflows/v214-release-sync.yml`, and the superseded `docs/V2_14_WORKING_SCOPE.md` development-only scope file.

Final formatter workflow run `31872582067` then validated the synchronized release Dart tree after the About source/test changes. It resolved dependencies, applied canonical Dart formatting, committed any real formatter drift, immediately reran the formatter, verified the tracked Dart tree remained clean, removed `.github/workflows/v214-final-format.yml`, and pushed the helper-free candidate.

## Permanent synchronized-candidate CI

Permanent pull-request CI run `31872668004` validated the fully synchronized owner-authored V2.14 release candidate.

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

One-time release-gate run `31872872493` independently validated the V2.14 candidate successfully on August 15, 2026.

The gate repeated the permanent checks and then executed the release-only build and repository assertions.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed;
- `flutter build web --release`: passed;
- `git diff --check`: passed;
- package version `2.14.0+19`: verified;
- About version `2.14.0`: verified;
- public `UnmatchedSquareBracketRule` export: verified;
- `UnmatchedSquareBracketRule` built-in registration: verified;
- stable rule ID `unmatched-square-bracket`: verified;
- exactly nine built-in writing-rule constructors: verified;
- focused V2.14 regression files: verified;
- explicit V2.13 preference-compatibility coverage: verified;
- `what_changed.md` V2.14 engineering ledger and release identity: verified;
- `CHANGELOG.md` V2.14 release entry: verified;
- README V2.14 current-release identity and section: verified;
- dedicated V2.14 behavior and validation documentation: verified;
- `web/manifest.json`: parsed successfully and contains the V2.14 advisory diagnostic description;
- direct runtime dependency boundary: verified as only Flutter and `shared_preferences`;
- release web `index.html` and `main.dart.js` outputs: verified;
- superseded V2.14 working-scope document: absent;
- unexpected V2.14 synchronizer, formatter, tool, or workflow helper residue: none found.

The successful gate removed `.github/workflows/v214-release-gate.yml` and pushed cleanup commit `d408e0d923ee5f45ac625098d0cc75de6e60bbd5`. Therefore the permanent candidate does not retain the release-gate helper.

## Final evidence-head CI requirement

This documentation-only evidence commit changes the pull-request head after the successful release gate, so the exact new head must receive one final green permanent CI run. It changes no Dart source, test logic, dependency, package/About identity, web build input, persistence behavior, or runtime behavior.

The final permanent run must again pass formatting, static analysis, the complete Flutter test suite, and benchmark smoke before merge.

## Merge policy

PR #79 must remain mergeable and its permanent diff must remain free of disposable V2.14 helpers. The final implementation merge must use a normal merge commit rather than squash so the deliberately granular implementation, regression, release, documentation, validation, and cleanup history is preserved.

Only the exact final green candidate may be merged to `main`. After merge, the resulting `main` commit must receive its own successful permanent CI run. A documentation-only post-merge evidence follow-up must then record the actual PR head/commit count, implementation merge SHA, release-gate run, and merged-main CI in this document and `what_changed.md`; that follow-up must itself pass CI, merge normally, and leave a final green `main` before V2.14 is considered complete.
