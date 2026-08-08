from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected one match, found {count}: {old[:100]!r}')
    file.write_text(text.replace(old, new, 1))


def insert_before(path: str, marker: str, block: str) -> None:
    replace_once(path, marker, f'{block}\n\n{marker}')


def require(path: str, needle: str) -> None:
    if needle not in Path(path).read_text():
        raise RuntimeError(f'{path}: required text missing: {needle!r}')


# Documentation must only advance after the application integration landed.
require('pubspec.yaml', 'version: 1.3.0+4')
require('lib/features/editor/spell_checker_page.dart', "ValueKey<String>('language-selector')")
require('lib/features/editor/dictionary_manager_dialog.dart', 'encodeForLanguage')

# README.
replace_once('README.md', '`1.2.0+3`', '`1.3.0+4`')
replace_once(
    'README.md',
    'Version 1.2 completes the Editor Experience milestone. It builds on V1.1 persistence with inline issue highlighting, active issue navigation, keyboard shortcuts, replace-all, correction undo, richer semantics, and clearer empty/error states. Personal words and suggestion-count preferences remain device-local; ignored words and correction history remain session-only.',
    'Version 1.3 completes the Language Architecture milestone. It adds explicit English (US) and English (UK) packs, Unicode-aware tokenization and normalization, language-tagged issue/suggestion metadata, persisted language selection, per-language personal dictionaries, and a version-2 language-aware dictionary transfer format. V1.2 inline review, replace-all, undo, keyboard navigation, and local-first privacy remain intact.',
)
replace_once(
    'README.md',
    '- Local spell checking: editor text is not sent to a remote spelling service.\n',
    '- Local spell checking: editor text is not sent to a remote spelling service.\n- Explicit built-in language selection: English (US) and English (UK).\n- Unicode-aware word tokenization and punctuation normalization.\n- Per-language persisted personal dictionaries with V1 migration.\n- Language-tagged detailed suggestion metadata.\n',
)
insert_before(
    'README.md',
    '## Main workflow',
    '''## Language selection\n\nUse the language selector above the editor to choose **English (US)** or **English (UK)**. The selection is stored locally and restored later. Changing language re-checks non-blank editor text using the new pack and starts a separate ignored-word/session state.\n\nSaved personal vocabulary is isolated by language. A word saved in `en-US` is not automatically accepted in `en-GB`. Version-2 dictionary exports include the language ID so the application can prevent accidental cross-language imports.\n\nSpellChecker 1.3 does not auto-detect language; explicit selection is intentional. See [Language packs](docs/LANGUAGE_PACKS.md).''',
)
replace_once(
    'README.md',
    '- [User guide](docs/USER_GUIDE.md)\n',
    '- [User guide](docs/USER_GUIDE.md)\n- [Language packs](docs/LANGUAGE_PACKS.md)\n',
)

# Changelog.
insert_before(
    'CHANGELOG.md',
    '## [1.2.0] - 2026-08-08',
    '''## [1.3.0] - 2026-08-08\n\n### Added\n\n- `SpellLanguagePack` abstraction and built-in language registry.\n- Explicit English (US) `en-US` and English (UK) `en-GB` packs.\n- Unicode-letter tokenization with curly-apostrophe and Unicode-hyphen normalization.\n- British English variant dictionary and pack-specific frequency metadata.\n- `SpellSuggestion` detailed metadata with language ID, display name, edit distance, frequency rank, and source.\n- Optional language ID on `SpellIssue`.\n- Persisted language selection.\n- Per-language personal dictionary namespaces.\n- Automatic migration of legacy V1 personal words into the default US namespace.\n- Version-2 personal dictionary transfer format containing language metadata.\n- Public `package:spellchecker/language.dart` language API barrel.\n- Explicit editor language selector with automatic re-check on pack changes.\n- Cross-language import protection for version-2 dictionary exports.\n- Unicode/variant/language-isolation/migration/widget regression tests.\n- Complete language-pack contributor and architecture documentation.\n\n### Changed\n\n- `SpellCheckerEngine` now delegates tokenization, normalization, suffix rules, dictionary data, frequency metadata, and suggestion distance policy to the selected pack.\n- Existing `SpellCheckerEngine()` callers still default to English (US).\n- Existing string `suggestionsFor()` remains available; `suggestionDetailsFor()` exposes metadata.\n- Personal vocabulary is isolated by selected language instead of sharing one global set.\n- About/version metadata advances to `1.3.0+4`.\n\n### Security and privacy\n\n- Language selection and per-language personal words remain device-local.\n- No automatic language detection, network pack download, analytics, telemetry, account system, or cloud spelling service was added.\n- Switching packs creates new language-specific session state so ignored/personal vocabulary does not silently leak across packs.\n- Legacy migration reads only SpellChecker's prior local personal-word key and moves it into the default US namespace.''',
)

