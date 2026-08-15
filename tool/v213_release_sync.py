from __future__ import annotations

from pathlib import Path
import subprocess


def read(path: str) -> str:
    return Path(path).read_text()


def replace_once(text: str, old: str, new: str, *, path: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f'{path}: expected one anchor {old!r}, found {count}')
    return text.replace(old, new, 1)


def insert_before(text: str, marker: str, block: str, *, path: str) -> str:
    count = text.count(marker)
    if count != 1:
        raise SystemExit(f'{path}: expected one marker {marker!r}, found {count}')
    return text.replace(marker, block.rstrip() + '\n\n' + marker, 1)


def after_heading(text: str, block: str, *, path: str) -> str:
    newline = text.find('\n')
    if newline < 0 or not text.startswith('# '):
        raise SystemExit(f'{path}: expected a Markdown H1 heading')
    remainder = text[newline + 1 :].lstrip('\n')
    return text[: newline + 1] + '\n' + block.rstrip() + '\n\n' + remainder


updates: dict[str, str] = {}

# CHANGELOG.md
path = 'CHANGELOG.md'
text = read(path)
block = '''## [2.13.0] - 2026-08-15

### Added

- Public advisory-only `UnmatchedParenthesisRule` with stable ID `unmatched-parenthesis`, exported through `package:spellchecker/writing.dart` and enabled by default for both built-in English packs when no explicit rule override exists.
- Deterministic literal parenthesis balancing with nested-pair support, single-character source ownership, source-ordered unmatched findings, and UTF-16 offset coverage around non-BMP text.
- Focused rule, analyzer, bounded-analysis, review-query, widget, preference-compatibility, Portable-settings, diagnostic-summary, benchmark, and 5,000-level stress regressions.
- Complete V2.13 behavior contract in `docs/V2_13_UNMATCHED_PARENTHESIS.md`.

### Changed

- The built-in writing-rule registry grows from seven to eight rules; unset/reset language preferences now resolve to the eight-rule default set.
- Benchmark workload identity and exact zero-total metadata now include `unmatched-parenthesis`.
- Package version advances to `2.13.0+18`; About version advances to `2.13.0`.

### Compatibility, security, privacy, and validation

- The rule is advisory-only because insertion versus deletion cannot be inferred safely. It has no replacement, is hidden by **Automatic fixes only**, and is skipped by batch correction while independent safe fixes can still apply.
- Explicit V2.12 seven-rule overrides remain authoritative; reset/unset preferences adopt the current eight-rule defaults. Persistence keys and Portable settings format version are unchanged.
- The rule is a literal parenthesis balancer, not a Markdown, code, URL, quoting, or domain-specific parser.
- V2.13 adds no runtime dependency, application network request, telemetry, account behavior, cloud writing service, background upload, document persistence, or hidden clipboard action.
- Final release validation requires package-aware canonical formatting, `flutter analyze`, the complete Flutter test suite, deterministic benchmark smoke, release-mode web build, release identity/manifest/dependency assertions, and zero disposable V2.13 helper residue.
'''
updates[path] = insert_before(text, '## [2.12.0] - 2026-08-15', block, path=path)

# README.md
path = 'README.md'
text = read(path)
text = replace_once(
    text,
    '- V2.12 missing-punctuation-space analysis with Unicode combining-mark boundaries, punctuation-only source ownership, safe batch composition, and a seven-rule default registry.',
    '- V2.13 advisory unmatched-parenthesis diagnostics with nested literal balancing, single-character source ownership, explicit V2.12 preference compatibility, and an eight-rule default registry.\n- V2.12 missing-punctuation-space analysis with Unicode combining-mark boundaries, punctuation-only source ownership, safe batch composition, and its historical seven-rule default registry.',
    path=path,
)
text = replace_once(
    text,
    '- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, and repeated-punctuation rules.',
    '- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, and unmatched-parenthesis rules.',
    path=path,
)
start = text.find('## Current release\n')
next_marker = '## Missing punctuation spacing and Unicode boundaries — V2.12\n'
end = text.find(next_marker, start)
if start < 0 or end < 0:
    raise SystemExit('README.md: current-release markers not found')
