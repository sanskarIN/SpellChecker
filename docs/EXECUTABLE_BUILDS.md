# Executable Builds and Packaging

This document is the authoritative build-and-packaging guide for turning the SpellChecker repository into runnable release artifacts.

It deliberately distinguishes between:

- the **committed Android, iOS, Linux, macOS, Web, and Windows Flutter runners**;
- the difference between CI-buildable artifacts and production-signed/store-ready distribution artifacts;
- the files that feed compilation;
- the files that validate the build before release;
- the metadata, documentation, CI, and release files that must be reviewed even when they are not compiled into the binary;
- target-specific signing, packaging, and distribution work that must never be confused with the cross-platform CI build contract.

SpellChecker is currently version `3.1.0+23` and requires Dart `>=3.8.0 <4.0.0` through `pubspec.yaml`.

> **Current support boundary:** the V3 cross-platform foundation commits `android/`, `ios/`, `linux/`, `macos/`, `web/`, and `windows/` runners and validates release-mode builds in CI. Production mobile/desktop signing, notarization, store credentials, and channel-specific installers remain external release-engineering concerns and must never be committed as secrets.

## 1. What counts as an executable artifact

Flutter targets do not all produce the same kind of deliverable.

| Target | Typical release deliverable | Current repository status |
| --- | --- | --- |
| Web | Complete `build/web/` directory | **Supported and release-built** |
| Android | `.aab` for Play distribution and/or `.apk` for direct install/testing | Runner committed; CI builds release APK |
| iOS | `.ipa` plus Xcode archive/signing metadata | Runner committed; CI builds release app without codesign |
| Windows | `.exe` plus adjacent DLLs/data, normally distributed as a directory/package | Runner committed; CI builds release bundle |
| macOS | `.app` application bundle, normally signed/notarized for distribution | Runner committed; CI builds release app |
| Linux | Executable plus `lib/` and `data/` bundle contents | Runner committed; CI builds release bundle |

For Windows and Linux especially, do **not** copy only the executable file and discard its neighboring runtime files. Flutter desktop release output is a bundle.

## 2. Build sources of truth

Before producing any artifact, use these repository files as the primary build contract:

- `pubspec.yaml` — package name, version, Dart constraint, Flutter dependency, runtime dependencies, Material asset declaration.
- `pubspec.lock` — resolved dependency graph used for reproducibility.
- `lib/main.dart` — application entry point.
- `lib/app.dart` — root Flutter application.
- `lib/` — all application/library behavior compiled into supported Flutter targets as reachable by the Dart compiler.
- `web/index.html` and `web/manifest.json` — committed web host metadata/bootstrap inputs.
- `analysis_options.yaml` — analyzer/lint configuration.
- `.github/workflows/ci.yml` — canonical source-validation gates.
- `.github/workflows/release.yml` — current release-build automation and artifact contract.

The release workflow installs dependencies, checks formatting, analyzes, runs the complete Flutter test suite, runs the benchmark smoke command, and then builds Android, iOS (without codesign), Linux, macOS, Web, and Windows in release mode on target-appropriate runners.

## 3. Required preflight on every build machine

From the repository root:

```bash
flutter doctor -v
flutter --version
dart --version
flutter pub get
```

Confirm that:

1. the Dart SDK satisfies `>=3.8.0 <4.0.0`;
2. `flutter doctor -v` reports the target toolchain you intend to build;
3. `pubspec.lock` is present and has not been unintentionally regenerated with unrelated dependency changes;
4. the intended source commit is checked out;
5. no signing secret, keystore, private key, provisioning profile, certificate password, API key, or machine-specific secret is committed to Git.

For a reproducible release record, capture:

```bash
git rev-parse HEAD
flutter --version
dart --version
```

## 4. Mandatory quality gates before packaging

Run the same project gates used by CI:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

Run the deterministic benchmark smoke used by CI/release automation:

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

Do not package a release from a source state that fails these gates.

For a clean rebuild when generated output might be stale:

```bash
flutter clean
flutter pub get
```

Then rerun the gates and the target build.

## 5. Cross-platform release build coverage

