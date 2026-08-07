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

Confirm that your Dart SDK satisfies the range in `pubspec.yaml`.

## Analyzer reports formatting or lint issues

Run:

```bash
dart format lib test
flutter analyze
```

## Tests fail after a dictionary change

Check whether the changed dictionary now considers a test word correct or changes suggestion ordering. Update behavior intentionally and keep regression coverage meaningful rather than simply weakening assertions.

## A correct word is reported as misspelled

The bundled dictionary is intentionally limited in version 1.0.

Options:

- Add the word to the session dictionary.
- Ignore the word for the current session.
- Contribute a broadly useful dictionary entry.

## No suggestions are shown

Suggestions are filtered by a maximum edit distance based on word length. A very different unknown word may have no close candidate in the bundled dictionary.

## A replacement does not happen

SpellChecker validates the issue offsets against the current editor text. If text changed after the check, it performs a fresh check instead of applying a potentially stale replacement.

## Web build fails

Run:

```bash
flutter doctor
flutter clean
flutter pub get
flutter build web --release
```

If the error comes from a newer or older Flutter web template expectation, regenerate only the local web host with the installed stable Flutter version and compare the generated host files before committing changes.

## CI fails but local tests pass

Run the exact CI commands from [TESTING.md](TESTING.md). Also compare your Flutter stable version with the version selected by the GitHub Actions Flutter setup step.
