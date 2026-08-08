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


require('pubspec.yaml', 'version: 2.0.0+5')
require('lib/features/editor/spell_checker_page.dart', "tooltip: 'Writing insights'")
require('docs/LANGUAGE_PACKS.md', '# Language Packs')

# README.
replace_once('README.md', '`1.3.0+4`', '`2.0.0+5`')
replace_once(
    'README.md',
    'Version 1.3 completes the Language Architecture milestone. It adds explicit English (US) and English (UK) packs, Unicode-aware tokenization and normalization, language-tagged issue/suggestion metadata, persisted language selection, per-language personal dictionaries, and a version-2 language-aware dictionary transfer format. V1.2 inline review, replace-all, undo, keyboard navigation, and local-first privacy remain intact.',
    'Version 2.0 adds the Advanced Writing Foundation: an optional local writing-rule plugin API, four deterministic built-in writing rules, language-pack eligibility, explicit per-session rule switches, stale-range-safe rule fixes, and a Writing insights dialog that reuses the existing correction undo history. V1.3 language selection, Unicode tokenization, per-language vocabulary, and all V1.2 spelling/editor workflows remain intact.',
)
replace_once(
    'README.md',
    '- Language-tagged detailed suggestion metadata.\n',
    '- Language-tagged detailed suggestion metadata.\n- Optional local **Writing insights** with per-rule session switches.\n- Public `WritingRule` plugin contract and deterministic `WritingAnalyzer`.\n- Built-in repeated-word, sentence-capitalization, repeated-space, and repeated-punctuation rules.\n- Stale-range-safe writing fixes integrated with **Undo correction**.\n',
)
insert_before(
    'README.md',
    '## Main workflow',
    '''## Writing insights\n\nSelect **Writing insights** from the app bar to run optional local writing rules against the current in-memory text. The dialog shows the current language, lets you enable/disable supported rules for this session, and displays deterministic findings.\n\nBuilt-in V2.0 rules cover repeated words, sentence capitalization, repeated spaces, and repeated punctuation. They are intentionally lightweight and do not claim to be a full grammar parser.\n\nA finding exposes **Apply safe fix** only when it has a deterministic replacement. Before mutation, SpellChecker verifies that the source range still contains the exact analysed text. Successful writing fixes enter the same bounded correction history as spelling fixes, so **Undo correction** restores the previous document.\n\nSee [Writing rules](docs/WRITING_RULES.md).''',
)
replace_once(
    'README.md',
    '- [Language packs](docs/LANGUAGE_PACKS.md)\n',
    '- [Language packs](docs/LANGUAGE_PACKS.md)\n- [Writing rules](docs/WRITING_RULES.md)\n',
)

# Changelog.
insert_before(
    'CHANGELOG.md',
    '## [1.3.0] - 2026-08-08',
    '''## [2.0.0] - 2026-08-08\n\n### Added\n\n- Public `WritingRule` plugin contract and `WritingRuleRegistry`.\n- `WritingAnalyzer` with language eligibility and session-level rule enable/disable filtering.\n- Immutable `WritingIssue` model with deterministic source range, severity, message, optional replacement, and language metadata.\n- `WritingCorrection` stale-range validation and safe fix result model.\n- Built-in repeated-word writing rule.\n- Built-in sentence-capitalization writing rule.\n- Built-in repeated-space writing rule.\n- Built-in repeated-punctuation writing rule.\n- Public `package:spellchecker/writing.dart` API barrel.\n- Optional **Writing insights** editor dialog.\n- Session-only rule switches inside Writing insights.\n- Language-aware local writing findings.\n- Safe writing fixes integrated with the existing correction undo stack.\n- Rule/analyzer/correction/widget regression tests.\n- Complete writing-rules architecture, API, privacy, accessibility, testing, support, and contributor documentation.\n\n### Changed\n\n- Product version advances to `2.0.0+5`.\n- About/web metadata now describes the optional local writing-rules layer.\n- SpellChecker's correction history can now contain both spelling and writing-rule fixes while remaining bounded and memory-only.\n\n### Security and privacy\n\n- Writing analysis is explicitly user-triggered and runs locally in memory.\n- No cloud grammar API, AI rewriting service, analytics, telemetry, account system, remote logging, or persisted writing-analysis history was added.\n- Writing corrections validate current source text before mutation.\n- Rule enablement is session-only in V2.0 and does not expand the persistent preference surface.''',
)

# Roadmap.
replace_once(
    'docs/ROADMAP.md',
    '''## 2.0 — Advanced writing foundation\n\nPossible future work:\n\n- Plugin-style language packs.\n- Optional grammar modules that can remain local.\n- Extensible suggestion ranking.\n- Cross-platform packaging and signed release automation.\n- More advanced document/session workflows without weakening local-first privacy.''',
    '''## 2.0 — Advanced writing foundation\n\nStatus: implemented foundation.\n\n- [x] Public local `WritingRule` plugin contract.\n- [x] Language-aware `WritingAnalyzer` and rule registry.\n- [x] Per-session rule enable/disable filtering.\n- [x] Repeated-word rule.\n- [x] Sentence-capitalization rule.\n- [x] Repeated-space rule.\n- [x] Repeated-punctuation rule.\n- [x] Deterministic writing issue model and severity metadata.\n- [x] Stale-range-safe writing correction API.\n- [x] Optional Writing insights editor UI.\n- [x] Writing fixes integrated with bounded correction undo.\n- [x] Rule/analyzer/correction/widget regression tests.\n- [x] Complete writing-rules documentation.\n\nFuture 2.x work can add richer rule catalogs, persisted rule preferences, additional language-specific rules, extensible spelling rankers, packaging/signing automation, and trusted plugin-loading designs without weakening the local-first privacy baseline.''',
)

