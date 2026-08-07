# SpellChecker

SpellChecker is a lightweight, open-source Flutter writing utility that checks text for possible spelling mistakes.

## Current status

Version 1.0 foundation is under development. The project currently includes a Flutter interface, a small built-in English dictionary, a reusable spell-checking engine, automated tests, and continuous integration.

## Features

- Write or paste text into a simple editor.
- Detect words that are not present in the current dictionary.
- Case-insensitive checking.
- Unit-tested spell-checking engine separated from the UI.
- Flutter support as the basis for Android, iOS, web, and desktop builds.

## Getting started

### Requirements

- Flutter stable
- Dart SDK compatible with the version declared in `pubspec.yaml`

### Run locally

```bash
flutter pub get
flutter run
```

### Quality checks

```bash
flutter analyze
flutter test
```

## Project structure

```text
lib/
  main.dart            Flutter application UI
  spell_checker.dart   Core spell-checking engine
test/
  spell_checker_test.dart
.github/workflows/
  ci.yml               Automated analysis and tests
```

## Roadmap

### v1.0 — Foundation

- [x] Open-source license
- [x] Flutter/Dart ignore rules
- [x] Core spell-checking engine
- [x] Initial editor interface
- [x] Unit tests
- [x] CI
- [x] Contributor documentation
- [ ] Expand dictionary coverage
- [ ] Add suggestions for misspelled words
- [ ] Add custom user dictionary
- [ ] Improve accessibility and keyboard support

### v1.1 — Suggestions and dictionaries

Planned work includes ranked spelling suggestions, importable dictionaries, personal words, and improved text highlighting.

### v1.2 — Writing experience

Planned work includes richer editor feedback, statistics, additional language support, and platform polish.

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. For security-sensitive reports, follow [SECURITY.md](SECURITY.md).

## License

SpellChecker is released under the [MIT License](LICENSE).
