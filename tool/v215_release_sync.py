from __future__ import annotations

import json
from pathlib import Path

RELEASE = '2.15.0+20'
ABOUT = '2.15.0'


def read(path: str) -> str:
    return Path(path).read_text()


def write(path: str, text: str) -> None:
    Path(path).write_text(text)


def require_once(path: str, needle: str) -> None:
    count = read(path).count(needle)
    if count != 1:
        raise SystemExit(f'{path}: expected exactly one anchor {needle!r}, found {count}')


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path}: expected exactly one replacement anchor {old!r}, found {count}')
    write(path, text.replace(old, new, 1))


def insert_after_heading(path: str, section: str) -> None:
    text = read(path)
    if '## V2.15' in text:
        raise SystemExit(f'{path}: V2.15 section already present')
    first_newline = text.find('\n')
    if first_newline < 0 or not text.startswith('# '):
        raise SystemExit(f'{path}: expected Markdown H1')
    write(path, text[: first_newline + 1] + '\n' + section.strip() + '\n' + text[first_newline + 1 :])


# Preflight every release-sensitive anchor before any writes.
require_once('pubspec.yaml', 'version: 2.15.0+20')
require_once('lib/features/editor/spell_checker_page.dart', "applicationVersion: '2.14.0'")
require_once('lib/features/editor/spell_checker_page.dart', 'advisory unmatched-parenthesis and unmatched-square-bracket diagnostics')
require_once('test/widget_test.dart', 'About dialog reports the current V2.14 release')
require_once('test/widget_test.dart', "find.textContaining('2.14.0')")
require_once('README.md', '`2.14.0+19`')
require_once('README.md', 'Version 2.14 is the **Unmatched Square Bracket Diagnostics** release.')
require_once('CHANGELOG.md', '## [2.14.0] - 2026-08-15')
require_once('what_changed.md', '# What Changed')
require_once('docs/WRITING_RULES.md', 'unmatched-square-bracket')
require_once('web/manifest.json', 'unmatched-square-bracket')
require_once('web/index.html', 'unmatched-square-bracket')

# About source and regression.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "applicationVersion: '2.14.0'",
    "applicationVersion: '2.15.0'",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    'advisory unmatched-parenthesis and unmatched-square-bracket diagnostics',
    'advisory unmatched-parenthesis, unmatched-square-bracket, and unmatched-curly-brace diagnostics',
)
replace_once(
    'test/widget_test.dart',
    'About dialog reports the current V2.14 release',
    'About dialog reports the current V2.15 release',
)
replace_once(
    'test/widget_test.dart',
    "find.textContaining('2.14.0')",
    "find.textContaining('2.15.0')",
)

# Changelog.
changelog_entry = '''## [2.15.0] - 2026-08-15

### Added
- Added public advisory-only `UnmatchedCurlyBraceRule` with stable ID `unmatched-curly-brace` for deterministic literal `{` / `}` balancing in both built-in English packs.
- Expanded the built-in/default writing-rule catalogue from nine rules to ten while preserving explicit V2.14 nine-rule overrides exactly.
- Added focused source-ownership, non-BMP UTF-16 offset, malformed-order, bounded-total, diagnostic-privacy, review-filter, benchmark, Portable-settings, editor, and 5,000-level stress regressions.

### Changed
- Writing insights reset/unset preferences now resolve to the ten-rule registry; explicit historical overrides remain authoritative.
- Benchmark workload identity and exact per-rule totals now include `unmatched-curly-brace`.
- Hardened the shared Writing insights lazy-item test helper and deferred `.first` selection until the safe-fix action is actually built.
- Advanced package identity to `2.15.0+20` and About identity to `2.15.0`.

### Safety and compatibility
- Unmatched curly braces are warning-level and advisory-only. They have no guessed replacement, are hidden by **Automatic fixes only**, and are skipped by batch correction while independent deterministic fixes still apply.
- Parenthesis, square-bracket, and curly-brace diagnostics retain independent one-character source ownership.
- Portable settings format/version, preference-key family, runtime dependencies, network behavior, telemetry, account behavior, and document persistence are unchanged.

'''
replace_once('CHANGELOG.md', '## [2.14.0] - 2026-08-15', changelog_entry + '## [2.14.0] - 2026-08-15')

