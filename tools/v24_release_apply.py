from pathlib import Path


def replace_once(path_name: str, old: str, new: str, label: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(old, new, 1))


def insert_before(path_name: str, marker: str, section: str, label: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if section.strip() in text:
        return
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(marker, section + '\n\n' + marker, 1))


def append_section(path_name: str, heading: str, body: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if heading in text:
        return
    suffix = '' if text.endswith('\n') else '\n'
    path.write_text(text + suffix + '\n' + heading + '\n\n' + body.strip() + '\n')


# About/version identity.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "      applicationVersion: '2.3.0',\n",
    "      applicationVersion: '2.4.0',\n",
    'About version',
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "          'A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, categorized local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.',\n",
    "          'A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, deterministic extensible suggestion ranking, categorized local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.',\n",
    'About description',
)

# README.
replace_once(
    'README.md',
    '- Language-tagged detailed suggestion metadata.\n',
    '- Language-tagged detailed suggestion metadata.\n- Public injectable `SpellSuggestionRanker` strategy with the pre-V2.4 ranking preserved as the default.\n- Stable lexical tie-breaking for custom ranker ties.\n',
    'README suggestion highlights',
)
replace_once(
    'README.md',
    '- Damerau-Levenshtein suggestion matching with frequency-aware tie breaking.\n',
    '- Damerau-Levenshtein candidate filtering with an extensible deterministic ranking strategy and frequency-aware default ordering.\n',
    'README ranking wording',
)
replace_once(
    'README.md',
    '`2.3.0+8`\n\nVersion 2.3 is the **Review Presets & Preference Portability** release. It keeps V2.2 categories, transient review filtering, reset-to-defaults, V2.1 correction safety, one-step undo, and keyboard workflows while adding stable reusable review presets plus a versioned non-document Portable settings format. Portable settings transfer selected language, suggestion count, and explicit per-language writing-rule overrides only; editor text, personal vocabulary, ignored words, findings, and correction history are excluded. Existing 2.x spelling/writing APIs remain compatible.',
    '`2.4.0+9`\n\nVersion 2.4 is the **Suggestion Ranking Extensibility & Determinism** release. It preserves the existing spelling candidate eligibility, Damerau-Levenshtein thresholds, default ranking order, metadata, language packs, V2.3 Portable settings/review presets, and all correction-safety behavior while extracting suggestion ordering into a public injectable strategy. Custom rankers receive normalized target/language context plus candidate distance, prefix, frequency, and source metadata; the engine applies a final lexical tie-break so equal custom scores remain deterministic. No user preference, transfer format, or runtime dependency changes in V2.4.',
    'README current release',
)
replace_once(
    'README.md',
    '│   │   ├── spell_suggestion.dart\n',
    '│   │   ├── spell_suggestion.dart\n│   │   ├── spell_suggestion_ranker.dart\n',
    'README core tree',
)
replace_once(
    'README.md',
    '│   ├── settings_transfer_service_test.dart\n',
    '│   ├── settings_transfer_service_test.dart\n│   ├── suggestion_ranker_test.dart\n',
    'README test tree',
)

# Changelog.
insert_before(
    'CHANGELOG.md',
    '## [2.3.0] - 2026-08-08',
    """## [2.4.0] - 2026-08-08

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
""",
    'V2.4 changelog',
)

# Roadmap.
insert_before(
    'docs/ROADMAP.md',
    '## Future 2.x direction',
    """## 2.4 — Suggestion ranking extensibility and determinism

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
""",
    'V2.4 roadmap',
)
replace_once(
    'docs/ROADMAP.md',
    '- Extensible spelling suggestion rankers.\n',
    '- Additional built-in ranker implementations driven by demonstrated ranking needs.\n',
    'future ranker item',
)

# API.
replace_once(
    'docs/API.md',
    'SpellChecker 2.3 exposes reusable spelling, language, correction, local writing-review, and portable-settings APIs through three public barrels.',
    'SpellChecker 2.4 exposes reusable spelling, language, correction, suggestion-ranking, local writing-review, and portable-settings APIs through three public barrels.',
    'API intro',
)
insert_before(
    'docs/API.md',
    '# V2.3 review preset and portable-settings APIs',
    """# V2.4 suggestion ranking APIs

## `SpellSuggestionCandidate`

Public immutable metadata for a candidate that already passed engine eligibility and maximum-edit-distance filtering:

```text
word
edit distance
prefixPenalty
frequencyRank
source
```

Rankers cannot use this API to reintroduce a candidate that the engine rejected before ranking.

## `SpellSuggestionRankingContext`

Provides the normalized target stem and active `SpellLanguagePack`. Recognized suffixes are removed before candidate ranking and reattached afterward, matching pre-V2.4 behavior.

## `SpellSuggestionRanker`

Implement `compare(context, a, b)` to order eligible candidates. Implementations should be deterministic and side-effect free. `SpellCheckerEngine` caches ranked results per normalized input word and assumes its ranker remains semantically stable for the engine lifetime.

If a ranker returns zero, the engine compares candidate words lexically. That final tie-break is engine-owned and guarantees deterministic ordering for equal custom scores.

## `DefaultSpellSuggestionRanker`

The default preserves the historical policy:

1. Lower Damerau-Levenshtein edit distance.
2. Lower first-character/prefix penalty.
3. Better (lower) frequency rank.
4. Shorter candidate word.
5. Engine lexical fallback.

## Engine injection

```dart
final engine = SpellCheckerEngine(
  suggestionRanker: const MySuggestionRanker(),
);
```

The new parameter is optional; callers that do not provide a ranker retain pre-V2.4 ordering.
""",
    'V2.4 API section',
)

