# Roadmap

The roadmap describes intended direction, not guaranteed delivery dates.

## 1.0 — Local spelling workflow

Status: implemented.

- [x] Flutter application shell.
- [x] Responsive editor UI.
- [x] Local spelling engine.
- [x] Starter English dictionary.
- [x] Ranked spelling suggestions.
- [x] Damerau-Levenshtein edit distance.
- [x] Case-preserving replacement.
- [x] Session personal dictionary.
- [x] Session ignore list.
- [x] Text statistics.
- [x] Web host.
- [x] Unit and widget tests.
- [x] Continuous integration.
- [x] Complete project documentation.

## 1.1 — Dictionary quality and persistence

Status: implemented.

- [x] Persistent device-local personal dictionary.
- [x] Import/export personal words.
- [x] Versioned JSON dictionary format.
- [x] Import from JSON arrays and plain word lists.
- [x] Larger curated English dictionary.
- [x] Frequency-aware suggestion ranking.
- [x] Better regular possessive and contraction handling.
- [x] Suffix-preserving correction suggestions.
- [x] User preference for 1–10 suggestions per issue.
- [x] Personal-dictionary management UI.
- [x] Separate persistent saved words from session-only ignored words.
- [x] Persistence, codec, engine, and widget regression tests.

## 1.2 — Editor experience

Status: implemented.

- [x] Inline issue highlighting in the editable text.
- [x] Stronger active-issue highlighting.
- [x] Keyboard-first issue navigation with F7 and Shift+F7.
- [x] Keyboard spelling check with Ctrl/Command+Enter.
- [x] Previous/next issue controls.
- [x] Active issue synchronization between editor selection and Results.
- [x] Results auto-scroll toward the active issue.
- [x] Replace-all for repeated checked occurrences.
- [x] Validated reusable text-correction API.
- [x] Undo-friendly single and replace-all corrections.
- [x] Stale source-offset protection.
- [x] Improved accessibility semantics and live-region states.
- [x] Dedicated blank-input and storage-warning states.
- [x] Unit/controller/widget regression coverage for editor behavior.

## 1.3 — Language architecture

Status: implemented.

- [x] Language-pack abstraction.
- [x] Unicode-aware tokenization.
- [x] Built-in English (US) and English (UK) dictionaries.
- [x] Explicit persisted language selection.
- [x] Language-specific normalization and suffix rules.
- [x] Language-specific suggestion metadata.
- [x] Language-tagged spelling issues.
- [x] Per-language personal dictionary persistence.
- [x] Legacy V1 personal-word migration into the default pack.
- [x] Version-2 language-aware dictionary transfer format.
- [x] Cross-language import protection.
- [x] Unicode/variant/isolation/persistence/widget tests.
- [x] Complete language-pack documentation.

## 2.0 — Advanced writing foundation

Status: implemented.

- [x] Public local `WritingRule` plugin contract.
- [x] Language-aware `WritingAnalyzer` and rule registry.
- [x] Rule enable/disable filtering.
- [x] Repeated-word rule.
- [x] Sentence-capitalization rule.
- [x] Repeated-space rule.
- [x] Repeated-punctuation rule.
- [x] Deterministic writing issue model and severity metadata.
- [x] Stale-range-safe writing correction API.
- [x] Optional Writing insights editor UI.
- [x] Individual writing fixes integrated with bounded correction undo.
- [x] Rule/analyzer/correction/widget regression tests.
- [x] Complete writing-rules documentation foundation.

## 2.1 — Writing workflow quality

Status: implemented.

- [x] Per-language persisted writing-rule preferences.
- [x] Backward-compatible unset/default rule semantics.
- [x] Explicit persisted empty rule set for “disable all”.
- [x] Language switching restores language-specific rule choices.
- [x] `WritingBatchCorrectionResult` public result model.
- [x] Safe `WritingCorrection.applyAll` batch API.
- [x] Stale and advisory finding skipping during batch correction.
- [x] Deterministic overlap resolution for automatic writing fixes.
- [x] End-to-start batch replacement for source-offset safety.
- [x] **Apply all safe fixes (N)** Writing insights action.
- [x] One-step undo for a complete writing-fix batch.
- [x] `Ctrl/Command+Shift+Enter` Writing insights shortcut.
- [x] Persistent rule-choice, batch-correction, startup, undo, and keyboard regression tests.
- [x] Full V2.1 documentation and release metadata.

## 2.2 — Writing review and rule management

Status: implemented.