All six Flutter target runners are committed. Normal builds do not require runner generation.

| Target | Host used by CI | Release-mode command | CI output |
| --- | --- | --- | --- |
| Web | Ubuntu | `flutter build web --release` | complete `build/web` directory |
| Android | Ubuntu | `flutter build apk --release` | release APK validation artifact |
| Linux | Ubuntu | `flutter build linux --release` | complete desktop bundle |
| Windows | Windows | `flutter build windows --release` | complete Release runtime directory |
| macOS | macOS | `flutter build macos --release` | `.app` bundle |
| iOS | macOS | `flutter build ios --release --no-codesign` | no-codesign `.app` validation bundle |

`.github/workflows/cross-platform.yml` runs these builds for normal V3 validation after shared format/analyze/test/benchmark gates succeed. `.github/workflows/release.yml` mirrors the same six-target build coverage for release tags or manual release-candidate dispatch.

Build success proves that the committed source and runner compile together. It does not replace production signing, notarization, store review, or installer/package-channel policy.

### Local target commands

Run only commands supported by the current machine/toolchain:

```bash
flutter build web --release
flutter build apk --release
flutter build linux --release
flutter build macos --release
flutter build windows --release
flutter build ios --release --no-codesign
```

The operating-system restrictions described in the target sections below still apply. In particular, Apple targets require macOS/Xcode and Windows builds require Windows/Visual Studio desktop tooling.

### Web deployment boundary

The complete `build/web/` directory is deployable static output. The release workflow uploads it as an artifact but does not currently deploy a hosted website. Optional Wasm mode (`flutter build web --release --wasm`) is not the official automated build mode and requires separate compatibility review.

### Artifact retention boundary

GitHub Actions artifacts are temporary workflow storage. They are not automatically permanent GitHub Releases, app-store packages, notarized applications, or hosted websites.

## 6. Native runner regeneration and migration policy

The native runner directories now exist and are tracked by `.metadata`. Use `flutter create` for these targets only when intentionally regenerating/migrating runner templates. Generate only targets you are intentionally reviewing. Examples:

```bash
flutter create --platforms=android .
flutter create --platforms=ios .
flutter create --platforms=windows .
flutter create --platforms=macos .
flutter create --platforms=linux .
```

Or generate an explicitly reviewed group in one command, for example:

```bash
flutter create --platforms=windows,macos,linux .
```

After generation:

1. inspect **every generated file** before committing;
2. choose stable package/application identifiers rather than accepting accidental placeholder identity;
3. replace placeholder application names/icons/metadata as appropriate;
4. confirm `shared_preferences` support for the target and test the actual persistence behavior;
5. validate clipboard, keyboard, accessibility, startup preference restoration, and storage error handling;
6. add target build CI;
7. define signing/credential handling without committing secrets;
8. update `docs/PLATFORM_SUPPORT.md`, `docs/RELEASING.md`, `README.md`, privacy/security documentation, and this file;
9. only then describe the target as repository-supported or release-supported.

Regenerating runners locally does **not** by itself authorize template changes. Review the diff, preserve stable package/bundle identity, rerun cross-platform CI, and update platform documentation before merging migration changes.

## 7. Android release artifacts

Android builds require a configured Android Flutter toolchain. Validate it with `flutter doctor -v`.

### App Bundle

For store-oriented release packaging:

```bash
flutter build appbundle --release
```

The standard Flutter output is under:

```text
build/app/outputs/bundle/release/
```

The `.aab` is the normal upload artifact for Google Play-style distribution workflows.

### APK

For an APK release build:

```bash
flutter build apk --release
```

The standard output is under:

```text
build/app/outputs/flutter-apk/
```

### Android release checklist

Before any official Android release:

- set the intended Android application ID;
- configure release signing using external/secret-managed credentials;
- never commit keystore passwords or private signing material;
- verify version/build mapping from `pubspec.yaml`;
- test install/startup, preferences, dictionary transfer, Portable settings, clipboard actions, accessibility, and keyboard behavior where relevant;
- add CI that actually builds the Android release artifact;
- document artifact retention and distribution.