# Architecture.
insert_before(
    'docs/ARCHITECTURE.md',
    '# V2.3 review presets and preference portability',
    """# V2.4 suggestion ranking boundary

Suggestion generation now has an explicit eligibility/ranking boundary:

```text
normalized unknown word
   │
   ├── recognized-suffix split
   │
   ▼
base + personal candidates
   │
   ├── token exclusions
   ├── length-difference guard
   └── language-pack maximum edit distance
          │ eligible candidates only
          ▼
SpellSuggestionRanker.compare
          │
          └── engine lexical fallback for score ties
                    │
                    ▼
SpellSuggestion metadata + suffix reattachment + cache
```

`SpellSuggestionRanker` is intentionally not a dynamic plugin loader. A host application supplies a Dart object when constructing `SpellCheckerEngine`; candidate filtering remains engine/language-pack authority. The cache is per engine instance, so rankers should not change semantics after construction.
""",
    'V2.4 architecture section',
)

append_section(
    'docs/DEVELOPMENT.md',
    '## V2.4 suggestion-ranker contracts',
    """Custom `SpellSuggestionRanker` implementations must be deterministic and side-effect free for a `SpellCheckerEngine` lifetime. Do not move candidate eligibility, maximum edit distance, token exclusions, suffix handling, or language normalization into a ranker. Return zero for genuinely equal custom scores and let the engine-owned lexical fallback provide stable ordering. Add focused tests whenever candidate metadata, ranking context, default ordering, cache assumptions, or tie semantics change.""",
)
append_section(
    'docs/TESTING.md',
    '## V2.4 focused suggestion-ranking coverage',
    """Run `flutter test test/suggestion_ranker_test.dart --reporter expanded` when changing ranking behavior. The suite protects historical default frequency ordering, optional custom ordering, engine lexical tie stability, normalized target/language context, distance/prefix/frequency/source candidate metadata, and the rule that ranking cannot bypass eligibility/edit-distance filtering. The complete suite must remain green because suggestion order is consumed by full spelling checks and editor widgets.""",
)
append_section(
    'docs/PRIVACY.md',
    '## Suggestion rankers — V2.4',
    """The V2.4 ranker API is local in-process Dart code supplied when constructing `SpellCheckerEngine`. SpellChecker does not persist ranker choice/state, dynamically download rankers, send candidate metadata to a service, or add a network dependency. The built-in application continues using `DefaultSpellSuggestionRanker`. Portable settings and personal-dictionary transfer formats are unchanged.""",
)
append_section(
    'SECURITY.md',
    '## Suggestion-ranker extension boundary — V2.4',
    """`SpellSuggestionRanker` is an injected in-process interface, not a trusted/dynamic plugin-loading system. SpellChecker does not discover, download, execute, or sandbox third-party ranker packages at runtime. Candidate eligibility and edit-distance limits remain in `SpellCheckerEngine` before custom ranking. Applications that compile in third-party ranker code are responsible for reviewing that code like any other dependency.""",
)
append_section(
    'CONTRIBUTING.md',
    '## V2.4 suggestion-ranking changes',
    """Preserve the default ranking order unless a release explicitly documents an intentional behavior change. Custom ranker support must not bypass engine eligibility filters, must retain deterministic lexical tie fallback, and must include focused tests for context/candidate metadata and cache-stability assumptions. Do not add dynamic plugin loading as part of a ranker change without a separate security design review.""",
)
append_section(
    'SUPPORT.md',
    '## V2.4 custom ranker reports',
    """For custom-ranker issues, include the ranker policy in pseudocode, a small synthetic dictionary/input, active language ID, expected/actual ordered candidate words, and whether the behavior reproduces with `DefaultSpellSuggestionRanker`. Do not include private document text or sensitive personal dictionaries.""",
)

# Releasing guide current identity.
replace_once(
    'docs/RELEASING.md',
    'Current V2.3 release:\n\n```text\n2.3.0+8\n```',
    'Current V2.4 release:\n\n```text\n2.4.0+9\n```',
    'release current version',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v2.3.0 -m "SpellChecker v2.3.0"\ngit push origin v2.3.0',
    'git tag -a v2.4.0 -m "SpellChecker v2.4.0"\ngit push origin v2.4.0',
    'release tag example',
)
replace_once(
    'docs/RELEASING.md',
    '3. Highlight V2.3 review presets and Portable settings semantics, plus V2.2 review categories/search/reset-to-defaults and the retained V2.1 persistence/batch/undo/shortcut foundation.',
    '3. Highlight V2.4 suggestion-ranker extensibility/default compatibility, plus the retained V2.3 review-preset/Portable settings and earlier correction-safety foundation.',
    'release notes guidance',
)
replace_once(
    'docs/RELEASING.md',
    'V2.3 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.',
    'V2.4 adds no new runtime dependency. `shared_preferences` remains the application-local preference adapter.',
    'release dependency note',
)

print('V2.4 release transform applied successfully.')
