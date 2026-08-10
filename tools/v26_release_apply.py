from pathlib import Path


def replace_once(path_name: str, old: str, new: str, label: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(old, new, 1))


def insert_before(path_name: str, marker: str, section: str, heading: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if heading in text:
        return
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(f'{path}: insert marker: expected exactly one, found {count}')
    path.write_text(text.replace(marker, section.rstrip() + '\n\n' + marker, 1))


def append_section(path_name: str, section: str, heading: str) -> None:
    path = Path(path_name)
    text = path.read_text()
    if heading in text:
        return
    path.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')


replace_once('pubspec.yaml', 'version: 2.5.0+10', 'version: 2.6.0+11', 'package version')
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "applicationVersion: '2.5.0'",
    "applicationVersion: '2.6.0'",
    'About version',
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    'categorized local writing rules, temporary review presets/search/filters,',
    'expanded deterministic local writing rules, temporary review presets/search/filters,',
    'About catalogue wording',
)

# README release identity and rule catalogue.
replace_once('README.md', '`2.5.0+10`', '`2.6.0+11`', 'README current version')
replace_once(
    'README.md',
    'Version 2.5 is the **Bounded Analysis & Large-Document Safety** release. It keeps V2.4 suggestion-ranker extensibility and every existing spelling/writing/persistence contract while adding public `SpellCheckReport` metadata and `SpellCheckerEngine.analyze()` for optional bounded issue capture. The built-in editor captures at most 200 spelling issues, labels genuinely truncated results as `200+`, and disables **Replace all** when the checked occurrence set is incomplete. No persistence format, network behavior, or runtime dependency changes in V2.5.',
    'Version 2.6 is the **Deterministic Writing Rule Expansion** release. It keeps the V2.5 bounded spelling contract and every existing persistence/correction safety guarantee while expanding the built-in English Writing insights catalogue with **Punctuation spacing** and **Trailing whitespace**. The specialized spacing rules own punctuation-adjacent and line/document-end whitespace ranges so batch correction does not produce conflicting collapse-versus-remove fixes. No persistence format, network behavior, or runtime dependency changes in V2.6.',
    'README release paragraph',
)
replace_once(
    'README.md',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, and repeated-punctuation rules.',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, trailing-whitespace, and repeated-punctuation rules.',
    'README highlight catalogue',
)
replace_once(
    'README.md',
    '- Repeated horizontal spaces.\n- Repeated identical punctuation.',
    '- Repeated interior horizontal spaces.\n- Horizontal whitespace before common punctuation.\n- Trailing horizontal whitespace at line/document ends.\n- Repeated identical punctuation.',
    'README Writing insights list',
)
insert_before(
    'README.md',
    '### Review filters — V2.2',
    '''### Expanded deterministic mechanics — V2.6

Writing insights now includes **Punctuation spacing** (`punctuation-spacing`) and **Trailing whitespace** (`trailing-whitespace`) for both built-in English packs. Both rules use exact source ranges and empty-string automatic replacements, so individual and batch fixes continue through the existing stale-range-safe `WritingCorrection` APIs.

`Repeated spaces` remains responsible for repeated interior spaces, but deliberately does not emit for a run immediately before common punctuation or at a line/document ending. Those ranges belong to the V2.6 specialized rules. This prevents two automatic rules from proposing incompatible fixes for the same characters while leaving the global V2.1 overlap policy unchanged.

Users whose per-language rule preference is **unset/default** receive the expanded registry defaults. An explicit saved rule list—including an explicit empty list—remains authoritative and is not silently expanded. **Reset rules to defaults** clears the stored override and therefore opts that language back into the current six-rule defaults.''',
    '### Expanded deterministic mechanics — V2.6',
)

# Changelog.
insert_before(
    'CHANGELOG.md',
    '## [2.5.0] - 2026-08-09',
    '''## [2.6.0] - 2026-08-10

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
- V2.6 adds no runtime dependency, network request, telemetry, cloud writing service, dynamic rule loading, or account behavior.''',
    '## [2.6.0] - 2026-08-10',
)

# Roadmap.
insert_before(
    'docs/ROADMAP.md',
    '## Future 2.x direction',
    '''## 2.6 — Deterministic writing rule expansion

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

''',
    '## 2.6 — Deterministic writing rule expansion',
)