The Android runner is committed and CI builds a release APK. Production store signing and channel-specific distribution remain separate release work.

## 8. iOS release artifacts

An iOS release build requires macOS and Xcode.

After runner generation and Xcode identity/signing configuration:

```bash
flutter build ipa --release
```

Flutter produces an Xcode archive under:

```text
build/ios/archive/
```

and exported IPA output under:

```text
build/ios/ipa/
```

Before an official iOS release:

- set the intended Bundle Identifier and display metadata;
- review Xcode deployment/signing settings;
- manage certificates/provisioning outside the repository;
- validate actual device/simulator behavior where appropriate;
- test preferences, imports/exports, clipboard, accessibility, and startup behavior;
- define CI/CD on a macOS runner;
- document TestFlight/App Store or other approved distribution procedure.

The iOS runner is committed and CI builds it in release mode with `--no-codesign`. Apple signing/provisioning is required for device/store distribution.

## 9. Windows executable bundle

Windows builds must be performed on a Windows development machine/runner with the required Visual Studio C++ desktop tooling configured for Flutter.

Build:

```powershell
flutter build windows --release
```

Flutter produces a release directory containing the application `.exe`, Flutter/runtime DLLs, plugin DLLs as required, and data assets.

**Package the full release directory**, not only the `.exe`.

Before an official Windows release:

- set the intended binary name in the generated Windows runner configuration;
- set product/file metadata and application icon;
- verify any Visual C++ runtime distribution requirement;
- test clean-machine launch, storage, clipboard, keyboard, high-DPI behavior, accessibility, and upgrade behavior;
- choose a distribution format such as a reviewed zip/MSIX/installer process;
- add Windows CI that builds and archives the complete runtime directory;
- define signing policy if code signing is used.

The Windows runner is committed and CI builds the complete release bundle on `windows-latest`.

## 10. macOS application bundle

macOS builds require macOS and Xcode.

Build:

```bash
flutter build macos --release
```

The release result is a macOS `.app` bundle under Flutter's macOS release build output.

Before an official macOS release:

- set the intended bundle identifier and display metadata;
- review app icon and entitlements;
- test local preferences/clipboard/accessibility/keyboard behavior;
- define signing and notarization for distribution outside development use;
- add macOS CI that builds the actual `.app` artifact;
- document packaging and distribution destination.

The macOS runner is committed and CI builds the release `.app`; public distribution still requires the intended signing/notarization policy.

## 11. Linux executable bundle

A Linux desktop build requires the Flutter Linux desktop toolchain. Common development requirements include Clang, CMake, Ninja, pkg-config, GTK development packages, and a supported C++ toolchain.

Build:

```bash
flutter build linux --release
```

Flutter places the release bundle under an architecture-specific path similar to:

```text
build/linux/<architecture>/release/bundle/
```

The bundle contains the application executable plus required `lib/` and `data/` content. **Distribute the complete bundle**, not only the executable.

Before an official Linux release:

- test on the intended Linux distribution/runtime baseline;
- inspect runtime library dependencies;
- define packaging (`tar`, distro package, Snap, or another reviewed method);
- validate preferences, clipboard, keyboard, accessibility, font/rendering, and startup behavior;
- add Linux desktop build CI and archive the complete bundle.

The Linux runner is committed and CI builds the complete release bundle on Ubuntu with the required desktop development packages.

## 12. Build modes

Use Flutter build modes deliberately:

- **debug** — development/debugging, assertions and developer tooling; not a production package;
- **profile** — performance measurement; not the normal public release artifact;
- **release** — optimized distribution build.

The repository release workflow uses release mode for web.

## 13. Versioning and artifact naming

Current package version:

```text
3.1.0+23
```

The version in `pubspec.yaml` is the project source of truth. Before producing an official release artifact:

1. update `pubspec.yaml` intentionally;
2. update `CHANGELOG.md`;
3. update current-version documentation/tests that assert the version;
4. run full gates;
5. build from the exact reviewed commit;
6. tag the reviewed commit consistently;
7. preserve the commit SHA/tool versions with the release evidence.

Do not move a public release tag to silently replace a published artifact.

