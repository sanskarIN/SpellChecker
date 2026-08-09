from pathlib import Path


def replace_once(path_name: str, old: str, new: str, label: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(old, new, 1))


def insert_before(path_name: str, marker: str, addition: str, label: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if addition.strip() in text:
        raise RuntimeError(f'{path}: {label}: addition already present')
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(marker, addition.rstrip() + '\n\n' + marker, 1))


def append_section(path_name: str, heading: str, body: str) -> None:
    path = Path(path_name)
    text = path.read_text().rstrip()
    if heading in text:
        raise RuntimeError(f'{path}: section already present: {heading}')
    path.write_text(text + '\n\n' + body.strip() + '\n')


# About metadata.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "applicationVersion: '2.5.0'",
    "applicationVersion: '2.6.0'",
    'About version',
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    'categorized local writing rules, temporary review presets/search/filters',
    'expanded deterministic punctuation-spacing writing rules, temporary review presets/search/filters',
    'About rule catalogue description',
)

# README release identity, feature list, project tree, and CI commands.
replace_once(
    'README.md',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, and repeated-punctuation rules.\n',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, repeated-punctuation, missing-space-after-punctuation, and space-before-punctuation rules.\n',
    'README built-in rule list',
)
replace_once(
    'README.md',
    '''`2.5.0+10`\n\nVersion 2.5 is the **Bounded Analysis & Large-Document Safety** release. It keeps V2.4 suggestion-ranker extensibility and every existing spelling/writing/persistence contract while adding public `SpellCheckReport` metadata and `SpellCheckerEngine.analyze()` for optional bounded issue capture. The built-in editor captures at most 200 spelling issues, labels genuinely truncated results as `200+`, and disables **Replace all** when the checked occurrence set is incomplete. No persistence format, network behavior, or runtime dependency changes in V2.5.\n''',
    '''`2.6.0+11`\n\nVersion 2.6 is the **Deterministic Writing Rule Catalogue Expansion** release. It keeps V2.5 bounded spelling analysis, V2.4 extensible suggestion ranking, V2.3 preference portability, and all existing correction/persistence contracts while adding two conservative English Mechanics rules: **Missing space after punctuation** and **Space before punctuation**. Users in the unset/default rule state receive the expanded six-rule default catalogue; explicit stored rule-ID sets remain explicit and do not silently gain new rules. Permanent CI now also builds the release web app on every quality run. No persistence format, network behavior, or runtime dependency changes in V2.6.\n''',
    'README current release',
)
replace_once(
    'README.md',
    '''The built-in rules cover:\n\n- Repeated adjacent words.\n- Sentence-start capitalization.\n- Repeated horizontal spaces.\n- Repeated identical punctuation.\n''',
    '''The built-in rules cover:\n\n- Repeated adjacent words.\n- Sentence-start capitalization.\n- Repeated horizontal spaces.\n- Repeated identical punctuation.\n- A comma or semicolon followed immediately by a letter.\n- One stray space immediately before common punctuation.\n''',
    'README writing rule catalogue',
)
insert_before(
    'README.md',
    '### Review filters — V2.2\n',
    '''### Expanded punctuation-spacing rules — V2.6\n\nThe English Writing insights catalogue now contains six built-in deterministic rules. `missing-space-after-punctuation` proposes a space when a comma or semicolon is followed immediately by a Unicode letter, while skipping repeated/clustered punctuation so the dedicated repeated-punctuation rule retains ownership. `space-before-punctuation` removes one stray ASCII space directly before common prose punctuation and deliberately skips multi-space runs so `repeated-space` retains that source range.\n\nBoth new rules are Mechanics rules with deterministic replacements and exact source ranges. A source such as `Hello ,world` can legitimately produce overlapping findings from the two new rules; the existing `WritingCorrection.applyAll` overlap contract remains authoritative, so the earlier safe range is applied and the overlapping finding is skipped until the next analysis.\n\nDefault-state compatibility is intentional: languages with no stored writing-rule override use the current six-rule registry defaults. A stored explicit non-empty or empty rule-ID set remains explicit and is not expanded during upgrade. **Reset rules to defaults** removes that override and therefore opts back into the current registry defaults.\n''',
    'README V2.6 writing section',
)
replace_once(
    'README.md',
    '''Run the core validation used by CI:\n\n```bash\nflutter pub get\nflutter analyze\nflutter test --reporter expanded\n```\n\nCheck formatting before committing:\n\n```bash\ndart format --output=none --set-exit-if-changed lib test\n```\n\nBuild the release web application when preparing a release:\n\n```bash\nflutter build web --release\n```\n''',
    '''Run the validation used by CI:\n\n```bash\nflutter pub get\ndart format --output=none --set-exit-if-changed lib test\nflutter analyze\nflutter test --reporter expanded\nflutter build web --release\n```\n\nThe tagged release workflow repeats those quality checks and uploads the generated web artifact.\n''',
    'README CI commands',
)
replace_once(
    'README.md',
    '│   ├── LANGUAGE_PACKS.md\n│   ├── PRIVACY.md',
    '│   ├── LANGUAGE_PACKS.md\n│   ├── PERFORMANCE.md\n│   ├── PRIVACY.md',
    'README performance doc tree',
)
replace_once(
    'README.md',
    '│   │   ├── settings_transfer_codec.dart\n│   │   ├── spell_checker_engine.dart',
    '│   │   ├── settings_transfer_codec.dart\n│   │   ├── spell_check_report.dart\n│   │   ├── spell_checker_engine.dart',
    'README spell report tree',
)
replace_once(
    'README.md',
    '│   ├── dictionary_preferences_test.dart\n│   ├── language_dictionary_codec_test.dart',
    '│   ├── bounded_analysis_widget_test.dart\n│   ├── dictionary_preferences_test.dart\n│   ├── language_dictionary_codec_test.dart',
    'README bounded widget tree',
)
replace_once(
    'README.md',
    '│   ├── spell_check_editing_controller_test.dart\n│   ├── spell_checker_test.dart',
    '│   ├── spell_check_editing_controller_test.dart\n│   ├── spell_check_report_test.dart\n│   ├── spell_checker_test.dart',
    'README spell report test tree',
)
replace_once(
    'README.md',
    '│   ├── writing_correction_test.dart\n│   ├── writing_preferences_test.dart',
    '│   ├── writing_catalogue_test.dart\n│   ├── writing_catalogue_widget_test.dart\n│   ├── writing_correction_test.dart\n│   ├── writing_preferences_test.dart',
    'README V2.6 test tree',
)

