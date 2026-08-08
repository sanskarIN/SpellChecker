# Troubleshooting

## `flutter` command not found

Install Flutter and ensure its `bin` directory is on your `PATH`.

```bash
flutter doctor
```

## Dependencies fail to resolve

Run:

```bash
flutter clean
flutter pub get
```

Confirm your Dart SDK satisfies `pubspec.yaml` and you are using Flutter stable. SpellChecker V1.2 adds no runtime dependency beyond the Flutter SDK and V1.1 `shared_preferences` dependency.

## Analyzer reports formatting or lint issues

Run:

```bash
dart format lib test
flutter analyze
```

CI treats analyzer failures as blocking. Fix source/test issues rather than suppressing lints only to make the workflow green.

## Tests fail only when tapping an issue action

V1.2 issue cards are taller because they can contain suggestions, occurrence counts, replace-all controls, and save/ignore actions. Flutter widget tests use a bounded default test surface, so a control can exist in the scrollable widget tree while being outside the hit-test viewport.

For a test that represents real scrolling behavior:

```dart
final control = find.text('Save word');
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

Do not shrink production UI solely to make an offscreen test tap work.

## A correct word is reported as misspelled

The bundled dictionary is curated rather than a complete linguistic database.

Options:

- **Save word** for persistent legitimate vocabulary.
- **Ignore once** for a temporary exception.
- Add the word in **Manage personal dictionary**.
- Contribute a broadly useful dictionary entry.

## Writing insights reports something intentional

Writing rules are optional deterministic heuristics. Disable that rule in the Writing insights dialog for the current session. Repeated spaces/punctuation, for example, can be intentional in specialized/informal text.

## Apply safe fix refuses to change text

The document changed after the finding was calculated, so the stored source range is stale. SpellChecker refuses to mutate the wrong text. Close/reopen Writing insights to refresh findings.

## Writing rule switches reset after restart

Expected in V2.0. Rule enablement is session-only and is not part of the persisted preferences yet.

## US/UK spelling changes after switching language

This is expected. `en-US` and `en-GB` deliberately differ for common variants such as `color`/`colour`, `center`/`centre`, and `theater`/`theatre`. Switching language invalidates old issues and re-checks the current text.

## A saved word exists in one language but not another

Expected. Personal dictionaries are isolated by language. Save/import the word separately for the intended pack.

## A version-2 dictionary import asks me to switch language

Version-2 exports include a language ID. SpellChecker prevents silently merging a tagged export into a different selected pack. Switch to the language named by the export, then import again.

Version-1/JSON-array/plain-list imports have no language metadata and are interpreted using the currently selected language.

## Inline underlines disappear when I type

This is expected. Inline issue ranges belong to the exact text snapshot that was checked. Manual text changes invalidate those ranges, so SpellChecker clears old highlights/results immediately.

Run **Check spelling** again (or press `Ctrl+Enter` / `⌘+Enter`) to create fresh issue ranges.

## An inline highlight looks missing after a check

SpellChecker validates every issue range before styling it. A stale, invalid, overlapping, or mismatching range is skipped rather than causing a bad highlight or exception.

If you can reproduce a missing current issue without editing after the check, file a bug with minimal synthetic text.

## F7 does not move to an issue

Check:

1. Run a spelling check first, or enter non-blank text and press F7 so the page can attempt a check.
2. Confirm the current text actually has unknown words.
3. Make sure your browser/OS has not captured F7 for another system command.
4. Try the visible previous/next issue buttons in the app bar or Results header.

`F7` moves forward; `Shift+F7` moves backward. Navigation wraps at both ends.

## Ctrl+Enter / Command+Enter does not check

Try the visible **Check spelling** button first.

If the button works but the shortcut does not, your platform/browser may intercept that key combination before Flutter receives it. Report the platform/browser and exact key combination with synthetic text.

## The active issue changed after Undo

Undo restores the previous `TextEditingValue`, including its caret/selection state, and then runs a fresh spelling check. SpellChecker selects an issue near the restored caret.

Therefore the restored active issue is not guaranteed to be issue 1. The important undo contract is that the corrected document state is restored and fresh checked issues are rebuilt.

## Replace all is not shown

**Replace all…** appears when:

- The current checked issue word appears more than once (case-insensitively) in the current checked issue list.
- The issue has at least one suggestion.

If a repeated text occurrence is spelled correctly or was not part of the checked issue list, it is not included.

## Replace all changed fewer words than expected

Replace-all deliberately mutates only still-current checked issue ranges matching the selected source word.

It does not perform an unrestricted find/replace. Stale ranges are skipped for safety. Re-run the spelling check and try again if the document changed after the previous check.

## A replacement does not happen

SpellChecker validates source offsets against current text. If the checked substring no longer equals the issue word, the editor refreshes spelling results instead of applying a stale edit.

This is expected safety behavior.

## Undo correction is disabled

The spelling-specific correction stack contains only programmatic spelling corrections.

It is cleared when:

- The user manually edits text.
- The editor is cleared.
- The application session ends.

It is not a full document history system.

## Snackbar Undo disappeared

The snackbar is temporary, but **Undo correction** remains available below the editor while the correction stack is non-empty.

If manual text was entered after the correction, the spelling-specific stack is intentionally cleared.

## Storage warning appears

If SpellChecker cannot load or write local preferences, it shows a warning that saved dictionary/preferences may not persist.

Session spelling still works.

Possible causes:

- Browser/profile storage restrictions.
- Private/incognito mode policies.
- Platform plugin/storage unavailability.
- App/browser data restrictions.

The warning does not indicate editor text was sent anywhere.

## A saved personal word disappears after restart

Check:

1. You selected **Save word**, not **Ignore once**.
2. The personal-dictionary badge/count increased.
3. **Manage personal dictionary** lists the word.
4. Local application/browser storage is allowed.
5. Private/incognito mode, profile reset, app-data clearing, or uninstall did not erase preferences.

SpellChecker stores personal words through `shared_preferences`; it does not cloud-sync them.

Use **Copy export** before clearing local data if you need a portable backup.

## Ignored words return after restart

Expected. **Ignore once** is session-only.

Use **Save word** for vocabulary that should survive restarts.

## Import is rejected

Accepted forms:

- SpellChecker JSON object with `version` and `words`.
- JSON array of words.
- Plain text separated by line breaks/commas.

Entries must contain letters with optional internal apostrophes/hyphens. Multi-word phrases, numbers, malformed entries, and unsupported versions are rejected.

```json
{
  "version": 1,
  "words": ["flutter", "open-source", "writer's"]
}
```

## Export does not appear anywhere

**Copy export** writes JSON to the local clipboard. It does not create a file or upload data.

Paste into a text editor or another SpellChecker import dialog to verify it. Clipboard behavior can be affected by platform/browser permissions.

## Suggestion count is not what I expected

Open **Manage personal dictionary** and check **Suggestions per spelling issue**.

Supported values are 1–10 and persist locally. Out-of-range stored values are normalized to the supported range.

## Suggestion ordering changed

Candidates are ranked by:

1. Edit distance.
2. First-character agreement.
3. Approximate frequency rank.
4. Candidate length.
5. Alphabetical order.

Adding dictionary/frequency data can change tie ordering without changing edit-distance behavior.

## A possessive or contraction is reported unexpectedly

Supported regular apostrophe suffixes include `'s`, `'re`, `'ve`, `'ll`, `'d`, `'m`, and `n't` when the stem is known.

Irregular forms may require direct dictionary coverage. Curly apostrophes are normalized for dictionary comparison.

## No suggestions are shown

Suggestions are bounded by edit-distance thresholds. A very different unknown word may have no close candidate.

Also verify the persisted suggestion-count setting; the minimum supported value is 1.

## Personal-dictionary storage reports an error

SpellChecker does not claim persistence success when writes fail. The engine/editor still works in session mode, but saved-word/preference operations may fail until storage is available.

For tests, use mocked preferences as described in [TESTING.md](TESTING.md).

## Web build fails

```bash
flutter doctor
flutter clean
flutter pub get
flutter build web --release
```

If a Flutter web template expectation is involved, regenerate only a local host with your stable Flutter version and review diffs before committing.

## CI fails but local tests pass

Run the exact CI commands:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Compare your Flutter/Dart versions with the workflow's **Show tool versions** step.

Widget tests use mocked preferences and may need `ensureVisible` for scrollable V1.2 issue actions.

## Clearing text did not clear my dictionary

Expected. **Clear** removes editor text, statistics, checked highlights/results, and spelling-correction undo history.

It does not clear saved personal words, suggestion preferences, or session ignored words. Manage those through their dedicated controls.
