from __future__ import annotations

from pathlib import Path
import subprocess

BRANCH = "v2.14-unmatched-square-bracket-2026-08-15"


def read(path: str) -> str:
    return Path(path).read_text()


def replace_once(text: str, old: str, new: str, *, path: str) -> str:
    count = text.count(old)
    if count != 1:
        raise SystemExit(f"{path}: expected one anchor, found {count}: {old[:90]!r}")
    return text.replace(old, new, 1)


def insert_before(text: str, marker: str, block: str, *, path: str) -> str:
    count = text.count(marker)
    if count != 1:
        raise SystemExit(f"{path}: expected one marker, found {count}: {marker!r}")
    return text.replace(marker, block.rstrip() + "\n\n" + marker, 1)


def insert_before_first_h2(text: str, block: str, *, path: str) -> str:
    marker = "\n## "
    index = text.find(marker)
    if index < 0:
        raise SystemExit(f"{path}: no H2 insertion point")
    return text[:index] + "\n\n" + block.strip() + "\n" + text[index:]


def commit_path(path: str, message: str) -> None:
    subprocess.run(["git", "add", path], check=True)
    staged = subprocess.run(
        ["git", "diff", "--cached", "--quiet", "--", path],
        check=False,
    )
    if staged.returncode == 0:
        raise SystemExit(f"{path}: expected a staged release change")
    subprocess.run(["git", "commit", "-m", message], check=True)


updates: dict[str, tuple[str, str]] = {}

# About identity and public feature sentence.
path = "lib/features/editor/spell_checker_page.dart"
text = read(path)
text = replace_once(
    text,
    "applicationVersion: '2.13.0'",
    "applicationVersion: '2.14.0'",
    path=path,
)
text = replace_once(
    text,
    "expanded deterministic local writing rules including advisory unmatched-parenthesis diagnostics",
    "expanded deterministic local writing rules including advisory unmatched-parenthesis and unmatched-square-bracket diagnostics",
    path=path,
)
updates[path] = (text, "release(v214): update About identity and feature description")

path = "test/widget_test.dart"
text = read(path)
text = replace_once(
    text,
    "About dialog reports the current V2.13 release",
    "About dialog reports the current V2.14 release",
    path=path,
)
text = replace_once(text, "'2.13.0'", "'2.14.0'", path=path)
updates[path] = (text, "test(v214): update About release regression")

# README: current release, top highlight, current built-in catalogue, and V2.14 section.
path = "README.md"
text = read(path)
if "## Unmatched square bracket diagnostics — V2.14" in text:
    raise SystemExit(f"{path}: V2.14 section already exists")
text = replace_once(
    text,
    "- V2.13 advisory unmatched-parenthesis diagnostics with nested literal balancing, single-character source ownership, explicit V2.12 preference compatibility, and an eight-rule default registry.",
    "- V2.14 advisory unmatched-square-bracket diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.13 preference compatibility, and a nine-rule default registry.\n- V2.13 advisory unmatched-parenthesis diagnostics with nested literal balancing, single-character source ownership, explicit V2.12 preference compatibility, and its historical eight-rule default registry.",
    path=path,
)
text = replace_once(
    text,
    "- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, and unmatched-parenthesis rules.",
    "- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, unmatched-parenthesis, and unmatched-square-bracket rules.",
    path=path,
)
start_marker = "## Current release\n\n"
next_marker = "## Unmatched parenthesis diagnostics — V2.13"
if text.count(start_marker) != 1 or text.count(next_marker) != 1:
    raise SystemExit(f"{path}: current-release markers are not unique")