current = '''## Current release

`2.13.0+18`

Version 2.13 is the **Unmatched Parenthesis Diagnostics** release. It adds the eighth built-in writing rule, `unmatched-parenthesis`, for deterministic local reporting of literal `(` and `)` characters that cannot be paired. The rule is warning-level and advisory-only: it never guesses an insertion or deletion, so existing automatic-fix filters and batch correction retain their safety boundary. Unset/reset rule preferences adopt the eight-rule registry while explicit V2.12 seven-rule choices remain unchanged. No persistence-format, runtime-dependency, telemetry, account, or application-network expansion is introduced.

## Unmatched parenthesis diagnostics — V2.13

`UnmatchedParenthesisRule` balances literal parentheses iteratively, accepts nesting, and reports each unmatched parenthesis with a one-character UTF-16 source range. A closing parenthesis without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. The implementation is covered around non-BMP text and with 5,000 levels of nesting.

The rule deliberately has no automatic replacement because the intended correction may be insertion, deletion, movement, or a larger rewrite. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Literal parentheses inside code, Markdown, quotes, URLs, or other domain syntax are not parser-suppressed in V2.13.

Existing explicit seven-rule V2.12 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current eight-rule registry. Portable settings keep the same format version and preserve both older explicit seven-rule sets and new eight-rule sets.

See [V2.13 unmatched parenthesis diagnostics](docs/V2_13_UNMATCHED_PARENTHESIS.md) and [Writing rules](docs/WRITING_RULES.md).

'''
text = text[:start] + current + text[end:]
updates[path] = text

