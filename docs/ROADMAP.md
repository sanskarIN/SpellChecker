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

Planned:

- Inline issue highlighting.
- Keyboard-first issue navigation.
- Replace-all for repeated occurrences.
- Undo-friendly replacement workflow.
- Improved accessibility semantics.
- Better empty/error states.

## 1.3 — Language architecture

Planned:

- Language-pack abstraction.
- Unicode-aware tokenization.
- Optional additional dictionaries.
- Explicit language selection.
- Language-specific normalization rules.

## 2.0 — Advanced writing foundation

Possible future work:

- Plugin-style language packs.
- Optional grammar modules that can remain local.
- Extensible suggestion ranking.
- Cross-platform packaging and signed release automation.

Privacy-first local behavior remains a design requirement unless a future optional network feature is explicitly documented and user-controlled.
