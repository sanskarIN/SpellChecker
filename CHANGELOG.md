# Changelog

All notable changes to SpellChecker are documented in this file.

The project follows semantic versioning for public releases where practical.

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
- Complete contributor, security, privacy, architecture, testing, release, support, governance, roadmap, and user documentation.
- GitHub bug report, feature request, pull request, and configuration templates.

### Security and privacy

- No remote spelling service is used.
- No analytics or telemetry dependencies are included.
- User text and session dictionary entries remain local to the running application.
