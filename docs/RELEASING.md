# Releasing

This page documents the current SpellChecker release process. The repository's automated release contract is a validated **Flutter web build artifact**; it does not currently build/publish native Android/iOS/Windows/macOS/Linux artifacts or automatically create a GitHub Release entry.

For the complete local build/package procedure, future native-runner generation, target-specific artifact expectations, signing boundaries, release verification, troubleshooting, and the machine-checked tracked-file build inventory, see [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Current package

```text
name: spellchecker
version: 2.16.0+21
Dart SDK: >=3.8.0 <4.0.0
```

`pubspec.yaml` is the package-version source of truth.

## Release workflow trigger

`.github/workflows/release.yml` runs when:

- a Git tag matching `v*` is pushed; or
- a maintainer manually dispatches the workflow.

Workflow name:

```text
Release build
```

Job:

```text
Validate benchmark tooling and build web release
```

Runner:

```text
ubuntu-latest
```

Timeout:

```text
25 minutes
```

Workflow permissions are read-only for repository contents.

## What the workflow validates

In order:

```bash
flutter --version
dart --version
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
flutter build web --release
```

Any failed gate prevents artifact upload.

The complete Flutter test suite includes the repository documentation checks. In particular, `test/documentation_repository_test.dart` requires the tracked-file inventory in [Executable builds and packaging](EXECUTABLE_BUILDS.md) to match `git ls-files`, so a newly committed file cannot be silently omitted from the executable/release documentation.

## Artifact

The workflow uploads:

```text
build/web
```

Artifact name:

```text
spellchecker-web-${github.ref_name}
```

The workflow fails if the build directory is missing and retains the artifact for 14 days.

This Actions artifact is not the same thing as a permanently published GitHub Release asset/site deployment.

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
- web release build succeeds;
- historical release/validation record is added when the release needs durable audit evidence.

For any future native release, also complete the target-specific checklist in [Executable builds and packaging](EXECUTABLE_BUILDS.md) before advertising or distributing that artifact.

## Versioning

SpellChecker currently uses a semantic-looking package version plus Flutter build metadata:

```text
MAJOR.MINOR.PATCH+BUILD
```

Example:

```text
2.16.0+21
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
git tag v2.16.0
git push origin v2.16.0
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
- web build result;
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

Current workflow builds only web. Do not call a release “Android/iOS/Windows/macOS/Linux release” unless the repository has intentionally added/validated those runners/builds/artifacts.

Official native release support would need target-specific runner files, CI builds, signing/credential policy, artifact process, platform privacy/security/accessibility review, and documentation. The complete native-support acceptance requirements and target build/package commands are in [Executable builds and packaging](EXECUTABLE_BUILDS.md).

See [Platform support](PLATFORM_SUPPORT.md) for the current support matrix.

## Release artifact verification

After workflow success:

1. inspect job summary/logs for every gate success;
2. confirm the uploaded artifact exists and uses the expected ref/tag suffix;
3. download/extract if needed and verify the web build directory has expected Flutter web output;
4. perform the release verification checklist in [Executable builds and packaging](EXECUTABLE_BUILDS.md);
5. keep the workflow run/tag/commit reference in any release announcement/validation record.

Because artifact retention is currently 14 days, do not treat Actions artifacts as permanent archival storage.

## Publishing/deployment

The current repository workflow stops at artifact upload. Deployment to a web host, GitHub Pages, package registry, app store, or GitHub Release is outside the automated release workflow.

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