# API.
insert_before(
    'docs/API.md',
    '## Stability',
    '''## Writing rules API (2.0)\n\nImport the writing subsystem with:\n\n```dart\nimport 'package:spellchecker/writing.dart';\n```\n\n`WritingRule` defines stable ID/name/description/language eligibility plus a side-effect-free `analyze(text, languagePack)` contract. `WritingAnalyzer` runs supported/enabled rules and returns a sorted immutable `WritingAnalysisResult`.\n\n`WritingIssue` carries rule identity, explanation, exact source range/original text, optional replacement, language ID, and severity.\n\n`WritingCorrection.apply(text, issue)` applies a fix only when the current range still equals `issue.originalText`; otherwise it returns the unchanged text with `applied == false`.\n\nSee [WRITING_RULES.md](WRITING_RULES.md) for built-in rule behavior and plugin requirements.''',
)

# Architecture.
insert_before(
    'docs/ARCHITECTURE.md',
    '### Language layer',
    '''### Writing-rules layer\n\nLocations: `lib/writing/` and `lib/writing.dart`.\n\n`WritingRule` plugins analyse text without side effects. `WritingAnalyzer` chooses rules by language eligibility and enabled-rule IDs, combines findings, and sorts them deterministically. `WritingCorrection` is the only reusable automatic-fix mutation primitive and validates stale source ranges before changing text.\n\nThe editor's Writing insights dialog is presentation-only: it displays supported rules/findings and returns a selected issue to the page. The page then validates/applies the fix and stores the pre-fix `TextEditingValue` in the existing bounded correction stack. Rule switches remain session-only.\n\nThis layer deliberately has no storage/network dependency.''',
)

# User guide.
insert_before(
    'docs/USER_GUIDE.md',
    '## Check text',
    '''## Writing insights\n\nSelect **Writing insights** in the app bar when you want optional local writing-rule feedback. The dialog shows supported rules for the selected language and lets you switch each rule on/off for the current session.\n\nV2.0 built-ins:\n\n- Repeated word.\n- Sentence capitalization.\n- Repeated spaces.\n- Repeated punctuation.\n\nFindings show rule name, message, source range, original text, and a suggested replacement when available. Select **Apply safe fix** to close the dialog and apply that one validated fix.\n\nA writing fix enters the same **Undo correction** history used by spelling corrections. If the document changed after analysis, the safe fix is refused and the dialog should be reopened to refresh findings.\n\nRule switches are intentionally not persisted in V2.0.''',
)

# Development.
insert_before(
    'docs/DEVELOPMENT.md',
    '## Adding or changing language packs',
    '''## Adding or changing writing rules\n\nUse `WritingRule` rather than adding rule logic to widgets. Rules must be deterministic, side-effect free, explicit about supported language IDs/base codes, and return exact source ranges. Provide automatic replacements only when they can be applied safely.\n\nRun:\n\n```bash\nflutter test test/writing_rules_test.dart\nflutter test test/writing_correction_test.dart\nflutter test test/writing_widget_test.dart\n```\n\nDo not add document logging, persistent analysis history, or network grammar calls as an implementation detail. See [WRITING_RULES.md](WRITING_RULES.md).''',
)

# Testing.
insert_before(
    'docs/TESTING.md',
    '## Language architecture coverage',
    '''## Writing-rules coverage\n\nV2.0 tests cover:\n\n- Each built-in deterministic rule.\n- Adjacent-word boundary behavior.\n- Sentence-start capitalization.\n- Space/punctuation replacement metadata.\n- Language eligibility for both built-in English packs.\n- Analyzer issue ordering/counts.\n- Per-rule enable/disable filtering.\n- Current versus stale writing corrections.\n- Writing insights dialog findings.\n- Safe writing fix integration with editor Undo correction.\n- Session rule toggling in the real widget tree.\n\nRule tests should use synthetic text and assert the intended public contract rather than incidental widget positions.''',
)

# Accessibility.
insert_before(
    'docs/ACCESSIBILITY.md',
    '## Inline issue highlighting',
    '''## Writing insights accessibility\n\nWriting insights uses a standard dialog, labeled rule switches, textual finding explanations, source ranges, and labeled fix controls. Findings are semantic containers and empty states use live-region semantics.\n\nRule meaning/fix availability must never depend only on severity color/icon. Keep rule switches keyboard reachable and do not automatically apply a writing fix when focus/selection changes.''',
)