# Writing rules canonical documentation.
replace_once(
    'docs/WRITING_RULES.md',
    'repeated-space\nrepeated-punctuation',
    'repeated-space\npunctuation-spacing\ntrailing-whitespace\nrepeated-punctuation',
    'writing built-in IDs',
)
append_section(
    'docs/WRITING_RULES.md',
    '''## V2.6 deterministic spacing rules

V2.6 expands `WritingRuleRegistry.builtIns` with two English Mechanics rules:

```text
punctuation-spacing
trailing-whitespace
```

### Punctuation spacing

`PunctuationSpacingRule` matches one or more horizontal spaces/tabs immediately before `, . ; : ! ?`. Its `originalText` is exactly the whitespace run and its deterministic automatic replacement is the empty string. It does not rewrite the punctuation itself.

### Trailing whitespace

`TrailingWhitespaceRule` matches horizontal spaces/tabs immediately before LF/CRLF line endings or at the document end. Newline characters are not part of the issue range; the automatic replacement removes only the trailing horizontal whitespace.

### Non-overlapping ownership

`RepeatedSpaceRule` now matches repeated **interior** spaces only. It deliberately excludes repeated runs immediately before common punctuation and before line/document endings. Those source ranges belong to the V2.6 specialized rules. The separation prevents a batch from receiving both “collapse to one space” and “remove all whitespace” candidates for the same range.

This does not change `WritingCorrection.applyAll` overlap semantics. Start/end/rule-ID ordering and conservative overlap skipping remain the global safety contract for genuinely overlapping findings from independent rules.

### Preference compatibility

The two new IDs are members of `WritingRuleRegistry.defaultEnabledRuleIds`. Therefore:

```text
unset preference      -> current six-rule defaults, including V2.6 rules
explicit non-empty    -> exactly the stored supported IDs; no silent expansion
explicit empty list   -> all rules disabled; no silent expansion
Reset rules           -> clears override -> current six-rule defaults
```

The existing `spellchecker.writing_rule_ids.v1.<language-id>` key meaning and storage format do not change. Both rules declare `en`, so they support the built-in `en-US` and `en-GB` packs.

### V2.6 regression requirements

Changes to either spacing rule must keep tests for exact source ranges, LF/CRLF/document-end handling, punctuation adjacency, interior-space ownership, English pack support, default registry membership, safe batch composition, Writing insights visibility, and one-step undo.''',
    '## V2.6 deterministic spacing rules',
)

