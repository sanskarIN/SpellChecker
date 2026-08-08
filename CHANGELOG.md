# Changelog

All notable changes to SpellChecker are documented in this file.

The project follows semantic versioning for public releases where practical.

## [2.1.0] - 2026-08-08

### Added

- Per-language persisted writing-rule preferences using versioned local preference keys.
- Backward-compatible rule-preference semantics: unset uses current built-in defaults, while an explicitly empty set disables all rules for that language.
- `WritingBatchCorrectionResult` with final text, safe caret offset, applied count, skipped count, and convenience `applied` state.
- `WritingCorrection.applyAll` for deterministic current-range batch correction.
- Deterministic overlap resolution for batch writing fixes.
- **Apply all safe fixes (N)** in Writing insights.
- One-step correction undo for a complete writing-fix batch.
- `Ctrl+Shift+Enter` / `Command+Shift+Enter` Writing insights keyboard shortcut.
- Persistence regression tests for normalized rule IDs, explicit empty sets, language isolation, and clearing one language independently.
- Batch-correction regression tests for multiple fixes, stale/advisory skipping, overlap handling, and all-unsafe input.
- Widget regression tests for batch apply/undo, persisted dialog switches, startup restoration, and the Writing insights keyboard shortcut.
- Complete V2.1 user, API, architecture, privacy, accessibility, testing, troubleshooting, release, support, security, and contributor documentation.

### Changed

- Package version advances to `2.1.0+6`.
- Writing-rule switches now survive normal application restarts for their selected language instead of being session-only.
- Changing language restores that language's writing-rule choices along with its personal vocabulary.
- Individual writing fixes now use the same shared bounded correction-undo helper as spelling corrections and batch writing fixes.
- Writing insights explains that rule choices are stored locally for the selected language.
- About metadata describes persistent rule choices, batch-safe writing fixes, and keyboard workflows.

### Safety and correctness

- Batch automatic fixes validate the original analysed source text before mutation.
- Findings without automatic replacements are skipped during batch correction.
- Stale findings are skipped rather than applied to changed text.
- Overlapping automatic fixes are resolved deterministically by source start, end, and rule ID; the earliest accepted finding wins.
- Accepted batch replacements are applied from the end of the document toward the beginning so checked offsets remain valid.
- The complete batch is one undo entry.
- Local persistence failure does not discard the user's current in-memory rule choices; the editor reports that the choices could not be saved.

### Security and privacy

- Only writing-rule identifiers are newly persisted; editor text and writing-analysis findings remain unpersisted.
- Rule preferences are namespaced by language and stored through the existing local `shared_preferences` adapter.
- No cloud grammar service, AI rewriting service, analytics, advertising, telemetry, account system, remote logging, or background document upload was added.
- Writing analysis remains explicitly user-triggered and local.

## [2.0.0] - 2026-08-08

### Added

- Public `WritingRule` plugin contract and `WritingRuleRegistry`.
- `WritingAnalyzer` with language eligibility and session-level rule enable/disable filtering.
- Immutable `WritingIssue` model with deterministic source range, severity, message, optional replacement, and language metadata.
- `WritingCorrection` stale-range validation and safe fix result model.
- Built-in repeated-word writing rule.
- Built-in sentence-capitalization writing rule.
- Built-in repeated-space writing rule.
- Built-in repeated-punctuation writing rule.
- Public `package:spellchecker/writing.dart` API barrel.
- Optional **Writing insights** editor dialog.
- Session-only rule switches inside Writing insights.
- Language-aware local writing findings.
- Safe writing fixes integrated with the existing correction undo stack.
- Rule/analyzer/correction/widget regression tests.
- Complete writing-rules architecture, API, privacy, accessibility, testing, support, and contributor documentation.

### Changed

- Product version advances to `2.0.0+5`.
- About/web metadata now describes the optional local writing-rules layer.
- SpellChecker's correction history can now contain both spelling and writing-rule fixes while remaining bounded and memory-only.

### Security and privacy

- Writing analysis is explicitly user-triggered and runs locally in memory.
- No cloud grammar API, AI rewriting service, analytics, telemetry, account system, remote logging, or persisted writing-analysis history was added.
- Writing corrections validate current source text before mutation.
- Rule enablement is session-only in V2.0 and does not expand the persistent preference surface.

