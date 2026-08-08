# Testing

## Test strategy

SpellChecker uses deterministic unit tests for spelling/correction algorithms, codec and persistence tests for dictionary durability, controller tests for inline rendering state, and Flutter widget tests for the complete editor workflow.

The suite is intentionally layered:

- Core spelling/correction behavior can run without a widget tree.
- Persistence tests never touch real machine/user preferences.
- Inline-controller tests verify rendering state independently from the full editor page.
- Widget tests verify keyboard and user interaction contracts.

## Run all tests

```bash
flutter test --reporter expanded
```

Short reporter:

```bash
flutter test
```

## Focused tests

```bash
flutter test test/spell_checker_test.dart
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
flutter test test/widget_test.dart
```

## Writing-rules coverage

V2.0 tests cover:

- Each built-in deterministic rule.
- Adjacent-word boundary behavior.
- Sentence-start capitalization.
- Space/punctuation replacement metadata.
- Language eligibility for both built-in English packs.
- Analyzer issue ordering/counts.
- Per-rule enable/disable filtering.
- Current versus stale writing corrections.
- Writing insights dialog findings.
- Safe writing fix integration with editor Undo correction.
- Session rule toggling in the real widget tree.

Rule tests should use synthetic text and assert the intended public contract rather than incidental widget positions.

## Language architecture coverage

V1.3 adds tests for:

- Built-in registry IDs/default behavior.
- Unicode tokenization and punctuation normalization.
- US/UK variant acceptance.
- Language-tagged issues and detailed suggestions.
- Personal/ignored in-memory isolation between engines.
- Version-2 language-tagged dictionary documents.
- Legacy version-1 dictionary compatibility.
- Selected-language persistence/fallback.
- Per-language personal-word namespaces and V1 migration.
- UI language switching/re-check behavior.
- Saved-word isolation across selector changes.

Language tests must prove that adding state to pack A does not change pack B.

## Core engine coverage

`test/spell_checker_test.dart` covers:

- Case-insensitive dictionary matching.
- Unknown-word detection.
- Source offsets.
- Close suggestion generation.
- Lower edit-distance ordering.
- Frequency-rank tie breaking.
- Suggestion-count limits.
- Supported contraction and possessive recognition from known stems.
- Suffix-preserving suggestions.
- Personal dictionary add behavior.
- Personal dictionary replacement/removal.
- Session-only ignored words.
- Clearing ignored words independently from personal words.
- Full in-memory session reset.
- Apostrophe tokenization.
- Expanded bundled dictionary coverage.

Ranking tests should assert exact order only when ordering itself is the contract.

## Text correction coverage

`test/text_correction_test.dart` protects V1.2 correction safety:

- Single replacement.
- Case-preserving title-case replacement.
- Refusal to apply stale issue offsets.
- Replace-all across repeated checked occurrences.
- End-to-start mutation behavior.
- Unrelated issue preservation.
- Upper/title/lower case matching.
- Replacement counts and changed/unchanged result state.

When correction logic changes, add tests at this layer before changing widget expectations.

## Inline editing controller coverage

`test/spell_check_editing_controller_test.dart` covers:

- Underline styling for checked issues.
- Stronger background style for active issue.
- Active issue index state.
- Clearing checked issue/highlight state.
- Building spans from current text safely.

Future edge-case tests should include stale/invalid ranges and overlapping ranges if controller behavior changes there.

## Personal dictionary codec coverage

`test/personal_dictionary_codec_test.dart` covers:

- Versioned JSON export.
- Normalized deterministic sorting.
- SpellChecker JSON-object import.
- JSON-array import.
- Newline/comma-separated plain-text import.
- Curly-apostrophe normalization.
- Invalid-entry rejection.
- Unsupported-format-version rejection.

## Persistence coverage

`test/dictionary_preferences_test.dart` covers:

- Saving/restoring normalized personal words.
- Persisting suggestion-count preferences.
- Clamping suggestion counts to 1–10.
- Clearing saved personal words.

Tests initialize isolated in-memory preferences:

```dart
SharedPreferences.setMockInitialValues(<String, Object>{});
```

Never read/write a developer machine's real preferences in tests.

## Edit-distance coverage

`test/edit_distance_test.dart` covers:

- Equal strings.
- Insertions.
- Deletions.
- Adjacent transposition.