# README current-release identity and current catalogue surfaces.
replace_once(
    'README.md',
    '- V2.14 advisory unmatched-square-bracket diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.13 preference compatibility, and a nine-rule default registry.',
    '- V2.15 advisory unmatched-curly-brace diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.14 preference compatibility, and a ten-rule default registry.\n- V2.14 advisory unmatched-square-bracket diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.13 preference compatibility, and its historical nine-rule default registry.',
)
replace_once(
    'README.md',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, unmatched-parenthesis, and unmatched-square-bracket rules.',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, unmatched-parenthesis, unmatched-square-bracket, and unmatched-curly-brace rules.',
)
old_current = '''`2.14.0+19`

Version 2.14 is the **Unmatched Square Bracket Diagnostics** release. It adds the ninth built-in writing rule, `unmatched-square-bracket`, for deterministic local reporting of literal `[` and `]` characters that cannot be paired. The rule is warning-level and advisory-only: it does not guess whether an unmatched bracket should be inserted, deleted, moved, or rewritten. Unset/reset rule preferences adopt the nine-rule registry while explicit V2.13 eight-rule choices remain exact. No persistence-format, runtime-dependency, telemetry, account, or application-network expansion is introduced.

## Unmatched square bracket diagnostics — V2.14'''
new_current = '''`2.15.0+20`

Version 2.15 is the **Unmatched Curly Brace Diagnostics** release. It adds the tenth built-in writing rule, `unmatched-curly-brace`, for deterministic local reporting of literal `{` and `}` characters that cannot be paired. The rule is warning-level and advisory-only: it does not guess whether an unmatched brace should be inserted, deleted, moved, or rewritten. Unset/reset rule preferences adopt the ten-rule registry while explicit V2.14 nine-rule choices remain exact. No persistence-format, runtime-dependency, telemetry, account, or application-network expansion is introduced.

## Unmatched curly brace diagnostics — V2.15

`UnmatchedCurlyBraceRule` balances literal curly braces iteratively, accepts nesting, and reports each unmatched brace with a one-character UTF-16 source range. A closing brace without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. Non-BMP offsets and 5,000 levels of nesting are covered by focused regressions.

The rule deliberately has no automatic replacement. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Parentheses and square brackets remain owned by their existing structural rules. Syntax-aware programming/template parsing remains outside V2.15 scope.

Existing explicit nine-rule V2.14 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current ten-rule registry. Portable settings keep the same format version and preserve both historical explicit sets and explicit V2.15 ten-rule sets.

See [V2.15 unmatched curly brace diagnostics](docs/V2_15_UNMATCHED_CURLY_BRACE.md) and [Writing rules](docs/WRITING_RULES.md).

## Unmatched square bracket diagnostics — V2.14'''
replace_once('README.md', old_current, new_current)