# what_changed.md
path = 'what_changed.md'
text = read(path)
ledger = '''## V2.13 — Unmatched Parenthesis Diagnostics

Release version: `2.13.0+18`

About version: `2.13.0`

V2.13 expands the deterministic local writing catalogue from seven to eight built-in rules with an intentionally advisory structural diagnostic. The production tree now contains the public `UnmatchedParenthesisRule`, registry/export integration, exact source ownership, compatibility-preserving preference behavior, bounded/exact diagnostics, benchmark identity, UI/filter integration, stress coverage, release identity, and synchronized documentation.

### Production rule and public API

- Adds `lib/writing/rules/unmatched_parenthesis_rule.dart`.
- Stable ID: `unmatched-parenthesis`.
- Public class: `UnmatchedParenthesisRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering built-in `en-US` and `en-GB` packs.
- Category: Mechanics through the source-compatible `WritingRule` default.
- Severity: warning.
- Default registry size moves from seven rules to eight.
- `WritingRuleRegistry.byId('unmatched-parenthesis')` resolves the built-in rule.

### Deterministic balancing and source ownership

The rule performs an iterative left-to-right scan of literal `(` and `)` code units. Openings are retained on a stack. A closing parenthesis consumes the most recent unmatched opening when possible; otherwise the closing character is unmatched. Remaining openings are unmatched after the scan. Findings are emitted in ascending source order.

Every issue owns exactly one parenthesis character. `start` and `end` are UTF-16 offsets with `end == start + 1`, and `originalText` is `(` or `)`. A dedicated non-BMP regression verifies that `😀)` reports the closing parenthesis at offset 2 rather than confusing Unicode scalar and UTF-16 indexing.

Nested balanced text is clean. Malformed ordering such as `)middle(` yields both findings in source order. Square/curly brackets are outside the rule's scope. The scanner is non-recursive; stress regressions cover 5,000 balanced nesting levels and 5,000 unmatched openings.

### Advisory-only correction boundary

V2.13 does not guess an automatic edit. An unmatched parenthesis might require inserting an opposite delimiter, deleting the reported character, moving text, or rewriting a larger phrase. The issue therefore leaves `replacement` null and `hasAutomaticFix` false.

Writing insights keeps the finding reviewable under Mechanics, while **Automatic fixes only** removes it from the visible finding set. A document containing only this advisory finding does not expose an **Apply all safe fixes** button. `WritingCorrection.applyAll` skips the advisory issue, increments the skipped count, and can still apply independent deterministic fixes in the same batch.

### Preference and Portable-settings compatibility

The storage key family remains `spellchecker.writing_rule_ids.v1.<language>`, and Portable settings remains format version 1.

- Unset rule preferences resolve to the current eight-rule default set.
- **Reset rules to defaults** clears the stored override and therefore adopts all eight defaults.
- An explicit V2.12 seven-rule set remains exactly seven rules and does not silently gain `unmatched-parenthesis`.
- Explicit empty/disable-all behavior remains unchanged.
- Portable settings round-trip an old explicit seven-rule set unchanged and preserve `unmatched-parenthesis` when it is explicitly present in an eight-rule set.

### Bounded analysis, diagnostics, and benchmark integration

The rule uses the existing analyzer result contract without format changes. Exact-at-limit analysis remains complete; overflow retains the globally earliest source-ordered prefix while `totalIssueCount` and `totalIssueCountByRule` report exact totals. Privacy-safe diagnostic summaries add the new stable rule name/ID/count row but continue to exclude editor text, finding excerpts, messages, replacements, and offsets.

The deterministic benchmark workload identity now has eight sorted rule IDs. Zero-finding benchmark samples materialize an explicit zero for `unmatched-parenthesis`; a focused controlled corpus asserts an exact count of one. Benchmark timings remain observational rather than correctness thresholds.

### UI and regression hardening

The eighth rule increased Writing insights list height. Existing and new widget regressions were hardened to scroll by lazy-build state rather than relying on seven-rule pixel geometry. This preserves the real lazy `ListView` interaction model while keeping bulk-fix, automatic-filter, explicit-override, reset, and advisory-only behavior testable.

Permanent focused coverage includes:

- `test/unmatched_parenthesis_rule_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_unmatched_parenthesis_widget_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/v213_settings_transfer_rule_compatibility_test.dart`
- `test/v213_writing_diagnostic_summary_test.dart`
- `test/v213_bounded_parenthesis_analysis_test.dart`
- `test/v213_parenthesis_stress_test.dart`
- `test/v213_review_query_parenthesis_test.dart`
- `test/v213_benchmark_parenthesis_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `test/widget_test.dart`

### Deliberate parser limitation

`UnmatchedParenthesisRule` is a literal delimiter balancer, not a Markdown, programming-language, URL, quoting, mathematical, or domain-specific parser. V2.13 does not suppress parentheses based on surrounding syntax. Syntax-aware exclusions require a future explicit parsing contract and corpus rather than heuristic mutation.

### Release, privacy, and dependency boundary

Package identity advances to `2.13.0+18`; About identity advances to `2.13.0`. V2.13 adds no runtime dependency, new preference key, Portable-settings format change, network request, telemetry, account, cloud writing service, background upload, document persistence, hidden clipboard action, or correction-engine fork.

Before release metadata was applied, permanent CI run `31869797175` passed package-aware formatting, `flutter analyze`, the full Flutter test suite, and deterministic benchmark smoke on the complete functional eight-rule implementation. The final release candidate must repeat those checks after release synchronization and also pass a release-mode web build plus version/export/manifest/dependency/helper-residue assertions.
'''
updates[path] = insert_before(text, '## V2.12 — Missing Punctuation Spacing & Unicode Boundary Completion', ledger, path=path)

