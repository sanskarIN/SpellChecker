# V2.12 Final Validation

Release candidate: `2.12.0+17` / About `2.12.0`.

This file records the final acceptance evidence for V2.12 after implementation, release synchronization, canonical formatting, full CI, and release-mode web validation.

## Implemented candidate

- The production `MissingPunctuationSpaceRule` exists in `lib/writing/rules/missing_punctuation_space_rule.dart`.
- The rule is publicly exported and registered as the seventh built-in writing rule.
- Dedicated baseline, decomposed-Unicode, non-BMP-offset, batch-composition, widget, persistence, registry, and benchmark regressions are tracked.
- Package identity is `2.12.0+17` and the About dialog identity is `2.12.0`.
- `CHANGELOG.md`, `README.md`, `what_changed.md`, roadmap, writing/API/testing/performance/user/privacy/security/support/contributor/release documentation, PR-template guidance, and web metadata are synchronized with V2.12.
- Guarded release synchronization completed and removed its script, workflow, and temporary diagnostic file.
- Package-aware Dart 3.13 formatting was applied after `flutter pub get`, matching the permanent CI order.
- The first full-suite attempt exposed four assertion-only regressions: one mixed-mechanics fixture without actual trailing whitespace, two V2.11 accessibility expectations frozen to six rules, and the V2.11 About-version expectation.
- Those four assertions were repaired in separate commits. Accessibility tests now derive their supported-rule total from the analyzer registry, the mixed-mechanics fixture contains real document-end trailing whitespace, and the About test expects V2.12.
- The repaired Dart tests were package-aware formatted and all disposable test/format diagnostics were removed.

## Permanent CI evidence

GitHub Actions CI run `31868043307` validated owner commit `61092ff4ae72ca6b329366a8d6b6d1623fddf3bc` successfully on August 15, 2026.

The permanent `.github/workflows/ci.yml` gate passed every required stage:

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

## Release-mode evidence

One-time release-gate run `31868121011` independently validated the V2.12 candidate successfully on August 15, 2026. The gate used Flutter stable and repeated the permanent validation stages before performing release-only checks.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed;
- `flutter build web --release`: passed;
- package version `2.12.0+17`: verified;
- About version `2.12.0`: verified;
- `MissingPunctuationSpaceRule` registry registration: verified;
- public writing export: verified;
- stable rule ID `missing-punctuation-space`: verified;
- focused V2.12 regression files: verified;
- `what_changed.md` V2.12 engineering ledger: verified;
- `CHANGELOG.md` V2.12 release entry: verified;
- README current V2.12 identity: verified;
- web manifest JSON parsing: passed;
- direct runtime dependency boundary (`flutter`, `shared_preferences`): verified;
- release web output files: verified;
- unexpected V2.12 helper workflows/tools/root diagnostics: none found.

The successful gate removed `.github/workflows/v212-release-gate.yml` itself and pushed cleanup commit `6c6094cedc3e658be43905992d64d0e1395fba0f`. Therefore the permanent candidate does not retain the one-time release gate.

## Final merge condition

This documentation-only evidence commit must itself receive a green permanent CI run because it changes the pull-request head after the successful release gate. No Dart source, release identity, dependency, runtime behavior, or build input is changed by this evidence update.

After that final CI run:

- PR #75 must remain mergeable;
- the permanent diff must contain no disposable V2.12 helper workflow, tool, or root diagnostic;
- the merge must preserve the granular implementation history rather than squash it;
- only the exact green candidate may be merged to `main`.
