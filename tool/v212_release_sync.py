from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, text: str) -> None:
    (ROOT / path).write_text(text, encoding="utf-8")


def replace_once(path: str, old: str, new: str) -> None:
    text = read(path)
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{path}: expected one anchor, found {count}: {old[:80]!r}")
    write(path, text.replace(old, new, 1))


def insert_after_heading(path: str, block: str) -> None:
    text = read(path)
    if block.strip() in text:
        return
    first_newline = text.find("\n")
    if first_newline < 0 or not text.startswith("# "):
        raise RuntimeError(f"{path}: missing top-level Markdown heading")
    write(path, text[: first_newline + 1] + "\n" + block.strip() + "\n" + text[first_newline + 1 :].lstrip("\n"))


# Executable release identity.
replace_once(
    "lib/features/editor/spell_checker_page.dart",
    "applicationVersion: '2.11.0',",
    "applicationVersion: '2.12.0',",
)

# Changelog: current release goes before the historical V2.11 entry.
changelog_block = """## [2.12.0] - 2026-08-15

### Added

- New public `MissingPunctuationSpaceRule` with stable rule ID `missing-punctuation-space`, exported through `package:spellchecker/writing.dart` and enabled by default for both built-in English packs.
- Deterministic automatic fixes for missing following whitespace after commas, semicolons, exclamation marks, and question marks when those punctuation marks sit between Unicode letter boundaries.
- Dedicated baseline, decomposed-Unicode, non-BMP-offset, analyzer/registry, benchmark-workload, persistence, widget, batch-fix, and one-step-undo regressions for the seventh built-in writing rule.
- A complete V2.12 behavior contract in `docs/V2_12_MISSING_PUNCTUATION_SPACING.md`.

### Changed

- The built-in writing-rule registry grows from six to seven rules, and unset/reset per-language preferences now resolve to the seven-rule default set.
- Unicode predecessor matching accepts a letter followed by zero or more combining marks, preserving decomposed accented-letter boundaries without consuming the following word.
- Deterministic benchmark workload metadata now includes `missing-punctuation-space`, including explicit zero totals when the rule has no findings.
- Package version advances to `2.12.0+17`; About version advances to `2.12.0`.

### Fixed

- Missing-space analysis now works after decomposed Unicode letter clusters such as `cafe\\u0301,naive` instead of treating the combining mark as a boundary failure.
- Pre-punctuation cleanup and missing-following-space fixes remain adjacent and non-overlapping, allowing safe batch composition for inputs such as `Hello ,world`.

### Compatibility, security, privacy, and validation

- Existing writing-rule IDs, persistence keys, Portable settings format, language IDs, correction APIs, diagnostic-summary format, and benchmark JSON format remain compatible.
- Period and colon boundaries are intentionally excluded from the new automatic rule to avoid claiming domains, versions, schemes, labels, times, and other syntax without a richer parser.
- Findings remain local and in memory; V2.12 adds no runtime dependency, telemetry, account behavior, cloud writing service, document persistence, background upload, or application network request.
- Final release validation requires canonical formatting, `flutter analyze`, the complete Flutter test suite, deterministic benchmark smoke, web release build, release-identity checks, and zero disposable V2.12 helper files in the permanent tree.

"""
replace_once(
    "CHANGELOG.md",
    "## [2.11.0] - 2026-08-14\n",
    changelog_block + "## [2.11.0] - 2026-08-14\n",
)