# docs/ROADMAP.md
path = 'docs/ROADMAP.md'
text = read(path)
text = replace_once(
    text,
    'Status: **implemented in the V2.12 release branch**.',
    'Status: implemented.',
    path=path,
)
roadmap = '''## Version 2.13 — Unmatched parenthesis diagnostics

Status: implemented.

- [x] Add public `UnmatchedParenthesisRule` with stable ID `unmatched-parenthesis`.
- [x] Expand the default built-in writing-rule catalogue from seven to eight rules.
- [x] Balance literal `(` and `)` deterministically with nested-pair support and source-ordered unmatched findings.
- [x] Preserve one-character UTF-16 source ownership, including non-BMP predecessor offsets.
- [x] Keep the rule advisory-only with no guessed replacement and warning severity.
- [x] Integrate Mechanics search/category review while **Automatic fixes only** excludes the advisory finding.
- [x] Preserve explicit V2.12 seven-rule overrides and let unset/reset preferences adopt eight-rule defaults.
- [x] Preserve Portable settings format version while round-tripping old and new explicit rule sets.
- [x] Extend exact bounded diagnostics, privacy-safe diagnostic summaries, and benchmark workload identity to the eighth rule.
- [x] Add 5,000-level iterative stress coverage plus rule/analyzer/widget/preference/transfer/diagnostic/benchmark regressions.
- [x] Advance package/About identity to `2.13.0+18` / `2.13.0` and synchronize public release documentation.
- [x] Add no runtime dependency, telemetry, account, cloud service, document upload, new preference key, or transfer-format change.
'''
updates[path] = insert_before(text, '## Future 2.x direction', roadmap, path=path)

# docs/WRITING_RULES.md
path = 'docs/WRITING_RULES.md'
text = read(path)
text = replace_once(
    text,
    'trailing-whitespace\nrepeated-punctuation\n```',
    'trailing-whitespace\nrepeated-punctuation\nunmatched-parenthesis\n```',
    path=path,
)
section = '''## V2.13 advisory structural rule

V2.13 adds `UnmatchedParenthesisRule` (`unmatched-parenthesis`) as the eighth built-in rule. It balances literal parentheses iteratively, owns exactly the unmatched parenthesis character, emits warning-level findings in source order, and deliberately provides no automatic replacement. This is an example of the plugin contract's advisory path: deterministic detection does not imply deterministic mutation.

Unset/reset preferences adopt the eight-rule registry. Explicit stored sets remain authoritative, including V2.12 seven-rule overrides and explicit empty sets. The rule is Mechanics by the source-compatible category default, is searchable by its metadata, and is hidden by **Automatic fixes only** because `hasAutomaticFix` is false.

See `docs/V2_13_UNMATCHED_PARENTHESIS.md` for exact balancing, source-range, compatibility, and parser-limit details.'''
updates[path] = after_heading(text, section, path=path)

