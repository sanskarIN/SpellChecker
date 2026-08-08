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

Status: implemented foundation.

- [x] Public local `WritingRule` plugin contract.
- [x] Language-aware `WritingAnalyzer` and rule registry.
- [x] Per-session rule enable/disable filtering.
- [x] Repeated-word rule.
- [x] Sentence-capitalization rule.
- [x] Repeated-space rule.
- [x] Repeated-punctuation rule.
- [x] Deterministic writing issue model and severity metadata.
- [x] Stale-range-safe writing correction API.
- [x] Optional Writing insights editor UI.
- [x] Writing fixes integrated with bounded correction undo.
- [x] Rule/analyzer/correction/widget regression tests.
- [x] Complete writing-rules documentation.

Future 2.x work can add richer rule catalogs, persisted rule preferences, additional language-specific rules, extensible spelling rankers, packaging/signing automation, and trusted plugin-loading designs without weakening the local-first privacy baseline.

Privacy-first local behavior remains a design requirement unless a future optional network feature is explicitly documented and user-controlled.