## 14. Signing and secrets

Signing is target/distribution specific, but the repository policy is universal:

- never commit private signing keys;
- never commit keystore/certificate passwords;
- never commit provisioning credentials or store API secrets;
- use CI secret storage or an appropriately secured local credential store;
- do not print secret values into CI logs;
- separate public build metadata from private signing material;
- document who/what can perform a release without documenting the secret itself.

The current web artifact does not use native application signing.

## 15. Release verification checklist

For every artifact, record and verify:

- source commit SHA;
- package version/build number;
- Flutter version;
- Dart version;
- dependency resolution success;
- formatting gate success;
- analyzer success;
- complete test-suite success;
- benchmark-smoke success when applicable;
- target release-build success;
- expected files exist in the output;
- artifact launches/loads in a clean target environment;
- local preference restoration works;
- personal dictionary export/import works;
- Portable settings export/import works;
- no editor text is unexpectedly persisted or transmitted;
- clipboard actions remain explicit;
- keyboard/accessibility paths remain usable;
- artifact checksum/provenance is recorded when used by the distribution process;
- signing/notarization/store validation is complete when the target requires it.

## 16. Failure recovery and common fixes

### Flutter cannot find the target

Run:

```bash
flutter doctor -v
flutter devices
```

For native desktop/mobile, first confirm the corresponding host toolchain is available. All supported runner directories are committed in the V3 cross-platform foundation.

### Dependency resolution differs unexpectedly

Check `pubspec.yaml` and `pubspec.lock`, then run:

```bash
flutter clean
flutter pub get
```

Review the lockfile diff before accepting it.

### Analyzer/test failures after runner generation

Generated platform changes can expose plugin/toolchain constraints. Do not suppress project checks to make packaging succeed. Fix the underlying issue, update tests/documentation, and rerun the full gates.

### Web output appears incomplete

Deploy/serve the complete `build/web/` directory. Flutter web output is a set of coordinated files and assets.

### Windows/Linux executable fails when copied alone

Use the complete generated release bundle. Flutter desktop applications depend on adjacent runtime libraries/data.

### Native signing fails

Treat signing as a platform/toolchain configuration problem. Do not solve it by committing private credentials to the repository.

## 17. CI/CD requirements for signed/distribution releases

A target must not be called release-supported until automation or a documented equivalent release procedure verifies the actual target artifact.

A complete native release addition should include:

1. reviewed platform runner files;
2. target-specific metadata/icons/identifiers;
3. build runner on the correct host OS;
4. dependency/format/analyze/test gates;
5. target build command;
6. artifact upload with failure-on-missing-output;
7. signing policy if applicable;
8. retention/provenance policy;
9. smoke/install validation where practical;
10. README/platform/release/privacy/security/documentation updates;
11. regression tests for target-sensitive behavior.

## 18. File-by-file repository build inventory

The following inventory exists so executable documentation cannot silently ignore committed project files. A file can be important to release readiness even when it is not compiled directly into a runtime artifact.

Interpret the sections as follows:

- **Repository/release control:** affects collaboration, CI, release metadata, policy, or reproducibility.
- **Runtime/build source:** may be compiled, bundled, imported, or used by the application/runtime build.
- **Validation source:** exercises behavior or release invariants and must pass before packaging.
- **Developer tooling:** executable/check tooling used during validation.
- **Documentation/evidence:** current contract or historical release evidence that must remain consistent with the code/release claims.

The marked list remains machine-checked for project-controlled files. Flutter-generated native runner trees are treated as managed platform roots, while `.metadata` and cross-platform workflow files are separately protected by repository tests.

<!-- tracked-file-inventory:start -->

### Repository/release control and root files

