# Releasing

This page documents the current SpellChecker release process. The V3 automated release contract validates source once and produces release-mode build artifacts for **Android, iOS, Linux, macOS, Web, and Windows**. It still does not automatically create a permanent GitHub Release entry or inject private production signing credentials.

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

Workflow name: `Cross-platform release build`. Repository contents permission remains read-only.

## What the workflow validates

The `quality` job runs once on Ubuntu and performs Flutter/Dart version reporting, dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke.

After quality succeeds, target jobs build in parallel:

```text
Web      ubuntu-latest   flutter build web --release
Android  ubuntu-latest   flutter build apk --release
Linux    ubuntu-latest   flutter build linux --release
Windows  windows-latest  flutter build windows --release
macOS    macos-latest    flutter build macos --release
iOS      macos-latest    flutter build ios --release --no-codesign
```

Each job fails if its expected output is missing and uploads a 30-day GitHub Actions artifact. Android/iOS/macOS/Windows distribution signing remains intentionally separate from source/build validation.

## Release artifacts

The workflow uploads target-specific artifacts named from the triggering ref or release tag. Web/Linux/Windows are complete runtime bundles/directories; Android is a validation release APK; macOS is an unsigned app build; iOS is a no-codesign app build.

Actions artifacts are not permanent GitHub Release assets and are not app-store publication.

## Pre-release checklist

Before tagging/dispatching a release, verify:

- intended code/docs are merged into `main`;
- CI is green on the exact `main` commit;
- `pubspec.yaml` version/build number is correct;
- README/docs current-version references are updated;
- About dialog/version tests match the package release intention;
- `CHANGELOG.md` contains the release entry;
- public API compatibility was reviewed;
- persistence/transfer-format compatibility was reviewed;
- writing-rule/language default migrations were reviewed;
- privacy/security docs match runtime data flows;
- full Flutter suite and benchmark smoke pass;
- the executable-build tracked-file inventory matches the actual repository;
- all configured cross-platform release-mode build jobs succeed;
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

The workflow accepts any tag beginning with `v`. Use a tag that clearly corresponds to the intended package release, for example:

```bash
git tag v1.2.3
git push origin v1.2.3
```

Before pushing a tag, make sure it points to the reviewed/green release commit. Replacing/moving public release tags damages reproducibility and should be avoided.

## Manual dispatch

A maintainer can run the workflow manually from GitHub Actions without creating a tag. In that case, `${{ github.ref_name }}` determines the artifact suffix from the dispatched ref.

Manual dispatch is useful for release-candidate verification but does not by itself change package version or create a release record.

## Release candidate validation

For a significant release, consider recording exact evidence:

- commit SHA;
- Flutter/Dart versions;
- format/analyzer/full test results;
- benchmark smoke result;
- Android/iOS/Linux/macOS/Web/Windows build results;
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

Update [Privacy](PRIVACY.md) and [Security](../SECURITY.md) before release when behavior changes.

## Platform support release review

All six Flutter runners are committed and cross-platform CI/release builds validate them. Before describing an artifact as production-distribution-ready, verify the relevant signing/notarization/store/installer policy rather than equating a successful CI build with channel approval.

See [Platform support](PLATFORM_SUPPORT.md) for the current matrix and [Executable builds and packaging](EXECUTABLE_BUILDS.md) for target-specific requirements.

## Release artifact verification

After workflow success:

1. confirm the common quality job succeeded;
2. confirm every intended platform build job succeeded;
3. confirm each uploaded artifact exists and uses the expected ref/tag suffix;
4. inspect or extract the complete bundle rather than only a single executable from desktop targets;
5. complete the target release verification checklist in [Executable builds and packaging](EXECUTABLE_BUILDS.md);
6. keep the workflow run/tag/commit reference in release evidence.

The workflow artifacts are retained for 30 days and should not be treated as permanent archival storage.

## Publishing/deployment

The current repository workflow stops at cross-platform artifact upload. Deployment to a web host, GitHub Pages, package registry, app store, installer channel, notarization service, or permanent GitHub Release remains outside the automated release workflow.

If a future deployment/publishing system is added, document:

- destination;
- credentials/secrets;
- approvals;
- rollback;
- provenance/signing;
- retention;
- privacy/security effects;
- version/tag mapping.

Target-specific packaging/signing details belong in [Executable builds and packaging](EXECUTABLE_BUILDS.md) and must remain consistent with this release contract.

## Rollback/hotfix

For a release regression:

1. identify/reproduce on the release tag/commit;
2. fix on a normal review branch with regression tests;
3. run full CI;
4. increment version when publishing a corrected release rather than silently moving an old tag;
5. update changelog/release notes;
6. create a new tag/artifact.

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
