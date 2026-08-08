# Testing

## Test strategy

SpellChecker uses deterministic unit tests for spelling algorithms, codec and persistence tests for dictionary durability, and Flutter widget tests for the user-visible editor workflow.

The test suite is organized so core spelling behavior does not require a widget tree and persistence behavior does not require real device storage.

## Run all tests

```bash
flutter test --reporter expanded
```

The shorter default reporter is also useful locally:

```bash
flutter test
```

## Run one file

```bash
flutter test test/spell_checker_test.dart
```

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
- Personal dictionary replacement and removal.
- Session-only ignored words.
- Clearing ignored words independently from personal words.
- Full in-memory session reset.
- Apostrophe tokenization.
- Expanded bundled dictionary coverage.

Ranking tests should assert exact order only when the ordering rule itself is under test. Candidate-existence tests should use `contains` when several equally valid close words can be reordered by future frequency-data improvements.

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

Codec tests protect the user-transfer format. Changing an existing format version requires migration/compatibility consideration rather than silently changing those tests.

## Persistence coverage

`test/dictionary_preferences_test.dart` covers:

- Saving and restoring normalized personal words.
- Persisting suggestion-count preferences.
- Clamping suggestion counts to the supported 1–10 range.
- Clearing saved personal words.

Tests initialize isolated in-memory preference data with:

```dart
SharedPreferences.setMockInitialValues(<String, Object>{});
```

Do not let persistence tests read or write a developer machine's real preferences.

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

`test/widget_test.dart` currently verifies three major workflows.

### Spelling workflow

1. Launch the app with mocked preferences.
2. Enter text.
3. Check spelling.
4. See an unknown word.
5. See a correction suggestion.

### Persistent Save word workflow

1. Launch the app with empty mocked preferences.
2. Enter an unknown synthetic word.
3. Check spelling.
4. Select **Save word**.
5. Verify the issue disappears.
6. Read mocked `SharedPreferences` and verify the normalized word was stored.

### Dictionary manager restore workflow

1. Seed mocked preferences with a saved word and suggestion-count preference.
2. Launch the app.
3. Wait for asynchronous preference restoration.
4. Verify the suggestion-count chip reflects the stored value.
5. Open **Manage personal dictionary**.
6. Verify the saved word appears.

Widget tests that use the persistence layer must call `SharedPreferences.setMockInitialValues` before pumping `SpellCheckerApp`.

## CI checks

The GitHub Actions CI workflow runs:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Formatting should also be checked locally before a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Apply formatting with:

```bash
dart format lib test
```

## Analyzer policy

Analyzer errors must be fixed in source/tests. Do not suppress a lint merely to make CI green unless the rule is demonstrably inappropriate for the whole project and the configuration change is documented.

Newer Dart lint sets can report style findings such as wildcard-parameter or collection-emptiness rules. Prefer updating code to current idioms when doing so does not change behavior.

## Regression tests

Every deterministic bug fix should include a regression test that fails before the fix and passes after it.

Good regression tests document the intended public behavior rather than incidental implementation details. For suggestion ranking, distinguish between:

- “this candidate must be available,” and
- “this candidate must rank before that candidate.”

Only the second requires an exact order assertion.

## Persistence failure behavior

The editor's **Save word** flow temporarily updates the engine, then writes the complete personal set. If storage fails, it restores the previous engine set. Tests for future storage adapters should preserve this no-false-success behavior.

Dictionary-manager mutations write through the provided persistence callback before committing the local dialog set.

## Test data privacy

Use synthetic text in tests. Do not add real private documents, credentials, account identifiers, or personal communications to the repository.