# Roadmap.
replace_once(
    'docs/ROADMAP.md',
    '''## 1.3 — Language architecture\n\nPlanned:\n\n- Language-pack abstraction.\n- Unicode-aware tokenization.\n- Optional additional dictionaries.\n- Explicit language selection.\n- Language-specific normalization rules.\n- Language-specific suggestion metadata.\n- Tests ensuring language packs do not leak state across selections.''',
    '''## 1.3 — Language architecture\n\nStatus: implemented.\n\n- [x] Language-pack abstraction.\n- [x] Unicode-aware tokenization.\n- [x] Built-in English (US) and English (UK) dictionaries.\n- [x] Explicit persisted language selection.\n- [x] Language-specific normalization and suffix rules.\n- [x] Language-specific suggestion metadata.\n- [x] Language-tagged spelling issues.\n- [x] Per-language personal dictionary persistence.\n- [x] Legacy V1 personal-word migration into the default pack.\n- [x] Version-2 language-aware dictionary transfer format.\n- [x] Cross-language import protection.\n- [x] Unicode/variant/isolation/persistence/widget tests.\n- [x] Complete language-pack documentation.''',
)

# API.
insert_before(
    'docs/API.md',
    '## `SpellCheckerEngine`',
    '''## Language APIs\n\nLanguage architecture is exported separately for clarity:\n\n```dart\nimport 'package:spellchecker/language.dart';\nimport 'package:spellchecker/spell_checker.dart';\n```\n\n`SpellLanguageRegistry.builtIns` contains the built-in packs and `defaultPack` remains `en-US`. Select a pack explicitly with `SpellCheckerEngine(languagePack: ...)`.\n\n`SpellLanguagePack` carries language/region identity, dictionary data, frequency ranks, Unicode token/validation patterns, normalization, recognized suffixes, and suggestion-source metadata.\n\n`SpellSuggestion` is returned by `suggestionDetailsFor()` and exposes the candidate, distance, frequency rank, language ID/display name, and source. `suggestionsFor()` remains the backward-compatible string-only API.\n\n`SpellIssue.languageId` identifies the pack that produced an issue and remains optional for source compatibility.\n\nSee [LANGUAGE_PACKS.md](LANGUAGE_PACKS.md) for the complete language contract.''',
)
insert_before(
    'docs/API.md',
    '## `PersonalDictionaryCodec`',
    '''### Language-aware dictionary documents\n\n`PersonalDictionaryCodec.encodeForLanguage(words, languagePack: pack)` writes format version 2 with a `language` field. `decodeDocument()` returns a `PersonalDictionaryDocument` containing `version`, `languageId`, and normalized words.\n\nLegacy `encode()` remains version-1-compatible. Version-1 objects, JSON arrays, and plain word lists inherit the caller/selected language because they contain no language metadata.''',
)

# Architecture.
insert_before(
    'docs/ARCHITECTURE.md',
    '### Data layer',
    '''### Language layer\n\nLocation: `lib/core/spell_language_pack.dart` plus language-specific data under `lib/data/`.\n\n`SpellLanguagePack` is the boundary between language-independent engine/editor behavior and language-specific tokenization, normalization, dictionaries, suffix rules, frequency metadata, and suggestion source labels.\n\n`SpellLanguageRegistry` currently supplies `en-US` and `en-GB`. The editor stores one selected pack ID and constructs a fresh engine when the selection changes, which clears temporary ignored/suggestion-cache state and loads only that pack's personal words.\n\nBuilt-in English packs use Unicode letter-property tokenization, normalize curly apostrophes/common Unicode hyphens, and deliberately differ on common US/UK spellings.\n\nDetailed suggestions carry pack identity through `SpellSuggestion`; issues carry optional `languageId`.''',
)
insert_before(
    'docs/ARCHITECTURE.md',
    '## Tokenization',
    '''## Language switch flow\n\n```text\nLanguage selector\n   │\n   ├── load per-language personal words\n   ├── persist selected language ID\n   ├── construct SpellCheckerEngine(selected pack)\n   ├── restore only selected-pack personal words\n   ├── clear correction/highlight/ignored session state\n   └── re-check non-blank editor text\n```\n\nA failed preference read/write surfaces storage-unavailable state but does not introduce a remote fallback or prevent session spelling.\n\nLegacy `spellchecker.personal_words.v1` values are interpreted as `en-US` and migrated to the V2 US namespace on first load.''',
)

