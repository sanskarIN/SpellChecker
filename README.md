# SpellChecker

[![CI](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

SpellChecker is a privacy-first, open-source Flutter spelling utility and writing assistant. It checks text locally, highlights possible spelling issues inside the editor, ranks correction suggestions, supports keyboard-first review, persistent personal vocabulary, replace-all, and undo-friendly correction workflows.

## Highlights

- Local spell checking: editor text is not sent to a remote spelling service.
- Explicit built-in language selection: English (US) and English (UK).
- Unicode-aware word tokenization and punctuation normalization.
- Per-language persisted personal dictionaries with V1 migration.
- Language-tagged detailed suggestion metadata.
- Optional local **Writing insights** with per-rule session switches.
- Public `WritingRule` plugin contract and deterministic `WritingAnalyzer`.
- Built-in repeated-word, sentence-capitalization, repeated-space, and repeated-punctuation rules.
- Stale-range-safe writing fixes integrated with **Undo correction**.
- Inline wavy underlines for checked spelling issues.
- Stronger visual treatment for the active spelling issue.
- Keyboard shortcuts: `Ctrl/⌘+Enter` to check, `F7` for next issue, `Shift+F7` for previous issue.
- Active issue synchronization between the editor selection and Results panel.
- Damerau-Levenshtein suggestion matching with frequency-aware tie breaking.
- Replace one occurrence with case preservation.
- Replace all checked occurrences of the same unknown word.
- Correction undo stack with an **Undo correction** control and snackbar **Undo** action.
- Stale source-offset protection before text mutation.
- Expanded bundled English vocabulary.
- Better regular contraction and possessive handling from known stems.
- Persistent device-local personal dictionary.
- Import personal words from SpellChecker JSON, JSON arrays, or plain word lists.
- Copy a versioned dictionary export to the clipboard.
- Session-only ignored-word support.
- Configurable 1–10 suggestions per issue, persisted on the device.
- Dedicated blank-input, clean-result, ready, and storage-warning states.
- Accessibility semantics and live-region announcements for important result states.
- Word, character, and sentence statistics.
- Responsive Material 3 editor UI with system light/dark theme support.
- Unit, persistence, codec, controller, and widget tests.
- GitHub Actions continuous integration and tagged web-release automation.
- Open-source contribution, security, privacy, accessibility, governance, support, and release documentation.

## Current release

`2.0.0+5`

Version 2.0 adds the Advanced Writing Foundation: an optional local writing-rule plugin API, four deterministic built-in writing rules, language-pack eligibility, explicit per-session rule switches, stale-range-safe rule fixes, and a Writing insights dialog that reuses the existing correction undo history. V1.3 language selection, Unicode tokenization, per-language vocabulary, and all V1.2 spelling/editor workflows remain intact.

## Language selection

Use the language selector above the editor to choose **English (US)** or **English (UK)**. The selection is stored locally and restored later. Changing language re-checks non-blank editor text using the new pack and starts a separate ignored-word/session state.

Saved personal vocabulary is isolated by language. A word saved in `en-US` is not automatically accepted in `en-GB`. Version-2 dictionary exports include the language ID so the application can prevent accidental cross-language imports.

SpellChecker 1.3 does not auto-detect language; explicit selection is intentional. See [Language packs](docs/LANGUAGE_PACKS.md).

## Writing insights

Select **Writing insights** from the app bar to run optional local writing rules against the current in-memory text. The dialog shows the current language, lets you enable/disable supported rules for this session, and displays deterministic findings.

Built-in V2.0 rules cover repeated words, sentence capitalization, repeated spaces, and repeated punctuation. They are intentionally lightweight and do not claim to be a full grammar parser.

A finding exposes **Apply safe fix** only when it has a deterministic replacement. Before mutation, SpellChecker verifies that the source range still contains the exact analysed text. Successful writing fixes enter the same bounded correction history as spelling fixes, so **Undo correction** restores the previous document.

See [Writing rules](docs/WRITING_RULES.md).

## Main workflow

1. Type or paste text into the editor.
2. Select **Check spelling** or press `Ctrl+Enter` / `⌘+Enter`.
3. Checked issues receive inline underlines and appear in the Results panel.
4. Use `F7` / **Next issue** or `Shift+F7` / **Previous issue** to move through issues. The active issue is selected in the editor and emphasized in Results.
5. Select a suggestion chip to replace one occurrence.
6. When a word occurs more than once, choose **Replace all…** to replace every matching checked occurrence with one suggestion.
7. Use snackbar **Undo** or **Undo correction** to restore the latest spelling correction. SpellChecker keeps a bounded in-memory correction history.
8. Select **Save word** to persist valid custom vocabulary on the current device.
9. Select **Ignore once** to suppress a word only for the current application session.
10. Open **Manage personal dictionary** to add/remove words, import/export vocabulary, clear saved words, or configure suggestions per issue.
11. Use **Clear ignored session words** to restore all temporary ignored-word checks without deleting saved personal words.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Run spelling check on Windows/Linux/web keyboard layouts |
| `⌘+Enter` | Run spelling check on macOS keyboard layouts |
| `F7` | Move to the next spelling issue |
| `Shift+F7` | Move to the previous spelling issue |

Issue navigation wraps from the final issue to the first and vice versa.

## Correction safety and undo

Spelling issues include source offsets from the most recent check. Before applying a correction, SpellChecker verifies that the text at those offsets still matches the issue. If text changed, it refreshes spelling results instead of mutating stale text.

Programmatic spelling corrections are stored in a bounded in-memory undo stack. **Replace all** is recorded as one correction, so one Undo restores the document state from before the bulk replacement. Normal manual typing clears the spelling-specific undo stack because the user has started a new editing history.

## Personal dictionary format

SpellChecker exports personal words as versioned JSON:

```json
{
  "version": 1,
  "words": [
    "flutter",
    "open-source",
    "writer's"
  ]
}
```

Imports also accept a JSON array or a newline/comma-separated word list. Imported words are normalized to lowercase, curly apostrophes are normalized to straight apostrophes, duplicates are removed, and invalid multi-word entries are rejected.

## Requirements

- Flutter stable
- Dart SDK `>=3.8.0 <4.0.0`
- A supported Flutter development environment

Check the local toolchain:

```bash
flutter doctor
flutter --version
dart --version
```

## Clone and run

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter run -d chrome
```

The repository includes Flutter web host files. The Dart/Flutter application code is platform-neutral; additional Flutter host runners can be generated with Flutter tooling when packaging for other supported targets.

## Quality checks

Run the same core validation used by CI:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Check formatting before committing:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Apply formatting with:

```bash
dart format lib test
```

## Project structure

```text
SpellChecker/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   └── pull_request_template.md
├── docs/
│   ├── ACCESSIBILITY.md
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
│   │   ├── personal_dictionary_codec.dart
│   │   ├── spell_checker_engine.dart
│   │   ├── spell_issue.dart
│   │   ├── text_correction.dart
│   │   └── text_statistics.dart
│   ├── data/
│   │   ├── english_dictionary.dart
│   │   ├── english_dictionary_extension.dart
│   │   └── english_word_frequencies.dart
│   ├── features/
│   │   └── editor/
│   │       ├── dictionary_manager_dialog.dart
│   │       ├── spell_check_editing_controller.dart
│   │       └── spell_checker_page.dart
│   └── storage/
│       └── dictionary_preferences.dart
├── test/
│   ├── dictionary_preferences_test.dart
│   ├── edit_distance_test.dart
│   ├── personal_dictionary_codec_test.dart
│   ├── spell_check_editing_controller_test.dart
│   ├── spell_checker_test.dart
│   ├── text_correction_test.dart
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

The application separates presentation, spelling logic, correction logic, data, and local persistence:

- `lib/features/editor/` contains the editor, inline-highlight controller, active issue/results workflow, and personal-dictionary manager.
- `lib/core/` contains reusable spelling, edit-distance, text-correction, import/export, issue-model, and statistics logic.
- `lib/data/` contains bundled dictionary and frequency-ranking data.
- `lib/storage/` owns device-local preferences used by the application UI.
- `lib/spell_checker.dart` is the public library entry point for reusable core functionality.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the complete design and state flows.

## Core API example

```dart
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine();
engine.replacePersonalDictionary(<String>{'flutter'});

final text = 'Helo Flutter';
final issues = engine.check(text, suggestionLimit: 3);

if (issues.isNotEmpty && issues.first.suggestions.isNotEmpty) {
  final corrected = TextCorrection.replaceOne(
    text,
    issues.first,
    issues.first.suggestions.first,
  );
  print(corrected.text);
}

final export = PersonalDictionaryCodec.encode(engine.personalDictionary);
print(export);
```

See [docs/API.md](docs/API.md) for supported public APIs and behavior.

## Privacy and storage

Spell checking remains local. The project contains no cloud spelling API, analytics SDK, advertising SDK, authentication system, or telemetry pipeline.

Editor text is not persisted by SpellChecker. Personal dictionary words and the suggestion-count preference are stored locally through `shared_preferences` so they can survive restarts. Ignored words remain in memory only. V1.2 correction undo snapshots are also memory-only and are discarded when the application session ends or when the user begins a new manual edit sequence. Import/export is user initiated and uses pasted text or the local clipboard.

See [docs/PRIVACY.md](docs/PRIVACY.md).

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [Language packs](docs/LANGUAGE_PACKS.md)
- [Writing rules](docs/WRITING_RULES.md)
- [API reference](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Development setup](docs/DEVELOPMENT.md)
- [Testing](docs/TESTING.md)
- [Accessibility](docs/ACCESSIBILITY.md)
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

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Keep spelling/correction logic independent from UI code, include regression tests for behavior changes, preserve keyboard and accessibility behavior, preserve privacy-first local behavior, and update documentation for user-visible changes.

## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## License

SpellChecker is released under the [MIT License](LICENSE).

Copyright © 2026 Sanskar.