start = text.index(start_marker) + len(start_marker)
end = text.index(next_marker)
current = """`2.14.0+19`

Version 2.14 is the **Unmatched Square Bracket Diagnostics** release. It adds the ninth built-in writing rule, `unmatched-square-bracket`, for deterministic local reporting of literal `[` and `]` characters that cannot be paired. The rule is warning-level and advisory-only: it does not guess whether an unmatched bracket should be inserted, deleted, moved, or rewritten. Unset/reset rule preferences adopt the nine-rule registry while explicit V2.13 eight-rule choices remain exact. No persistence-format, runtime-dependency, telemetry, account, or application-network expansion is introduced.

## Unmatched square bracket diagnostics — V2.14

`UnmatchedSquareBracketRule` balances literal square brackets iteratively, accepts nesting, and reports each unmatched bracket with a one-character UTF-16 source range. A closing bracket without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. Non-BMP offsets and 5,000 levels of nesting are covered by focused regressions.

The rule deliberately has no automatic replacement. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Parentheses remain owned by the V2.13 rule; curly braces and syntax-aware parsing remain outside V2.14 scope.

Existing explicit eight-rule V2.13 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current nine-rule registry. Portable settings keep the same format version and preserve both older explicit sets and explicit V2.14 nine-rule sets.

See [V2.14 unmatched square bracket diagnostics](docs/V2_14_UNMATCHED_SQUARE_BRACKET.md) and [Writing rules](docs/WRITING_RULES.md).

"""
text = text[:start] + current + text[end:]
updates[path] = (text, "docs(v214): publish current release in README")

# Changelog release entry.
path = "CHANGELOG.md"
text = read(path)
block = """## [2.14.0] - 2026-08-15

### Added

- Public advisory-only `UnmatchedSquareBracketRule` with stable ID `unmatched-square-bracket`, exported through `package:spellchecker/writing.dart` and enabled by default for both built-in English packs when no explicit rule override exists.
- Deterministic literal square-bracket balancing with nested-pair support, one-character UTF-16 source ownership, source-ordered unmatched findings, and non-BMP offset coverage.
- Focused rule, analyzer, correction-skip, bounded-analysis, review-query, widget, preference-compatibility, Portable-settings, privacy-safe diagnostic-summary, benchmark, and 5,000-level stress regressions.
- Complete V2.14 behavior contract in `docs/V2_14_UNMATCHED_SQUARE_BRACKET.md`.

### Changed

- The built-in writing-rule registry grows from eight to nine rules; unset/reset language preferences now resolve to the nine-rule default set.
- Benchmark workload identity and exact zero-total metadata now include `unmatched-square-bracket`.
- Historical registry-size/widget regressions are expansion-safe and no longer depend on fixed catalogue pixel geometry.
- Package version advances to `2.14.0+19`; About version advances to `2.14.0`.

### Compatibility, security, privacy, and validation

- The rule is advisory-only because insertion versus deletion versus wider rewrite cannot be inferred safely. It has no replacement, is hidden by **Automatic fixes only**, and is skipped by batch correction while independent safe fixes can still apply.
- Explicit V2.13 eight-rule overrides remain authoritative; reset/unset preferences adopt current nine-rule defaults. Persistence keys and Portable settings format version are unchanged.
- The rule is a literal square-bracket balancer, not a Markdown, code, URL, citation, quotation, mathematical, or domain-specific parser.
- V2.14 adds no runtime dependency, application network request, telemetry, account behavior, cloud writing service, background upload, document persistence, or hidden clipboard action.
- Final release validation requires package-aware canonical formatting, `flutter analyze`, the complete Flutter test suite, deterministic benchmark smoke, release-mode web build, release identity/manifest/dependency assertions, and zero disposable V2.14 helper residue.
"""
text = insert_before(text, "## [2.13.0] - 2026-08-15", block, path=path)
updates[path] = (text, "docs(v214): add changelog release entry")

