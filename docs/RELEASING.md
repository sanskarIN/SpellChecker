# Releasing

This document describes the SpellChecker release procedure.

## Preconditions

Before releasing:

- `main` contains the intended code.
- CI is passing on the exact release commit.
- `pubspec.yaml` contains the intended `MAJOR.MINOR.PATCH+BUILD` version.
- `CHANGELOG.md` contains a dated release entry.
- README/current-release text matches behavior.
- API/architecture/user/development/testing/accessibility/troubleshooting docs are current.
- Privacy/security/support/contributor documentation matches persisted/runtime data behavior.
- Persistent key/format changes have migration and regression tests.
- Keyboard, correction safety, batch grouping, and undo behavior are documented/tested.
- One-time development/reconciliation workflows/scripts are absent from the release tree.

Do not tag a branch with failing, unverified, or approval-blocked validation unless an equivalent exact-tree release gate has executed every required check and that evidence is recorded.

## Versioning

Flutter version format:

```text
MAJOR.MINOR.PATCH+BUILD
```

Current V2.11 release candidate:

```text
2.11.0+16
```

Increase the semantic version for user-visible releases and build number for packaging iterations as appropriate.

# Persistent-data compatibility

V2.3 persists:

- Selected language ID.
- Personal dictionary words per language.
- Suggestion-count preference.
- Enabled writing-rule IDs per language.

Current key families include:

```text
spellchecker.personal_words.v2.<language-id>
spellchecker.language_id.v1
spellchecker.suggestion_limit.v1
spellchecker.writing_rule_ids.v1.<language-id>
```

The legacy V1 personal-word key remains a migration/compatibility source for the default US namespace.

Before changing persisted semantics:

1. Define old-value compatibility.
2. Decide whether migration is required.
3. Add old-to-new tests.
4. Preserve explicit empty-vs-unset semantics where relevant.
5. Update API/privacy/security/changelog docs.
6. Never silently reinterpret an existing key/transfer version.

## Writing-rule preference compatibility

V2.1 distinguishes:

```text
missing key       -> use current registry defaults
stored non-empty  -> explicit enabled IDs
stored empty list -> explicit disable-all
```

A future release must not collapse explicit empty into missing/unset.

Rule IDs are persistent identifiers. Renaming/removing them requires compatibility review; unknown old IDs should remain safely ignorable.

# Personal dictionary transfer compatibility

Current application exports use language-aware version 2:

```json
{
  "version": 2,
  "language": "en-US",
  "words": ["example"]
}
```

Legacy version-1 objects/JSON arrays/plain word lists remain supported where documented.

Do not silently import a version-2 document into a mismatched language.

# Non-persistent sensitive state

Do not accidentally persist during release work:

- Editor documents.
- Spelling issue lists.
- Writing findings/messages/source excerpts.
- Active issue index.
- Ignored words.
- Suggestion cache.
- Correction undo snapshots.
- Batch correction plans.

Correction snapshots can contain complete editor text and must remain memory-only unless a separately reviewed product/privacy change explicitly redesigns this boundary.

# Local release verification

From a clean checkout of the exact intended release commit:

```bash
flutter clean
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
dart run tool/benchmark_large_document.dart --repeats=4 --warmup=0 --iterations=1 --spelling-limit=2 --writing-limit=5 --suggestions=0 --language=en-US --json
flutter build web --release
```

Verify printed Flutter/Dart versions satisfy `pubspec.yaml`.

# V2.2 review-management smoke additions

1. Open Writing insights and verify rule categories/visible counts.
2. Search `clarity` and confirm repeated-word review remains while Mechanics rules are hidden.
3. Clear filters and confirm the complete enabled-rule review returns.
4. Select Mechanics only on synthetic text containing Mechanics and Clarity findings.
5. Use **Apply visible safe fixes** and verify only visible automatic fixes are applied.
6. Undo once and verify the exact pre-batch document returns.
7. Disable a rule so a language-specific override exists.
8. Use **Reset rules to defaults**.
9. Verify the rule preference key is removed/unset rather than stored as a concrete list.
10. Reopen Writing insights and verify current registry defaults are active.
11. Verify review search/chips/automatic-only state do not persist after closing/reopening the dialog.
12. Exercise a reset storage-failure test/path and verify session defaults remain active while durability failure is reported.

# V2.1 smoke test

