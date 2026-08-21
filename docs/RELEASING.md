# Releasing

This page documents the current SpellChecker release process. The V3 automated release contract validates source once and produces release-mode build artifacts for **Android, iOS, Linux, macOS, Web, and Windows**. Exact version-tag runs additionally publish a permanent GitHub Release with normalized cross-platform assets, a SHA-256 checksum manifest, and GitHub build-provenance attestations. Private production signing credentials are never injected from the public repository by default.

For the complete local build/package procedure, target-specific artifact expectations, runner migration policy, signing boundaries, release verification, troubleshooting, and repository build inventory, see [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Current package

```text
name: spellchecker
version: 3.2.0+25
Dart SDK: >=3.8.0 <4.0.0
```

`pubspec.yaml` is the package-version source of truth.

## Release workflow trigger

`.github/workflows/release.yml` runs when a Git tag matching `v*` is pushed or when a maintainer manually dispatches the workflow.

For a tag-triggered run, the workflow derives the release version from `pubspec.yaml` by removing Flutter build metadata after `+` and requires the tag to equal `vMAJOR.MINOR.PATCH`. For example, package version `3.2.0+25` requires tag `v3.2.0`. A mismatched `v*` tag fails the quality job before Flutter setup or target packaging. Manual workflow dispatch is intentionally not subject to this tag check because it is used for release-candidate validation from branches or commits.

Workflow name: `Cross-platform release build`. The workflow-level permission remains `contents: read`. Only the final tag-only publishing job elevates to `contents: write`, `id-token: write`, and `attestations: write` so it can publish GitHub Release assets and build provenance after every required platform job succeeds.

## What the workflow validates

The `quality` job runs once on Ubuntu. It resolves the package version, release version, and a filesystem-safe artifact suffix. On tag-triggered runs it verifies the release tag against the package version, then performs Flutter/Dart version reporting, dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke.

After quality succeeds, target jobs build in parallel:

```text
Web      ubuntu-latest   flutter test --platform chrome test/widget_test.dart
                         flutter build web --release
Android  ubuntu-latest   flutter build apk --release + flutter build appbundle --release
Linux    ubuntu-latest   flutter build linux --release
Windows  windows-latest  flutter build windows --release
macOS    macos-latest    flutter build macos --release
iOS      macos-latest    flutter build ios --release --no-codesign
```

The Android target additionally runs the focused Android repository-support contract and verifies the production-manifest privacy policy before packaging. The Web target runs the existing app-level widget workflow in Chrome before its release build, then verifies its manifest and install icons after build. Web and Windows outputs are normalized into ZIP archives. Linux, macOS, and iOS outputs are wrapped in tar archives so Unix executable permission bits and native bundle structure survive artifact transport. Each job fails if its expected output is missing and uploads a 30-day GitHub Actions artifact used by release-candidate validation and the final tag-publishing job.

For exact version tags, `publish-release` downloads the normalized target artifacts only after all six build jobs succeed. It verifies the complete expected asset set, generates a SHA-256 manifest, creates build-provenance attestations, creates or refreshes the matching GitHub Release, uploads all release assets, and verifies that every expected file is present on the published Release.

Android/iOS/macOS/Windows distribution signing remains intentionally separate from source/build validation.

## Release artifacts

The build jobs normalize outputs into stable filenames. For a tag such as `v3.2.0`, the permanent GitHub Release contains the equivalent of:

```text
spellchecker-web-v3.2.0.zip
spellchecker-android-validation-v3.2.0.apk
spellchecker-android-validation-v3.2.0.aab
spellchecker-linux-v3.2.0.tar.gz
spellchecker-windows-v3.2.0.zip
spellchecker-macos-unsigned-v3.2.0.tar.gz
spellchecker-ios-no-codesign-v3.2.0.tar.gz
spellchecker-v3.2.0-SHA256SUMS.txt
```

The signing words in those names are part of the public trust boundary:

- Android APK/AAB — release-mode **validation** builds; when no private upload keystore is supplied, the repository intentionally uses its fallback signing path. These files must not be represented as Play production-signed artifacts.
- iOS — release-mode `.app` built with `--no-codesign`; it is not an App Store/TestFlight IPA.
- macOS — unsigned release `.app` bundle preserved inside a tar archive; signing/notarization is separate.
- Windows — release runtime bundle; code signing/installer packaging is separate.
- Linux — complete release bundle preserved inside a tar archive.
- Web — complete verified `build/web` static site wrapped as a ZIP.

The checksum manifest covers the seven platform asset files before the manifest itself is added. GitHub build-provenance attestations bind the release asset bytes to the workflow run that produced them.

GitHub Actions artifacts remain temporary 30-day workflow storage. Exact tag runs also publish the normalized files to the tag's GitHub Release for durable release distribution. Manual workflow dispatch does **not** publish a GitHub Release.

## Pre-release checklist

Before tagging/dispatching a release, verify:

- intended code/docs are merged into `main`;
- CI is green on the exact `main` commit;
- `pubspec.yaml` version/build number is correct;
- for a tag-triggered release, the tag equals `v` plus the package version before `+`;
- README/docs current-version references are updated;
- About dialog/version tests match the package release intention;
- `CHANGELOG.md` contains the release entry;
- public API compatibility was reviewed;
- persistence/transfer-format compatibility was reviewed;
- writing-rule/language default migrations were reviewed;
- privacy/security docs match runtime data flows;
- full Flutter suite and benchmark smoke pass;
- Web Chrome widget smoke passes;
- the executable-build tracked-file inventory matches the actual repository;
- all configured cross-platform release-mode build jobs succeed;
- Android release validation produces both the APK and AAB and preserves the production-manifest policy;
- the final tag-only publish job verifies all normalized assets, checksum generation, provenance attestation, and GitHub Release upload;
- historical release/validation record is added when the release needs durable audit evidence.

Before signed/store distribution, also complete the target-specific signing, packaging, accessibility, privacy/security, and clean-environment verification checklist in [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Versioning

SpellChecker uses a semantic-looking package version plus Flutter build metadata:

```text
MAJOR.MINOR.PATCH+BUILD
```

Generic example:

```text
1.2.3+45
```

When incrementing the version:

1. edit `pubspec.yaml`;
2. update root README/docs current release references;
3. update user-visible About/version text if it is not derived dynamically;
4. update tests asserting version text;
5. update `CHANGELOG.md`;
6. ensure release/history documentation identifies the intended version.

Do not rewrite historical files' old versions merely because the current version changes.

## Tagging

Tag-triggered release packaging requires the exact tag `vMAJOR.MINOR.PATCH`, where `MAJOR.MINOR.PATCH` is the `pubspec.yaml` version before `+BUILD` metadata. For example, a package version `1.2.3+45` must use:

```bash
git tag v1.2.3
git push origin v1.2.3
```

A tag such as `v1.2.4`, `v1.2.3+45`, or another mismatched `v*` value still triggers the workflow but is rejected by the quality job before packaging. This prevents a release artifact from being labeled with a version that disagrees with source metadata.

Before pushing a tag, make sure it points to the reviewed/green release commit. Replacing/moving public release tags damages reproducibility and should be avoided. A successful exact version tag is also the publication trigger for the permanent GitHub Release.

## Manual dispatch

A maintainer can run the workflow manually from GitHub Actions without creating a tag. The workflow sanitizes `/` characters in `${{ github.ref_name }}` when it derives the artifact filename suffix so release-candidate builds from namespaced branches remain valid files.

Manual dispatch is useful for release-candidate verification and intentionally bypasses the tag/version equality check. It builds and uploads the same normalized platform artifacts to temporary GitHub Actions storage, but the `publish-release` job is tag-only and therefore does not create or modify a GitHub Release for manual runs.

## Release candidate validation

For a significant release, consider recording exact evidence:

- commit SHA;
- Flutter/Dart versions;
- format/analyzer/full test results;
- benchmark smoke result;
- Chrome Web widget-smoke result;
- Android APK and AAB build results plus the Android support-contract result;
- iOS/Linux/macOS/Web/Windows build results;
- normalized release asset names;
- SHA-256 manifest result;
- GitHub build-provenance attestation result on tag runs;
- GitHub Release publication verification on tag runs;
- executable/package verification result;
- migration/compatibility checks;
- known limitations;
- relevant focused stress/Unicode/accessibility tests.

Historical validation records should be linked from [Release history](RELEASE_HISTORY.md).

## Changelog

`CHANGELOG.md` should summarize user/developer-visible changes in release order.

A useful release entry separates:

- new features;
- bug fixes;
- API behavior;
- persistence/format migrations;
- accessibility/privacy/security changes;
- platform/release changes;
- notable compatibility notes.

Do not duplicate entire design documents into the changelog; link durable docs where necessary.

## Public API release review

Before releasing an exported API change, inspect the three public barrels:

```text
lib/spell_checker.dart
lib/language.dart
lib/writing.dart
```

Check:

- constructor/method signature compatibility;
- field nullability/default changes;
- equality/hash behavior where callers may rely on value objects;
- validation/error behavior;
- deterministic ordering changes;
- UTF-16/scalar semantics;
- source ownership/correction semantics;
- custom rule/ranker/language extension compatibility.

Update [API](API.md) and [Examples](EXAMPLES.md).

## Persistence/format release review

Check:

- selected-language restoration;
- suggestion limit;
- personal dictionary per-language keys/migration;
- writing-rule unset/non-empty/empty semantics;
- current personal dictionary format version 2 plus legacy readers;
- Portable settings format/version 1;
- storage write-failure truthfulness;
- import rollback behavior.

A persisted format version change requires explicit migration/backward-compatibility design, not only a codec edit.

## Writing-rule release review

If the built-in registry/defaults change, verify:

- stable IDs;
- exact current registry count;
- explicit older stored sets remain authoritative;
- unset/reset state adopts the new default set;
- explicit empty state remains disable-all;
- Portable settings preserves explicit overrides;
- rule interactions/source ownership/batch behavior;
- diagnostic totals/filtering/UI labels;
- benchmark workload comparability.

Update [Writing rules](WRITING_RULES.md), [Features](FEATURES.md), and current user/API docs.

## Language release review

If adding/changing a built-in language pack, review dictionary/data licensing, normalization/tokenization, regional variants, suggestions, personal-dictionary transfer, preference isolation, writing eligibility, settings validation, benchmark options, and user docs.

See [Language packs](LANGUAGE_PACKS.md).

## Privacy/security release review

A release must not introduce undisclosed network/storage/diagnostic behavior.

Specifically check for new:

- dependencies;
- HTTP/network clients;
- telemetry/analytics/crash upload;
- account/auth SDKs;
- file/document persistence;
- platform permissions;
- clipboard automation;
- external plugin/model downloads;
- logging of document/finding/vocabulary data.

The release workflow's GitHub publishing network activity is repository automation, not application runtime telemetry or document processing. Application runtime behavior remains local/offline unless separately changed and documented.

Update [Privacy](PRIVACY.md) and [Security](../SECURITY.md) before release when behavior changes.

## Platform support release review

All six Flutter runners are committed and cross-platform CI/release builds validate them. Before describing an artifact as production-distribution-ready, verify the relevant signing/notarization/store/installer policy rather than equating a successful CI build with channel approval.

For Android, CI validates both release packaging forms while the production upload keystore remains external to Git. Web also has a browser-runtime smoke gate in Chrome before packaging. See [Platform support](PLATFORM_SUPPORT.md), [Executable builds](EXECUTABLE_BUILDS.md), and the Android runner guide for target-specific requirements.

## Release artifact verification

After workflow success:

1. confirm the common quality job succeeded;
2. on a tag-triggered run, confirm the tag/version guard succeeded;
3. confirm the Web Chrome widget smoke succeeded;
4. confirm every intended platform build job succeeded;
5. confirm every normalized platform artifact exists and uses the expected sanitized ref/tag suffix;
6. for Android, confirm both the APK and AAB are present and distinguish CI validation signing from the intended production upload certificate;
7. extract Linux/macOS/iOS tar archives before inspection so their preserved permission/bundle metadata is retained;
8. inspect or extract the complete bundle rather than only a single executable from desktop targets;
9. on tag runs, verify the SHA-256 manifest contains all seven platform asset filenames and validate downloaded files against it;
10. on tag runs, confirm GitHub build-provenance attestations were created and the `publish-release` verification step found every `dist/` file on the GitHub Release;
11. complete the target release verification checklist in [Executable builds and packaging](EXECUTABLE_BUILDS.md);
12. keep the workflow run/tag/commit reference in release evidence.

Temporary GitHub Actions artifacts are retained for 30 days. The exact version tag's GitHub Release is the durable repository distribution record for these automated assets; store/channel publication still follows each platform's signing and review requirements.

## Publishing/deployment

Exact version tags now publish permanent repository release assets to GitHub Releases. This does **not** deploy the Web build to a host and does not publish Android, iOS, macOS, Windows, or Linux artifacts to an app store/package channel.

Still-separate distribution work includes:

- Web hosting/GitHub Pages or another hosting destination;
- Google Play upload/signing promotion;
- App Store/TestFlight archive/signing/provisioning;
- macOS signing/notarization;
- Windows code signing/installer packaging;
- Linux package-repository formats and signing.

Any future deployment/publishing system should document destination, credentials/secrets, approvals, rollback, provenance/signing, retention, privacy/security effects, and version/tag mapping.

Target-specific packaging/signing details belong in [Executable builds and packaging](EXECUTABLE_BUILDS.md) and must remain consistent with this release contract.

## Rollback/hotfix

For a release regression:

1. identify/reproduce on the release tag/commit;
2. fix on a normal review branch with regression tests;
3. run full CI;
4. increment version when publishing a corrected release rather than silently moving an old tag;
5. update changelog/release notes;
6. create a new tag so the corrected build receives its own checksums, provenance, and GitHub Release assets.

## BMC/funding

Funding is optional and independent from releases. The canonical BMC link is:

```text
https://buymeacoffee.com/sanskarIN
```

Do not condition release access, bug/security reporting, or contribution review on financial support.

## Related documentation

- [Testing](TESTING.md)
- [Development](DEVELOPMENT.md)
- [Executable builds and packaging](EXECUTABLE_BUILDS.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Performance](PERFORMANCE.md)
- [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md)
- [Release history](RELEASE_HISTORY.md)