# Changelog and roadmap.
insert_before(
    'CHANGELOG.md',
    '## [2.5.0] - 2026-08-09\n',
    '''## [2.6.0] - 2026-08-09\n\n### Added\n\n- Public `MissingSpaceAfterPunctuationRule` with stable ID `missing-space-after-punctuation`.\n- Public `SpaceBeforePunctuationRule` with stable ID `space-before-punctuation`.\n- Unicode-letter-aware comma/semicolon missing-space detection with deterministic insertion replacements.\n- Conservative single-space-before-punctuation detection that leaves multi-space ownership to `repeated-space`.\n- Focused rule, registry, Unicode, source-range, repeated-punctuation-exclusion, multi-space-ownership, overlap, batch, widget, and undo regressions.\n- Permanent CI release-web build validation for every push/PR quality run.\n\n### Changed\n\n- Package version advances to `2.6.0+11`; About version advances to `2.6.0`.\n- The built-in English writing catalogue expands from four to six rules.\n- `WritingRuleRegistry.defaultEnabledRuleIds` now contains the two new Mechanics rule IDs.\n- Unset/default language profiles therefore use six built-in rules; explicit stored rule sets remain exactly explicit.\n- README/project tree and writing-rule/API/architecture/testing/privacy/security/release documentation describe the expanded catalogue and upgrade semantics.\n\n### Compatibility, correction safety, security, and privacy\n\n- No existing writing-rule ID, category, persistence key, Portable settings format, spelling API, or correction contract changes.\n- Repeated/clustered punctuation is excluded from the missing-space rule so the existing repeated-punctuation rule retains ownership.\n- Multi-space-before-punctuation runs are excluded from the new single-space rule so the existing repeated-space rule retains ownership.\n- New-rule overlaps still use the existing deterministic `WritingCorrection.applyAll` conflict policy; no widget bypasses source-range/stale/overlap checks.\n- No new runtime dependency, persistence payload, analytics, telemetry, network request, cloud grammar service, dynamic rule loading, or document upload is introduced.\n\n''',
    'V2.6 changelog',
)
insert_before(
    'docs/ROADMAP.md',
    '## Future 2.x direction\n',
    '''## 2.6 — Deterministic writing rule catalogue expansion\n\nStatus: implemented.\n\n- [x] Public missing-space-after-punctuation Mechanics rule.\n- [x] Public single-space-before-punctuation Mechanics rule.\n- [x] Unicode-letter support for the missing-space rule.\n- [x] Repeated-punctuation exclusion to avoid duplicate ownership.\n- [x] Multi-space exclusion to preserve repeated-space ownership.\n- [x] Six-rule built-in/default registry integration.\n- [x] Explicit stored rule sets remain unchanged across upgrade.\n- [x] Deterministic overlap handling through the existing batch-correction contract.\n- [x] Focused unit/registry/batch/widget/undo regression coverage.\n- [x] Permanent CI web-release build validation.\n- [x] Complete V2.6 API/writing/privacy/security/release documentation.\n\n''',
    'V2.6 roadmap',
)