# Detailed engineering ledger requested by the project owner.
ledger = '''## V2.15 — Unmatched Curly Brace Diagnostics

Release identity: package `2.15.0+20`; About `2.15.0`.

### Production rule and public API
- Added `lib/writing/rules/unmatched_curly_brace_rule.dart` with public `UnmatchedCurlyBraceRule`.
- Stable rule ID is `unmatched-curly-brace`; display name is `Unmatched curly brace`.
- Exported the rule through `package:spellchecker/writing.dart`.
- Registered it as the tenth built-in/default rule in `WritingRuleRegistry` after the V2.14 square-bracket rule.
- The rule supports language code `en`, so both built-in `en-US` and `en-GB` packs are eligible.

### Deterministic scanner and source ownership
- The implementation scans literal UTF-16 code-unit indexes iteratively from left to right.
- `{` pushes its source index; `}` consumes the most recent available opening; a closing brace with an empty opening stack is unmatched immediately; openings remaining after the scan are unmatched.
- Unmatched indexes are source-sorted before issue emission.
- Every issue owns exactly one ASCII brace: `start` is the brace UTF-16 offset, `end == start + 1`, and `originalText` is `{` or `}`.
- Non-BMP regression coverage verifies that the `}` in `😀}` begins at UTF-16 offset 2.
- Parenthesis, square-bracket, and curly-brace rules are independent delimiter families and do not claim each other's characters.

### Advisory-only correction boundary
- Findings are warning-level with no replacement and `hasAutomaticFix == false`.
- SpellChecker does not guess whether the correct edit is insertion, deletion, movement, or a larger rewrite.
- **Automatic fixes only** excludes curly-brace findings.
- A curly-brace-only document exposes no apply-all safe-fix action.
- `WritingCorrection.applyAll` skips the advisory finding while applying independent deterministic fixes such as repeated-space corrections.

### Catalogue and preference compatibility
- The built-in/default writing catalogue expands from nine rules to ten.
- Unset preferences continue to mean “follow current registry defaults,” now all ten supported rules.
- **Reset rules to defaults** clears the explicit per-language override and therefore adopts the current ten-rule registry.
- Explicit V2.14 nine-rule overrides remain exactly nine rules and do not silently gain `unmatched-curly-brace`.
- Older explicit sets and explicit empty/disable-all sets remain authoritative.
- Preference key family `spellchecker.writing_rule_ids.v1.<language>` is unchanged.

### Portable settings compatibility
- Portable settings format/version is unchanged.
- A V2.14 explicit nine-rule override round-trips unchanged and excludes the V2.15 ID.
- An explicit ten-rule V2.15 set round-trips with `unmatched-curly-brace` intact.
- An unset override remains unset rather than being serialized as a frozen ten-rule list.

### Bounded exact analysis
- Curly-brace findings use the existing bounded `WritingAnalysisResult` model.
- Exactly-at-limit results remain complete; truncation is true only when at least one additional finding exists.
- `totalIssueCount` and `totalIssueCountByRule['unmatched-curly-brace']` remain exact even when retained findings are bounded.
- Global bounded ordering still retains the earliest source-ordered findings across all enabled writing rules.

### Privacy-safe diagnostics
- `WritingAnalysisDiagnosticSummary` includes the stable curly-brace rule metadata and captured/total counts.
- Focused regressions verify private surrounding editor phrases are not copied into diagnostic summaries.
- No finding excerpt, replacement text, source document, telemetry payload, or network request was added.

### Benchmark and stress coverage
- Benchmark writing-rule identity now contains ten stable sorted IDs including `unmatched-curly-brace`.
- Clean benchmark workloads materialize an explicit zero for the new rule.
- A controlled benchmark corpus verifies captured count 1, exact total 1, per-rule total 1, and no truncation.
- Iterative stress tests cover 5,000 balanced nesting levels and 5,000 unmatched opening braces without recursive scanning.

### Writing insights and review integration
- The rule participates in the existing Mechanics category, rule search, finding search, exact visible/captured/total semantics, rule switch, per-language persistence, reset-to-defaults, Portable settings, and advisory presentation.
- Searching `curly brace` matches the rule/finding metadata.
- **Automatic fixes only** truthfully hides the advisory finding.
- Explicit disable of `unmatched-curly-brace` persists while other current defaults remain enabled.

### Catalogue-expansion widget regression hardening
- Adding the tenth rule exposed a historical widget-test assumption in `test/writing_widget_test.dart`, not a production editor failure.
- The shared lazy-build helper received a larger bounded search budget for the taller Writing insights catalogue.
- The actual blocker was an eager `find.text('Apply safe fix').first`: `.first` was evaluated while the lazy item had zero matches, so the test threw before scrolling could build it.
- The regression now scrolls using the zero-or-more base finder and selects `.first` only after the target exists.
- Historical V2.14 test titles were made expansion-safe while their exact saved nine-rule compatibility fixtures remain unchanged.

### Focused permanent regression files
- `test/unmatched_curly_brace_rule_test.dart`
- `test/v215_unmatched_curly_brace_integration_test.dart`
- `test/v215_bounded_curly_brace_analysis_test.dart`
- `test/v215_writing_diagnostic_summary_test.dart`
- `test/v215_curly_brace_stress_test.dart`
- `test/v215_review_query_curly_brace_test.dart`
- `test/v215_benchmark_curly_brace_test.dart`
- `test/v215_settings_transfer_rule_compatibility_test.dart`
- `test/v215_rule_preference_compatibility_widget_test.dart`
- `test/v215_unmatched_curly_brace_widget_test.dart`
- current catalogue coverage in `test/writing_rules_test.dart` and `test/analysis_benchmark_runner_test.dart`
- expansion-safe historical V2.14 registry/preferences/settings regressions
- shared lazy Writing insights finder regression in `test/writing_widget_test.dart`.

### Deliberate parser limitation
- `UnmatchedCurlyBraceRule` is a literal delimiter balancer, not a programming-language, template-language, Markdown, mathematics, URL, citation, quotation, or domain-specific parser.
- V2.15 does not heuristically suppress braces inside code-like/template-like text. A future syntax-aware exclusion requires an explicit parser/ownership contract and corpus rather than guessed mutation.

### Runtime, privacy, and format boundary
- No runtime dependency was added; direct application dependencies remain Flutter and `shared_preferences`.
- No new application-network behavior, cloud grammar service, telemetry, account flow, background upload, hidden clipboard action, or document persistence was added.
- No preference-key family, Portable-settings format version, diagnostic-summary format version, or correction-engine fork was added.

### Functional validation evidence
- Permanent CI run `31876071657` passed package resolution, canonical Dart formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on owner-authored V2.15 head `d82a8e68a0fce15601f8dfe3ae56a17580e41363`.
- Earlier red runs were retained as engineering evidence: the first stopped at canonical formatting; later runs exposed and isolated the lazy `.first` widget-test bug described above. No release identity was stamped until the corrected ten-rule implementation passed the complete functional gate.

'''
replace_once('what_changed.md', '# What Changed\n', '# What Changed\n\n' + ledger)

