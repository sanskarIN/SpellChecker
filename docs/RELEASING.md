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

Current V2.1 release:

```text
2.1.0+6
```

Increase the semantic version for user-visible releases and build number for packaging iterations as appropriate.

# Persistent-data compatibility

V2.1 persists:

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
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build web --release
```

Verify printed Flutter/Dart versions satisfy `pubspec.yaml`.

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
git tag -a v2.1.0 -m "SpellChecker v2.1.0"
git push origin v2.1.0
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
3. Highlight V2.1 persisted per-language rule choices, batch safe fixes, one-step batch undo, and Writing insights shortcut.
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

V2.1 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.

# Signing and stores

Never commit:

- Signing certificates.
- Store tokens.
- API credentials.
- Service-account keys.
- Release secrets.

Use secure facilities of the release/build platform.