# Writing rules contract.
replace_once(
    'docs/WRITING_RULES.md',
    '''repeated-word\nsentence-capitalization\nrepeated-space\nrepeated-punctuation\n''',
    '''repeated-word\nsentence-capitalization\nrepeated-space\nrepeated-punctuation\nmissing-space-after-punctuation\nspace-before-punctuation\n''',
    'stable writing rule IDs',
)
append_section(
    'docs/WRITING_RULES.md',
    '## V2.6 punctuation-spacing catalogue expansion',
    '''## V2.6 punctuation-spacing catalogue expansion\n\nV2.6 adds two public English Mechanics rules to `WritingRuleRegistry.builtIns` and therefore to `defaultEnabledRuleIds`.\n\n### `missing-space-after-punctuation`\n\n`MissingSpaceAfterPunctuationRule` matches a comma or semicolon followed immediately by a Unicode letter. Its issue range contains the punctuation plus following letter, and its replacement inserts exactly one ASCII space between them. Colons, periods, question marks, and exclamation marks are intentionally outside this automatic rule because their safe spacing needs more context.\n\nThe rule skips a candidate when another review punctuation character immediately precedes the matched comma/semicolon. This leaves repeated/clustered punctuation to `repeated-punctuation` rather than creating competing automatic findings for the same run.\n\n### `space-before-punctuation`\n\n`SpaceBeforePunctuationRule` matches one ASCII space directly before `, . ; : ! ?` and replaces that two-character range with the punctuation mark. It skips the candidate when another space or tab immediately precedes the matched space. Multi-space runs therefore remain owned by `repeated-space`; after a repeated-space correction and refreshed analysis, a remaining single stray punctuation space can be handled by the V2.6 rule.\n\n### Upgrade/default semantics\n\nNo storage migration writes new IDs into existing preferences. The existing three-state contract remains authoritative:\n\n```text\nmissing key       -> current registry defaults (now six built-in IDs)\nstored non-empty  -> explicit stored IDs only\nstored empty list -> explicit disable-all\n```\n\nA user with an explicit pre-V2.6 set does not silently gain the new rules. **Reset rules to defaults** clears the override and opts that language back into current registry defaults. Portable settings preserve the same missing-versus-explicit semantics.\n\n### Overlap example\n\n`Hello ,world` can produce `space-before-punctuation` on ` ,` and `missing-space-after-punctuation` on `,w`. Those ranges overlap at the comma. `WritingCorrection.applyAll` keeps its established deterministic ordering/overlap policy: the earlier source range is accepted and the overlapping later candidate is skipped. Re-analysis then exposes any remaining safe finding. V2.6 does not create a special-case mutation path.\n\n### Tests\n\n`test/writing_catalogue_test.dart` protects rule scope, Unicode behavior, exact ranges/replacements, registry defaults, ownership exclusions, and overlap/batch behavior. `test/writing_catalogue_widget_test.dart` protects unset-profile switches plus batch correction and one-step undo in the real Writing insights workflow.''',
)