# README current release, highlights, built-in catalogue, and V2.12 release section.
replace_once("README.md", "`2.11.0+16`", "`2.12.0+17`")
replace_once(
    "README.md",
    "Version 2.11 is the **Keyboard-First Writing Insights Accessibility** release. It gives the existing local Writing insights dialog direct Ctrl/Command+F search focus, deterministic two-stage Escape behavior, live semantic rule/finding counts, release-mode validation of the dialog capture bound, and focused keyboard/semantics regressions. It also strengthens the V2.10 benchmark so exact per-rule totals explicitly contain every analyzed rule, including zero-count rules. No new persistence format, runtime dependency, telemetry, account behavior, or application network request is introduced.",
    "Version 2.12 is the **Missing Punctuation Spacing and Unicode Boundaries** release. It adds the seventh built-in writing rule, `missing-punctuation-space`, for deterministic missing-following-space fixes after commas, semicolons, exclamation marks, and question marks between Unicode letter boundaries. Decomposed combining-mark predecessors are supported, punctuation-only source ownership composes safely with the existing pre-punctuation spacing rule, and the benchmark/test/documentation contracts now describe the seven-rule workload. No new persistence format, runtime dependency, telemetry, account behavior, or application network request is introduced.",
)
replace_once(
    "README.md",
    "- V2.11 keyboard-first Writing insights review with Ctrl/Command+F search focus, deterministic Escape filter clearing, and live rule/finding count semantics.\n",
    "- V2.12 missing-punctuation-space analysis with Unicode combining-mark boundaries, punctuation-only source ownership, safe batch composition, and a seven-rule default registry.\n- V2.11 keyboard-first Writing insights review with Ctrl/Command+F search focus, deterministic Escape filter clearing, and live rule/finding count semantics.\n",
)
replace_once(
    "README.md",
    "- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, trailing-whitespace, and repeated-punctuation rules.",
    "- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, and repeated-punctuation rules.",
)
replace_once(
    "README.md",
    "- Horizontal whitespace before common punctuation.\n- Trailing horizontal whitespace at line/document ends.",
    "- Horizontal whitespace before common punctuation.\n- Missing following whitespace after commas, semicolons, exclamation marks, and question marks between Unicode letter boundaries.\n- Trailing horizontal whitespace at line/document ends.",
)
replace_once(
    "README.md",
    "Users whose per-language rule preference is **unset/default** receive the expanded registry defaults. An explicit saved rule list—including an explicit empty list—remains authoritative and is not silently expanded. **Reset rules to defaults** clears the stored override and therefore opts that language back into the current six-rule defaults.",
    "Users whose per-language rule preference is **unset/default** receive the expanded registry defaults. An explicit saved rule list—including an explicit empty list—remains authoritative and is not silently expanded. **Reset rules to defaults** clears the stored override and therefore opted that language back into the then-current six-rule defaults in V2.6; V2.12 now resolves an unset/reset language to the seven-rule default catalogue.",
)
v212_readme = """## Missing punctuation spacing and Unicode boundaries — V2.12

V2.12 adds `MissingPunctuationSpaceRule` (`missing-punctuation-space`) to the public writing-rule API and default registry. For both built-in English packs it detects `,`, `;`, `!`, and `?` between Unicode letter boundaries when the following horizontal whitespace is missing, and proposes a deterministic punctuation-plus-space replacement. Periods and colons stay outside this automatic scope.

The predecessor boundary accepts a Unicode letter followed by zero or more combining marks, so decomposed text such as `cafe\\u0301,naive` is handled without consuming the following word. The issue range owns only the punctuation mark. When whitespace also exists before the punctuation, `punctuation-spacing` owns that whitespace and `missing-punctuation-space` owns the adjacent punctuation mark, allowing `WritingCorrection.applyAll` to produce `Hello, world` from `Hello ,world` without overlapping edits.

Users with an unset writing-rule preference receive the seven-rule default catalogue. Existing explicit per-language sets—including an explicit empty set—remain authoritative and are not silently expanded. **Reset rules to defaults** clears the override and therefore opts the language into the current seven-rule defaults.

See [V2.12 missing punctuation spacing and Unicode boundaries](docs/V2_12_MISSING_PUNCTUATION_SPACING.md) and [Writing rules](docs/WRITING_RULES.md).

"""
replace_once(
    "README.md",
    "## Keyboard-first Writing insights accessibility — V2.11\n",
    v212_readme + "## Keyboard-first Writing insights accessibility — V2.11\n",
)

# Roadmap: insert implemented milestone before the future direction.
roadmap_block = """## Version 2.12 — Missing punctuation spacing and Unicode boundaries

Status: **implemented in the V2.12 release branch**.

- Add public `MissingPunctuationSpaceRule` with stable ID `missing-punctuation-space`.
- Expand the default built-in writing-rule catalogue from six to seven rules.
- Detect missing following whitespace after `,`, `;`, `!`, and `?` only when Unicode letters bound the punctuation.
- Accept decomposed Unicode predecessors using a letter plus zero-or-more combining marks.
- Preserve punctuation-only issue ownership so the new fix remains adjacent to, not overlapping with, `punctuation-spacing` cleanup.
- Keep periods and colons outside the deterministic automatic scope.
- Preserve explicit per-language rule selections while allowing unset/reset preferences to adopt the new seven-rule defaults.
- Extend benchmark workload identity and zero-total metadata to the seventh rule.
- Add baseline, Unicode, non-BMP-offset, batch-composition, persistence, registry, benchmark, and widget regressions.
- Advance package/About identity to `2.12.0+17` / `2.12.0` and synchronize the public release documentation.

"""
replace_once(
    "docs/ROADMAP.md",
    "## Future 2.x direction\n",
    roadmap_block + "## Future 2.x direction\n",
)

