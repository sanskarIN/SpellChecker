# Releasing

This document describes the project release procedure.

## Preconditions

Before releasing:

- `main` contains the intended code.
- CI is passing.
- Version in `pubspec.yaml` is correct.
- `CHANGELOG.md` contains the release entry.
- User-visible documentation matches behavior.
- Security/privacy documentation is current.

## Versioning

The Flutter version field uses:

```text
MAJOR.MINOR.PATCH+BUILD
```

Example:

```text
1.0.0+1
```

Increase the build number for packaging iterations as needed.

## Local release verification

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

## Tagging

Create an annotated tag from the verified `main` commit:

```bash
git checkout main
git pull --ff-only
git tag -a v1.0.0 -m "SpellChecker v1.0.0"
git push origin v1.0.0
```

Pushing a `v*` tag triggers the repository release build workflow, which validates the project and uploads the release web build as a workflow artifact.

## GitHub release

After the tagged workflow passes:

1. Create a GitHub Release for the tag.
2. Use the corresponding changelog section as the release notes foundation.
3. Attach approved release artifacts when appropriate.
4. Verify links and version text.

## Rollback

Do not move a published release tag silently. If a release contains a defect:

1. Fix it on `main`.
2. Add regression tests.
3. Increment the patch version/build number.
4. Publish a new tag.

## Signing and stores

Mobile/desktop signing credentials and store secrets must never be committed. Store them using the secure facilities of the relevant build/release environment.
