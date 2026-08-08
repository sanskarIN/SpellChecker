# Troubleshooting

## `flutter` command not found

Install Flutter and ensure its `bin` directory is on your `PATH`.

Then run:

```bash
flutter doctor
```

## Dependencies fail to resolve

Run:

```bash
flutter clean
flutter pub get
```

Confirm that your Dart SDK satisfies the range in `pubspec.yaml` and that you are using a supported Flutter stable release.

SpellChecker 1.1 depends on `shared_preferences` for local personal-dictionary storage. If dependency resolution fails, inspect the solver output before changing version constraints.

## Analyzer reports formatting or lint issues

Run:

```bash
dart format lib test
flutter analyze
```

CI treats analyzer failures as blocking. Fix the reported source/test issue rather than suppressing a lint only to make the workflow green.

## Tests fail after a dictionary change

A new bundled word can change two behaviors:

- A test word may become accepted instead of reported as unknown.
- A suggestion list/order may change because the candidate set or frequency tie-break changes.

Keep tests aligned with the behavior they actually intend to protect. Use exact-order assertions only for ranking rules; use candidate-existence assertions when any valid close candidate order is acceptable.

## A correct word is reported as misspelled

The V1.1 bundled dictionary is larger than V1.0 but is still not a complete linguistic database.

Options:

- Select **Save word** to persist legitimate vocabulary on this device/profile.
- Select **Ignore once** for a temporary session exception.
- Add the word manually in **Manage personal dictionary**.
- Contribute a broadly useful curated dictionary entry.

## A saved personal word disappears after restart

Check the following:

1. Make sure you selected **Save word**, not **Ignore once**.
2. Confirm the personal-dictionary badge/count increases.
3. Open **Manage personal dictionary** and verify the word is listed.
4. Ensure the browser/profile or platform allows local application preferences.
5. Check whether private/incognito browsing, profile reset, app-data clearing, or uninstall/reinstall removed local preferences.

SpellChecker stores personal words through `shared_preferences`; it does not synchronize them to a cloud account.

Use **Copy export** before clearing browser/application data if you want a portable backup.

## Ignored words return after restart

This is expected. **Ignore once** is session-only by design.

Use **Save word** for vocabulary that should survive restarts.

## Import is rejected

Accepted import formats are:

- SpellChecker JSON object with `version` and `words`.
- JSON array of words.
- Plain text separated by line breaks and/or commas.

Each word must contain letters with optional internal apostrophes or hyphens. Multi-word phrases, numbers, and malformed entries are rejected.

For example, this is valid:

```json
{
  "version": 1,
  "words": ["flutter", "open-source", "writer's"]
}
```

An unsupported future/unknown format version is rejected intentionally rather than guessed.

## Export does not appear anywhere

**Copy export** writes the versioned JSON document to the local clipboard; it does not create a file or upload data.

Paste the clipboard contents into a text file, notes application, or another SpellChecker import dialog to verify the export.

Clipboard access can be affected by browser/platform permission policies.

## Suggestion count is not what I expected

Open **Manage personal dictionary** and check **Suggestions per spelling issue**.

Supported values are 1–10. The preference is stored locally and restored on startup.

If stored data contains a value outside that range, SpellChecker normalizes it to the nearest supported value.

## Suggestion ordering changed

V1.1 ranks candidates by:

1. Edit distance.
2. First-character agreement.
3. Approximate frequency rank.
4. Candidate length.
5. Alphabetical order.

Adding dictionary words or frequency ranks can therefore change tie ordering without changing the underlying edit-distance algorithm.

## A possessive or contraction is reported unexpectedly

V1.1 recognizes several regular apostrophe suffixes from known stems, including `'s`, `'re`, `'ve`, `'ll`, `'d`, `'m`, and `n't`.

If the stem is not known, the whole form can still be reported. Irregular contractions may require direct dictionary coverage.

Curly apostrophes are normalized to straight apostrophes for dictionary comparison.

## No suggestions are shown

Suggestions are filtered by a maximum edit distance based on target length. A very different unknown word may have no close candidate in the bundled or personal dictionary.

Also check the configured suggestion count. A value of 1 still shows at most one candidate; the UI does not support zero as a persisted preference.

## A replacement does not happen

SpellChecker validates issue offsets against the current editor text. If text changed after the check, the editor runs a fresh check instead of applying a potentially stale replacement.

## Personal-dictionary storage reports an error

The editor is designed not to claim persistence success when the underlying preference write fails.

Possible causes include platform storage restrictions or an unavailable plugin backend. The spell-checking engine itself still works locally; persistent personal-word operations may fail until storage is available.

For development/tests, use mocked preferences as described in [TESTING.md](TESTING.md).

## Web build fails

Run:

```bash
flutter doctor
flutter clean
flutter pub get
flutter build web --release
```

If the error comes from a Flutter web template expectation, regenerate only the local web host with the installed stable Flutter version and compare generated files before committing changes.

## CI fails but local tests pass

Run the exact CI commands:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Also compare your Flutter stable/Dart versions with the versions printed by the GitHub Actions **Show tool versions** step.

Persistence/widget tests use mocked `SharedPreferences`; if a new test depends on real local storage, refactor it so CI remains deterministic.

## Clearing text did not clear my dictionary

This is expected. **Clear** only clears editor content/results/statistics.

Saved personal words and suggestion preferences are separate application settings. Manage them through **Manage personal dictionary**.

Temporary ignored words are cleared through the dedicated ignored-word action or when the application session ends.