Use synthetic text/vocabulary only.

## Startup/persistence

1. Launch with no saved settings.
2. Verify default language is English (US).
3. Open Writing insights and confirm default enabled rules.
4. Disable one rule, close the dialog, reopen it, and confirm it remains disabled.
5. Restart/reload and confirm the rule choice restores.
6. Switch to English (UK) and confirm its rule choices are independent.
7. Disable every UK writing rule, restart/reload, and confirm explicit disable-all restores rather than defaults.
8. Switch back to US and confirm the US rule set returns.
9. Save synthetic personal vocabulary in each language and confirm isolation/restoration.
10. Change suggestion count and confirm restoration.

## Spelling regression

11. Check a known synthetic misspelling with the button.
12. Check with `Ctrl/Command+Enter`.
13. Verify inline highlighting and Results agree.
14. Verify F7 / Shift+F7 wrap navigation.
15. Replace one spelling issue and test Undo.
16. Replace all checked repeated spelling occurrences and test one-step Undo.
17. Modify text after checking and verify stale correction is refused/refreshed.

## Writing insights regression

18. Open Writing insights from the app-bar control.
19. Open it with `Ctrl/Command+Shift+Enter`.
20. Verify all supported built-in rules are listed.
21. Use synthetic text containing each built-in finding pattern.
22. Apply one safe fix and undo it.
23. Change text after analysis and verify stale individual fix is refused.

## V2.1 batch writing fix

24. Use text such as `hello  world world!!`.
25. Open Writing insights and verify **Apply all safe fixes (N)**.
26. Apply the batch.
27. Verify deterministic safe fixes are reflected in one final text.
28. Verify applied/skipped feedback is understandable.
29. Use **Undo correction** once and verify the exact pre-batch document returns.
30. Exercise a synthetic overlap case through unit tests; manual UI overlap depends on available built-in ranges.

## Language/transfer regression

31. Verify `color`/`colour` variant behavior under US/UK.
32. Verify Unicode tokens such as `café` remain whole tokens.
33. Export personal vocabulary and inspect `version: 2` plus language ID.
34. Attempt a tagged cross-language import and confirm it is blocked.
35. Verify legacy V1 personal-word migration into US remains intact on a migration fixture/test profile.

## Accessibility/layout

36. Verify keyboard-only spelling and Writing insights workflows.
37. Verify rule switches, individual fix, batch fix, and Undo are keyboard reachable.
38. Verify light/dark themes.
39. Verify increased text scale.
40. Verify narrow/800×600 layout does not overflow and scrollable actions remain reachable.
41. Verify important state is understandable without color alone.

# Automated release checks

Normal CI now requires all of these checks to pass:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

The tagged release workflow runs those same quality checks and additionally builds the release web application:

```bash
flutter build web --release
```

For a feature branch that uses an exact-tree integration/reconciliation gate, record the final validated commit SHA and confirm all temporary gate/helper files were deleted before the commit was pushed.

# Tagging

From verified `main`:

```bash
git checkout main
git pull --ff-only
git tag -a v2.10.0 -m "SpellChecker v2.10.0"
git push origin v2.10.0
```

Pushing a `v*` tag triggers the repository release workflow. Do not tag an unmerged feature/reconciliation branch.

# Verify tagged workflow

The tagged workflow must finish successfully before presenting its artifact as verified.

If it fails:

1. Do not silently move/overwrite the published tag.
2. Diagnose the failure.
3. Fix on `main` with regression tests.
4. Increment/publish a new version/tag if the failed tag was already shared externally.

# GitHub Release

After the tagged workflow passes:

1. Create a GitHub Release for that tag.
2. Use the matching changelog section as the release-note foundation.
3. Highlight V2.10 deterministic synthetic large-document benchmarking, retained V2.9 privacy-safe diagnostic summaries, V2.8 exact-count diagnostics, and V2.7 bounded-review safety, while noting compatibility with earlier writing-rule, Portable settings, ranking, and correction-safety foundations.
4. Mention persistent-data/privacy behavior.
5. Attach approved artifacts where appropriate.
6. Verify links/version text.
7. Verify the release points to the same commit that passed release validation.

# Rollback and hotfixes

Do not silently move a published tag.

For a defect:

1. Fix on `main`.
2. Add a regression test.
3. Update changelog.
4. Increment patch/build version.
5. Publish a new tag.