# Troubleshooting.
insert_before(
    'docs/TROUBLESHOOTING.md',
    '## US/UK spelling changes after switching language',
    '''## Writing insights reports something intentional\n\nWriting rules are optional deterministic heuristics. Disable that rule in the Writing insights dialog for the current session. Repeated spaces/punctuation, for example, can be intentional in specialized/informal text.\n\n## Apply safe fix refuses to change text\n\nThe document changed after the finding was calculated, so the stored source range is stale. SpellChecker refuses to mutate the wrong text. Close/reopen Writing insights to refresh findings.\n\n## Writing rule switches reset after restart\n\nExpected in V2.0. Rule enablement is session-only and is not part of the persisted preferences yet.''',
)

# Releasing.
insert_before(
    'docs/RELEASING.md',
    '## Tagging',
    '''## V2.0 writing-rules smoke test\n\nBefore tagging V2.0:\n\n1. Open Writing insights under both built-in English packs.\n2. Verify all four built-in rules appear.\n3. Use synthetic text containing each rule pattern.\n4. Disable/re-enable one rule and verify findings update.\n5. Apply a safe finding and verify document text/caret update.\n6. Use Undo correction and verify the pre-fix document returns.\n7. Change document text after analysis and verify a stale fix is refused.\n8. Verify blank/clean Writing insights states.\n9. Verify dialog keyboard access and larger-text/narrow viewport behavior.\n10. Re-run V1.3 language switching/import/isolation and V1.2 spelling/replace-all/undo smoke tests.\n\nUse synthetic text only.''',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v1.3.0 -m "SpellChecker v1.3.0"\ngit push origin v1.3.0',
    'git tag -a v2.0.0 -m "SpellChecker v2.0.0"\ngit push origin v2.0.0',
)

# Privacy.
insert_before(
    'docs/PRIVACY.md',
    '## User text',
    '''## Local writing-rule analysis\n\nV2.0 Writing insights receives the current document text only in application memory when the user explicitly opens the dialog. Built-in rules perform deterministic local analysis and do not transmit, log, persist, or synchronize document text/findings.\n\nWriting-rule enablement is session-only. Writing fixes reuse the existing memory-only correction history, which can temporarily contain editor snapshots and is discarded according to the existing correction-history policy.\n\nNo cloud grammar/AI service, analytics, remote logging, telemetry, or account system was introduced.''',
)

# Contributing.
insert_before(
    'CONTRIBUTING.md',
    '## Language-pack contributions',
    '''## Writing-rule contributions\n\nFollow [docs/WRITING_RULES.md](docs/WRITING_RULES.md). New rules need a stable ID, clear scope, explicit language eligibility, deterministic ranges, unit tests, stale-fix tests when applicable, and user/privacy documentation.\n\nDo not market a simple heuristic as full grammar analysis. Do not add text logging/network processing through a rule implementation.''',
)

# Security.
insert_before(
    'SECURITY.md',
    '## Language-pack safety',
    '''## Writing-rule safety\n\nRules process the current document in memory, so they must not log, persist, upload, or otherwise expose source text. Automatic fixes validate exact current source text before mutation.\n\nA future third-party rule/plugin loader requires a separate trust/signing/sandbox/update threat model; `WritingRule` being a plugin interface does not mean untrusted runtime code loading is enabled in V2.0.''',
)

# Support.
insert_before(
    'SUPPORT.md',
    '## Language-pack reports',
    '''## Writing-rules reports\n\nFor Writing insights bugs, include the rule name/ID, selected language, synthetic input, expected finding/fix, and whether text changed after analysis. State whether disabling the rule works and whether Undo correction restores the previous document.\n\nDo not post private documents or sensitive writing samples.''',
)

# Issue templates.
replace_once(
    '.github/ISSUE_TEMPLATE/bug_report.yml',
    '        - Language selection / language packs\n',
    '        - Language selection / language packs\n        - Writing insights / local writing rules\n        - Writing rule safe fix / undo\n',
)
replace_once(
    '.github/ISSUE_TEMPLATE/feature_request.yml',
    '        - Language selection / Unicode rules\n',
    '        - Language selection / Unicode rules\n        - Writing rules / writing insights\n',
)

# Pull request template.
insert_before(
    '.github/pull_request_template.md',
    '## Language architecture',
    '''## Writing rules\n\n- [ ] Rule logic is side-effect free and outside Flutter widgets.\n- [ ] Supported languages are explicit.\n- [ ] Automatic fixes validate exact current source text.\n- [ ] Rule changes include focused unit/widget tests.\n- [ ] No document logging, hidden persistence, telemetry, or network grammar processing is introduced.''',
)

for path, needle in (
    ('README.md', '`2.0.0+5`'),
    ('CHANGELOG.md', '## [2.0.0]'),
    ('docs/ROADMAP.md', '## 2.0 — Advanced writing foundation\n\nStatus: implemented foundation.'),
    ('docs/API.md', '## Writing rules API (2.0)'),
    ('docs/ARCHITECTURE.md', '### Writing-rules layer'),
    ('docs/USER_GUIDE.md', '## Writing insights'),
    ('docs/PRIVACY.md', '## Local writing-rule analysis'),
):
    require(path, needle)

print('V2.0 documentation integration applied successfully.')