# User guide.
insert_before(
    'docs/USER_GUIDE.md',
    '## Check text',
    '''## Choose a language\n\nUse the language dropdown above the editor. Version 1.3 includes **English (US)** and **English (UK)**.\n\nThe selected language is saved locally. Switching language re-checks non-blank text with the new dictionary and starts a separate temporary ignored-word state.\n\nExamples:\n\n```text\nEnglish (US): color\nEnglish (UK): colour\n```\n\nSaved personal words are per-language. A US personal word is not automatically accepted in UK mode. Version-2 dictionary exports include their language; switch to the matching language before importing a tagged export.\n\nSpellChecker does not auto-detect language in V1.3.''',
)

# Development.
insert_before(
    'docs/DEVELOPMENT.md',
    '## Adding bundled dictionary words',
    '''## Adding or changing language packs\n\nLanguage packs live behind `SpellLanguagePack`; do not place language-specific tokenization/normalization logic in widgets.\n\nA new pack requires a stable ID/display name, Unicode-aware token/validation rules, normalization, licensed dictionary data, suggestion metadata policy, isolation tests, persistence tests, selector tests, documentation, and privacy/security review for any runtime download/network requirement.\n\nRun the dedicated V1.3 tests:\n\n```bash\nflutter test test/language_pack_test.dart\nflutter test test/language_dictionary_codec_test.dart\nflutter test test/language_preferences_test.dart\nflutter test test/language_widget_test.dart\n```\n\nSee [LANGUAGE_PACKS.md](LANGUAGE_PACKS.md).''',
)

# Testing.
insert_before(
    'docs/TESTING.md',
    '## Core engine coverage',
    '''## Language architecture coverage\n\nV1.3 adds tests for:\n\n- Built-in registry IDs/default behavior.\n- Unicode tokenization and punctuation normalization.\n- US/UK variant acceptance.\n- Language-tagged issues and detailed suggestions.\n- Personal/ignored in-memory isolation between engines.\n- Version-2 language-tagged dictionary documents.\n- Legacy version-1 dictionary compatibility.\n- Selected-language persistence/fallback.\n- Per-language personal-word namespaces and V1 migration.\n- UI language switching/re-check behavior.\n- Saved-word isolation across selector changes.\n\nLanguage tests must prove that adding state to pack A does not change pack B.''',
)

# Accessibility.
insert_before(
    'docs/ACCESSIBILITY.md',
    '## Inline issue highlighting',
    '''## Language selector accessibility\n\nThe V1.3 language selector is a standard Flutter dropdown with visible language names. It must remain keyboard reachable and expose the current selection through standard semantics.\n\nChanging language re-checks current non-blank text; users should not need to infer the new language only from spelling changes. Keep the visible selected language label present.\n\nDo not implement automatic language switching that unexpectedly moves focus or changes rules without explicit user action.''',
)

# Troubleshooting.
insert_before(
    'docs/TROUBLESHOOTING.md',
    '## Inline underlines disappear when I type',
    '''## US/UK spelling changes after switching language\n\nThis is expected. `en-US` and `en-GB` deliberately differ for common variants such as `color`/`colour`, `center`/`centre`, and `theater`/`theatre`. Switching language invalidates old issues and re-checks the current text.\n\n## A saved word exists in one language but not another\n\nExpected. Personal dictionaries are isolated by language. Save/import the word separately for the intended pack.\n\n## A version-2 dictionary import asks me to switch language\n\nVersion-2 exports include a language ID. SpellChecker prevents silently merging a tagged export into a different selected pack. Switch to the language named by the export, then import again.\n\nVersion-1/JSON-array/plain-list imports have no language metadata and are interpreted using the currently selected language.''',
)