notes = {
    'docs/API.md': '''## V2.13 API note

`package:spellchecker/writing.dart` now exports `UnmatchedParenthesisRule`, stable ID `unmatched-parenthesis`. The existing `WritingRule`, `WritingIssue`, `WritingAnalyzer`, `WritingAnalysisResult`, `WritingCorrection`, review-query, persistence, diagnostic-summary, and benchmark result formats are unchanged. The new rule returns warning findings with `replacement == null`, so callers must continue to treat automatic correction as optional.''',
    'docs/ARCHITECTURE.md': '''## V2.13 architecture note

The built-in writing registry now contains eight rules. `UnmatchedParenthesisRule` is an iterative local scanner that stores unmatched opening offsets and emits source-ordered one-character advisory findings. It reuses the existing analyzer, review, preference, diagnostic, benchmark, and correction-skip layers; there is no parallel parser, correction engine, persistence subsystem, service, or network path.''',
    'docs/DEVELOPMENT.md': '''## V2.13 development note

Writing-rule changes must preserve exact source ownership and explicitly choose advisory versus automatic correction semantics. V2.13's `unmatched-parenthesis` rule is advisory-only and includes nested/malformed/UTF-16, bounded-analysis, UI, preference-compatibility, Portable-settings, diagnostics, benchmark, and 5,000-level stress regressions. Run package-aware formatting after `flutter pub get`, then `flutter analyze`, the full Flutter suite, and benchmark smoke.''',
    'docs/TESTING.md': '''## V2.13 test boundary

The eight-rule release adds focused tests for literal parenthesis balancing, one-character UTF-16 offsets, advisory-only correction skipping, lazy Writing insights interaction, explicit V2.12 seven-rule preference compatibility, Portable settings, exact bounded totals, privacy-safe diagnostic rows, benchmark identity, and 5,000-level iterative stress behavior. Existing widget tests use lazy-build-aware scrolling rather than fixed seven-rule geometry.''',
    'docs/PERFORMANCE.md': '''## V2.13 parenthesis scanner

`UnmatchedParenthesisRule` scans the supplied UTF-16 string once and uses an iterative stack of opening offsets. The final unmatched indexes are source ordered before findings are emitted. Runtime is dominated by the linear scan plus ordering of unmatched indexes; retained memory grows with unmatched/nesting depth rather than recursion. Stress tests cover 5,000 balanced nesting levels and 5,000 unmatched openings. This remains a correctness regression, not a timing threshold.''',
    'docs/USER_GUIDE.md': '''## V2.13 unmatched parenthesis findings

Writing insights can now report an opening or closing parenthesis that has no matching pair. The finding is advisory: SpellChecker highlights the unmatched character but does not offer **Apply safe fix** because it cannot know whether you intended to insert a partner, delete the character, or rewrite the surrounding text. **Automatic fixes only** hides these findings. You can disable the rule per language like other writing rules.''',
    'docs/ACCESSIBILITY.md': '''## V2.13 accessibility note

The eighth writing rule participates in the existing live rule/finding count semantics and lazy Writing insights list. Its warning remains keyboard-reviewable like other findings, while **Automatic fixes only** removes it from visible finding counts because it has no deterministic replacement. Widget regressions scroll by lazy-build state so accessibility expectations do not depend on the historical seven-rule viewport height.''',
    'docs/TROUBLESHOOTING.md': '''## V2.13 unmatched-parenthesis troubleshooting

The new rule balances literal `(` and `)` characters and is not a Markdown, programming-language, URL, quoting, or mathematical parser. If syntax intentionally contains an unmatched literal parenthesis, disable `unmatched-parenthesis` for that language or review the finding manually; V2.13 will not auto-edit it. Privacy-safe diagnostic summaries can report the rule ID/count without including the source text.''',
    'docs/LANGUAGE_PACKS.md': '''## V2.13 writing-rule eligibility

`UnmatchedParenthesisRule` declares language code `en`, so it is available to both built-in `en-US` and `en-GB` packs without duplicating pack-specific logic. Language eligibility still flows through `WritingRule.supports(pack)`. Explicit per-language rule overrides remain isolated; adding the eighth default does not rewrite an existing explicit V2.12 set.''',
    'docs/PRIVACY.md': '''## V2.13 privacy note

Unmatched-parenthesis analysis is local and in memory. The rule adds no document storage, telemetry, network request, background upload, account behavior, or hidden clipboard operation. Privacy-safe diagnostic summaries may include the stable rule name/ID and counts, but continue to exclude editor text, finding excerpts, messages, replacements, and source offsets.''',
    'docs/RELEASING.md': '''## V2.13 release gate

The V2.13 candidate identity is package `2.13.0+18` / About `2.13.0`, with eight built-in writing rules including `unmatched-parenthesis`. Release validation must confirm package-aware formatting, static analysis, the complete Flutter suite, deterministic benchmark smoke, `flutter build web --release`, public export/registry identity, manifest JSON, unchanged direct runtime dependency boundary, V2.13 `what_changed.md` coverage, and zero disposable V2.13 helper files.''',
    'SECURITY.md': '''## V2.13 writing-rule security boundary

`UnmatchedParenthesisRule` treats input as data only: it scans literal UTF-16 delimiters and does not execute, interpret, fetch, or evaluate surrounding code/markup. It is advisory-only and therefore cannot mutate a document through its own finding. Large/untrusted-input policies still belong to the host application; the built-in stress tests are regression coverage, not an execution-time sandbox.''',
    'SUPPORT.md': '''## V2.13 support note

For unmatched-parenthesis reports, include whether the text intentionally contains literal unmatched delimiters (for example in code or markup) and whether the rule was enabled explicitly or through defaults. The **Copy diagnostic summary** action can share the stable rule ID and counts without copying document excerpts. Do not include private document text unless you choose to share it separately.''',
    'CONTRIBUTING.md': '''## V2.13 writing-rule contribution example

The `unmatched-parenthesis` rule demonstrates the required separation between deterministic detection and safe mutation. New rules should have stable IDs, explicit language eligibility, exact source-range ownership, adversarial/Unicode tests, and a justified `replacement` decision. When a correction is ambiguous, prefer an advisory finding over guessing an edit.''',
    '.github/pull_request_template.md': '''## Writing-rule safety (when applicable)

- [ ] New/changed writing-rule IDs are stable and preference compatibility is documented.
- [ ] Source ranges have exact ownership tests, including Unicode/UTF-16 cases where relevant.
- [ ] Automatic replacement is provided only when the edit is deterministic; ambiguous findings remain advisory.
- [ ] Registry/default changes include persistence, Portable-settings, UI, diagnostics, benchmark, and documentation review.''',
}
for path, block in notes.items():
    updates[path] = after_heading(read(path), block, path=path)

