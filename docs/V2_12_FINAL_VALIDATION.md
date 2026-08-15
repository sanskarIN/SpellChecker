# V2.12 Final Validation

Release candidate: `2.12.0+17` / About `2.12.0`.

This file records the completed acceptance evidence for V2.12 after implementation, release synchronization, canonical formatting, full CI, release-mode web validation, merge, and post-merge main-branch validation.

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

## Pull-request CI evidence

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

After release-gate evidence was recorded, final pull-request CI run `31868255146` also passed formatting, analysis, the complete test suite, and benchmark smoke on final PR head `e74713c23ce010658e0e67e5d2c5593d3b794dd4`.

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

## Merge evidence

PR #75, **V2.12 missing punctuation spacing and Unicode boundaries**, was merged with the normal GitHub merge method on August 15, 2026.

- final PR head: `e74713c23ce010658e0e67e5d2c5593d3b794dd4`;
- merge commit on `main`: `eecf286c3722ac681e2117f38163326100a0564f`;
- branch commits preserved: 70;
- permanent files changed by the PR: 36;
- merge strategy: merge commit, not squash;
- `what_changed.md`: included in the merged permanent diff;
- disposable V2.12 workflow/tool/root diagnostic files: none in the permanent diff.

## Post-merge main validation

GitHub Actions main-branch CI run `31868368430` validated merge commit `eecf286c3722ac681e2117f38163326100a0564f` successfully on August 15, 2026.

Results on the actual merged `main` tree:

- dependency resolution: passed;
- canonical formatting: passed;
- static analysis: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

This confirms the merge itself did not change or invalidate the green pull-request candidate.

## Publishing boundary

At the time V2.12 was merged, the repository had no existing Git tags and no GitHub Releases. V2.12 therefore does not introduce a new tagging/release-publication convention as an incidental side effect of this implementation. The package/About release identity and release workflow remain ready for a future explicit publishing decision.

## Completed acceptance state

V2.12 is complete when this documentation-only post-merge evidence update is merged after receiving its own green pull-request CI. That update changes no Dart source, runtime dependency, application behavior, release identity, test logic, or build input beyond this Markdown record.