# Writing-rule reference: catalogue, dedicated contract, and test list.
replace_once(
    "docs/WRITING_RULES.md",
    "repeated-space\npunctuation-spacing\ntrailing-whitespace",
    "repeated-space\npunctuation-spacing\nmissing-punctuation-space\ntrailing-whitespace",
)
v212_rules = """## V2.12 missing punctuation spacing

`MissingPunctuationSpaceRule` is the seventh built-in rule and uses stable ID `missing-punctuation-space`. It supports language code `en`, so both built-in English packs are eligible.

The rule detects selected punctuation (``,``, `;`, `!`, `?`) between Unicode letter boundaries when no following space exists. Its predecessor accepts a Unicode letter plus zero or more combining marks, which keeps decomposed accented text eligible. A lookahead checks the following Unicode letter without consuming it.

The issue owns only the punctuation mark and proposes that punctuation plus one trailing space. Optional horizontal whitespace before the mark belongs to `punctuation-spacing`; this makes the two edits adjacent and lets the existing batch-correction algorithm apply both safely. Repeated punctuation, periods, colons, numeric-only boundaries, and symbol-only boundaries remain outside this rule's deterministic scope.

Unset/reset rule preferences include this rule through the current registry defaults. Explicit saved rule sets remain explicit and are not automatically expanded during upgrade.

Focused coverage lives in `test/missing_punctuation_space_rule_test.dart`, `test/missing_punctuation_space_unicode_test.dart`, and `test/v212_missing_punctuation_space_widget_test.dart`. See `docs/V2_12_MISSING_PUNCTUATION_SPACING.md` for the full release contract.

"""
replace_once(
    "docs/WRITING_RULES.md",
    "## Adding a new rule\n",
    v212_rules + "## Adding a new rule\n",
)
replace_once(
    "docs/WRITING_RULES.md",
    "test/writing_rules_test.dart\n",
    "test/writing_rules_test.dart\ntest/missing_punctuation_space_rule_test.dart\ntest/missing_punctuation_space_unicode_test.dart\ntest/v212_missing_punctuation_space_widget_test.dart\n",
)

# Engineering ledger: prepend a detailed V2.12 entry before the existing historical ledger.
ledger = """## V2.12 — Missing Punctuation Spacing & Unicode Boundary Completion

Release version: `2.12.0+17`

About version: `2.12.0`

V2.12 completes the production work that an earlier experimental branch could not safely ship: the repository now contains the actual `MissingPunctuationSpaceRule`, public export, built-in registration, deterministic corrections, Unicode regressions, benchmark integration, user workflow coverage, release identity, and synchronized documentation in the same mergeable tree.

### Production rule and public API

- Adds `lib/writing/rules/missing_punctuation_space_rule.dart`.
- Stable ID: `missing-punctuation-space`.
- Public class: `MissingPunctuationSpaceRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering both built-in `en-US` and `en-GB` packs.
- Default registry size moves from six rules to seven.
- `WritingRuleRegistry.byId('missing-punctuation-space')` resolves the built-in rule.

### Deterministic matching scope

The rule owns a deliberately narrow automatic transformation: selected punctuation between Unicode letters when the following space is missing. Supported punctuation is `,`, `;`, `!`, and `?`. Periods and colons are excluded to avoid claiming common domains, versions, schemes, labels, times, and syntax that require richer parsing.

The predecessor recognizes `Unicode letter + zero or more combining marks`. The following Unicode letter is checked with a lookahead and is not consumed. A combining mark without a preceding letter does not establish a boundary. Repeated punctuation does not create a competing missing-space finding.

### Source ownership and correction composition

Each new finding owns only its punctuation character and replaces it with the same punctuation plus one space. Horizontal whitespace before punctuation remains owned by `punctuation-spacing`.

For `Hello ,world`, the existing rule owns the space and the V2.12 rule owns the comma. Their ranges are adjacent, not overlapping, so `WritingCorrection.applyAll` can safely produce `Hello, world` while retaining stale-range validation, deterministic overlap handling, end-to-start application, applied/skipped counts, and one-step editor undo.

### Preference compatibility

No storage key or transfer-format version changes. An unset/reset language now resolves to the current seven-rule default set. An explicit stored set—including an explicit empty set—remains authoritative and is not silently expanded.

### Regression coverage

- `test/missing_punctuation_space_rule_test.dart`: supported punctuation, exclusions, language eligibility, letter boundaries, repeated-punctuation ownership, and punctuation-only offsets.
- `test/missing_punctuation_space_unicode_test.dart`: decomposed and multiple combining marks, adjacent pre-space composition, mark-alone rejection, period/colon exclusions, and non-BMP following-letter UTF-16 offsets.
- `test/writing_rules_test.dart`: seven-rule registry/default/analyzer integration.
- `test/analysis_benchmark_runner_test.dart`: seven-rule workload identity and exact zero totals.
- `test/v212_missing_punctuation_space_widget_test.dart`: default-enabled rule switch, mixed batch correction, one-step undo, and explicit-disable persistence.

### Release and compatibility boundary

Package identity advances to `2.12.0+17`; About identity advances to `2.12.0`. V2.12 adds no runtime dependency, network call, telemetry, account, background upload, document persistence, new preference key, Portable settings format change, language auto-detection, or correction-engine fork.

### Required final validation

The exact permanent head must pass canonical Dart formatting, `flutter analyze`, the full Flutter test suite, deterministic benchmark smoke, release web build, version/documentation identity assertions, `git diff --check`, and a disposable-helper residue check before merge. The permanent tree must contain neither the formatter helper nor the guarded release-sync helper used during development.

"""
replace_once("what_changed.md", "## V2.7 —", ledger + "## V2.7 —")