# API/architecture/development/testing/user docs.
append_section(
    'docs/API.md',
    '# V2.6 writing catalogue APIs',
    '''# V2.6 writing catalogue APIs\n\n`package:spellchecker/writing.dart` now exports `MissingSpaceAfterPunctuationRule` and `SpaceBeforePunctuationRule`. Both implement the existing `WritingRule` contract, use stable IDs, report `WritingRuleCategory.mechanics`, support English via the `en` language identifier, produce exact non-empty source ranges, and provide deterministic automatic replacements.\n\nNo new analyzer or correction API is introduced. `WritingAnalyzer`, `WritingReviewQuery`, review presets, `WritingCorrection.apply/applyAll`, per-language preference IDs, and Portable settings continue to consume rules through their existing contracts.\n\nBecause both new rules are included in `WritingRuleRegistry.builtIns`, `defaultEnabledRuleIds` expands to six IDs. This changes only the existing **unset/default** preference state. Explicit stored sets and explicit empty sets keep their established meaning.''',
)
append_section(
    'docs/ARCHITECTURE.md',
    '# V2.6 writing catalogue ownership',
    '''# V2.6 writing catalogue ownership\n\nThe two new punctuation-spacing rules live in `lib/writing/rules/` and remain pure local analyzers. They do not add widget logic, persistence adapters, network boundaries, or a second correction engine.\n\nRule ownership is deliberately conservative:\n\n```text\nrepeated-punctuation              owns repeated/clustered punctuation runs\nrepeated-space                    owns runs of 2+ spaces\nmissing-space-after-punctuation   owns comma/semicolon + immediate letter\nspace-before-punctuation          owns one stray space + punctuation\n```\n\nWhen distinct rule ranges still overlap, the existing batch-correction ordering and overlap resolver is the sole mutation authority. The editor never merges or directly applies overlapping replacements itself.\n\nDefault registry expansion flows through the existing `_effectiveWritingRuleIds` behavior: missing preference uses current defaults, while explicit stored sets are intersected with supported registry IDs and remain explicit.''',
)
append_section(
    'docs/DEVELOPMENT.md',
    '## V2.6 writing catalogue development contract',
    '''## V2.6 writing catalogue development contract\n\nWhen adding or changing built-in rules, preserve stable IDs, exact source ranges, explicit language eligibility, deterministic replacements, and correction-engine ownership. Test adjacent/overlapping interactions with every automatic built-in whose range can intersect.\n\nFor punctuation/spacing changes specifically, test Unicode letters, repeated punctuation, multi-space runs, source-boundary positions, refreshed analysis after a skipped overlap, explicit stored preference sets, reset-to-default behavior, and one-step batch undo.\n\nDo not expand a rule's automatic scope merely to reduce the number of analysis passes if doing so introduces ambiguous prose interpretation. Narrow deterministic rules are preferred over broad speculative rewriting.''',
)
append_section(
    'docs/TESTING.md',
    '## V2.6 writing catalogue coverage',
    '''## V2.6 writing catalogue coverage\n\nFocused V2.6 tests:\n\n```bash\nflutter test test/writing_catalogue_test.dart\nflutter test test/writing_catalogue_widget_test.dart\n```\n\nThe core suite protects comma/semicolon insertion, Unicode following letters, already-correct spacing, repeated-punctuation exclusion, single-space-before-punctuation removal, multi-space ownership, six-rule registry/default membership, selective analyzer execution, and deterministic overlap handling across two analysis passes.\n\nThe widget suite protects new default switches for an unset profile and verifies that two non-overlapping V2.6 findings batch through the existing correction path and restore exactly with one Undo.\n\nPermanent CI now runs formatting, analyzer, the complete test suite, and `flutter build web --release` on every main push and pull request.''',
)
append_section(
    'docs/USER_GUIDE.md',
    '# Punctuation spacing rules — V2.6',
    '''# Punctuation spacing rules — V2.6\n\nWriting insights includes two additional English Mechanics checks.\n\n**Missing space after punctuation** suggests one space when a comma or semicolon is followed immediately by a letter, such as `hello,world` → `hello, world`. It does not automatically handle every punctuation type or repeated punctuation sequence.\n\n**Space before punctuation** removes one stray space before common punctuation, such as `hello , world` → `hello, world`. Runs of multiple spaces are handled first by the existing Repeated spaces rule.\n\nIf two safe findings overlap, **Apply all safe fixes** can apply one and report the overlapping finding as skipped. Reopen Writing insights after the correction to analyze the updated text. This is expected safety behavior, not data loss.\n\nIf you previously saved an explicit rule selection, the two new rules remain off unless they are part of that stored set. Use the switches to enable them or choose **Reset rules to defaults** to return the language to the current six-rule default catalogue.''',
)