# Tailored V2.15 notes across maintained permanent docs.
sections = {
    '.github/pull_request_template.md': '''## V2.15 review note\nFor writing-rule catalogue changes, reviewers should verify deterministic source ownership, advisory-vs-automatic correction safety, explicit historical rule-set compatibility, bounded exact totals, privacy-safe diagnostics, and expansion-safe lazy Writing insights widget coverage.''',
    'CONTRIBUTING.md': '''## V2.15 writing-rule contribution baseline\nThe current built-in catalogue has ten rules. New structural rules must define exact source ownership, demonstrate non-BMP offset behavior where relevant, preserve explicit historical overrides, and avoid guessed automatic replacements unless the edit is deterministic.''',
    'SECURITY.md': '''## V2.15 local-analysis boundary\nUnmatched curly-brace diagnostics are computed locally from in-memory editor text. V2.15 adds no network request, telemetry, account behavior, background upload, cloud grammar service, or document persistence.''',
    'SUPPORT.md': '''## V2.15 support note\n`unmatched-curly-brace` is advisory-only. If a `{` or `}` warning appears, SpellChecker intentionally does not guess whether to insert, delete, move, or rewrite text. The rule can be disabled per language in Writing insights.''',
    'docs/ACCESSIBILITY.md': '''## V2.15 Writing insights accessibility\nThe tenth rule participates in the existing keyboard-search, Mechanics filter, rule-switch, visible/captured/total semantics, and advisory-finding presentation. Catalogue growth also hardened lazy widget-test discovery so controls are located after they are built rather than by fixed geometry.''',
    'docs/API.md': '''## V2.15 API addition\n`package:spellchecker/writing.dart` now exports `UnmatchedCurlyBraceRule`. Its stable ID is `unmatched-curly-brace`; it is warning-level, supports English language code `en`, owns one brace source character, and exposes no automatic replacement.''',
    'docs/ARCHITECTURE.md': '''## V2.15 architecture note\nThe writing pipeline now has ten built-ins. `UnmatchedCurlyBraceRule` reuses the existing registry, analyzer, bounded-result, diagnostic-summary, review-query, preference, Portable-settings, and correction-skip paths; no parallel engine or storage/network subsystem was introduced.''',
    'docs/DEVELOPMENT.md': '''## V2.15 development baseline\nWhen changing the ten-rule catalogue, run canonical formatting after dependency resolution, `flutter analyze`, the complete Flutter suite, and benchmark smoke. Structural-rule changes should also run focused source-ownership, bounded-total, preference/Portable-settings, widget, privacy, and stress regressions.''',
    'docs/LANGUAGE_PACKS.md': '''## V2.15 language-pack behavior\n`UnmatchedCurlyBraceRule` declares supported language code `en`, so both built-in English (US) and English (UK) packs enable it by default when no explicit rule override exists. Explicit per-language historical overrides remain authoritative.''',
    'docs/PERFORMANCE.md': '''## V2.15 benchmark catalogue\nDeterministic benchmark identity now includes ten stable writing-rule IDs, including `unmatched-curly-brace`. The new scanner is iterative and focused tests exercise 5,000 balanced and 5,000 unmatched braces; benchmark timings remain observational, not correctness thresholds.''',
    'docs/PRIVACY.md': '''## V2.15 privacy boundary\nCurly-brace analysis is local and deterministic. Diagnostic summaries may include stable rule metadata and counts but not private editor excerpts. V2.15 adds no telemetry, application-network request, cloud writing service, account flow, or background document upload.''',
    'docs/RELEASING.md': '''## V2.15 release acceptance\nThe V2.15 candidate is `2.15.0+20` / About `2.15.0`. Acceptance requires clean package-aware formatting, static analysis, complete tests, benchmark smoke, release web build, exact ten-rule/export/version/documentation checks, and zero disposable V2.15 helper residue before normal merge.''',
    'docs/ROADMAP.md': '''## V2.15 — Unmatched Curly Brace Diagnostics — implemented\nV2.15 completes the next deterministic structural-rule increment: public advisory `unmatched-curly-brace`, a ten-rule default catalogue, exact one-character UTF-16 ownership, explicit V2.14 nine-rule preference compatibility, Portable-settings compatibility, bounded/private diagnostics, benchmark/stress coverage, and expansion-safe Writing insights widget regressions.''',
    'docs/TESTING.md': '''## V2.15 regression matrix\nV2.15 adds direct curly-brace scanner tests plus analyzer/batch, bounded totals, privacy diagnostics, benchmark, 5,000-level stress, review filters, explicit V2.14 preference compatibility, Portable settings, and editor widget coverage. The shared Writing insights safe-fix test now defers `.first` until the lazy action exists.''',
    'docs/TROUBLESHOOTING.md': '''## V2.15 unmatched curly-brace findings\nAn unmatched `{` or `}` warning is advisory. SpellChecker does not know whether your intended correction is to add the opposite brace, remove the current brace, move text, or rewrite a larger expression. Disable `Unmatched curly brace` in Writing insights when literal brace balancing is not useful for the selected language/workflow.''',
    'docs/USER_GUIDE.md': '''## V2.15 unmatched curly braces\nWriting insights now includes **Unmatched curly brace** by default for the built-in English packs. It reports literal unpaired `{` or `}` characters but never edits them automatically. **Automatic fixes only** hides these advisory findings, while Reset rules to defaults adopts all ten current built-ins.''',
}
for path, section in sections.items():
    insert_after_heading(path, section)