## [1.3.0] - 2026-08-08

### Added

- `SpellLanguagePack` abstraction and built-in language registry.
- Explicit English (US) `en-US` and English (UK) `en-GB` packs.
- Unicode-letter tokenization with curly-apostrophe and Unicode-hyphen normalization.
- British English variant dictionary and pack-specific frequency metadata.
- `SpellSuggestion` detailed metadata with language ID, display name, edit distance, frequency rank, and source.
- Optional language ID on `SpellIssue`.
- Persisted language selection.
- Per-language personal dictionary namespaces.
- Automatic migration of legacy V1 personal words into the default US namespace.
- Version-2 personal dictionary transfer format containing language metadata.
- Public `package:spellchecker/language.dart` language API barrel.
- Explicit editor language selector with automatic re-check on pack changes.
- Cross-language import protection for version-2 dictionary exports.
- Unicode/variant/language-isolation/migration/widget regression tests.
- Complete language-pack contributor and architecture documentation.

### Changed

- `SpellCheckerEngine` now delegates tokenization, normalization, suffix rules, dictionary data, frequency metadata, and suggestion distance policy to the selected pack.
- Existing `SpellCheckerEngine()` callers still default to English (US).
- Existing string `suggestionsFor()` remains available; `suggestionDetailsFor()` exposes metadata.
- Personal vocabulary is isolated by selected language instead of sharing one global set.
- About/version metadata advances to `1.3.0+4`.

### Security and privacy

- Language selection and per-language personal words remain device-local.
- No automatic language detection, network pack download, analytics, telemetry, account system, or cloud spelling service was added.
- Switching packs creates new language-specific session state so ignored/personal vocabulary does not silently leak across packs.
- Legacy migration reads only SpellChecker's prior local personal-word key and moves it into the default US namespace.

## [1.2.0] - 2026-08-08

### Added

- Inline wavy-underlined spelling issue highlighting inside the editable text.
- Stronger inline and Results-panel styling for the active issue.
- `F7` next-issue and `Shift+F7` previous-issue keyboard navigation.
- `Ctrl+Enter` / `Cmd+Enter` spelling-check shortcuts.
- Previous/next issue controls in the app bar and Results header.
- Active issue synchronization with editor text selection.
- Automatic Results-panel scrolling toward the active issue.
- Public `TextCorrection` and `TextCorrectionResult` APIs.
- Replace-all for repeated checked occurrences of the same unknown word.
- Bounded in-memory spelling-correction undo history.
- Snackbar **Undo** and persistent **Undo correction** controls.
- Dedicated blank-input state.
- Explicit local-storage-unavailable warning while session spelling remains usable.
- Live-region semantics for important results and warning states.
- Selected-state semantics and descriptive labels for spelling issue cards.
- Unit tests for validated correction primitives and inline highlighting.
- Widget tests for blank-state behavior, keyboard navigation, replace-all, undo, and existing persistence workflows.

### Changed

- Single replacements now use the same offset-validation and case-preservation primitive as replace-all.
- Spelling results refuse stale source ranges and refresh instead of mutating changed text.
- Results cards expose repeated-occurrence counts and a replace-all menu when appropriate.
- Manual text edits clear checked highlights and the spelling-specific correction undo stack.
- Package version advanced to `1.2.0+3`.
- About dialog updated to version 1.2.0.

### Accessibility

- Standard keyboard-first issue navigation is available without pointer interaction.
- Editor semantics explain checked inline issue highlighting.
- Active issue cards expose selected state and issue position/count semantics.
- Empty, clean, and storage-warning states expose descriptive live-region content.
- Essential state is not communicated only by inline underline color or badges.

### Security and privacy

- V1.2 adds no new runtime dependency, network service, analytics, authentication, advertising, or telemetry.
- Editor text remains unpersisted by SpellChecker.
- Correction undo snapshots are held only in memory and are discarded when the application session ends or manual editing starts a new correction history.
- Existing personal dictionary and suggestion-count persistence remains unchanged.

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
