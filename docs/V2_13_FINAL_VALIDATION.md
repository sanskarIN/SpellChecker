# V2.13 Final Validation

Release candidate: `2.13.0+18` / About `2.13.0`.

This document records the final acceptance boundary and evidence for the SpellChecker V2.13 unmatched-parenthesis release. It is intentionally documentation-only so an owner-authored commit can trigger the permanent pull-request CI gate after all disposable implementation, synchronization, patch, and formatting helpers have removed themselves.

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

## Established functional evidence

Permanent CI run `31869797175` validated the complete functional eight-rule implementation before release metadata synchronization. It passed:

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

The complete Flutter suite initially exposed three lazy-list geometry assumptions after the registry grew from seven to eight rules. Those tests were repaired to scroll by build state/visibility instead of fixed historical pixel geometry. The subsequent functional CI run above passed in full.

## Release synchronization and formatting evidence

The guarded release-documentation synchronization completed successfully in workflow run `31870124244`. It committed the permanent release surfaces individually—including the complete V2.13 `what_changed.md` engineering ledger—and removed both its script and workflow from the permanent branch.

The final package-aware formatter completed successfully in workflow run `31870150516`. It resolved dependencies before formatting, applied any real Dart 3.13 formatter output, immediately reran the formatter, verified the tracked Dart tree remained clean, and removed its own workflow before pushing the helper-free branch head.

## Permanent PR CI acceptance gate

The exact documentation-only head containing this file must pass the permanent `.github/workflows/ci.yml` workflow:

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

A failure in formatting, static analysis, tests, or benchmark smoke remains a release blocker.

## Independent release-mode gate

After permanent PR CI is green, an independent one-time release gate must validate the same helper-free candidate plus release-only assertions:

- `flutter build web --release` succeeds;
- package version is exactly `2.13.0+18`;
- About version is exactly `2.13.0`;
- `UnmatchedParenthesisRule` is registered and publicly exported;
- stable rule ID `unmatched-parenthesis` is present;
- built-in/default writing catalogue has eight stable rule IDs;
- focused V2.13 regression files exist;
- `what_changed.md`, `CHANGELOG.md`, README current-release identity, and V2.13 behavior documentation are present;
- `web/manifest.json` parses as valid JSON;
- direct runtime dependencies remain only Flutter and `shared_preferences`;
- release web output files exist;
- no unexpected tracked V2.13 formatter, synchronizer, diagnostic, patch, or release-gate helper remains in the permanent candidate.

The one-time release gate must delete itself after successful validation. Its cleanup commit must then be followed by an owner-authored evidence update and another successful permanent CI run before merge.

## Merge policy

PR #77 must remain mergeable and its permanent diff must remain helper-free. The final merge must use a normal merge commit rather than squash so the deliberately granular implementation, regression, release, documentation, diagnostic, and cleanup history is preserved.

Only the exact green candidate may be merged to `main`. After merge, the resulting `main` commit must receive its own successful permanent CI run before V2.13 is considered complete.
