# V2.12 Final Validation

Release candidate: `2.12.0+17` / About `2.12.0`.

This file records the final acceptance boundary for V2.12 after implementation, release synchronization, and canonical formatting. It is intentionally documentation-only so this owner-authored commit can trigger the permanent pull-request CI gate after the self-removing formatter has deleted itself.

## Already established before the final CI head

- The production `MissingPunctuationSpaceRule` exists in `lib/writing/rules/missing_punctuation_space_rule.dart`.
- The rule is publicly exported and registered as the seventh built-in writing rule.
- Dedicated baseline, decomposed-Unicode, non-BMP-offset, batch-composition, widget, persistence, registry, and benchmark regressions are tracked.
- Package identity is `2.12.0+17` and the About dialog identity is `2.12.0`.
- `CHANGELOG.md`, `README.md`, `what_changed.md`, roadmap, writing/API/testing/performance/user/privacy/security/support/contributor/release documentation, PR-template guidance, and web metadata are synchronized with V2.12.
- Guarded release synchronization completed and removed its script, workflow, and temporary diagnostic file.
- The V2.12 final formatter completed successfully on the synchronized tree and removed its workflow. No Dart file is changed by this validation-record commit.

## Permanent CI acceptance gate

The exact PR head must pass the repository's permanent `.github/workflows/ci.yml` checks:

```text
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
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

A failure at any stage is a release blocker and must be repaired in a dedicated commit before merge.

## Final release gate after permanent CI

After permanent CI is green, the candidate must also pass a release-mode web build and repository-hygiene assertions covering:

- package/About version identity;
- seven stable built-in writing-rule IDs including `missing-punctuation-space`;
- public export of `MissingPunctuationSpaceRule`;
- presence of the V2.12 focused regression suites;
- `what_changed.md` V2.12 engineering ledger entry;
- valid web manifest JSON;
- unchanged direct runtime dependency boundary (`flutter` and `shared_preferences`);
- no tracked `v212` formatter, synchronizer, diagnostic, or release-gate helper artifact in the permanent candidate tree.

Only the exact validated permanent candidate may be merged to `main`. The merge must preserve the granular implementation history rather than squash it.