# Web metadata
path = 'web/index.html'
text = read(path)
updates[path] = replace_once(
    text,
    'Unicode-aware missing-punctuation spacing, bounded large-document spelling and Writing insights',
    'Unicode-aware missing-punctuation spacing, advisory unmatched-parenthesis diagnostics, bounded large-document spelling and Writing insights',
    path=path,
)

path = 'web/manifest.json'
text = read(path)
updates[path] = replace_once(
    text,
    'Unicode-aware missing-punctuation spacing, bounded large-document spelling and Writing insights',
    'Unicode-aware missing-punctuation spacing, advisory unmatched-parenthesis diagnostics, bounded large-document spelling and Writing insights',
    path=path,
)

commit_messages = {
    'CHANGELOG.md': 'docs(changelog): add V2.13 release entry',
    'README.md': 'docs(readme): publish V2.13 current release contract',
    'what_changed.md': 'docs(ledger): record complete V2.13 engineering changes',
    'docs/ROADMAP.md': 'docs(roadmap): mark V2.13 unmatched parenthesis implemented',
    'docs/WRITING_RULES.md': 'docs(writing): document eighth advisory rule',
    'docs/API.md': 'docs(api): document V2.13 public rule export',
    'docs/ARCHITECTURE.md': 'docs(architecture): record V2.13 rule integration',
    'docs/DEVELOPMENT.md': 'docs(development): add V2.13 rule workflow guidance',
    'docs/TESTING.md': 'docs(testing): document V2.13 regression boundary',
    'docs/PERFORMANCE.md': 'docs(performance): document parenthesis scanner behavior',
    'docs/USER_GUIDE.md': 'docs(user): explain advisory parenthesis findings',
    'docs/ACCESSIBILITY.md': 'docs(accessibility): document V2.13 review semantics',
    'docs/TROUBLESHOOTING.md': 'docs(troubleshooting): add parenthesis diagnostic guidance',
    'docs/LANGUAGE_PACKS.md': 'docs(language): document V2.13 English rule eligibility',
    'docs/PRIVACY.md': 'docs(privacy): record V2.13 local-only boundary',
    'docs/RELEASING.md': 'docs(release): add V2.13 release gate',
    'SECURITY.md': 'docs(security): record V2.13 advisory scanner boundary',
    'SUPPORT.md': 'docs(support): add V2.13 diagnostic guidance',
    'CONTRIBUTING.md': 'docs(contributing): add advisory-rule contribution guidance',
    '.github/pull_request_template.md': 'docs(pr): add writing-rule safety checklist',
    'web/index.html': 'docs(web): advertise V2.13 advisory diagnostics',
    'web/manifest.json': 'docs(web): update manifest for V2.13 diagnostics',
}

missing = set(updates) - set(commit_messages)
if missing:
    raise SystemExit(f'missing commit messages for: {sorted(missing)}')

# All transformations are validated above before any file is written.
for path, text in updates.items():
    Path(path).write_text(text)

for path, message in commit_messages.items():
    subprocess.run(['git', 'add', path], check=True)
    subprocess.run(['git', 'commit', '-m', message], check=True)
