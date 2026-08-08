# Releasing

This document describes the SpellChecker release procedure.

## Preconditions

Before releasing:

- `main` contains the intended code.
- GitHub Actions CI is passing on the release commit.
- `pubspec.yaml` contains the intended `MAJOR.MINOR.PATCH+BUILD` version.
- `CHANGELOG.md` contains a dated release entry.
- README and user-facing documentation match current behavior.
- API and architecture documentation match exported/public behavior.
- Security, privacy, and accessibility documentation are current.
- Persistent-data behavior and any migrations are documented and tested.

Do not create a release tag from a branch with failing or missing required validation.

## Versioning

The Flutter version field uses:

```text
MAJOR.MINOR.PATCH+BUILD
```

Examples:

```text
1.0.0+1
1.1.0+2
```

Increase the semantic version for user-visible releases and the build number for packaging iterations as needed.

## V1.1 persistent-data compatibility

SpellChecker 1.1 introduces device-local persistence for:

- Personal dictionary words.
- Suggestion-count preference.

The preference keys and personal-dictionary export format are versioned. Before a future release changes either format:

1. Define whether old values remain readable.
2. Add migration logic when compatibility is required.
3. Add tests for old-to-new behavior.
4. Update `docs/PRIVACY.md`, `docs/API.md`, and the changelog.
5. Never silently reinterpret an existing dictionary export version.

The V1.1 export format is:

```json
{
  "version": 1,
  "words": ["example"]
}
```

## Local release verification

From a clean checkout of the intended release commit:

```bash
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build web --release
```

Inspect the printed Flutter/Dart versions and confirm they satisfy `pubspec.yaml`.

## V1.1 release smoke test

Before tagging V1.1 or a maintenance release based on it, manually verify when practical:

1. Launch with no saved preferences.
2. Check a known misspelling and replace it.
3. Save a synthetic personal word.
4. Restart/reload and confirm the saved word is restored.
5. Change the suggestion count and confirm it is restored after restart/reload.
6. Ignore a word and confirm the ignore does not persist across a new application session.
7. Export the personal dictionary and inspect the JSON version/normalized words.
8. Import the export and confirm duplicates are not created.
9. Remove one personal word and clear all personal words.
10. Verify light/dark theme, narrow layout, and keyboard access to new dictionary controls.

Use synthetic words/data for release verification.

## Tagging

Create an annotated tag from the verified `main` commit. For V1.1:

```bash
git checkout main
git pull --ff-only
git tag -a v1.1.0 -m "SpellChecker v1.1.0"
git push origin v1.1.0
```

Pushing a `v*` tag triggers the repository release-build workflow. That workflow validates the project and uploads the release web build as a GitHub Actions artifact.

## Verify the tagged workflow

The tagged release workflow must finish successfully before publishing release notes or presenting the artifact as a verified release.

If the workflow fails:

1. Do not move or overwrite the published tag silently.
2. Diagnose the failure.
3. Fix the issue on `main` with tests when appropriate.
4. Publish a new version/tag if the failed tag has already been shared externally.

## GitHub release

After the tagged workflow passes:

1. Create a GitHub Release for the tag.
2. Use the matching `CHANGELOG.md` section as the release-notes foundation.
3. Mention important persistence/privacy behavior for releases that change it.
4. Attach approved release artifacts when appropriate.
5. Verify repository/documentation links and user-visible version text.
6. Verify the release points to the same commit that passed validation.

## Rollback and hotfixes

Do not move a published release tag silently. If a release contains a defect:

1. Fix it on `main`.
2. Add regression tests.
3. Update the changelog.
4. Increment the patch/build version.
5. Publish a new tag.

For persistence defects, also verify that the fix does not destroy or reinterpret existing saved personal words.

## Dependency review

Before a release that changes dependencies:

- Review the dependency purpose.
- Confirm it does not add unexpected network/analytics behavior.
- Run `flutter pub get` from a clean checkout.
- Ensure CI resolves the same constraints successfully.
- Update development/privacy documentation when runtime behavior changes.

V1.1 uses `shared_preferences` solely for application-local preference storage.

## Signing and stores

Mobile/desktop signing credentials, app-store tokens, certificates, and release secrets must never be committed. Store them using the secure facilities of the relevant build/release environment.