# Detailed engineering ledger requested by the project workflow.
path = "what_changed.md"
text = read(path)
ledger = """## V2.14 — Unmatched Square Bracket Diagnostics

Release version: `2.14.0+19`

About version: `2.14.0`

V2.14 expands the deterministic local writing catalogue from eight to nine built-in rules with a second deliberately advisory structural diagnostic. The production tree adds the public `UnmatchedSquareBracketRule`, registry/export integration, one-character UTF-16 source ownership, compatibility-preserving preference behavior, bounded/exact diagnostics, privacy-safe diagnostic-summary coverage, benchmark identity, review/editor integration, deep stress coverage, release identity, and synchronized documentation.

### Production rule and public API

- Adds `lib/writing/rules/unmatched_square_bracket_rule.dart`.
- Stable ID: `unmatched-square-bracket`.
- Public class: `UnmatchedSquareBracketRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering built-in `en-US` and `en-GB` packs.
- Category: Mechanics through the source-compatible `WritingRule` default.
- Severity: warning.
- Default registry size moves from eight rules to nine.
- `WritingRuleRegistry.byId('unmatched-square-bracket')` resolves the built-in rule.

### Deterministic balancing and source ownership

The rule performs an iterative left-to-right scan of literal `[` and `]` code units. Openings are retained on a stack. A closing bracket consumes the most recent unmatched opening when possible; otherwise the closing character is unmatched. Remaining openings are unmatched after the scan, and final findings are emitted in ascending source order.

Every issue owns exactly one bracket character. `start` and `end` are UTF-16 offsets with `end == start + 1`, and `originalText` is `[` or `]`. A non-BMP regression verifies that `😀]` reports the closing bracket at UTF-16 offset 2. Nested square brackets are accepted; malformed ordering such as `]middle[` yields both findings in source order. Parentheses remain independent under the V2.13 rule, and curly braces are outside V2.14 ownership.

The scanner is non-recursive. Stress regressions cover 5,000 balanced nesting levels and 5,000 unmatched openings.

### Advisory-only correction boundary

V2.14 does not guess an automatic edit. An unmatched square bracket may require inserting an opposite bracket, deleting the reported character, moving text, or rewriting a larger expression. The issue therefore leaves `replacement` null and `hasAutomaticFix` false.

Writing insights keeps the finding reviewable under Mechanics, while **Automatic fixes only** removes it from the visible finding set. A document containing only this advisory finding does not expose **Apply all safe fixes**. `WritingCorrection.applyAll` skips the advisory issue, increments the skipped count, and can still apply independent deterministic fixes in the same batch.

### Preference and Portable-settings compatibility

The storage key family remains `spellchecker.writing_rule_ids.v1.<language>`, and Portable settings remains format version 1.

- Unset rule preferences resolve to the current nine-rule default set.
- **Reset rules to defaults** clears the stored override and therefore adopts all nine current defaults.
- An explicit V2.13 eight-rule set remains exactly eight rules and does not silently gain `unmatched-square-bracket`.
- Older explicit sets and explicit empty/disable-all behavior remain authoritative.
- Portable settings round-trip an old explicit V2.13 eight-rule set unchanged and preserve `unmatched-square-bracket` when explicitly present in a V2.14 nine-rule set.

### Bounded analysis, diagnostics, and benchmark integration

The rule reuses the existing analyzer/result contracts without format changes. Exact-at-limit analysis remains complete; overflow retains the globally earliest source-ordered prefix while `totalIssueCount` and `totalIssueCountByRule` report exact totals. Privacy-safe diagnostic summaries add the new stable rule name/ID/count row but continue to exclude editor text, finding excerpts, messages, replacements, and offsets.

The deterministic benchmark workload identity now has nine sorted rule IDs. Zero-finding benchmark samples materialize an explicit zero for `unmatched-square-bracket`; a focused controlled corpus asserts an exact count of one. Benchmark timings remain observational rather than correctness thresholds.

### UI and regression hardening

The ninth rule participates in the existing lazy Writing insights list, search, Mechanics category, automatic-fix filter, per-language rule switches, reset workflow, and preference persistence. The V2.14 widget suite verifies default-enabled behavior, advisory-only presentation, automatic-fix filtering, and explicit-disable persistence.

Catalogue growth also removed the remaining fixed `-1400` findings-list drag from the core widget suite. Tests now build the exact safe-fix action they intend to use, avoiding historical pixel assumptions as the registry evolves.

Permanent focused coverage includes:

- `test/unmatched_square_bracket_rule_test.dart`
- `test/v214_unmatched_square_bracket_integration_test.dart`
- `test/v214_unmatched_square_bracket_widget_test.dart`
- `test/v214_rule_preference_compatibility_widget_test.dart`
- `test/v214_settings_transfer_rule_compatibility_test.dart`
- `test/v214_writing_diagnostic_summary_test.dart`
- `test/v214_bounded_square_bracket_analysis_test.dart`
- `test/v214_square_bracket_stress_test.dart`
- `test/v214_review_query_square_bracket_test.dart`
- `test/v214_benchmark_square_bracket_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/widget_test.dart`

### Deliberate parser limitation

`UnmatchedSquareBracketRule` is a literal delimiter balancer, not a Markdown, programming-language, URL, citation, quotation, mathematical, or domain-specific parser. V2.14 does not suppress square brackets based on surrounding syntax. Syntax-aware exclusions require a future explicit parsing contract and corpus rather than heuristic mutation.

### Release, privacy, dependency, and validation boundary

Package identity advances to `2.14.0+19`; About identity advances to `2.14.0`. V2.14 adds no runtime dependency, new preference key, Portable-settings format change, network request, telemetry, account, cloud writing service, background upload, document persistence, hidden clipboard action, or correction-engine fork.

Before release metadata synchronization, permanent CI run `31872367596` passed package-aware formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the functional nine-rule implementation. The final release candidate must repeat those checks after release synchronization and also pass a release-mode web build plus version/export/registry/manifest/dependency/helper-residue assertions.
"""
text = insert_before(text, "## V2.13 — Unmatched Parenthesis Diagnostics", ledger, path=path)
updates[path] = (text, "docs(ledger): add complete V2.14 engineering ledger")

