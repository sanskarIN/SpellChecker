# V2.14 Final Validation

Release candidate: `2.14.0+19` / About `2.14.0`.

This document records the final acceptance evidence for the SpellChecker V2.14 unmatched-square-bracket release after implementation, compatibility hardening, release synchronization, package-aware formatting, permanent CI, independent release-mode web validation, normal merge, and merged-main validation.

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

Permanent pull-request CI run `31872668004` validated the fully synchronized owner-authored V2.14 release candidate. Dependency resolution, canonical formatting, static analysis, the complete Flutter test suite, and deterministic benchmark smoke all passed.

## Independent release-mode evidence

One-time release-gate run `31872872493` independently validated the V2.14 candidate successfully on August 15, 2026.

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

The successful gate removed `.github/workflows/v214-release-gate.yml` and pushed cleanup commit `d408e0d923ee5f45ac625098d0cc75de6e60bbd5`.

## Final PR head and implementation merge evidence

The release-gate evidence update produced exact final PR head `199e8f6c17a659c2eb5d7fd54a3fde9187f333df`. Permanent PR CI run `31873000788` passed canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on that exact head.

PR #79 contained 60 branch commits and 45 permanent changed files at the merge boundary. The permanent diff was helper-free and contained only source, tests, release identity, documentation, web metadata, and `what_changed.md` changes.

PR #79 was merged with a normal merge commit rather than squash or rebase so the full 60-commit granular implementation/release history remains reachable. The implementation merge commit is:

`ae2e66669747b44b408297f663d500f86c254369`

The merge tree is `c859fdb14f1867b84773300fa6db1c8c8d205845`, identical to the already-green final PR tree.

## Merged-main CI evidence

Post-merge `main` CI run `31873077140` validated implementation merge `ae2e66669747b44b408297f663d500f86c254369`.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

The implementation merge therefore has independent release-mode evidence and a successful permanent default-branch CI run.

## Final evidence follow-up boundary

This post-merge evidence branch changes only `docs/V2_14_FINAL_VALIDATION.md` and `what_changed.md` in its permanent diff. It changes no Dart source, test logic, dependency, package/About identity, persistence format, web build input, or runtime behavior.

The evidence pull request must pass permanent CI, merge normally, and leave its resulting `main` merge commit green before V2.14 is considered fully complete.