# Privacy/security/support/contributing/releasing.
append_section(
    'docs/PRIVACY.md',
    '## V2.6 writing catalogue privacy behavior',
    '''## V2.6 writing catalogue privacy behavior\n\nThe new punctuation-spacing rules analyze the explicitly requested editor text in memory exactly like existing built-in rules. Their findings can contain a short exact source range and deterministic replacement, but SpellChecker does not persist or upload those findings.\n\nRegistry-default expansion does not write a migration record. Existing explicit rule-ID preferences remain unchanged; missing preferences simply resolve against the current built-in defaults at runtime. V2.6 adds no telemetry, analytics, remote grammar/spelling service, document upload, account system, or runtime dependency.''',
)
append_section(
    'SECURITY.md',
    '## V2.6 writing catalogue safety boundary',
    '''## V2.6 writing catalogue safety boundary\n\nThe new rule IDs are compiled source-controlled metadata, not dynamic code-loading instructions. Automatic punctuation-spacing replacements still pass through exact-source validation and the shared deterministic overlap resolver.\n\nRepeated/clustered punctuation and multi-space ownership exclusions reduce competing automatic ranges without weakening the existing rules. An overlap that remains is skipped by `WritingCorrection.applyAll` rather than being merged heuristically.\n\nNo dynamic plugin loading, remote rule download, executable imported rule data, network grammar service, or new runtime package is introduced.''',
)
append_section(
    'SUPPORT.md',
    '# V2.6 punctuation-spacing reports',
    '''# V2.6 punctuation-spacing reports\n\nFor a V2.6 writing-rule issue, include synthetic text, selected language, the rule ID (`missing-space-after-punctuation` or `space-before-punctuation`), expected source range/replacement, enabled-rule IDs when relevant, and whether another automatic finding overlapped.\n\nFor upgrade/default reports, state whether the language's writing-rule preference key was missing, explicitly non-empty, or explicitly empty. Do not post a full preference dump containing private vocabulary or document data.''',
)
append_section(
    'CONTRIBUTING.md',
    '## V2.6 writing catalogue changes',
    '''## V2.6 writing catalogue changes\n\nNew deterministic writing rules must define a stable ID, narrow user-readable scope, explicit supported language IDs, exact source ranges/original text, and deterministic replacements only when the documented transformation is safe. Review overlap ownership with existing rules before adding a new automatic range.\n\nChanges that expand `WritingRuleRegistry.defaultEnabledRuleIds` must document unset/default versus explicit-set upgrade behavior and include persistence/widget regressions where relevant.''',
)
replace_once(
    'docs/RELEASING.md',
    'Current V2.5 release:\n\n```text\n2.5.0+10\n```',
    'Current V2.6 release:\n\n```text\n2.6.0+11\n```',
    'release current version',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v2.5.0 -m "SpellChecker v2.5.0"\ngit push origin v2.5.0',
    'git tag -a v2.6.0 -m "SpellChecker v2.6.0"\ngit push origin v2.6.0',
    'release tag example',
)
append_section(
    'docs/RELEASING.md',
    '## V2.6 writing catalogue release checks',
    '''## V2.6 writing catalogue release checks\n\nBefore tagging V2.6-compatible code, verify both new stable rule IDs/exports, exact range/replacement tests, Unicode following-letter behavior, repeated-punctuation/multi-space exclusions, six-rule default registry membership, explicit stored-set compatibility, overlap/batch behavior, widget batch+undo flow, `2.6.0+11` / About `2.6.0`, and complete documentation.\n\nNormal CI now includes the release web build, so the exact release PR head must pass formatting, analyzer, complete tests, and `flutter build web --release`. The tagged workflow repeats quality/build validation and uploads the web artifact.''',
)
replace_once(
    'docs/RELEASING.md',
    '''Normal CI now requires all of these checks to pass:\n\n```bash\nflutter pub get\ndart format --output=none --set-exit-if-changed lib test\nflutter analyze\nflutter test --reporter expanded\n```\n\nThe tagged release workflow runs those same quality checks and additionally builds the release web application:\n\n```bash\nflutter build web --release\n```\n''',
    '''Normal CI now requires all of these checks to pass on the exact push/PR tree:\n\n```bash\nflutter pub get\ndart format --output=none --set-exit-if-changed lib test\nflutter analyze\nflutter test --reporter expanded\nflutter build web --release\n```\n\nThe tagged release workflow repeats the same quality/build checks and uploads the generated web application as the release artifact.\n''',
    'release CI policy',
)