## Statistics coverage

`test/text_statistics_test.dart` covers:

- Word count.
- Character count.
- Sentence count.
- Blank input.

## Widget coverage

`test/widget_test.dart` now verifies the main V1.2 workflows.

### Basic spelling workflow

1. Launch with mocked preferences.
2. Enter text.
3. Check spelling.
4. Verify an issue, suggestion controls, and active issue indicator.

### Blank-input state

1. Launch with blank editor.
2. Run a spelling check.
3. Verify **Nothing to check**.

### Keyboard issue navigation

1. Enter text with two synthetic unknown words.
2. Check spelling.
3. Verify **Issue 1 of 2**.
4. Send `F7`.
5. Verify **Issue 2 of 2**.

Future shortcut tests should also cover `Shift+F7` and Ctrl/Command+Enter when platform/key-event behavior is deterministic in Flutter test.

### Replace-all and undo

1. Enter repeated unknown text.
2. Check spelling.
3. Verify repeated occurrence count and **Replace all…**.
4. Scroll the control into the test viewport when necessary.
5. Choose a replacement menu item.
6. Verify issues are removed when the chosen suggestion fixes them.
7. Use snackbar **Undo**.
8. Verify repeated issue state is restored.

The test intentionally does not force the restored active issue to be issue 1. Undo restores the previous `TextEditingValue`, including caret position; active issue selection can therefore legitimately favor a later issue near the restored caret.

### Persistent Save word workflow

1. Launch with empty mocked preferences.
2. Enter an unknown synthetic word.
3. Check spelling.
4. Scroll **Save word** into view when required by the test viewport.
5. Select **Save word**.
6. Verify the issue disappears.
7. Verify mocked `SharedPreferences` contains the normalized word.

### Dictionary manager restore workflow

1. Seed mocked preferences with a saved word and suggestion-count preference.
2. Launch the app.
3. Wait for asynchronous restoration.
4. Verify the stored suggestion count.
5. Open **Manage personal dictionary**.
6. Verify the saved word appears.

## Widget test viewport rules

Flutter test uses a bounded default surface. V1.2 issue cards contain enough content that actions can be built in the scrollable list but outside the visible hit-test region.

When a real user would scroll to a control, tests should do the same:

```dart
final control = find.text('Replace all…').first;
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

Do not change production layout solely to make an offscreen test tap succeed.

## Keyboard test guidance

Use `tester.sendKeyEvent` for simple shortcut contracts such as F7. After key events, call `pumpAndSettle` before checking UI state.

Do not assert focus details more strictly than the user-visible contract unless focus itself is the behavior being protected.

## Semantics testing

V1.2 adds semantic containers/live regions but the current suite primarily verifies behavior and controller state. New accessibility regressions should add `SemanticsTester` or targeted semantic-node assertions when stable under the supported Flutter version.

Key contracts to protect:

- Issue card selected state.
- Result-count/empty-state announcements.
- Storage-warning live region.
- Editor semantic label.
- Icon controls retaining meaningful tooltips/labels.

## CI checks

GitHub Actions runs:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Formatting should also be checked locally:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Apply formatting:

```bash
dart format lib test
```

## Analyzer policy

Analyzer errors must be fixed in source/tests. Do not suppress a lint merely to make CI green unless the rule is genuinely inappropriate for the project and the configuration change is documented.

## Regression-test policy

Every deterministic bug fix should include a regression test that fails before the fix and passes after it.

Tests should protect user-visible/public contracts instead of accidental implementation details. Examples:

- Suggestion candidate existence vs. exact ranking order.
- Undo restoring checked content vs. forcing one active issue index.
- A control being reachable in a scrollable list vs. assuming it is inside a 600px test viewport.

## Persistence failure behavior

The editor's **Save word** flow temporarily updates the engine, then writes the complete personal set. If storage fails, it restores the previous set and marks storage unavailable.

Dictionary-manager changes persist before committing local dialog state.

Session spelling must remain usable when local preference storage is unavailable.

## Correction-history privacy

Correction undo snapshots can contain editor text. They must remain in memory only. Tests should not write those snapshots to files/preferences, logs, fixtures, or failure messages beyond minimal synthetic samples.

## Test data privacy

Use synthetic text in tests. Do not add private documents, credentials, account identifiers, personal communications, or sensitive dictionary exports to the repository.
