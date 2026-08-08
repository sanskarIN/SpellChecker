# Releasing

This document describes the SpellChecker release procedure.

## Preconditions

Before releasing:

- `main` contains the intended code.
- GitHub Actions CI is passing on the exact release commit.
- `pubspec.yaml` contains the intended `MAJOR.MINOR.PATCH+BUILD` version.
- `CHANGELOG.md` contains a dated release entry.
- README and user-facing documentation match current behavior.
- API/architecture documentation matches exported behavior.
- Security, privacy, accessibility, testing, and troubleshooting documentation is current.
- Persistent-data behavior and migrations are documented/tested.
- Editor shortcut, correction, and undo behavior is documented/tested.

Do not create a release tag from a branch with failing or missing required validation.

## Versioning

Flutter version field:

```text
MAJOR.MINOR.PATCH+BUILD
```

Examples:

```text
1.0.0+1
1.1.0+2
1.2.0+3
```

Increase semantic version for user-visible releases and build number for packaging iterations as needed.

## Persistent-data compatibility

SpellChecker persists:

- Personal dictionary words.
- Suggestion-count preference.

Preference keys and personal-dictionary export format are versioned. Before changing either format:

1. Define old-value compatibility.
2. Add migration logic if needed.
3. Add old-to-new tests.
4. Update privacy/API/changelog docs.
5. Never silently reinterpret an existing dictionary export version.

Current export format:

```json
{
  "version": 1,
  "words": ["example"]
}
```

V1.2 does not change this persisted format.

## V1.2 non-persistent editor state

Do not accidentally turn these into persistent data during release preparation:

- Editor text.
- Checked issue list.
- Active issue index.
- Ignored words.
- Correction undo snapshots.

The correction undo stack can contain editor-text snapshots and must remain memory-only unless a future explicitly reviewed feature changes that design.

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

Confirm Flutter/Dart versions satisfy `pubspec.yaml`.

## V1.2 release smoke test

Before tagging V1.2 or a maintenance release based on it, manually verify when practical:

### Basic checking

1. Launch with no saved preferences.
2. Enter a known misspelling.
3. Check using the button.
4. Check again using `Ctrl+Enter`/`Command+Enter` on applicable platforms.
5. Verify inline underlining and Results issue state agree.

### Navigation

6. Enter at least three synthetic misspellings.
7. Verify `F7` moves forward and wraps.
8. Verify `Shift+F7` moves backward and wraps.
9. Verify app-bar and Results previous/next controls.
10. Verify active issue selection appears in the editor and Results auto-scrolls when needed.

### Corrections

11. Replace one occurrence and verify case preservation.
12. Use snackbar **Undo** and verify the previous document returns.
13. Repeat a misspelling with mixed capitalization.
14. Use **Replace all…** and verify each checked occurrence is replaced with matching capitalization.
15. Use **Undo correction** and verify the full bulk edit is restored as one step.
16. Modify text manually after a correction and verify old correction history/highlights do not incorrectly remain active.
17. Change text after checking and verify stale replacement refreshes rather than mutating the wrong range.

### States and accessibility

18. Check a blank editor and verify **Nothing to check**.
19. Check a clean sentence and verify **No issues found**.
20. Verify keyboard-only access to issue navigation and correction controls.
21. Verify light/dark themes, larger text, and narrow layout.
22. Verify active state is understandable through Results text/semantics rather than color alone.

### Persistence regression

23. Save a synthetic personal word.
24. Restart/reload and confirm it is restored.
25. Change suggestion count and confirm restoration.
26. Verify **Ignore once** does not persist across a new session.
27. Export/import synthetic personal vocabulary.

Use only synthetic text and vocabulary during release verification.

## Tagging

Create an annotated tag from the verified `main` commit. For V1.2:

```bash
git checkout main
git pull --ff-only
git tag -a v1.2.0 -m "SpellChecker v1.2.0"
git push origin v1.2.0
```

Pushing a `v*` tag triggers the release-build workflow, which validates the project and uploads the release web build as a GitHub Actions artifact.

## Verify tagged workflow

The tagged workflow must finish successfully before presenting the artifact as a verified release.

If it fails:

1. Do not silently move/overwrite the published tag.
2. Diagnose the failure.
3. Fix on `main` with regression tests when appropriate.
4. Publish a new version/tag if the failed tag was already shared.

## GitHub release

After the tagged workflow passes:

1. Create a GitHub Release for the tag.
2. Use the matching changelog section as release-note foundation.
3. Call out important keyboard/editor/correction behavior for V1.2.
4. Mention persistence/privacy behavior when relevant.
5. Attach approved artifacts where appropriate.
6. Verify links and user-visible version text.
7. Verify the release points to the exact commit that passed validation.

## Rollback and hotfixes

Do not move a published release tag silently. If a release contains a defect:

1. Fix on `main`.
2. Add regression tests.
3. Update changelog.
4. Increment patch/build version.
5. Publish a new tag.

For correction defects, test stale offsets, replace-all ordering, and undo grouping. For persistence defects, verify saved personal data is not destroyed or reinterpreted.

## Dependency review

Before a release that changes dependencies:

- Review dependency purpose.
- Confirm no unexpected network/analytics behavior.
- Run `flutter pub get` cleanly.
- Ensure CI resolves the same constraints.
- Update development/privacy docs when runtime behavior changes.

V1.2 adds no new runtime dependency. `shared_preferences` remains used solely for application-local preference storage.

## Signing and stores

Mobile/desktop signing credentials, store tokens, certificates, and release secrets must never be committed. Use secure release-environment facilities.