For writing batch defects test:

- Stale range behavior.
- Advisory skipping.
- Overlap resolution.
- End-to-start mutation.
- Applied/skipped counts.
- One-step undo grouping.

For preference defects test:

- Unset/default state.
- Explicit empty state.
- Language isolation.
- Existing stored IDs.
- Storage failure behavior.

For personal-vocabulary defects test migration/import compatibility before release.

# Dependency review

Before a release changing dependencies:

- Document the purpose.
- Review runtime network/storage/analytics permissions/behavior.
- Run a clean dependency resolution.
- Confirm CI resolves the same constraints.
- Update development/privacy/security docs.

V2.10 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.

# Signing and stores

Never commit:

- Signing certificates.
- Store tokens.
- API credentials.
- Service-account keys.
- Release secrets.

Use secure facilities of the release/build platform.

## V2.3 release checks

For a V2.3-compatible release, verify the package/About version pair, stable review-preset IDs, `spellchecker-settings` format/version compatibility, unset-versus-empty rule override semantics, deterministic settings encoding, privacy exclusions, rollback tests, focused V2.3 suites, complete regression suite, and `flutter build web --release`. Confirm the intended release tree contains no one-time `tools/v23_*` helper or `.github/workflows/v23-*` recovery/integration workflow before tagging.

## V2.5 bounded-analysis release checks

Before tagging V2.5-compatible code, verify:

1. `SpellCheckerEngine.check()` still matches unbounded `analyze()` results.
2. Exact-cap inputs without later unknowns remain complete.
3. Overflow inputs prove truncation without suggestion generation for the overflow issue.
4. The editor displays `200+` only for proven truncation.
5. The limited-results notice is visible and exposed to semantics.
6. Replace all is absent for limited results and still present for complete repeated-issue results.
7. `docs/PERFORMANCE.md` matches the implementation.
8. No new runtime dependency/persistence/network behavior was introduced unintentionally.
9. Formatting, analyzer, focused V2.5 tests, complete tests, and `flutter build web --release` pass on the exact release tree.

## V2.6 release checks

Verify package/About versions `2.6.0+11` / `2.6.0`, both stable new rule IDs, six built-in registry/default IDs, punctuation/trailing exact-range behavior, repeated-space non-overlap ownership, explicit rule-preference compatibility, focused V2.6 tests, complete writing tests, complete regression suite, and `flutter build web --release`.

Smoke-test synthetic input containing interior repeated spaces, spaces before punctuation, LF/CRLF trailing whitespace, document-end whitespace, and repeated punctuation. Confirm **Apply all safe fixes** yields the expected complete text and one **Undo correction** restores the exact original. Confirm an explicit old saved rule list does not silently gain V2.6 IDs, while **Reset rules to defaults** makes the current six-rule defaults active.

Before tagging, confirm the tracked tree has no `tools/v26_*` helper and no `.github/workflows/v26-*` temporary gate/recovery workflow.

## V2.7 bounded Writing insights release checks

Before tagging V2.7:

1. Verify `WritingAnalyzer.analyze()` remains unbounded when `maxIssues` is omitted.
2. Verify zero/negative `maxIssues` values are rejected.
3. Verify an exact-limit result is complete when no additional finding exists.
4. Verify a true overflow result exposes `isTruncated == true`, `isComplete == false`, and the configured `issueLimit`.
5. Verify bounded results equal the globally sorted prefix of unbounded results even when custom rules yield findings out of order.
6. Verify Writing insights uses a 200-finding limit and only shows limited-state wording after overflow is proven.
7. Verify search/presets/category/fix-only filters operate on captured findings in a limited result.
8. Verify limited batch labels say **captured** and one Undo restores the complete pre-batch editor text.
9. Verify `pubspec.lock` and direct runtime dependencies are unchanged unless a separately reviewed dependency change is intended.
10. Verify `what_changed.md`, README, changelog, roadmap, API/performance/writing/user/accessibility/privacy/security/support docs, and web metadata describe V2.7 consistently.
11. Verify no `tools/v27*` or `.github/workflows/v27-*` helper/gate artifact is present in the release tree.
12. Run formatting, analyzer, the complete test suite, and `flutter build web --release` on the exact intended release SHA.

Tag the verified release only from the exact merged `main` commit:

