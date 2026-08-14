# Changelog

All notable changes to SpellChecker are documented in this file.

The project follows semantic versioning for public releases where practical.

## [2.9.0] - 2026-08-14

### Added

- Public `WritingAnalysisDiagnosticSummary` and `WritingRuleDiagnosticSummary` models with deterministic lexical rule ordering.
- Explicit Writing insights **Copy diagnostic summary** action that copies only the privacy-safe formatted diagnostic metadata after a user action.
- `WritingAnalysisDiagnosticSummary.fromResult(...)` for metadata-only snapshots over V2.8 exact diagnostics and `toPlainText()` for stable shareable text.
- Focused V2.9 coverage for bounded exact totals, compatibility results without exact totals, empty results, deterministic ordering, and exclusion of document/finding content from diagnostic summaries.
- Regression coverage for release-mode report/result invariants, normalized custom frequency keys, immutable suffix configuration, dot-connected sentence boundaries, IME composition, Unicode statistics, duplicate writing-rule IDs, and V2.9 About/version metadata.

### Changed

- Package version is `2.9.0+14`; the About dialog reports `2.9.0`.
- `SpellCheckReport` constructor consistency checks now execute at runtime instead of relying on debug-only assertions.
- `WritingAnalysisResult` now rejects captured findings owned by non-analyzed rules, findings with a different result language, and per-rule totals for non-analyzed rules.
- `WritingAnalyzer` rejects duplicate configured rule IDs so persisted IDs and diagnostics remain unambiguous.
- Custom suggestion-frequency keys are normalized through the active language pack; normalized duplicates retain the best (lowest) frequency rank.
- `SpellLanguagePack` defensively snapshots recognized suffix configuration in addition to dictionary/frequency collections.
- Sentence-capitalization boundaries require separating whitespace after terminal punctuation, preventing dot-connected text such as `example.com` from being treated as a new sentence.
- Inline spelling highlighting preserves Flutter's native active IME composing span while composition is in progress.
- `TextStatistics` counts Unicode-letter words and supported apostrophe/hyphen forms consistently with the spelling tokenizer.
- Flutter 3.47/Dart 3.13 analyzer/formatter configuration and resolved transitive dependency metadata are synchronized with the CI toolchain.
- Obsolete V2.2, V2.3, and V2.8 one-time reconciliation workflows are removed from the permanent release tree.

### Compatibility, security, privacy, and validation

- V2.8 analyzer/result APIs, capture semantics, exact totals, writing-rule IDs, preference formats, Portable settings, correction safety, ranking extension points, and language IDs remain source/data compatible for valid inputs.
- The V2.9 diagnostic formatter contains counts and rule metadata only and does not read editor text, finding messages/excerpts, replacements, or source offsets.
- V2.9 adds no runtime dependency, analytics, telemetry, account behavior, cloud writing service, persistence format, automatic clipboard write, or application network request.
- The hardening audit validates formatting, static analysis, the complete Flutter test suite, and the release web build on the final candidate tree before merge.

## [2.8.0] - 2026-08-12

### Added

- Exact deterministic writing-analysis diagnostics on analyzer-produced `WritingAnalysisResult` values: `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`.
- Exact whole-analysis finding counts while bounded mode continues retaining only the globally earliest configured finding prefix.
- Per-enabled-rule total finding metadata in Writing insights.
- Exact captured/total findings badge and accessible limited-analysis wording in Writing insights.
- Stable `writing-findings-total-badge` widget key for diagnostics regression coverage without depending on tooltip lifecycle.
- Dedicated core and widget diagnostics coverage for exact totals, per-rule totals, uncaptured counts, result invariants, immutability, disabled-rule exclusion, lazy dialog rendering, and singular/plural limited-result wording.

### Changed