# Releasing.
insert_before(
    'docs/RELEASING.md',
    '## Tagging',
    '''## V1.3 language smoke test\n\nBefore tagging V1.3:\n\n1. Start with `en-US`; verify `color` is accepted and `colour` is variant-specific.\n2. Switch to `en-GB`; verify current text is re-checked and `colour` is accepted.\n3. Verify Unicode tokens such as `café`/`naïve` remain whole words.\n4. Save synthetic vocabulary in US mode, switch to UK, and verify it does not leak.\n5. Save different UK vocabulary and verify each set restores when switching back/forth.\n6. Restart/reload and verify selected language restores.\n7. Export a language-tagged personal dictionary and verify `version: 2` plus language ID.\n8. Attempt to import the tagged export under the other language and verify the UI blocks the cross-language merge.\n9. Verify legacy V1 personal words migrate into the US namespace.\n10. Re-run V1.2 inline highlighting/navigation/replace-all/undo regression smoke checks under both built-in packs.\n\nUse only synthetic vocabulary.''',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v1.2.0 -m "SpellChecker v1.2.0"\ngit push origin v1.2.0',
    'git tag -a v1.3.0 -m "SpellChecker v1.3.0"\ngit push origin v1.3.0',
)

# Privacy.
insert_before(
    'docs/PRIVACY.md',
    '## User text',
    '''## Language selection and per-language vocabulary\n\nV1.3 stores the selected built-in language ID locally and namespaces personal vocabulary by language. It does not send language selection, editor text, or personal vocabulary to a server.\n\nSwitching language creates new in-memory pack/session state so temporary ignored words and suggestion caches do not leak to another pack.\n\nThe only migration reads SpellChecker's existing local V1 personal-word key and treats it as `en-US`; no external data is fetched.\n\nV1.3 adds no automatic language detection or keyboard/text telemetry.''',
)

# Contributing.
insert_before(
    'CONTRIBUTING.md',
    '## Dictionary contributions',
    '''## Language-pack contributions\n\nFollow [docs/LANGUAGE_PACKS.md](docs/LANGUAGE_PACKS.md). Language-specific tokenization/normalization belongs in a pack, not widgets. New packs require compatible/licensed data, Unicode tests, state-isolation tests, selector/persistence coverage, migration considerations, and documentation.\n\nDo not add runtime dictionary downloads or network language detection without explicit privacy/security design review.''',
)

# Security.
insert_before(
    'SECURITY.md',
    '## Import/export safety',
    '''## Language-pack safety\n\nBuilt-in packs are compiled local data. V1.3 does not download executable/content packs at runtime.\n\nLanguage-tagged dictionary imports validate the format version and supported language ID before merging. Pack switches construct isolated session state so ignored/personal vocabulary is not silently shared.\n\nAny future remote pack registry/download mechanism requires separate signature/integrity, licensing, privacy, and update-channel threat modeling.''',
)

# Support.
insert_before(
    'SUPPORT.md',
    '## Feature requests',
    '''## Language-pack reports\n\nFor language issues, include the selected pack ID/display name and synthetic sample word. Distinguish among tokenization, normalization, dictionary coverage, variant spelling, suggestion ranking, personal-word isolation, persisted selection, and import/export language metadata.\n\nDo not attach copyrighted dictionary datasets or private vocabulary dumps.''',
)

# GitHub templates: add language area to bug/feature report where absent.
replace_once(
    '.github/ISSUE_TEMPLATE/bug_report.yml',
    '        - Spell checking or suggestions\n',
    '        - Spell checking or suggestions\n        - Language selection / language packs\n        - Unicode tokenization / normalization\n',
)
replace_once(
    '.github/ISSUE_TEMPLATE/feature_request.yml',
    '        - Dictionary or language packs\n',
    '        - Dictionary or language packs\n        - Language selection / Unicode rules\n',
)

# Pull request template language checklist.
insert_before(
    '.github/pull_request_template.md',
    '## Correction safety',
    '''## Language architecture\n\n- [ ] Language-specific rules remain behind `SpellLanguagePack` instead of widgets.\n- [ ] Personal/ignored state does not leak across packs.\n- [ ] Unicode/tokenization/normalization changes have focused tests.\n- [ ] Dictionary data licensing/provenance is suitable for this repository.\n- [ ] Import/export/persistence migration behavior is documented when changed.''',
)

# Final guards.
for path, needle in (
    ('README.md', '`1.3.0+4`'),
    ('CHANGELOG.md', '## [1.3.0]'),
    ('docs/ROADMAP.md', '## 1.3 — Language architecture\n\nStatus: implemented.'),
    ('docs/API.md', '## Language APIs'),
    ('docs/ARCHITECTURE.md', '### Language layer'),
    ('docs/USER_GUIDE.md', '## Choose a language'),
    ('docs/PRIVACY.md', '## Language selection and per-language vocabulary'),
):
    require(path, needle)

print('V1.3 documentation integration applied successfully.')