```bash
git tag -a v2.7.0 <verified-main-sha> -m "SpellChecker 2.7.0"
git push origin v2.7.0
```

## V2.8 exact writing-diagnostics release checks

Before tagging V2.8:

1. Verify package/About versions are `2.8.0+13` / `2.8.0`.
2. Verify analyzer-produced results expose exact `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`.
3. Verify direct V2.7-style `WritingAnalysisResult` construction can still omit exact diagnostics.
4. Verify an unbounded analyzer result reports exact totals equal to its retained result count.
5. Verify an exact-at-limit bounded result remains complete with zero uncaptured findings.
6. Verify a true overflow result reports an exact total greater than `capturedIssueCount`, a positive exact uncaptured count, and the correct global retained prefix.
7. Verify exact per-rule totals sum to the exact overall total and disabled/unsupported rules do not contribute.
8. Verify Writing insights displays exact first-N-of-total wording and the exact number of findings not retained.
9. Verify the `writing-findings-total-badge` renders the intended captured/total value when limited.
10. Verify enabled rule metadata shows exact `Total findings: N` values and the dialog remains lazy/scrollable without inaccessible controls.
11. Verify limited search/presets/categories/fix-only review and individual/batch fixes remain captured-only.
12. Verify singular/plural uncaptured-finding wording and filtered-empty limited-result wording.
13. Verify one Undo still restores a complete pre-batch document and stale-range/overlap safety remains unchanged.
14. Verify `pubspec.lock` and direct runtime dependencies are unchanged from V2.7 unless an independently reviewed dependency change exists.
15. Verify `.github/FUNDING.yml`, README, `SUPPORT.md`, and `CONTRIBUTING.md` contain `https://buymeacoffee.com/sanskarIN` and that no application runtime code contacts that service.
16. Verify `CHANGELOG.md`, `docs/ROADMAP.md`, API/architecture/performance/writing/development/testing/user/accessibility/troubleshooting/language/privacy/security/support/contribution/releasing docs, README/web metadata, and `what_changed.md` describe V2.8 consistently.
17. Verify no `tools/v28*`, `.github/workflows/v28-*`, or other disposable V2.8 helper/final-gate file is present in the release tree.
18. Run `flutter pub get`, format verification, analyzer, focused V2.8 diagnostics/limited-dialog tests, the complete regression suite, and `flutter build web --release` on the exact intended release SHA.
19. Record the exact final release-gate run and permanent-CI run in the V2.8 PR and engineering ledger without changing the validated SHA.
20. Merge only that exact green feature SHA, then compare the merged `main` tree with the validated feature tree and require zero file differences.

Tag only the verified merged `main` commit:

```bash
git tag -a v2.8.0 <verified-main-sha> -m "SpellChecker 2.8.0"
git push origin v2.8.0
```

## V2.10 deterministic benchmark release checks

Before tagging V2.10, verify package/About versions `2.10.0+15` / `2.10.0`; deterministic scenario generation and option validation; immutable/stable benchmark result aggregation; US/UK runner coverage; human/JSON report exclusion of corpus text; formatter coverage for `tool/`; the threshold-free benchmark smoke command in both CI and release workflows; unchanged runtime dependencies/persistence formats; complete regression tests; and `flutter build web --release`.

Run the documented benchmark command on synthetic data only and record the exact command plus Flutter/Dart versions when publishing comparative timing evidence. Do not fail a release merely because machine-dependent elapsed values differ from another machine. Confirm no temporary V2.10 synchronization/validation workflow remains in the release tree before tagging.

## V2.11 release-specific checks

Before tagging `v2.11.0`, additionally verify:

- `pubspec.yaml` reports `2.11.0+16` and About reports `2.11.0`.
- Ctrl/Command+F focuses Writing insights review search while focus is inside the dialog.
- First Escape clears active transient review filters and keeps the dialog open; a subsequent Escape closes when the query is empty.
- Rule/finding live semantics remain reachable in the real lazy list, including exact limited-result wording.
- Non-positive `WritingInsightsDialog.maxIssues` is rejected in release-mode runtime code.
- Benchmark samples contain exact per-rule totals for every analyzed rule, including explicit zero entries.
- The permanent workflow directory contains only intended reusable workflows; all `v211-*` development helpers are removed.

The normal release gate remains dependency resolution + lockfile cleanliness + formatting + analyze + full tests + synthetic benchmark smoke + release web build.

