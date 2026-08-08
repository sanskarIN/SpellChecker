# Changelog

All notable changes to SpellChecker are documented in this file.

The project follows semantic versioning for public releases where practical.

## [1.1.0] - 2026-08-08

### Added

- Persistent personal dictionary backed by Flutter `shared_preferences`.
- Persistent 1–10 suggestion-count preference.
- Personal-dictionary manager with add, remove, clear, import, and export controls.
- Versioned personal-dictionary JSON export format.
- Import support for SpellChecker JSON objects, JSON arrays, and newline/comma-separated word lists.
- Clipboard export for personal dictionary data.
- Expanded bundled English vocabulary.
- Approximate frequency ranks for deterministic suggestion tie breaking.
- Regular contraction and possessive recognition from known stems.
- Suffix-preserving correction suggestions for supported apostrophe forms.
- Public `PersonalDictionaryCodec` API.
- Dedicated persistence and import/export regression tests.
- Widget tests that verify persisted editor behavior.

### Changed

- Personal dictionary entries now survive application restarts instead of being session-only.
- Ignored words remain intentionally session-only and can be cleared independently.
- Suggestion ranking now considers edit distance, prefix agreement, frequency rank, word length, and alphabetical order in that sequence.
- The editor distinguishes **Save word** from **Ignore once**.
- The app bar exposes saved-word and ignored-word counts.
- Package version advanced to `1.1.0+2`.
- Dart SDK lower bound advanced to `3.8.0` to match the configured Flutter/Dart tooling.

### Security and privacy

- Editor text still remains local and is not persisted by SpellChecker.
- Personal words and suggestion-count preferences are stored only in application-local preferences.
- Import/export remains user initiated and uses pasted text or the clipboard.
- No analytics, advertising, authentication, telemetry, or cloud spelling service was added.

## [1.0.0] - 2026-08-07

### Added

- Flutter Material 3 SpellChecker application shell.
- Responsive editor and results layout.
- Local tokenization and dictionary-based spelling checks.
- Ranked suggestions using Damerau-Levenshtein edit distance.
- Case-preserving word replacement from suggestion chips.
- In-memory personal dictionary.
- In-memory ignored-word list.
- Session dictionary reset action.
- Word, character, and sentence statistics.
- Built-in English starter dictionary.
- System light and dark theme support.
- Web host files and manifest.
- Unit tests for spell checking, suggestions, session behavior, edit distance, and statistics.
- Widget test for the main spelling workflow.
- GitHub Actions continuous integration.
- Release workflow for tagged web builds.
- Complete contributor, security, privacy, accessibility, architecture, testing, release, support, governance, roadmap, and user documentation.
- GitHub bug report, feature request, pull request, and configuration templates.

### Fixed

- Corrected about-dialog handling in the Flutter UI.
- Aligned suggestion tests with the documented deterministic ranking contract.
- Aligned the Dart SDK lower bound with the configured lint tooling.
- Aligned README and testing documentation with the actual CI commands.

### Security and privacy

- No remote spelling service is used.
- No analytics or telemetry dependencies are included.
- User text and session dictionary entries remain local to the running application.
