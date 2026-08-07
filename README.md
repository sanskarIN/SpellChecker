# SpellChecker

[![CI](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

SpellChecker is a privacy-first, open-source Flutter spelling utility and writing assistant. It checks text locally, identifies unknown words, ranks correction suggestions, lets users replace mistakes, and supports temporary personal and ignored-word dictionaries for the current session.

## Highlights

- Local spell checking: typed text is not sent to a remote spelling service.
- Ranked spelling suggestions using Damerau-Levenshtein edit distance.
- Case-insensitive matching with case-preserving replacements.
- Personal dictionary for session-specific vocabulary.
- Ignore-word support for temporary exceptions.
- Word, character, and sentence statistics.
- Responsive Material 3 editor UI.
- System light/dark theme support.
- Web entry point committed in the repository.
- Unit and widget tests.
- GitHub Actions analysis, formatting, and test checks.
- Open-source contribution, security, governance, support, and release documentation.

## Current release

`1.0.0+1`

Version 1.0 provides a complete local spelling-check workflow and the project foundation needed for future dictionary expansion, persistent preferences, and additional language packs.

## Screens and workflow

1. Type or paste text into the editor.
2. Select **Check spelling**.
3. Review unknown words in the Results panel.
4. Choose a suggestion to replace a word, add the word to the session dictionary, or ignore it for the session.
5. Use the reset action in the app bar to clear session dictionary entries and ignored words.

## Requirements

- Flutter stable
- Dart SDK `>=3.4.0 <4.0.0`
- A supported Flutter development environment

Check your environment:

```bash
flutter doctor
flutter --version
```

## Clone and run

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter run -d chrome
```

The repository includes the Flutter web host files. The Dart/Flutter application code is platform-neutral and can be used with other Flutter host platforms after generating the desired platform runner with Flutter tooling.

## Quality checks

Run the same checks used by CI:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Format code locally with:

```bash
dart format lib test
```

## Project structure

```text
SpellChecker/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   └── pull_request_template.md
├── docs/
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   ├── PRIVACY.md
│   ├── RELEASING.md
│   ├── ROADMAP.md
│   ├── TESTING.md
│   ├── TROUBLESHOOTING.md
│   └── USER_GUIDE.md
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── spell_checker.dart
│   ├── core/
│   │   ├── edit_distance.dart
│   │   ├── spell_checker_engine.dart
│   │   ├── spell_issue.dart
│   │   └── text_statistics.dart
│   ├── data/
│   │   └── english_dictionary.dart
│   └── features/
│       └── editor/
│           └── spell_checker_page.dart
├── test/
│   ├── edit_distance_test.dart
│   ├── spell_checker_test.dart
│   ├── text_statistics_test.dart
│   └── widget_test.dart
├── web/
│   ├── index.html
│   └── manifest.json
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── GOVERNANCE.md
├── LICENSE
├── SECURITY.md
├── SUPPORT.md
├── analysis_options.yaml
└── pubspec.yaml
```

## Architecture

The application separates presentation from spelling logic:

- `lib/features/editor/` contains the user interface and interaction workflow.
- `lib/core/` contains reusable spelling, distance, issue-model, and text-statistics logic.
- `lib/data/` contains bundled dictionary data.
- `lib/spell_checker.dart` is the public library entry point for core functionality.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the full design and data flow.

## Core API example

```dart
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine();
final issues = engine.check('Helo world');

for (final issue in issues) {
  print(issue.word);
  print(issue.suggestions);
}
```

See [docs/API.md](docs/API.md) for supported public APIs and behavior.

## Privacy

Spell checking is local. The application does not contain analytics, advertising SDKs, cloud spelling APIs, authentication, or telemetry. Session dictionary entries remain in memory only and are cleared when the app process ends or the user resets the session.

See [docs/PRIVACY.md](docs/PRIVACY.md).

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [API reference](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Development setup](docs/DEVELOPMENT.md)
- [Testing](docs/TESTING.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Roadmap](docs/ROADMAP.md)
- [Release procedure](docs/RELEASING.md)
- [Privacy](docs/PRIVACY.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Security policy](SECURITY.md)
- [Governance](GOVERNANCE.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)

## Contributing

Contributions are welcome. Before opening a pull request, read [CONTRIBUTING.md](CONTRIBUTING.md). Keep spelling logic testable and independent from UI code, include tests for behavior changes, and update documentation for user-visible changes.

## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## License

SpellChecker is released under the [MIT License](LICENSE).

Copyright © 2026 Sanskar.