# Cross-cutting technical docs.
append_section(
    'docs/API.md',
    '''## V2.6 writing-rule API additions

`package:spellchecker/writing.dart` now exports `PunctuationSpacingRule` and `TrailingWhitespaceRule`. Their stable IDs are `punctuation-spacing` and `trailing-whitespace` respectively. Both implement the existing `WritingRule` contract; no abstract interface member was added, so external rule implementations remain source-compatible.

Both rules return exact, non-empty source ranges and deterministic empty-string replacements. `WritingRuleRegistry.builtIns` and `defaultEnabledRuleIds` now contain six built-ins. Existing explicit per-language stored rule-ID sets remain explicit and are intersected with supported registered IDs as before.

`RepeatedSpaceRule` retains its public ID/API but narrows its matching responsibility to repeated interior spaces, delegating punctuation-adjacent and terminal whitespace ranges to the specialized V2.6 rules.''',
    '## V2.6 writing-rule API additions',
)
append_section(
    'docs/ARCHITECTURE.md',
    '''## V2.6 spacing-rule ownership boundary

The writing analyzer still executes independent deterministic rules and sorts their findings before correction. V2.6 avoids a new conflict-resolution layer by assigning mutually exclusive whitespace responsibilities: `RepeatedSpaceRule` owns repeated interior spaces, `PunctuationSpacingRule` owns horizontal whitespace before common punctuation, and `TrailingWhitespaceRule` owns horizontal whitespace before line/document endings.

All findings continue through the existing `WritingCorrection` safety boundary. Widgets do not directly mutate source ranges, and V2.6 introduces no new persistence, service, network, or background-processing layer.''',
    '## V2.6 spacing-rule ownership boundary',
)
append_section(
    'docs/DEVELOPMENT.md',
    '''## V2.6 writing-rule development checks

When changing whitespace-oriented rules, test ownership boundaries as well as positive matches. A new automatic rule must not accidentally create a second incompatible replacement for an exact range already owned by another built-in. Use synthetic LF, CRLF, punctuation-adjacent, interior-space, and document-end cases. Keep issue ranges exact and keep widget tests on the real lazy Writing insights `ListView`; scroll controls into view rather than making production lists eager for tests.''',
    '## V2.6 writing-rule development checks',
)
append_section(
    'docs/TESTING.md',
    '''## V2.6 deterministic writing-rule coverage

`test/v26_writing_rules_test.dart` and the expanded `test/writing_rules_test.dart` protect punctuation-spacing/trailing-whitespace matching, exact source ranges, LF/CRLF/document-end behavior, registry/default enablement, English pack eligibility, non-overlapping repeated-space ownership, batch composition with repeated punctuation, Writing insights switch visibility, and one-step undo.

The legacy `test/writing_widget_test.dart` continues to exercise the real lazy dialog. Because the built-in catalogue now contains six rules, batch-action tests scroll farther through the actual list before locating/tapping actions; no eager test-only production layout is introduced.''',
    '## V2.6 deterministic writing-rule coverage',
)
append_section(
    'docs/USER_GUIDE.md',
    '''## V2.6 punctuation and trailing-whitespace checks

Writing insights includes **Punctuation spacing** and **Trailing whitespace** for English (US) and English (UK). Punctuation spacing removes spaces/tabs immediately before common punctuation such as commas, periods, colons, semicolons, question marks, and exclamation marks. Trailing whitespace removes spaces/tabs at line endings or at the end of the document without removing newline characters.

Both are normal per-language writing-rule switches. If you have never customized rule choices, they are enabled with the current defaults. If you previously saved an explicit rule list, SpellChecker preserves that list instead of silently adding new rules; use **Reset rules to defaults** if you want the current complete default catalogue.''',
    '## V2.6 punctuation and trailing-whitespace checks',
)
append_section(
    'docs/LANGUAGE_PACKS.md',
    '''## V2.6 English writing-rule eligibility

`punctuation-spacing` and `trailing-whitespace` declare the language code `en`, so both built-in English (US) and English (UK) packs are eligible. V2.6 does not change spelling tokenization, normalization, dictionary contents, language IDs, personal vocabulary namespaces, or dictionary transfer formats.''',
    '## V2.6 English writing-rule eligibility',
)
append_section(
    'docs/ACCESSIBILITY.md',
    '''## V2.6 Writing insights accessibility

The two new rules appear as the same labeled `SwitchListTile` controls used by existing writing rules, so they remain keyboard/focus/assistive-technology reachable. Their findings use the existing semantic finding-card and safe-fix controls. Expanded catalogue tests intentionally scroll the real lazy dialog so narrow/small viewports remain part of the supported interaction model.''',
    '## V2.6 Writing insights accessibility',
)
append_section(
    'docs/TROUBLESHOOTING.md',
    '''## V2.6 spacing rules are missing or inactive

If **Punctuation spacing** or **Trailing whitespace** is not enabled after upgrading, check whether the language has an explicit saved writing-rule override. V2.6 preserves explicit non-empty and explicit empty sets. Use **Reset rules to defaults** to clear that override and opt back into the current registry defaults. The two rules are currently eligible for the built-in English (US) and English (UK) packs only.''',
    '## V2.6 spacing rules are missing or inactive',
)
append_section(
    'docs/PRIVACY.md',
    '''## V2.6 writing-rule privacy boundary

Punctuation-spacing and trailing-whitespace analysis runs locally against the in-memory editor text through the existing `WritingAnalyzer`. Findings/source snippets remain memory-only. V2.6 persists no new value: only the existing per-language rule-ID preferences can reference the two new stable IDs after a user changes/reset rule choices. No document text, whitespace finding, correction plan, analytics event, telemetry, or network request is added.''',
    '## V2.6 writing-rule privacy boundary',
)
append_section(
    'SECURITY.md',
    '''## V2.6 deterministic rule safety

The two new spacing rules are source-controlled Dart implementations compiled with the application. They do not interpret or execute document content, load external rules, or bypass `WritingCorrection` source validation. Specialized ownership of punctuation-adjacent/trailing whitespace prevents conflicting built-in automatic replacements for the same exact source range. V2.6 adds no dependency, permission, remote service, telemetry, or dynamic-code boundary.''',
    '## V2.6 deterministic rule safety',
)
append_section(
    'SUPPORT.md',
    '''## V2.6 spacing-rule reports

For punctuation-spacing/trailing-whitespace bugs, provide a minimal synthetic sample and say whether it involves interior repeated spaces, whitespace immediately before punctuation, LF/CRLF line endings, or document-end whitespace. Include the selected English pack and whether rule choices were unset/default or explicitly saved. Do not attach a private document when a short synthetic string can reproduce the issue.''',
    '## V2.6 spacing-rule reports',
)
append_section(
    'CONTRIBUTING.md',
    '''## V2.6 writing-rule catalogue contributions

Whitespace-rule changes must document source-range ownership and include interaction tests with existing automatic rules. Do not rely on rule-ID alphabetical ordering to repair avoidable overlap: when two built-ins have distinct semantic responsibilities, prefer non-overlapping matching boundaries. Preserve stable shipped IDs, per-language explicit preference semantics, deterministic fixes, and the existing correction safety/undo pipeline.''',
    '## V2.6 writing-rule catalogue contributions',
)
append_section(
    '.github/pull_request_template.md',
    '''## V2.6 deterministic writing-rule checklist

Complete when relevant.

- [ ] New/changed built-in rule IDs are stable and documented.
- [ ] Exact source ranges and automatic replacements have focused tests.
- [ ] English pack eligibility is explicit/tested when applicable.
- [ ] Rule ownership does not create avoidable conflicting exact-range replacements.
- [ ] Unset/default versus explicit persisted rule-list semantics remain compatible.
- [ ] Writing insights lazy-list accessibility/viewport behavior is exercised realistically.
- [ ] Batch composition and one-step undo remain safe.
- [ ] No new persistence/network/telemetry/runtime dependency is introduced unintentionally.
- [ ] No temporary `tools/v26_*` or `.github/workflows/v26-*` release artifact remains in the final tree.''',
    '## V2.6 deterministic writing-rule checklist',
)