- `.github/CODEOWNERS`
- `.github/FUNDING.yml`
- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/config.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/dependabot.yml`
- `.github/pull_request_template.md`
- `.github/workflows/ci.yml`
- `.github/workflows/release.yml`
- `.gitignore`
- `CHANGELOG.md`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `GOVERNANCE.md`
- `LICENSE`
- `README.md`
- `SECURITY.md`
- `SUPPORT.md`
- `analysis_options.yaml`
- `pubspec.lock`
- `pubspec.yaml`
- `what_changed.md`

### Documentation and release evidence

- `docs/ACCESSIBILITY.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/CONFIGURATION.md`
- `docs/DEVELOPMENT.md`
- `docs/DOCUMENTATION_MAINTENANCE.md`
- `docs/EXECUTABLE_BUILDS.md`
- `docs/EXAMPLES.md`
- `docs/FAQ.md`
- `docs/FEATURES.md`
- `docs/GETTING_STARTED.md`
- `docs/GLOSSARY.md`
- `docs/KEYBOARD_SHORTCUTS.md`
- `docs/LANGUAGE_PACKS.md`
- `docs/PERFORMANCE.md`
- `docs/PLATFORM_SUPPORT.md`
- `docs/POST_V216_AUDIT_2026_08_16.md`
- `docs/PRIVACY.md`
- `docs/README.md`
- `docs/RELEASE_HISTORY.md`
- `docs/RELEASING.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `docs/TROUBLESHOOTING.md`
- `docs/USER_GUIDE.md`
- `docs/V2_10_BENCHMARK.md`
- `docs/V2_11_ACCESSIBILITY.md`
- `docs/V2_12_FINAL_VALIDATION.md`
- `docs/V2_12_MISSING_PUNCTUATION_SPACING.md`
- `docs/V2_13_FINAL_VALIDATION.md`
- `docs/V2_13_UNMATCHED_PARENTHESIS.md`
- `docs/V2_14_FINAL_VALIDATION.md`
- `docs/V2_14_UNMATCHED_SQUARE_BRACKET.md`
- `docs/V2_15_FINAL_VALIDATION.md`
- `docs/V2_15_UNMATCHED_CURLY_BRACE.md`
- `docs/V2_16_BUG_AUDIT.md`
- `docs/V2_16_FINAL_VALIDATION.md`
- `docs/V2_9_DIAGNOSTIC_SUMMARY.md`
- `docs/WRITING_RULES.md`

### Runtime/build source

- `lib/app.dart`
- `lib/core/edit_distance.dart`
- `lib/core/personal_dictionary_codec.dart`
- `lib/core/settings_transfer_codec.dart`
- `lib/core/spell_check_report.dart`
- `lib/core/spell_checker_engine.dart`
- `lib/core/spell_issue.dart`
- `lib/core/spell_language_pack.dart`
- `lib/core/spell_suggestion.dart`
- `lib/core/spell_suggestion_ranker.dart`
- `lib/core/text_correction.dart`
- `lib/core/text_statistics.dart`
- `lib/data/english_dictionary.dart`
- `lib/data/english_dictionary_extension.dart`
- `lib/data/english_gb_dictionary.dart`
- `lib/data/english_word_frequencies.dart`
- `lib/data/french_dictionary.dart`
- `lib/data/german_dictionary.dart`
- `lib/data/hindi_dictionary.dart`
- `lib/data/italian_dictionary.dart`
- `lib/data/portuguese_br_dictionary.dart`
- `lib/data/spanish_dictionary.dart`
- `lib/features/editor/dictionary_manager_dialog.dart`
- `lib/features/editor/settings_transfer_dialog.dart`
- `lib/features/editor/spell_check_editing_controller.dart`
- `lib/features/editor/spell_checker_page.dart`
- `lib/features/editor/writing_insights_dialog.dart`
- `lib/language.dart`
- `lib/main.dart`
- `lib/spell_checker.dart`
- `lib/storage/dictionary_preferences.dart`
- `lib/storage/settings_transfer_service.dart`
- `lib/writing.dart`
- `lib/writing/rules/missing_punctuation_space_rule.dart`
- `lib/writing/rules/punctuation_spacing_rule.dart`
- `lib/writing/rules/repeated_punctuation_rule.dart`
- `lib/writing/rules/repeated_space_rule.dart`
- `lib/writing/rules/repeated_word_rule.dart`
- `lib/writing/rules/sentence_capitalization_rule.dart`
- `lib/writing/rules/trailing_whitespace_rule.dart`
- `lib/writing/rules/unmatched_curly_brace_rule.dart`
- `lib/writing/rules/unmatched_parenthesis_rule.dart`
- `lib/writing/rules/unmatched_square_bracket_rule.dart`
- `lib/writing/writing_analysis_diagnostic_summary.dart`
- `lib/writing/writing_analyzer.dart`
- `lib/writing/writing_correction.dart`
- `lib/writing/writing_issue.dart`
- `lib/writing/writing_review_preset.dart`
- `lib/writing/writing_review_query.dart`
- `lib/writing/writing_rule.dart`
- `lib/writing/writing_rule_category.dart`
- `web/index.html`
- `web/manifest.json`

