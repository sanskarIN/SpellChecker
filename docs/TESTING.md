# Testing Guide

This page describes the current SpellChecker test strategy, quality gates, and regression expectations. Historical release-validation records are indexed in [Release history](RELEASE_HISTORY.md).

For complete build/package validation and target artifact checks, see [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Required repository gate

After dependency resolution:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

CI also runs deterministic benchmark command smoke. Cross-platform CI repeats the quality gate and then builds release-mode Android, iOS (without codesigning), Linux, macOS, Web, and Windows targets. The Android packaging job additionally runs the Android repository-support contract, verifies the production-manifest privacy boundary, and builds both APK and Android App Bundle outputs. The iOS and macOS jobs run the Apple repository-support contract, lint Apple metadata, inspect compiled bundle identity/version data, and require an embedded privacy manifest before packaging. The tagged/manual release workflow mirrors those six target builds with longer-lived artifacts.

Do not treat focused tests as a substitute for the complete suite before merge.

## Apply formatting locally

```bash
dart format lib test tool
```

Formatting is part of CI. Documentation-only changes can still touch Dart regression tests, so run the canonical formatter whenever `test/`, `lib/`, or `tool/` changes. Android runner-contract changes should also keep `android/test/` canonically formatted; the Android packaging jobs enforce that focused formatting boundary before running the Android support test.

## Test layers

SpellChecker uses several complementary regression layers.

### Pure/core unit tests

Cover deterministic reusable behavior such as:

- unrestricted Damerau-Levenshtein distance;
- spelling engine acceptance/suggestions;
- suggestion ranking;
- text correction/casing;
- text statistics;
- personal-dictionary codec;
- Portable-settings codec;
- language-pack tokenization/normalization;
- writing rules/analyzer/correction/query/presets/diagnostics.

### Persistence tests

Use mocked `shared_preferences` behavior to cover:

- selected language;
- suggestion count normalization;
- legacy/default-language personal-word migration;
- per-language vocabulary isolation;
- writing-rule unset/non-empty/empty states;
- reset/clear semantics;
- persistence failure handling;
- settings import rollback/transaction behavior.

### Widget tests

Cover the bundled user workflow:

- startup/preference restoration;
- editor/result states;
- spelling navigation/correction;
- personal dictionary management;
- language switching;
- Writing insights controls;
- filtering/presets/search;
- safe individual/batch fixes and undo;
- bounded/limited-result messages;
- keyboard shortcuts;
- semantics/accessibility state;
- storage warnings;
- About/version behavior.

### Unicode regression tests

Cover:

- non-BMP scalars;
- decomposed Latin combining-mark sequences;
- apostrophe/hyphen normalization;
- UTF-16 source ownership;
- Unicode-scalar edit-distance/suggestion-length behavior;
- Unicode-safe correction capitalization;
- quoted sentence boundaries/statistics.

### Stress tests

Structural delimiter rules use iterative behavior and should retain large-nesting/malformed-input stress coverage so parser-like recursion/stack failures are not introduced.

### Benchmark-tool tests

Cover benchmark option parsing, deterministic scenario generation/identity, result/report validation, reporter formats, runner behavior, and command smoke.

### Repository metadata/documentation tests

Repository tests protect non-code project contracts such as Buy Me a Coffee surfaces and the complete documentation hub/current capability references.

`test/documentation_repository_test.dart` protects documentation and repository metadata by checking:

- the documentation hub covers every evergreen topic;
- repository-relative Markdown links resolve;
- tracked Markdown files outside the GitHub-template exception have at least one H1, balanced fenced code blocks, and no unresolved merge-conflict markers;
- package/About/changelog/current-release version references remain synchronized;
- current language documentation names every `SpellLanguageRegistry` built-in;
- current writing documentation names every `WritingRuleRegistry.builtIns` rule;
- committed runner anchors remain present;
- the marked tracked-file inventory in `docs/EXECUTABLE_BUILDS.md` matches `git ls-files` exactly.

The tracked-file inventory check is intentionally repository-wide: files can affect release readiness even when they are not compiled into the runtime artifact. A newly added, deleted, renamed, or stale tracked path therefore fails the test until executable-build documentation is updated.

### Android repository-support contract

`android/test/android_repository_support_test.dart` protects Android-specific repository invariants that should not be left to documentation review alone. It checks:

- the stable Android namespace/application ID;
- Flutter-managed compile, target, and minimum SDK values;
- Java/Kotlin JVM compatibility;
- production-signing configuration plus safe secret exclusions;
- production manifest offline/privacy settings;
- predictive-back integration;
- debug/profile development Internet permission separation;
- APK and AAB CI/release packaging coverage;
- the Flutter-stable AGP/Kotlin compatibility path.

Both the normal cross-platform Android packaging job and tagged/manual Android release job run this contract before creating artifacts.

### Apple repository-support contract

`test/apple_repository_support_test.dart` protects Apple-specific repository and release invariants that must stay true across Flutter/Xcode upgrades. It checks:

- the stable `in.sanskar.spellchecker` iOS identity;
- the iOS 15 deployment baseline and iPhone/iPad target family;
- Flutter-managed Apple build name/build number placeholders;
- explicit iOS App Transport Security denial of arbitrary loads, web-content exceptions, and local-network exceptions;
- the stable macOS product/bundle identity;
- macOS App Sandbox release entitlement presence;
- absence of macOS release network client/server and JIT entitlements;
- the `shared_preferences_foundation` dependency contract that supplies the Apple preferences implementation/privacy manifest;
- Apple CI/release build, compiled-bundle identity, and embedded privacy-manifest checks.

The iOS and macOS jobs then validate the compiled artifacts, not only the repository text. They require the expected bundle ID, non-empty version metadata, and at least one embedded `PrivacyInfo.xcprivacy` before the `.app` is packaged.

## Useful focused commands

Core spelling/correction:

```bash
flutter test test/edit_distance_test.dart
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
```

Language/codec/persistence:

```bash
flutter test test/language_pack_test.dart
flutter test test/language_dictionary_codec_test.dart
flutter test test/language_preferences_test.dart
flutter test test/dictionary_preferences_test.dart
```

Writing analysis/correction:

```bash
flutter test test/writing_rules_test.dart
flutter test test/writing_correction_test.dart
flutter test test/writing_preferences_test.dart
flutter test test/writing_review_query_test.dart
flutter test test/writing_review_preset_test.dart
flutter test test/writing_analysis_diagnostics_test.dart
```

Application workflows:

```bash
flutter test test/widget_test.dart
flutter test test/language_widget_test.dart
flutter test test/writing_widget_test.dart
flutter test test/bounded_analysis_widget_test.dart
```

Repository/documentation metadata:

```bash
flutter test test/bmc_repository_metadata_test.dart
flutter test test/documentation_repository_test.dart
```

Android repository support:

```bash
dart format --output=none --set-exit-if-changed android/test
flutter test android/test/android_repository_support_test.dart --reporter expanded
```

Apple repository support:

```bash
flutter test test/apple_repository_support_test.dart --reporter expanded
```

On macOS, native metadata can also be linted directly:

```bash
plutil -lint ios/Runner/Info.plist
plutil -lint macos/Runner/Info.plist macos/Runner/Release.entitlements macos/Runner/DebugProfile.entitlements
```

The documentation command performs the focused documentation/metadata audit described above. The Android commands validate and format-check the runner-specific support contract without requiring a production signing key. The Apple contract is host-independent at source-test time; the macOS GitHub-hosted build jobs additionally inspect the real compiled `.app` bundles.

Some focused filenames are added as features evolve. Use the `test/` directory and full suite as the final source of truth for shared application behavior, plus the Android and Apple support contracts for platform runner/release invariants.

## Spelling-engine test requirements

When changing `SpellCheckerEngine`, test both `check()` and/or `analyze()` semantics relevant to the change.

### Acceptance

Test:

- base dictionary words;
- personal words;
- ignored words;
- recognized suffix/stem behavior;
- language variants;
- normalization edge cases.

### Suggestions

Test:

- deterministic ordering;
- scalar edit distance;
- suggestion target/candidate length;
- custom frequency data;
- personal dictionary candidates;
- custom ranker ties plus lexical fallback;
- suffix reattachment;
- non-positive suggestion limits.

### Bounded spelling

For `maxIssues` changes, prove:

- invalid non-positive limits fail;
- fewer issues than limit -> complete;
- exactly at limit with no overflow -> complete;
- at least one additional unknown -> truncated;
- captured list never exceeds the limit;
- overflow proof does not generate an unnecessary suggestion set;
- scan metadata remains consistent.

## UTF-16 source ownership

Source ranges must be tested against the exact analyzed string:

```dart
expect(text.substring(issue.start, issue.end), issue.originalText);
```

For spelling issues:

```dart
expect(text.substring(issue.start, issue.end), issue.word);
```

Do not calculate expected offsets by counting user-perceived characters when the input contains non-BMP scalars. Dart source/editing positions are UTF-16 code-unit offsets.

## Unicode scalar tests

When logic deliberately operates on Unicode scalars, test at least one non-BMP value so an accidental `value[0]`/single-code-unit implementation cannot pass unnoticed.

Examples of scalar-sensitive areas:

- edit distance;
- suggestion target/candidate length;
- first-character rank penalty;
- correction casing;
- sentence capitalization.

When combining marks are relevant, include decomposed input such as a Latin base letter plus combining accent and verify normalization/source ownership separately.

## Text statistics tests

Cover:

- empty/whitespace text;
- words with Unicode letters/combining marks/apostrophes/hyphens;
- punctuation-terminated sentences;
- closing quote/bracket after terminal punctuation;
- trailing unfinished sentence after completed boundaries;
- character count as Dart UTF-16 string length.

## Correction safety tests

### Spelling

Test:

- current range applies;
- stale range refuses;
- invalid/empty suggestion refuses;
- replace-all only affects represented matching issue ranges;
- end-to-start range safety;
- casing per occurrence;
- non-BMP first-scalar casing behavior;
- resulting caret remains valid.

### Writing

Test:

- automatic current issue applies;
- advisory issue skips;
- stale issue skips;
- invalid range skips;
- multiple safe non-overlapping fixes apply;
- deterministic overlap winner;
- later overlap increments `skippedCount`;
- accepted mutations apply from end to start;
- caret adjustment remains valid;
- all-unsafe input returns unchanged text.

## Writing-rule test checklist

Every built-in rule change should review:

- stable ID;
- display metadata;
- category;
- severity;
- full language ID/language-code eligibility;
- positive examples;
- near-miss/non-match examples;
- exact source range and `originalText`;
- replacement or deliberate advisory null;
- interaction with every automatic built-in rule;
- Unicode behavior;
- bounded analyzer totals;
- filters/query/preset behavior where searchable metadata changes;
- per-language preference/default compatibility;
- Portable-settings compatibility;
- diagnostic-summary counts;
- widget workflow/undo;
- stress behavior for structural rules.

## Writing analyzer tests

`WritingAnalyzer` tests should prove:

- duplicate configured rule IDs are rejected;
- unsupported/disabled rules do not run/count;
- unbounded result ordering is deterministic;
- bounded collector retains the globally earliest prefix, not simply first yielded values;
- exact totals include uncaptured findings;
- exact per-rule totals sum to the exact overall total;
- captured issues belong to analyzed rules/result language;
- direct compatibility-style construction can omit exact diagnostics;
- malformed exact-total combinations are rejected.

## Review query/preset tests

Cover:

- search normalization;
- matches across rule metadata and finding metadata;
- category filtering;
- missing rule metadata when a category filter is active;
- automatic-fix filtering;
- rule switches remaining visible under fix-only review;
- stable preset IDs/values;
- `byId` fallback;
- search layered over presets.

## Widget-test synchronization

Avoid using `pumpAndSettle()` when a test deliberately leaves a Future unresolved; that can wait forever for a state that is intentionally pending.

Use explicit `pump()`/controlled completion for loading-state tests. Use `pumpAndSettle()` only when the workflow is expected to reach a settled frame state.

When testing lazy dialog/list content, scroll/ensure visibility rather than assuming every off-screen child is mounted.

## Preference failure tests

When simulating persistence failures, verify both sides of the contract:

1. application state/message does not falsely claim the value was durably saved;
2. session behavior is either rolled back or explicitly documented as session-only.

For writing-rule save failure, current in-memory switch choices can remain active while durability is reported unavailable. For personal-word save failure, the editor restores the previous in-memory personal dictionary.

## Transfer-format tests

### Personal dictionary

Test:

- version-2 language-aware round trip;
- sorted/deduplicated normalized words;
- legacy V1 support;
- array/plain-list compatibility;
- unsupported version;
- missing/unsupported version-2 language;
- invalid word entries;
- decomposed Unicode normalization;
- UI wrong-language import refusal/merge behavior.

### Portable settings

Test:

- deterministic round trip;
- selected language;
- 1–10 suggestion bounds;
- multiple explicit language overrides;
- explicit empty override preservation;
- missing override means defaults;
- invalid format/version/language/value shapes;
- duplicate/invalid rule IDs;
- import persistence transaction/rollback;
- personal vocabulary remains untouched.

## Accessibility/keyboard tests

When changing keyboard/focus/semantics behavior, cover:

- Ctrl/Meta+Enter spelling check;
- Ctrl/Meta+Shift+Enter Writing insights;
- F7/Shift+F7 issue navigation;
- Ctrl/Meta+F writing search focus;
- Escape clearing active transient query before closing;
- live count/result semantics;
- focus/visibility of actionable controls;
- keyboard and visible pointer/touch alternatives.

See [Accessibility](ACCESSIBILITY.md) and [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

## Benchmark smoke

CI's deterministic smoke form is equivalent to:

```bash
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

The purpose is to prove the benchmark command, options, deterministic scenario, analysis result validation, and reporter pipeline work. It is not a universal performance threshold.

See [Performance](PERFORMANCE.md).

## CI

`.github/workflows/ci.yml` is the primary source-quality workflow. On pushes and pull requests to `main`, it validates:

1. checkout/tool setup;
2. Flutter/Dart version visibility;
3. `flutter pub get`;
4. canonical format check across `lib test tool`;
5. `flutter analyze`;
6. complete Flutter test suite, including repository documentation/metadata validation;
7. benchmark CLI smoke.

`.github/workflows/v3-docs-sync.yml` is the focused documentation/metadata workflow. For relevant documentation, registry, version, and workflow paths it installs dependencies, verifies formatting of `test/documentation_repository_test.dart`, and runs that audit directly.

`.github/workflows/cross-platform.yml` repeats the complete source quality gate and then builds/uploads short-retention validation artifacts for Android APK + Android App Bundle, iOS no-codesign app, Linux bundle, macOS app, Web bundle, and Windows bundle on appropriate GitHub-hosted operating systems. The Android job additionally format-checks and runs `android/test/android_repository_support_test.dart` and verifies the production manifest before packaging. The iOS/macOS jobs lint native metadata, run `test/apple_repository_support_test.dart`, verify the compiled `CFBundleIdentifier` and version fields, and require an embedded `PrivacyInfo.xcprivacy` before packaging.

## Release validation

`.github/workflows/release.yml` runs on `v*` tags or manual dispatch. It repeats formatting, analysis, the complete Flutter test suite, and benchmark smoke before building six target release outputs:

- Android release APK and Android App Bundle;
- iOS release app without codesigning;
- Linux release bundle;
- macOS release app;
- Web release bundle;
- Windows release bundle.

The Android release job also runs the focused support contract and production-manifest policy checks before building. The Apple release jobs mirror the normal CI contract: plist/entitlement linting, focused Apple repository-support tests, compiled bundle identity/version checks, and embedded privacy-manifest validation are required before iOS/macOS artifacts are archived. Artifacts are retained by the workflow for validation/distribution staging. Production signing/notarization credentials and external store/publication steps remain outside this repository workflow. See [Platform support](PLATFORM_SUPPORT.md), [Executable builds and packaging](EXECUTABLE_BUILDS.md), and [Releasing](RELEASING.md).

## Before opening a PR

Run the complete gate. Also review:

- public API compatibility;
- persistence/format compatibility;
- UTF-16 source ownership;
- Unicode scalar/decomposed coverage;
- bounded-result semantics;
- privacy/security changes;
- current documentation updates;
- executable-build tracked-file inventory updated for every tracked path addition/deletion/rename;
- platform/build claims consistent with committed runners and actual CI/release jobs;
- Android runner changes pass the Android support contract and keep APK/AAB claims synchronized;
- Apple runner/release changes pass the Apple support contract and preserve artifact-level bundle/privacy validation;
- historical release docs left historically accurate.

## Related documentation

- [Development](DEVELOPMENT.md)
- [Architecture](ARCHITECTURE.md)
- [API](API.md)
- [Writing rules](WRITING_RULES.md)
- [Performance](PERFORMANCE.md)
- [Executable builds and packaging](EXECUTABLE_BUILDS.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Releasing](RELEASING.md)
- [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md)