- Package version advances to `2.8.0+13`; About version advances to `2.8.0`.
- A limited Writing insights review can now report the exact relationship between captured and observed findings, for example `200/1437`, instead of only an unknown `200+` state when analyzer diagnostics are available.
- The limited-analysis notice reports **the first N of M findings** and the exact number of findings not retained by the capture limit.
- Enabled rule metadata reports exact total findings contributed by each enabled/supported rule during the current analysis.
- Filtered-empty limited-review copy reports the exact uncaptured quantity and uses grammatically correct singular/plural wording.
- Widget tests navigate the real lazy Writing insights list rather than forcing normally off-screen controls to remain eagerly mounted.

### Compatibility, performance, security, and privacy

- The V2.7 `maxIssues` capture contract is unchanged: bounded analysis still retains only the globally earliest review-order prefix and filters/fixes remain captured-only when results are incomplete.
- Analyzer-produced results always provide exact diagnostics; direct V2.7-style construction of `WritingAnalysisResult` may omit them for source compatibility.
- Exact diagnostic totals count rule findings during the normal full enabled-rule scan without retaining uncaptured `WritingIssue` objects.
- V2.8 does not claim a CPU-time, wall-clock-time, or maximum-document-size bound. It adds deterministic count diagnostics rather than timing telemetry.
- Existing writing-rule IDs/defaults/preferences, review presets/query behavior, correction safety, overlap resolution, one-step undo, V2.5 spelling bounds, V2.4 ranking, and Portable settings remain compatible.
- V2.8 adds no persistence format, preference key, runtime dependency, network request, account behavior, cloud writing service, telemetry, background upload, or persisted editor/finding data.

## [2.7.0] - 2026-08-11

### Added

- Optional positive `maxIssues` capture bound for `WritingAnalyzer.analyze()` while preserving `null` as the historical unbounded behavior.
- Bounded writing-analysis metadata on `WritingAnalysisResult`: `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`.
- A globally ordered bounded collector that retains the same earliest finding prefix as unbounded analysis without retaining the complete finding set.
- Built-in Writing insights capture policy of 200 findings with accessible limited-result explanation.
- Focused core and widget coverage for exact-at-limit completeness, proven overflow, out-of-order rule streams, captured batch fixes, filtering, and immutable result lists.

### Changed

- Package version advances to `2.7.0+12`; About version advances to `2.7.0`.
- Writing insights displays a `200+`-style limited count only when an additional finding beyond the capture limit is actually observed.
- Limited-result review filters operate on captured findings only and say so explicitly.
- Limited-result batch actions use **Apply captured safe fixes** / **Apply visible captured safe fixes** wording rather than implying every whole-document finding is represented.
- Bounded analysis continues to run every enabled/supported rule over the supplied text so the retained set is the correct global review-order prefix even when a later rule yields an earlier finding.

### Compatibility, performance, security, and privacy

- Existing callers that omit `maxIssues` receive the same unbounded analysis contract as V2.6 and earlier.
- Reaching the numerical limit alone does not imply truncation; `isTruncated` becomes true only after at least one additional finding is observed.
- The V2.7 bound limits retained finding objects, not document length, rule CPU time, or the total number of rule matches that may be scanned.
- Existing rule IDs, per-language rule preferences, review presets/filters, Portable settings, correction safety, one-step undo, V2.5 spelling bounds, and V2.4 suggestion ranking remain compatible.
- V2.7 changes no persistence format or preference key and adds no runtime dependency, network request, telemetry, cloud writing service, account behavior, or background document processing.

## [2.6.0] - 2026-08-10

### Added

- Built-in English `PunctuationSpacingRule` with stable ID `punctuation-spacing` for horizontal whitespace immediately before common punctuation.
- Built-in English `TrailingWhitespaceRule` with stable ID `trailing-whitespace` for horizontal whitespace immediately before LF/CRLF line endings or the document end.
- Public exports for both new deterministic writing rules.
- Focused V2.6 rule, registry, exact-range, batch-composition, Writing insights visibility, and one-step undo regression coverage.

### Changed

