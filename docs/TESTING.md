# Testing

## Test strategy

SpellChecker uses focused unit tests for core algorithms and widget tests for important UI workflows.

## Run all tests

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
- Unknown word detection.
- Source offsets.
- Ranked suggestions.
- Personal dictionary behavior.
- Ignore behavior.
- Session reset behavior.
- Apostrophe tokenization.

## Edit distance coverage

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

`test/widget_test.dart` verifies the primary user path:

1. Launch app.
2. Enter text.
3. Check spelling.
4. See an unknown word.
5. See a correction suggestion.

## CI checks

The CI workflow runs:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Formatting should also be checked locally before a pull request:

```bash
dart format --output=none --set-exit-if-changed lib test
```

## Regression tests

Every bug fix should include a test that fails before the fix and passes after it whenever the behavior can be tested deterministically.

## Test data privacy

Use synthetic text in tests. Do not add real private documents, credentials, or personal communications to the repository.
