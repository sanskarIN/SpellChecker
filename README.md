# SpellChecker

[![CI](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

SpellChecker is a privacy-first, open-source Flutter spelling utility and writing assistant. It checks text locally, highlights spelling issues inside the editor, ranks correction suggestions, supports explicit language packs, persistent per-language vocabulary and writing-rule preferences, keyboard-first review, batch-safe corrections, and undo-friendly editing workflows.

## Highlights

- Local spell checking and writing analysis: editor text is not sent to a remote spelling or grammar service.
- Explicit built-in language selection: English (US) and English (UK).
- Unicode-aware word tokenization and punctuation normalization.
- Per-language persisted personal dictionaries with legacy V1 migration.
- Per-language persisted writing-rule preferences with backward-compatible defaults.
- Language-tagged detailed suggestion metadata.
- Optional local **Writing insights** with configurable deterministic rules.
- Public `WritingRule` plugin contract and deterministic `WritingAnalyzer`.
- Built-in repeated-word, sentence-capitalization, repeated-space, and repeated-punctuation rules.
- **Apply all safe fixes** for non-overlapping current writing findings.
- Stale-range-safe individual and batch writing corrections.
- One-step undo for a complete writing-fix batch.
- `Ctrl/⌘+Shift+Enter` opens Writing insights.
- Inline wavy underlines for checked spelling issues.
- Stronger visual treatment for the active spelling issue.
- `Ctrl/⌘+Enter` spelling check, `F7` next issue, and `Shift+F7` previous issue.
- Active issue synchronization between editor selection and the Results panel.
- Damerau-Levenshtein suggestion matching with frequency-aware tie breaking.
- Replace one occurrence with case preservation.
- Replace all checked occurrences of the same unknown word.
- Bounded in-memory correction undo history shared by spelling and writing fixes.
- Stale source-offset protection before every automatic text mutation.
- Expanded bundled English vocabulary.
- Better regular contraction and possessive handling from known stems.
- Import/export of language-aware personal dictionaries.
- Session-only ignored-word support.
- Configurable 1–10 suggestions per issue, persisted locally.
- Dedicated blank-input, clean-result, ready, and storage-warning states.
- Accessibility semantics and live-region announcements for important result states.
- Word, character, and sentence statistics.
- Responsive Material 3 UI with system light/dark theme support.
- Unit, persistence, codec, controller, and widget regression tests.
- GitHub Actions continuous integration and tagged web-release automation.
- Open-source contribution, security, privacy, accessibility, governance, support, and release documentation.

## Current release

`2.1.0+6`

Version 2.1 is the Writing Workflow Quality release. It keeps the V2.0 local writing-rule foundation and adds durable per-language rule choices, safe batch correction with deterministic overlap handling, one-step batch undo, and the `Ctrl/⌘+Shift+Enter` Writing insights shortcut. Existing V1.3 language-pack behavior and V1.2 spelling/editor workflows remain compatible.

## Language selection

Use the compact language selector in the Editor header to choose **English (US)** or **English (UK)**. The selection is stored locally and restored later. Changing language re-checks non-blank editor text using the selected pack and loads that language's saved personal vocabulary and writing-rule choices.

Saved personal vocabulary is isolated by language. A word saved in `en-US` is not automatically accepted in `en-GB`. Version-2 personal-dictionary exports include the language ID so the application can prevent accidental cross-language imports.

SpellChecker does not auto-detect language. Explicit selection is intentional. See [Language packs](docs/LANGUAGE_PACKS.md).

## Writing insights

Select **Writing insights** in the app bar or press `Ctrl+Shift+Enter` / `⌘+Shift+Enter` to run optional local writing rules against the current in-memory editor text.

The built-in rules cover:

- Repeated adjacent words.
- Sentence-start capitalization.
- Repeated horizontal spaces.
- Repeated identical punctuation.

These rules are deterministic helpers, not a claim of full natural-language grammar coverage.

### Persistent rule choices

Each language has its own locally stored set of enabled writing-rule IDs. V2.1 distinguishes three states:

- No stored preference: use the current built-in default rule set.
- Non-empty stored set: enable exactly those supported rule IDs.
- Empty stored set: explicitly disable all writing rules for that language.

Changing a switch in Writing insights updates the active session immediately. When local preference storage is available, the choice is saved and restored on later launches. A storage failure does not discard the current session choice; the editor reports that persistence is unavailable.

### Safe individual fixes

A finding exposes **Apply safe fix** only when the rule provides a deterministic replacement. Before mutation, SpellChecker verifies that the source range still contains the exact text that was analysed. A stale finding is refused instead of being applied to changed text.

### Apply all safe fixes

When one or more findings have automatic replacements, Writing insights exposes **Apply all safe fixes (N)**.

Batch correction follows a deterministic safety contract:

1. Findings are ordered by source start, then end, then rule ID.
2. Advisory findings without replacements are skipped.
3. Stale findings whose source range no longer matches are skipped.
4. If automatic fixes overlap, the earliest deterministic finding is retained and later overlapping findings are skipped.
5. Accepted replacements are applied from the end of the document toward the beginning so checked offsets remain valid.
6. The operation reports how many fixes were applied and how many findings were skipped.
7. The entire batch is recorded as one correction-history entry, so one **Undo correction** restores the document from before the batch.

See [Writing rules](docs/WRITING_RULES.md).

## Main workflow

1. Type or paste text into the editor.
2. Choose the explicit spelling language.
3. Select **Check spelling** or press `Ctrl+Enter` / `⌘+Enter`.
4. Checked issues receive inline underlines and appear in the Results panel.
5. Use `F7` / **Next issue** or `Shift+F7` / **Previous issue** to move through issues.
6. Select a suggestion chip to replace one spelling occurrence.
7. When an unknown word occurs more than once, use **Replace all…** for checked matching occurrences.
8. Open **Writing insights** or press `Ctrl/⌘+Shift+Enter` for local writing-rule review.
9. Enable or disable rules for the selected language; V2.1 saves those choices locally.
10. Apply one safe writing fix or **Apply all safe fixes**.
11. Use snackbar **Undo** or **Undo correction** to restore the latest spelling or writing correction. A batch writing fix is one undo entry.
12. Select **Save word** to persist valid custom vocabulary for the selected language.
13. Select **Ignore once** for a session-only spelling exception.
14. Open **Manage personal dictionary** to add/remove words, import/export vocabulary, clear saved words, or configure suggestions per issue.
15. Use **Clear ignored session words** to restore temporary ignored-word checks without deleting saved settings.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Run spelling check on Windows/Linux/web keyboard layouts |
| `⌘+Enter` | Run spelling check on macOS keyboard layouts |
| `Ctrl+Shift+Enter` | Open Writing insights on Windows/Linux/web keyboard layouts |
| `⌘+Shift+Enter` | Open Writing insights on macOS keyboard layouts |
| `F7` | Move to the next spelling issue |
| `Shift+F7` | Move to the previous spelling issue |

Issue navigation wraps from the final spelling issue to the first and vice versa.

## Correction safety and undo

Spelling and writing findings include source offsets from a specific analysis snapshot. Before applying an automatic correction, SpellChecker verifies that the text at those offsets still matches the checked source text. If it does not, the correction is refused or skipped.

Programmatic spelling and writing corrections are stored in one bounded in-memory correction stack. Spelling **Replace all** and Writing insights **Apply all safe fixes** are each recorded as one correction, so one Undo restores the state from before the corresponding bulk operation. Manual typing starts a new editing history and clears the correction-specific undo stack.

## Personal dictionary format

Current language-aware exports use version 2:

```json
{
  "version": 2,
  "language": "en-US",
  "words": [
    "flutter",
    "open-source",
    "writer's"
  ]
}
```

The codec remains backward-compatible with version-1 SpellChecker objects, JSON arrays, and newline/comma-separated word lists. Imported entries are normalized according to the selected language pack, duplicates are removed, and invalid entries are rejected. A version-2 export with an unsupported or mismatched language is not silently reinterpreted.

## Local persistence

SpellChecker currently stores these settings locally through `shared_preferences`:

- Selected language ID.
- Personal dictionary words, namespaced by language.
- Suggestion-count preference.
- Enabled writing-rule IDs, namespaced by language.

SpellChecker does **not** persist editor documents, spelling result lists, writing-analysis findings, ignored words, active issue positions, or correction undo snapshots.

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

Run the core validation used by CI:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Check formatting before committing:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Build the release web application when preparing a release:

```bash
flutter build web --release
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
│   ├── LANGUAGE_PACKS.md
│   ├── PRIVACY.md
│   ├── RELEASING.md
│   ├── ROADMAP.md
│   ├── TESTING.md
│   ├── TROUBLESHOOTING.md
│   ├── USER_GUIDE.md
│   └── WRITING_RULES.md
├── lib/
│   ├── app.dart
│   ├── language.dart
│   ├── main.dart
│   ├── spell_checker.dart
│   ├── writing.dart
│   ├── core/
│   │   ├── edit_distance.dart
│   │   ├── personal_dictionary_codec.dart
│   │   ├── spell_checker_engine.dart
│   │   ├── spell_issue.dart
│   │   ├── spell_language_pack.dart
│   │   ├── spell_suggestion.dart
│   │   ├── text_correction.dart
│   │   └── text_statistics.dart
│   ├── data/
│   │   ├── english_dictionary.dart
│   │   ├── english_dictionary_extension.dart
│   │   ├── english_gb_dictionary.dart
│   │   └── english_word_frequencies.dart
│   ├── features/editor/
│   │   ├── dictionary_manager_dialog.dart
│   │   ├── spell_check_editing_controller.dart
│   │   ├── spell_checker_page.dart
│   │   └── writing_insights_dialog.dart
│   ├── storage/
│   │   └── dictionary_preferences.dart
│   └── writing/
│       ├── rules/
│       ├── writing_analyzer.dart
│       ├── writing_correction.dart
│       ├── writing_issue.dart
│       └── writing_rule.dart
├── test/
│   ├── dictionary_preferences_test.dart
│   ├── language_dictionary_codec_test.dart
│   ├── language_pack_test.dart
│   ├── language_preferences_test.dart
│   ├── personal_dictionary_codec_test.dart
│   ├── spell_check_editing_controller_test.dart
│   ├── spell_checker_test.dart
│   ├── text_correction_test.dart
│   ├── text_statistics_test.dart
│   ├── widget_test.dart
│   ├── writing_correction_test.dart
│   ├── writing_preferences_test.dart
│   ├── writing_rules_test.dart
│   └── writing_widget_test.dart
├── web/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── SECURITY.md
├── SUPPORT.md
└── pubspec.yaml
```

## Architecture

The application separates presentation, spelling, writing-rule analysis, correction, data, and local persistence:

- `lib/core/` contains reusable spelling/language/correction primitives.
- `lib/writing/` contains the local writing-rule plugin contract, analyzer, issue model, built-in rules, and safe corrections.
- `lib/features/editor/` contains the editor, spelling results, language selection, dictionary management, and Writing insights UI.
- `lib/data/` contains bundled dictionaries and ranking data.
- `lib/storage/` owns device-local preferences used by the application UI.
- `lib/spell_checker.dart`, `lib/language.dart`, and `lib/writing.dart` are public reusable API barrels.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Core API examples

Spelling:

```dart
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine();
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
```

Writing analysis and a batch correction:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

final analyzer = WritingAnalyzer();
final pack = SpellLanguageRegistry.englishUs;
final analysis = analyzer.analyze(
  'hello  world!!',
  languagePack: pack,
);

final corrected = WritingCorrection.applyAll(
  'hello  world!!',
  analysis.issues,
);
print(corrected.text); // Hello world!
```

See [docs/API.md](docs/API.md) for the public contracts.

## Privacy and storage

Spell checking and Writing insights remain local. The project contains no cloud spelling/grammar API, analytics SDK, advertising SDK, authentication system, or telemetry pipeline.

Editor text is not persisted by SpellChecker. Personal words, selected language, suggestion count, and writing-rule IDs are stored locally through `shared_preferences`. Ignored words, analysis findings, and correction undo snapshots remain in memory only. Import/export is user initiated and uses pasted text or the local clipboard.

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

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Keep spelling and writing-rule logic independent from UI code, include regression tests for behavior changes, preserve deterministic correction safety, preserve keyboard/accessibility behavior, keep user text local by default, and update documentation for user-visible changes.

## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## License

SpellChecker is released under the [MIT License](LICENSE).

Copyright © 2026 Sanskar.