# Web/PWA and PR review metadata.
replace_once(
    'web/index.html',
    'bounded large-document spelling results, filtered batch-safe local fixes',
    'bounded large-document spelling results, expanded deterministic punctuation-spacing rules, filtered batch-safe local fixes',
    'web V2.6 metadata',
)
replace_once(
    'web/manifest.json',
    'bounded large-document spelling results, filtered batch-safe local fixes',
    'bounded large-document spelling results, expanded deterministic punctuation-spacing rules, filtered batch-safe local fixes',
    'manifest V2.6 metadata',
)
append_section(
    '.github/pull_request_template.md',
    '## V2.6 writing catalogue',
    '''## V2.6 writing catalogue\n\nComplete when relevant.\n\n- [ ] New/changed rule IDs are stable and documented.\n- [ ] Automatic scope is narrow, deterministic, and language-explicit.\n- [ ] Exact source ranges/original text and replacements are tested.\n- [ ] Interaction/overlap ownership with existing automatic rules is tested.\n- [ ] Unset/default versus explicit stored rule-set behavior is preserved.\n- [ ] Batch correction still uses the shared stale/overlap/undo contract.\n- [ ] No rule-specific widget mutation path, remote processing, telemetry, or dynamic code loading was introduced.''',
)

# README documentation index: add performance if not already listed there.
readme = Path('README.md')
text = readme.read_text()
if '- [Performance and large-document behavior](docs/PERFORMANCE.md)' not in text:
    marker = '- [Language packs](docs/LANGUAGE_PACKS.md)\n'
    if text.count(marker) != 1:
        raise RuntimeError('README documentation index language marker mismatch')
    text = text.replace(
        marker,
        marker + '- [Performance and large-document behavior](docs/PERFORMANCE.md)\n',
        1,
    )
    readme.write_text(text)

print('V2.6 release materialization completed successfully.')