# Permanent documentation surfaces. Insert the V2.14 release-specific contract before
# the first existing H2 so existing historical sections remain intact.
doc_sections = {
    ".github/pull_request_template.md": """## V2.14 structural-rule release checks

When a change touches the current unmatched-square-bracket milestone, confirm that `unmatched-square-bracket` keeps one-character UTF-16 ownership, remains advisory-only, preserves explicit older rule overrides, participates in bounded/private diagnostics and benchmark identity, and does not add parser claims or automatic mutations without dedicated evidence.

- [ ] The nine-rule registry/export identity is covered when the catalogue changes.
- [ ] Advisory findings remain excluded by **Automatic fixes only** and skipped by batch correction.
- [ ] Explicit V2.13 eight-rule preferences and Portable settings remain exact unless the user resets or explicitly opts in.
- [ ] Release metadata, `what_changed.md`, web metadata, behavior docs, and final validation evidence are synchronized for `2.14.0+19`.
""",
    "CONTRIBUTING.md": """## V2.14 structural diagnostics contribution boundary

The current built-in catalogue contains nine rules. `unmatched-square-bracket` demonstrates the expected contract for structural advisory diagnostics: literal deterministic detection, exact source ownership, no guessed mutation, explicit compatibility tests for stored rule sets, bounded/exact diagnostic coverage, and privacy-safe copied summaries. New delimiter/parser behavior must document whether it is literal or syntax-aware and must not silently broaden automatic correction scope.
""",
    "SECURITY.md": """## V2.14 structural diagnostic security boundary

`UnmatchedSquareBracketRule` scans the in-memory editor string locally and never executes or interprets bracket contents. It adds no parser, network request, telemetry, account, upload, persistence key, runtime dependency, or hidden clipboard action. Copied writing diagnostics continue to expose stable rule metadata/counts rather than document excerpts.
""",
    "SUPPORT.md": """## V2.14 unmatched-square-bracket reports

For an unexpected V2.14 structural finding, include the app version `2.14.0`, language pack, stable rule ID `unmatched-square-bracket`, whether the rule preference is default or explicit, and a minimal non-sensitive delimiter pattern when possible. Privacy-safe Writing analysis diagnostics can provide rule/count metadata without copying the editor document.
""",
    "docs/ACCESSIBILITY.md": """## V2.14 accessibility coverage

Writing insights now exposes nine built-in rule switches when current English defaults are active. The new **Unmatched square bracket** rule uses the existing accessible switch/list/finding semantics, Mechanics filtering, live visible/total finding counts, and keyboard-scrollable dialog. Advisory-only findings never expose a misleading automatic-fix action.
""",
    "docs/API.md": """## V2.14 public writing API

`package:spellchecker/writing.dart` now exports `UnmatchedSquareBracketRule` with stable ID `unmatched-square-bracket`. The existing `WritingRule`, `WritingIssue`, `WritingAnalyzer`, bounded-result, diagnostic-summary, review-query, correction, preference, and Portable-settings contracts are unchanged. Analyzer-produced default English results can now include nine built-in rule IDs.
""",
    "docs/ARCHITECTURE.md": """## V2.14 structural-rule architecture

The ninth built-in rule is a small iterative delimiter scanner layered on the existing writing subsystem. It scans `[`/`]`, keeps opening UTF-16 offsets in a stack, emits one-character advisory findings, and reuses the shared registry, analyzer ordering/bounds, diagnostic-summary, review/filter, persistence, Portable-settings, correction-skip, and editor pathways. No parallel parser or correction engine is introduced.
""",
    "docs/DEVELOPMENT.md": """## V2.14 development notes

Structural detection and structural mutation remain separate decisions. `UnmatchedSquareBracketRule` may deterministically prove that a literal bracket is unmatched, but it cannot prove whether insertion, deletion, movement, or a larger rewrite is correct. Development changes to this rule should preserve the stable ID, exact UTF-16 range, English eligibility, advisory-only replacement contract, explicit-override compatibility, and 5,000-level iterative stress coverage.
""",
    "docs/LANGUAGE_PACKS.md": """## V2.14 language eligibility

`unmatched-square-bracket` declares support for language code `en`, so both built-in `en-US` and `en-GB` packs receive the ninth default writing rule when no explicit override is stored. The release does not add auto-detection, a new language pack, or language-specific bracket parsing.
""",
    "docs/PERFORMANCE.md": """## V2.14 square-bracket analysis cost

The structural scan is iterative and makes one pass over UTF-16 code units while retaining unmatched opening offsets. Final unmatched indexes are source-ordered before issue emission. Stress tests cover 5,000 nested pairs and 5,000 unmatched openings to guard against recursion/stack-overflow regressions. Benchmark correctness continues to use deterministic counts; timing remains observational.
""",
    "docs/PRIVACY.md": """## V2.14 privacy boundary

Square-bracket analysis remains local and in memory. V2.14 adds no remote grammar request, telemetry, account, upload, cloud storage, background transfer, document persistence, or new preference payload. Privacy-safe diagnostic summaries may include `unmatched-square-bracket` and exact counts but exclude the editor text and finding excerpts that produced them.
""",
    "docs/RELEASING.md": """## V2.14 release acceptance

The V2.14 release identity is package `2.14.0+19` and About `2.14.0`. Release validation must verify the public `UnmatchedSquareBracketRule` export, stable ID `unmatched-square-bracket`, exactly nine built-in rules, focused V2.14 regression files, explicit V2.13 preference compatibility, synchronized `what_changed.md`/changelog/README/web metadata, unchanged direct runtime dependencies, a successful release web build, and zero disposable V2.14 helper residue.
""",
    "docs/ROADMAP.md": """## V2.14 — Unmatched Square Bracket Diagnostics — Implemented

V2.14 completes the next deterministic 2.x catalogue increment: a ninth built-in, advisory-only `unmatched-square-bracket` rule with nested literal balancing, exact one-character UTF-16 ownership, V2.13 explicit-override compatibility, Portable-settings preservation, bounded/private diagnostics, benchmark identity, stress coverage, and editor/review integration. It intentionally does not introduce syntax-aware parsing or automatic bracket mutation.
""",
    "docs/TESTING.md": """## V2.14 regression requirements

The ninth-rule release adds direct square-bracket scanner tests plus integration, bounded exact-total, privacy-safe diagnostic-summary, review-query, benchmark, Portable-settings, preference, widget, and 5,000-level stress suites. Historical registry/widget regressions must remain expansion-safe: exact current catalogue size belongs to the current-version integration test, while older-version tests should assert preservation of their rule/override contract instead of freezing future defaults.
""",
    "docs/TROUBLESHOOTING.md": """## V2.14 unmatched square bracket troubleshooting

The V2.14 rule is a literal `[`/`]` balancer. It can therefore report brackets that are intentionally unpaired inside code, Markdown, URLs, citations, quotations, mathematics, or another domain syntax. Disable the rule for the current language when that literal policy does not fit the document; do not treat the warning as an automatic deletion recommendation. **Automatic fixes only** hides these advisory findings.
""",
    "docs/USER_GUIDE.md": """## V2.14 unmatched square bracket workflow

Writing insights includes **Unmatched square bracket** under Mechanics. It reports literal `[` or `]` characters that cannot be paired and is enabled by current defaults. The finding is advisory: there is no automatic replacement because the intended correction may be insertion, deletion, movement, or rewriting. **Automatic fixes only** hides it, while other safe fixes can still be applied. Explicit older rule choices remain unchanged until you enable the rule or use **Reset rules to defaults**.
""",
    "docs/WRITING_RULES.md": """## V2.14 ninth built-in rule

The current built-in catalogue contains nine rules. `UnmatchedSquareBracketRule` (`unmatched-square-bracket`) is an English Mechanics warning that iteratively balances literal `[` and `]`, owns exactly one unmatched bracket in UTF-16 source coordinates, and never supplies an automatic replacement. It is independent from `unmatched-parenthesis`; both structural rules reuse the existing analyzer, bounded totals, review filters, diagnostics, preference model, and correction-skip behavior.
""",
}