# Release guide identity and explicit smoke checks.
replace_once(
    'docs/RELEASING.md',
    'Current V2.5 release:',
    'Current V2.6 release:',
    'releasing current release heading',
)
replace_once('docs/RELEASING.md', '2.5.0+10', '2.6.0+11', 'releasing current version')
replace_once(
    'docs/RELEASING.md',
    'git tag -a v2.5.0 -m "SpellChecker v2.5.0"\ngit push origin v2.5.0',
    'git tag -a v2.6.0 -m "SpellChecker v2.6.0"\ngit push origin v2.6.0',
    'releasing tag example',
)
append_section(
    'docs/RELEASING.md',
    '''## V2.6 release checks

Verify package/About versions `2.6.0+11` / `2.6.0`, both stable new rule IDs, six built-in registry/default IDs, punctuation/trailing exact-range behavior, repeated-space non-overlap ownership, explicit rule-preference compatibility, focused V2.6 tests, complete writing tests, complete regression suite, and `flutter build web --release`.

Smoke-test synthetic input containing interior repeated spaces, spaces before punctuation, LF/CRLF trailing whitespace, document-end whitespace, and repeated punctuation. Confirm **Apply all safe fixes** yields the expected complete text and one **Undo correction** restores the exact original. Confirm an explicit old saved rule list does not silently gain V2.6 IDs, while **Reset rules to defaults** makes the current six-rule defaults active.

Before tagging, confirm the tracked tree has no `tools/v26_*` helper and no `.github/workflows/v26-*` temporary gate/recovery workflow.''',
    '## V2.6 release checks',
)

# Web metadata.
replace_once(
    'web/index.html',
    'categorized local writing rules',
    'expanded deterministic local writing rules',
    'web writing description',
) if 'categorized local writing rules' in Path('web/index.html').read_text() else replace_once(
    'web/index.html',
    'Writing insights review presets, portable non-document preferences, bounded large-document spelling results,',
    'Writing insights review presets plus expanded punctuation/trailing-whitespace rules, portable non-document preferences, bounded large-document spelling results,',
    'web writing description alternate',
)
replace_once(
    'web/manifest.json',
    'Writing insights review presets, portable non-document preferences, bounded large-document spelling results,',
    'Writing insights review presets plus expanded punctuation/trailing-whitespace rules, portable non-document preferences, bounded large-document spelling results,',
    'manifest writing description',
)