- Package version advances to `2.6.0+11`; About version advances to `2.6.0`.
- The default built-in writing registry expands from four to six rules for users in the unset/default preference state.
- `RepeatedSpaceRule` now owns only repeated interior spaces; punctuation-adjacent and line/document-end whitespace ranges are delegated to the specialized V2.6 rules so automatic fixes do not overlap with incompatible replacement semantics.
- Lazy Writing insights widget tests scroll through the real expanded rule catalogue before interacting with findings/batch actions.

### Compatibility, security, and privacy

- Explicit per-language saved rule lists remain explicit; V2.6 does not silently add new rule IDs to a stored non-empty or empty override.
- Resetting rules still clears the override key, after which current registry defaults include the two V2.6 rules.
- Existing `WritingCorrection.apply`/`applyAll` stale-range, deterministic ordering, overlap, end-to-start mutation, and one-step undo contracts are unchanged.
- Both new rules are deterministic, English-only, local, source-controlled rules. No editor text, findings, review state, or correction history is newly persisted.
- V2.6 adds no runtime dependency, network request, telemetry, cloud writing service, dynamic rule loading, or account behavior.

## [2.5.0] - 2026-08-09

### Added

- Public immutable `SpellCheckReport` with captured issues, scanned-token count, truncation state, issue limit, completeness, and captured-count metadata.
- Public `SpellCheckerEngine.analyze()` API with optional positive `maxIssues` capture bound.
- Dedicated `docs/PERFORMANCE.md` contract for large-document behavior and profiling.
- End-to-end widget coverage for the 200-issue editor cap and limited-result bulk-action safety.

### Changed

- Package version advances to `2.5.0+10`; About version advances to `2.5.0`.
- Historical `SpellCheckerEngine.check()` remains unbounded and delegates to `analyze()` without a cap.
- After a bounded analysis reaches its capture cap, the engine scans only until it either reaches the token-stream end or proves that one additional unknown token exists.
- The proven overflow issue is not materialized and receives no suggestion generation.
- The built-in editor captures at most 200 spelling issues and renders a `200+` badge only when an additional issue is actually proven.
- Limited results show an accessible explanation and label repeated words as captured occurrences.
- **Replace all** is hidden when spelling results are truncated because the checked occurrence set is incomplete.

### Compatibility, performance, security, and privacy

- Inputs with exactly the configured issue count remain complete when no later issue exists.
- Single-occurrence correction, navigation, highlighting, personal-dictionary actions, ignored-word behavior, V2.4 suggestion ranking, V2.3 Portable settings, and writing workflows remain compatible.
- `maxIssues` bounds captured issues/expensive suggestion materialization; it is not represented as a hard document-length bound.
- `SpellCheckReport` remains memory-only and adds no persistence, telemetry, network request, logging, background upload, or runtime dependency.

## [2.4.0] - 2026-08-08

### Added

- Public `SpellSuggestionCandidate` metadata for eligible suggestion candidates.
- Public `SpellSuggestionRankingContext` carrying the normalized correction target and active language pack.
- Public `SpellSuggestionRanker` strategy interface.
- Public `DefaultSpellSuggestionRanker` implementing the exact pre-V2.4 ranking policy.
- Optional `suggestionRanker` injection in `SpellCheckerEngine`.
- Focused tests for default compatibility, custom ordering, lexical tie stability, ranking context/candidate metadata, and eligibility-filter boundaries.

### Changed

- Package version advances to `2.4.0+9`; About version advances to `2.4.0`.
- Suggestion candidate ordering is delegated to the injected ranker after the existing language-pack eligibility/edit-distance filters run.
- The engine applies a final lexical word tie-break whenever a ranker returns zero, keeping custom-ranker ties deterministic.
- The suggestion cache assumes the ranker is deterministic and stable for the lifetime of its engine instance.

### Compatibility, security, and privacy

- `DefaultSpellSuggestionRanker` preserves the previous order: edit distance, prefix penalty, frequency rank, word length, lexical fallback.
- Custom ranking cannot bypass maximum edit distance, compound-token exclusions, or other existing candidate eligibility checks.
- V2.4 does not dynamically load plugins/rankers, add network behavior, persist ranker state, change Portable settings/personal-dictionary formats, or add a runtime dependency.