for path, section in doc_sections.items():
    text = read(path)
    if "V2.14" in text[:4000] and path != ".github/pull_request_template.md":
        raise SystemExit(f"{path}: unexpected existing V2.14 content near top")
    if path == ".github/pull_request_template.md":
        if "## V2.14 structural-rule release checks" in text:
            raise SystemExit(f"{path}: V2.14 checklist already exists")
        text = section.strip() + "\n\n" + text
    else:
        text = insert_before_first_h2(text, section, path=path)
    slug = Path(path).stem.lower().replace("_", "-")
    updates[path] = (text, f"docs(v214): synchronize {slug} guidance")

# Web metadata keeps the same structure and only expands the advisory feature wording.
for path in ("web/index.html", "web/manifest.json"):
    text = read(path)
    text = replace_once(
        text,
        "advisory unmatched-parenthesis diagnostics",
        "advisory unmatched-parenthesis and unmatched-square-bracket diagnostics",
        path=path,
    )
    updates[path] = (text, f"web(v214): synchronize {Path(path).name} metadata")

# Full preflight: every update must differ, every path must exist, and no helper
# writes happen before all guarded transformations have succeeded.
for path, (new_text, _) in updates.items():
    original = read(path)
    if original == new_text:
        raise SystemExit(f"{path}: release transform produced no change")

# Apply all planned text changes, then create one permanent commit per file.
for path, (new_text, _) in updates.items():
    Path(path).write_text(new_text)

ordered_paths = [
    "lib/features/editor/spell_checker_page.dart",
    "test/widget_test.dart",
    "README.md",
    "CHANGELOG.md",
    "what_changed.md",
    ".github/pull_request_template.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "SUPPORT.md",
    "docs/ACCESSIBILITY.md",
    "docs/API.md",
    "docs/ARCHITECTURE.md",
    "docs/DEVELOPMENT.md",
    "docs/LANGUAGE_PACKS.md",
    "docs/PERFORMANCE.md",
    "docs/PRIVACY.md",
    "docs/RELEASING.md",
    "docs/ROADMAP.md",
    "docs/TESTING.md",
    "docs/TROUBLESHOOTING.md",
    "docs/USER_GUIDE.md",
    "docs/WRITING_RULES.md",
    "web/index.html",
    "web/manifest.json",
]

for path in ordered_paths:
    commit_path(path, updates[path][1])

print(f"V2.14 release synchronization committed {len(ordered_paths)} permanent files on {BRANCH}.")