### Validation source

- `test/analysis_benchmark_command_test.dart`
- `test/analysis_benchmark_options_test.dart`
- `test/analysis_benchmark_reporter_test.dart`
- `test/analysis_benchmark_result_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/analysis_benchmark_scenario_test.dart`
- `test/bmc_repository_metadata_test.dart`
- `test/bounded_analysis_widget_test.dart`
- `test/dictionary_preferences_test.dart`
- `test/documentation_repository_test.dart`
- `test/edit_distance_test.dart`
- `test/language_dictionary_codec_test.dart`
- `test/language_pack_test.dart`
- `test/language_preferences_test.dart`
- `test/language_widget_test.dart`
- `test/multilingual_language_pack_test.dart`
- `test/multilingual_preferences_test.dart`
- `test/multilingual_widget_test.dart`
- `test/missing_punctuation_space_rule_test.dart`
- `test/missing_punctuation_space_unicode_test.dart`
- `test/personal_dictionary_codec_test.dart`
- `test/sentence_capitalization_quote_test.dart`
- `test/sentence_capitalization_unicode_test.dart`
- `test/settings_transfer_codec_test.dart`
- `test/settings_transfer_dialog_test.dart`
- `test/settings_transfer_service_test.dart`
- `test/spell_check_editing_controller_test.dart`
- `test/spell_check_report_test.dart`
- `test/spell_checker_test.dart`
- `test/suggestion_ranker_test.dart`
- `test/text_correction_test.dart`
- `test/text_statistics_test.dart`
- `test/unmatched_curly_brace_rule_test.dart`
- `test/unmatched_parenthesis_rule_test.dart`
- `test/unmatched_square_bracket_rule_test.dart`
- `test/v211_writing_keyboard_test.dart`
- `test/v211_writing_semantics_test.dart`
- `test/v212_missing_punctuation_space_widget_test.dart`
- `test/v213_benchmark_parenthesis_test.dart`
- `test/v213_bounded_parenthesis_analysis_test.dart`
- `test/v213_parenthesis_stress_test.dart`
- `test/v213_review_query_parenthesis_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/v213_settings_transfer_rule_compatibility_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_unmatched_parenthesis_widget_test.dart`
- `test/v213_writing_diagnostic_summary_test.dart`
- `test/v214_benchmark_square_bracket_test.dart`
- `test/v214_bounded_square_bracket_analysis_test.dart`
- `test/v214_review_query_square_bracket_test.dart`
- `test/v214_rule_preference_compatibility_widget_test.dart`
- `test/v214_settings_transfer_rule_compatibility_test.dart`
- `test/v214_square_bracket_stress_test.dart`
- `test/v214_unmatched_square_bracket_integration_test.dart`
- `test/v214_unmatched_square_bracket_widget_test.dart`
- `test/v214_writing_diagnostic_summary_test.dart`
- `test/v215_benchmark_curly_brace_test.dart`
- `test/v215_bounded_curly_brace_analysis_test.dart`
- `test/v215_curly_brace_stress_test.dart`
- `test/v215_review_query_curly_brace_test.dart`
- `test/v215_rule_preference_compatibility_widget_test.dart`
- `test/v215_settings_transfer_rule_compatibility_test.dart`
- `test/v215_unmatched_curly_brace_integration_test.dart`
- `test/v215_unmatched_curly_brace_widget_test.dart`
- `test/v215_writing_diagnostic_summary_test.dart`
- `test/v216_startup_preference_sync_widget_test.dart`
- `test/v23_widget_test.dart`
- `test/v26_writing_rules_test.dart`
- `test/widget_test.dart`
- `test/writing_analysis_diagnostic_summary_test.dart`
- `test/writing_analysis_diagnostics_test.dart`
- `test/writing_analysis_diagnostics_widget_test.dart`
- `test/writing_analysis_limit_test.dart`
- `test/writing_analysis_limit_widget_test.dart`
- `test/writing_correction_test.dart`
- `test/writing_preferences_test.dart`
- `test/writing_review_preset_test.dart`
- `test/writing_review_query_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`