# Scope-specific documentation notes. These are deliberately concise and do not rewrite historical release facts.
notes = {
    "docs/API.md": """## V2.12 API note

The public writing API now exports `MissingPunctuationSpaceRule` with stable ID `missing-punctuation-space`. It is part of `WritingRuleRegistry.builtIns` and the default enabled set for supported English packs. Findings own the punctuation-only UTF-16 source range and propose punctuation plus one following space. The analyzer/result/correction method signatures and persistence contracts are unchanged.
""",
    "docs/ARCHITECTURE.md": """## V2.12 architecture note

The deterministic local writing pipeline now has seven built-in rules. `missing-punctuation-space` runs through the existing `WritingRule` → `WritingAnalyzer` → `WritingIssue` → `WritingCorrection` path; it does not introduce a second parser, mutation engine, persistence layer, service, isolate, network path, or dependency. Its punctuation-only ownership is intentionally adjacent to the existing pre-punctuation spacing rule.
""",
    "docs/DEVELOPMENT.md": """## V2.12 development note

Changes to writing boundaries must test Unicode source ranges as Dart UTF-16 offsets, explicit language eligibility, interaction with every automatic built-in rule, stale-safe individual correction, deterministic batch overlap behavior, registry defaults, and benchmark workload identity. V2.12's focused suites are the baseline and Unicode missing-punctuation tests plus the V2.12 widget workflow test; permanent CI still runs the complete suite.
""",
    "docs/PERFORMANCE.md": """## V2.12 benchmark note

The deterministic benchmark's writing workload now contains seven analyzed built-in rule IDs, including `missing-punctuation-space`. Exact per-rule totals continue to include zero values for analyzed rules with no findings. The new regular expression is local/deterministic; benchmark timings remain machine/toolchain observations and are not correctness thresholds or a CPU-time/document-size security guarantee.
""",
    "docs/TESTING.md": """## V2.12 testing note

V2.12 adds `missing_punctuation_space_rule_test.dart`, `missing_punctuation_space_unicode_test.dart`, and `v212_missing_punctuation_space_widget_test.dart`, and updates registry/benchmark regressions for the seven-rule workload. Coverage includes decomposed combining marks, multiple marks, a non-BMP following letter, adjacent batch composition, default enablement, explicit-disable persistence, and one-step undo. Release acceptance still requires the entire `flutter test` suite.
""",
    "docs/USER_GUIDE.md": """## V2.12 user note

Writing insights now includes **Missing punctuation space**. For English (US) and English (UK), it can offer a safe fix when a comma, semicolon, exclamation mark, or question mark sits directly before the next word, such as `Hello,world`. The fix inserts one following space. Periods and colons are intentionally not covered. Existing explicit rule choices remain unchanged until the user resets or edits them; an unset/reset language uses the current seven-rule defaults.
""",
    "docs/ACCESSIBILITY.md": """## V2.12 accessibility note

The seventh rule uses the existing Writing insights switch, finding-card, safe-fix, batch-fix, keyboard, focus, and semantic-count infrastructure. V2.12 adds no pointer-only action and does not remove the Ctrl/Command+Shift+Enter, Ctrl/Command+F, Escape, or existing live-region workflows. The rule's user-visible name is **Missing punctuation space**.
""",
    "docs/TROUBLESHOOTING.md": """## V2.12 troubleshooting note

If **Missing punctuation space** is absent or disabled after upgrading, check whether that language already has an explicit saved writing-rule selection. V2.12 respects explicit lists instead of silently adding the new rule. Use **Reset rules to defaults** to clear the override and adopt the current seven-rule default catalogue. Period/colon cases and punctuation not bounded by letters are deliberate non-matches, not failed analysis.
""",
    "docs/LANGUAGE_PACKS.md": """## V2.12 language-pack note

`MissingPunctuationSpaceRule` declares support for language code `en`, so both registered built-in English variants (`en-US` and `en-GB`) are eligible. V2.12 does not add a language pack, language auto-detection, cross-language preference merging, or a new normalization contract.
""",
    "docs/PRIVACY.md": """## V2.12 privacy note

Missing-punctuation analysis runs in the same local in-memory Writing insights pipeline as the other built-ins. Editor text, source excerpts, findings, and replacements are not added to preferences, Portable settings, telemetry, or network requests. V2.12 adds no account, cloud grammar service, document upload, background upload, or runtime dependency.
""",
    "docs/RELEASING.md": """## V2.12 release note

The V2.12 candidate identity is package `2.12.0+17` and About `2.12.0`. Release acceptance must verify the seven-rule registry/export, focused Unicode and widget regressions, full formatting/analyzer/tests, deterministic benchmark smoke, release web build, documentation identity, and absence of disposable `v212` helper files. A tag/release must point only at the exact validated merged tree.
""",
    "SECURITY.md": """## V2.12 security note

The new missing-punctuation rule is deterministic, source-controlled, local code. It deliberately excludes period/colon syntax, does not load remote rules or data, and uses the existing stale-source validation and conservative batch-overlap policy before mutation. V2.12 adds no new dependency, service, credential, network request, file parser, or dynamic plugin-loading path.
""",
    "SUPPORT.md": """## V2.12 support note

For `Hello,world`-style cases, confirm the selected language is English (US) or English (UK) and that **Missing punctuation space** is enabled in Writing insights. Users with an older explicit rule selection may need **Reset rules to defaults** to opt into the new seventh default rule. Period and colon boundaries are intentionally outside V2.12's automatic scope.
""",
    "CONTRIBUTING.md": """## V2.12 contributor note

The built-in writing catalogue now contains seven stable IDs, including `missing-punctuation-space`. Writing-rule contributions that touch token or punctuation boundaries must include Unicode/UTF-16 offset cases and interaction tests with existing automatic rules. Do not broaden V2.12's period/colon exclusions or punctuation-only ownership without a separately reviewed behavior contract and regression set.
""",
    ".github/pull_request_template.md": """## V2.12 writing-boundary reminder

For writing-rule changes, confirm stable IDs, language eligibility, Unicode/UTF-16 source ranges, adjacent/overlapping automatic-fix ownership, default-vs-explicit preference behavior, benchmark workload metadata, and focused plus full-suite regressions. V2.12's `missing-punctuation-space` rule is the reference case for decomposed combining-mark boundaries and punctuation-only ownership.
""",
}
for path, block in notes.items():
    insert_after_heading(path, block)