## [2.3.0] - 2026-08-08

### Added

- Public `WritingReviewPreset` with stable **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes** IDs.
- Writing insights preset chips that project into the existing reusable review-query state while retaining temporary free-text search.
- Public `SpellCheckerSettingsDocument` and version-1 `SpellCheckerSettingsCodec` for deterministic non-document preference transfer.
- **Portable settings** dialog with explicit local clipboard export and validated pasted-JSON import.
- Internal `SettingsTransferService` that exports durable preference state, replaces the complete portable preference set on import, and performs best-effort rollback after a failed write.
- Focused preset, settings codec, persistence rollback, dialog, and end-to-end editor workflow regression tests.

### Changed

- Package version advances to `2.3.0+8`; About version advances to `2.3.0`.
- Portable import can change selected language, suggestion count, and explicit per-language writing-rule overrides while preserving editor text and target-language personal vocabulary.
- Successful portable import clears stale issue/correction state and rechecks non-blank text with the imported language.
- V2.3 release recovery removes temporary integration helpers/workflows from the permanent tree.

### Compatibility, security, and privacy

- Portable override documents preserve the distinction between a missing language key (unset/use registry defaults) and a present empty list (explicit disable-all).
- Valid well-formed unknown future rule IDs are preserved; malformed rule IDs, unsupported languages, unsupported formats/versions, malformed structures, and suggestion limits outside 1–10 are rejected.
- Portable settings exclude editor text, personal vocabulary, ignored session words, spelling/writing findings, and correction history.
- Import validation and preference writes are local. `shared_preferences` has no multi-key transaction, so rollback after a write failure is best effort and is not described as atomic.
- Review preset/search/category/automatic-fix state remains transient and unpersisted.
- No new runtime dependency, cloud grammar/spelling service, analytics, telemetry, account system, or remote document transfer is introduced.


## [2.2.0] - 2026-08-08

### Added

- Public `WritingRuleCategory` review metadata with **Mechanics** and **Clarity** categories.
- Source-compatible default `WritingRule.category` implementation so existing V2 external rules continue compiling and default to Mechanics.
- Built-in repeated-word rule classified as Clarity; existing mechanics-oriented built-ins retain the source-compatible Mechanics default.
- Public `WritingReviewQuery` for reusable search, category, and automatic-fix filtering outside Flutter widgets.
- Writing insights search field covering rule metadata and finding text/replacement metadata.
- Mechanics/Clarity `FilterChip` review controls.
- **Automatic fixes only** review toggle.
- **Clear review filters** action.
- Visible/total rule and finding counts.
- Category labels in rule descriptions and finding semantics/cards.
- **Apply visible safe fixes (N)** when review filters are active.
- **Reset rules to defaults** action that returns the selected language to the unset/default rule-preference state.
- `writing_review_query_test.dart` and expanded Writing insights widget tests for categories, search, filtered batch/undo, and reset-to-defaults.

### Changed

- Package version advances to `2.2.0+7`.
- About/web metadata describes categorized review and reset-to-default behavior.
- Filtered batch correction reuses the V2.1 stale/advisory/overlap/end-to-start safety contract and remains one undo entry.
- Finding category lookup uses the dialog's actual `WritingAnalyzer` rule set so custom analyzers preserve custom rule categories.
- Review filters are dialog-local and do not alter per-language persisted rule preferences.

### Persistence, security, and privacy

- Search text, selected categories, automatic-fixes-only state, visible finding sets, and review counts are not persisted.
- Resetting rules clears `spellchecker.writing_rule_ids.v1.<language-id>` instead of storing a copy of current defaults.
- A reset persistence failure keeps current-session defaults active while reporting that the saved override could not be cleared.
- No editor text, finding source excerpts, review queries, filtered batch plans, analytics, telemetry, cloud grammar service, or new runtime dependency was added.

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