# Writing-rules current catalogue and V2.15 contract.
writing_rules = read('docs/WRITING_RULES.md')
if '## V2.15 current catalogue' in writing_rules:
    raise SystemExit('docs/WRITING_RULES.md: V2.15 section already present')
first_newline = writing_rules.find('\n')
v215_rules = '''## V2.15 current catalogue
The current built-in/default catalogue contains ten stable rule IDs:

- `repeated-word`
- `sentence-capitalization`
- `repeated-space`
- `punctuation-spacing`
- `missing-punctuation-space`
- `trailing-whitespace`
- `repeated-punctuation`
- `unmatched-parenthesis`
- `unmatched-square-bracket`
- `unmatched-curly-brace`

`unmatched-curly-brace` is advisory-only, warning-level, and owns exactly one `{` or `}` UTF-16 source character. Parentheses, square brackets, and curly braces remain independent structural families. Unset/reset preferences follow this ten-rule catalogue; explicit V2.14 nine-rule sets remain exact.

'''
write('docs/WRITING_RULES.md', writing_rules[: first_newline + 1] + '\n' + v215_rules + writing_rules[first_newline + 1 :])

# Web metadata. Keep JSON valid through structural parsing/writing.
manifest_path = Path('web/manifest.json')
manifest = json.loads(manifest_path.read_text())
description = manifest.get('description', '')
if 'unmatched-square-bracket' not in description:
    raise SystemExit('web/manifest.json: expected V2.14 description anchor')
manifest['description'] = description.replace(
    'unmatched-parenthesis and unmatched-square-bracket diagnostics',
    'unmatched-parenthesis, unmatched-square-bracket, and unmatched-curly-brace diagnostics',
)
manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + '\n')

replace_once(
    'web/index.html',
    'unmatched-parenthesis and unmatched-square-bracket diagnostics',
    'unmatched-parenthesis, unmatched-square-bracket, and unmatched-curly-brace diagnostics',
)

# Final guard: release identity and permanent behavior doc must exist; temporary scope is removed by workflow.
if not Path('docs/V2_15_UNMATCHED_CURLY_BRACE.md').exists():
    raise SystemExit('missing permanent V2.15 behavior documentation')