- [x] Public writing-rule categories.
- [x] Source-compatible category default for existing V2 rule implementations.
- [x] Clarity classification for repeated-word review.
- [x] Public reusable `WritingReviewQuery`.
- [x] Rule/finding text search.
- [x] Mechanics/Clarity category filters.
- [x] Automatic-fixes-only finding filter.
- [x] Clear-review-filters workflow.
- [x] Visible/total rule and finding counts.
- [x] Category labels in Writing insights findings and rule metadata.
- [x] Apply-visible-safe-fixes workflow using V2.1 batch safety and one-step undo.
- [x] True reset-to-defaults that clears the per-language stored override.
- [x] Transient/non-persisted review-filter privacy boundary.
- [x] Query/filter/reset/filtered-batch regression tests.
- [x] Complete V2.2 documentation and release metadata.

## 2.3 — Review presets and preference portability

Status: implemented.

- [x] Public stable review-preset metadata and IDs.
- [x] All findings, Mechanics, Clarity, and Automatic fixes presets.
- [x] Presets reuse `WritingReviewQuery` and retain transient free-text search.
- [x] Versioned deterministic non-document settings codec.
- [x] Portable selected language and 1–10 suggestion-count preference.
- [x] Portable complete explicit per-language writing-rule override map.
- [x] Preservation of unset/default versus explicit-empty/disable-all semantics.
- [x] Forward-compatible preservation of well-formed unknown rule IDs.
- [x] Dedicated Portable settings copy/import dialog.
- [x] Persistence-first import with best-effort rollback on write failure.
- [x] Personal-vocabulary and editor-text exclusion/preservation guarantees.
- [x] Focused codec/persistence/dialog/widget regression coverage.
- [x] Complete V2.3 documentation, privacy, release, and repository metadata.


## 2.4 — Suggestion ranking extensibility and determinism

Status: implemented.

- [x] Public eligible-candidate ranking metadata.
- [x] Public normalized target/language ranking context.
- [x] Injectable `SpellSuggestionRanker` engine strategy.
- [x] Source-compatible default ranker preserving the pre-V2.4 order.
- [x] Engine-owned lexical tie-break for deterministic custom-ranker ties.
- [x] Candidate eligibility/edit-distance filtering remains authoritative before ranking.
- [x] Existing suffix reattachment, personal-dictionary candidates, detailed suggestion metadata, caching, and suggestion limits remain compatible.
- [x] Focused custom/default/tie/context/eligibility regression coverage.
- [x] API/architecture/development/testing/privacy/security/release documentation.


## 2.5 — Bounded analysis and large-document safety

Status: implemented.

- [x] Public immutable `SpellCheckReport` analysis metadata.
- [x] Backward-compatible unbounded `check()` behavior.
- [x] Optional positive `maxIssues` capture bound on `analyze()`.
- [x] Truncation reported only after an additional unknown token is proven.
- [x] No suggestion generation for the proven overflow issue.
- [x] Built-in editor cap of 200 captured spelling issues.
- [x] `200+` result badge and accessible limited-result notice.
- [x] Captured-occurrence wording for limited results.
- [x] Bulk Replace all suppression for incomplete checked occurrence sets.
- [x] Focused core and widget regression coverage.
- [x] Dedicated performance/profiling documentation.
- [x] No persistence/network/runtime-dependency expansion.

## 2.6 — Deterministic writing rule expansion

Status: implemented.

- [x] Built-in English punctuation-spacing rule with stable public ID.
- [x] Built-in English trailing-whitespace rule with stable public ID.
- [x] Exact source-range and deterministic empty-string replacement contracts.
- [x] Six-rule built-in registry/default set for unset preferences.
- [x] Explicit persisted non-empty/empty rule preferences remain unchanged.
- [x] Interior repeated-space ownership separated from punctuation/trailing whitespace ownership.
- [x] Safe batch composition with repeated punctuation and one-step undo.
- [x] Writing insights exposes both new rule switches.
- [x] Focused rule/analyzer/interaction/widget regression coverage.
- [x] Complete V2.6 documentation, privacy/security, release, and web metadata updates.
- [x] No persistence/network/runtime-dependency expansion.

## Future 2.x direction

Possible future work includes:

- Richer deterministic writing-rule catalogues.
- Additional language-specific writing rules.
- Additional review presets/categories driven by demonstrated workflows.
- Additional portable non-document preferences with explicit compatibility/version review.
- Additional built-in ranker implementations driven by demonstrated ranking needs.
- Trusted plugin-loading designs with explicit security boundaries.
- Cross-platform packaging and signing automation.
- Performance profiling for very large documents.

Privacy-first local behavior remains a design requirement unless a future optional network feature is explicitly documented, reviewed, and user-controlled.