### Developer tooling

- `tool/benchmark/analysis_benchmark_command.dart`
- `tool/benchmark/analysis_benchmark_options.dart`
- `tool/benchmark/analysis_benchmark_reporter.dart`
- `tool/benchmark/analysis_benchmark_result.dart`
- `tool/benchmark/analysis_benchmark_runner.dart`
- `tool/benchmark/analysis_benchmark_scenario.dart`
- `tool/benchmark_large_document.dart`

- `docs/V3_0_CROSS_PLATFORM_FOUNDATION.md`
- `docs/V3_1_MULTILINGUAL_FOUNDATION.md`

<!-- tracked-file-inventory:end -->

## 19. How each inventory class affects executable creation

### Repository/release control

These files generally do not compile into the Dart application, but they define whether the release is reviewable, reproducible, secure, supported, and correctly automated. In particular, the two workflow files define the existing CI/release behavior, while `pubspec.yaml`, `pubspec.lock`, and `analysis_options.yaml` directly affect dependency/tooling behavior.

### Documentation and release evidence

These files are not runtime code, but executable claims must match them. A release that builds successfully while documentation falsely claims unsupported platforms is still an incorrect project release. Current-state docs should be updated with any platform/build change; historical V2.x records remain historical evidence and should not be rewritten simply to look current.

### Runtime/build source

These files contain the application/library implementation and committed web host. They are the primary source inputs for the current web artifact and the portable Dart/Flutter implementation that future native runners would host.

### Validation source

Every test file participates in the complete `flutter test --reporter expanded` gate. A target package should not be produced by skipping the full suite merely because a focused test passed.

### Developer tooling

The benchmark files are run by CI/release smoke validation. They are not user telemetry and are not bundled because the release workflow executes them as development tooling before `flutter build web --release`.

## 20. Keeping this inventory complete

`test/documentation_repository_test.dart` checks the marked inventory against `git ls-files`.

When adding, deleting, or renaming a tracked file:

1. update the marked inventory in this document in the same change;
2. classify the file correctly;
3. document any new build/release effect;
4. run the full test suite;
5. if it is a platform runner file, also update platform/release/security/privacy documentation and the relevant build automation.

This intentionally makes repository-file coverage part of CI rather than relying only on manual documentation review.

## 21. Official upstream Flutter references

Use Flutter's current official documentation when changing build tooling or platform runners:

- Web build/release: `https://docs.flutter.dev/deployment/web`
- Web project/build setup: `https://docs.flutter.dev/platform-integration/web/building`
- Desktop support and adding desktop runners: `https://docs.flutter.dev/platform-integration/desktop`
- Windows build integration: `https://docs.flutter.dev/platform-integration/windows/building`
- macOS build integration: `https://docs.flutter.dev/platform-integration/macos/building`
- Linux build integration: `https://docs.flutter.dev/platform-integration/linux/building`
- Android deployment: `https://docs.flutter.dev/deployment/android`
- iOS deployment: `https://docs.flutter.dev/deployment/ios`
- Flutter deployment index: `https://docs.flutter.dev/deployment`

When upstream Flutter behavior changes, update this document and the build automation together rather than leaving commands stale.

## 22. Related SpellChecker documentation

- [Getting started](GETTING_STARTED.md)
- [Development](DEVELOPMENT.md)
- [Testing](TESTING.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Releasing](RELEASING.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Architecture](ARCHITECTURE.md)
- [Privacy](PRIVACY.md)
- [Security](../SECURITY.md)
- [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md)