# Web metadata stays version-neutral but now mentions the new local mechanics coverage.
replace_once(
    "web/index.html",
    "persistent per-language vocabulary and writing-rule choices, bounded large-document spelling and Writing insights,",
    "persistent per-language vocabulary and writing-rule choices, Unicode-aware missing-punctuation spacing, bounded large-document spelling and Writing insights,",
)
replace_once(
    "web/manifest.json",
    "persistent per-language vocabulary and writing-rule choices, bounded large-document spelling and Writing insights,",
    "persistent per-language vocabulary and writing-rule choices, Unicode-aware missing-punctuation spacing, bounded large-document spelling and Writing insights,",
)

# Guardrails: current identity and core catalogue must agree before anything is committed.
assert "version: 2.12.0+17" in read("pubspec.yaml")
assert "applicationVersion: '2.12.0'" in read("lib/features/editor/spell_checker_page.dart")
assert "missing-punctuation-space" in read("lib/writing/writing_analyzer.dart")
assert "missing_punctuation_space_rule.dart" in read("lib/writing.dart")
assert "## [2.12.0] - 2026-08-15" in read("CHANGELOG.md")
assert "`2.12.0+17`" in read("README.md")
assert "## V2.12 — Missing Punctuation Spacing & Unicode Boundary Completion" in read("what_changed.md")

print("V2.12 release surfaces synchronized successfully.")
