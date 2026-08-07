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

Planned:

- Persistent personal dictionary.
- Import/export personal words.
- Larger curated English dictionary.
- Frequency-aware suggestion ranking.
- Better possessive and contraction handling.
- User preferences for suggestion count.

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
