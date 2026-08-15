# SpellChecker

[![CI](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/SpellChecker/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buymeacoffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

SpellChecker is a privacy-first, open-source Flutter spelling utility and writing assistant. It checks text locally, highlights spelling issues inside the editor, ranks correction suggestions, supports explicit language packs, persistent per-language vocabulary and writing-rule preferences, keyboard-first review, batch-safe corrections, and undo-friendly editing workflows.

## Highlights

- Local spell checking and writing analysis: editor text is not sent to a remote spelling or grammar service.
- Explicit built-in language selection: English (US) and English (UK).
- Unicode-aware word tokenization and punctuation normalization.
- Per-language persisted personal dictionaries with legacy V1 migration.
- Per-language persisted writing-rule preferences with backward-compatible defaults.
- Language-tagged detailed suggestion metadata.
- Public injectable `SpellSuggestionRanker` strategy with the pre-V2.4 ranking preserved as the default.
- Stable lexical tie-breaking for custom ranker ties.
- Bounded large-document spelling analysis with an explicit first-200 issue UI policy and safe limited-result messaging.
- Bounded Writing insights analysis with an explicit first-200 finding policy, exact observed/per-rule totals, captured/total diagnostics, and captured-only limited-review/fix semantics.
- Deterministic privacy-safe V2.9 writing-analysis diagnostic summaries containing counts and rule metadata only.
- Developer-run V2.10 deterministic large-document benchmark tooling with synthetic corpus generation, versioned JSON/human reports, and CI smoke coverage.
- V2.15 advisory unmatched-curly-brace diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.14 preference compatibility, and a ten-rule default registry.
- V2.14 advisory unmatched-square-bracket diagnostics with nested literal balancing, single-character UTF-16 ownership, explicit V2.13 preference compatibility, and its historical nine-rule default registry.
- V2.13 advisory unmatched-parenthesis diagnostics with nested literal balancing, single-character source ownership, explicit V2.12 preference compatibility, and its historical eight-rule default registry.
- V2.12 missing-punctuation-space analysis with Unicode combining-mark boundaries, punctuation-only source ownership, safe batch composition, and its historical seven-rule default registry.
- V2.11 keyboard-first Writing insights review with Ctrl/Command+F search focus, deterministic Escape filter clearing, and live rule/finding count semantics.
- Optional local **Writing insights** with configurable deterministic rules.

- Writing-rule categories with source-compatible **Mechanics** default and built-in **Clarity** review.
- Stable Writing insights review presets: **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes**.
- Temporary Writing insights search, category filters, and **Automatic fixes only** review.
- Versioned **Portable settings** copy/import for selected language, suggestion count, and explicit per-language writing-rule overrides.
- **Apply visible safe fixes (N)** when review filters are active.
- **Reset rules to defaults** clears the selected language's stored override so future registry defaults can evolve.
- Public `WritingRule` plugin contract and deterministic `WritingAnalyzer`.
- Built-in repeated-word, sentence-capitalization, repeated-space, punctuation-spacing, missing-punctuation-space, trailing-whitespace, repeated-punctuation, unmatched-parenthesis, unmatched-square-bracket, and unmatched-curly-brace rules.
- **Apply all safe fixes** for non-overlapping current writing findings.
- Stale-range-safe individual and batch writing corrections.
- One-step undo for a complete writing-fix batch.
- `Ctrl/⌘+Shift+Enter` opens Writing insights.
- Inline wavy underlines for checked spelling issues.
- Stronger visual treatment for the active spelling issue.
- `Ctrl/⌘+Enter` spelling check, `F7` next issue, and `Shift+F7` previous issue.
- Active issue synchronization between editor selection and the Results panel.
- Damerau-Levenshtein candidate filtering with an extensible deterministic ranking strategy and frequency-aware default ordering.
- Replace one occurrence with case preservation.
- Replace all checked occurrences of the same unknown word.
- Bounded in-memory correction undo history shared by spelling and writing fixes.
- Stale source-offset protection before every automatic text mutation.
- Expanded bundled English vocabulary.
- Better regular contraction and possessive handling from known stems.
- Import/export of language-aware personal dictionaries.
- Session-only ignored-word support.
- Configurable 1–10 suggestions per issue, persisted locally.
- Dedicated blank-input, clean-result, ready, and storage-warning states.
- Accessibility semantics and live-region announcements for important result states.
- Word, character, and sentence statistics.
- Responsive Material 3 UI with system light/dark theme support.
- Unit, persistence, codec, controller, and widget regression tests.
- GitHub Actions continuous integration and tagged web-release automation.
- Open-source contribution, security, privacy, accessibility, governance, support, and release documentation.

## Current release

`2.15.0+20`

Version 2.15 is the **Unmatched Curly Brace Diagnostics** release. It adds the tenth built-in writing rule, `unmatched-curly-brace`, for deterministic local reporting of literal `{` and `}` characters that cannot be paired. The rule is warning-level and advisory-only: it does not guess whether an unmatched brace should be inserted, deleted, moved, or rewritten. Unset/reset rule preferences adopt the ten-rule registry while explicit V2.14 nine-rule choices remain exact. No persistence-format, runtime-dependency, telemetry, account, or application-network expansion is introduced.

## Unmatched curly brace diagnostics — V2.15

`UnmatchedCurlyBraceRule` balances literal curly braces iteratively, accepts nesting, and reports each unmatched brace with a one-character UTF-16 source range. A closing brace without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. Non-BMP offsets and 5,000 levels of nesting are covered by focused regressions.

The rule deliberately has no automatic replacement. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Parentheses and square brackets remain owned by their existing structural rules. Syntax-aware programming/template parsing remains outside V2.15 scope.

Existing explicit nine-rule V2.14 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current ten-rule registry. Portable settings keep the same format version and preserve both historical explicit sets and explicit V2.15 ten-rule sets.

See [V2.15 unmatched curly brace diagnostics](docs/V2_15_UNMATCHED_CURLY_BRACE.md) and [Writing rules](docs/WRITING_RULES.md).

## Unmatched square bracket diagnostics — V2.14

`UnmatchedSquareBracketRule` balances literal square brackets iteratively, accepts nesting, and reports each unmatched bracket with a one-character UTF-16 source range. A closing bracket without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. Non-BMP offsets and 5,000 levels of nesting are covered by focused regressions.

The rule deliberately has no automatic replacement. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Parentheses remain owned by the V2.13 rule; curly braces and syntax-aware parsing remain outside V2.14 scope.

Existing explicit eight-rule V2.13 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current nine-rule registry. Portable settings keep the same format version and preserve both older explicit sets and explicit V2.14 nine-rule sets.

See [V2.14 unmatched square bracket diagnostics](docs/V2_14_UNMATCHED_SQUARE_BRACKET.md) and [Writing rules](docs/WRITING_RULES.md).

## Unmatched parenthesis diagnostics — V2.13

`UnmatchedParenthesisRule` balances literal parentheses iteratively, accepts nesting, and reports each unmatched parenthesis with a one-character UTF-16 source range. A closing parenthesis without an available opening is unmatched immediately; openings left after the scan are also unmatched; final findings are source ordered. The implementation is covered around non-BMP text and with 5,000 levels of nesting.

The rule deliberately has no automatic replacement because the intended correction may be insertion, deletion, movement, or a larger rewrite. **Automatic fixes only** hides these findings, and `WritingCorrection.applyAll` skips them while still applying independent safe fixes. Literal parentheses inside code, Markdown, quotes, URLs, or other domain syntax are not parser-suppressed in V2.13.

Existing explicit seven-rule V2.12 overrides remain authoritative. Languages with no override—or languages reset to defaults—use the current eight-rule registry. Portable settings keep the same format version and preserve both older explicit seven-rule sets and new eight-rule sets.

See [V2.13 unmatched parenthesis diagnostics](docs/V2_13_UNMATCHED_PARENTHESIS.md) and [Writing rules](docs/WRITING_RULES.md).

## Missing punctuation spacing and Unicode boundaries — V2.12

V2.12 adds `MissingPunctuationSpaceRule` (`missing-punctuation-space`) to the public writing-rule API and default registry. For both built-in English packs it detects `,`, `;`, `!`, and `?` between Unicode letter boundaries when the following horizontal whitespace is missing, and proposes a deterministic punctuation-plus-space replacement. Periods and colons stay outside this automatic scope.

The predecessor boundary accepts a Unicode letter followed by zero or more combining marks, so decomposed text such as `cafe\u0301,naive` is handled without consuming the following word. The issue range owns only the punctuation mark. When whitespace also exists before the punctuation, `punctuation-spacing` owns that whitespace and `missing-punctuation-space` owns the adjacent punctuation mark, allowing `WritingCorrection.applyAll` to produce `Hello, world` from `Hello ,world` without overlapping edits.

Users with an unset writing-rule preference receive the seven-rule default catalogue. Existing explicit per-language sets—including an explicit empty set—remain authoritative and are not silently expanded. **Reset rules to defaults** clears the override and therefore opts the language into the current seven-rule defaults.

See [V2.12 missing punctuation spacing and Unicode boundaries](docs/V2_12_MISSING_PUNCTUATION_SPACING.md) and [Writing rules](docs/WRITING_RULES.md).

## Keyboard-first Writing insights accessibility — V2.11

While Writing insights is open, `Ctrl+F` / `Command+F` moves focus to the existing **Search rules and findings** field. Escape is intentionally two-stage: when transient search/category/automatic-fix filters are active it clears the entire transient review query and keeps the dialog open; when the review query is already empty, Escape closes the dialog through the normal result path. A focus anchor inside the shortcut scope keeps these bindings available while keyboard focus moves among dialog controls.

Visible rule and finding counts now expose concise live semantic labels. Limited results keep their existing captured-only safety boundary and, when exact diagnostics are available, announce the relationship between visible, captured, and exact total findings without implying uncaptured findings are reviewable or fixable. `WritingInsightsDialog.maxIssues` is validated at runtime, so invalid non-positive bounds are rejected in release builds as well as tests.

V2.11 does not persist review search/categories/automatic-fix filters, does not add clipboard behavior beyond the existing explicit diagnostic-summary copy action, and does not add network or telemetry behavior. See [V2.11 accessibility contract](docs/V2_11_ACCESSIBILITY.md) and [Accessibility](docs/ACCESSIBILITY.md).

## Deterministic large-document benchmark — V2.10

V2.10 adds a developer-run benchmark target built from generated synthetic text and a fixed benchmark dictionary/frequency table, so corpus shape and spelling eligibility remain stable when bundled dictionaries evolve. Each measured iteration creates fresh spelling/analyzer state and records bounded spelling scan metadata plus exact writing-analysis totals.

```bash
dart run tool/benchmark_large_document.dart \
  --repeats=2000 \
  --warmup=1 \
  --iterations=5 \
  --spelling-limit=200 \
  --writing-limit=200 \
  --suggestions=5 \
  --language=en-US \
  --json
```

Omit `--json` for the human-readable report. Reports include only scenario shape, language, analysis outcome counts/states, sorted analyzed writing-rule IDs, exact per-rule finding totals, and elapsed microseconds; they never serialize the generated corpus text. Timings are machine/toolchain dependent and are intended for controlled comparisons, not pass/fail correctness thresholds. Both `en-US` and `en-GB` are supported.

The benchmark lives under `tool/` and is not an application telemetry feature or a new public runtime API. CI runs only a tiny synthetic smoke scenario to verify the command remains executable; it does not enforce timing targets. See [Performance and large-document behavior](docs/PERFORMANCE.md).

## Shareable writing-analysis diagnostics — V2.9

`WritingAnalysisDiagnosticSummary.fromResult(...)` builds an immutable metadata snapshot from a `WritingAnalysisResult`. Pass the analyzer's rules when human-readable rule names are desired; rows are always emitted in lexical rule-ID order.

```dart
final result = WritingAnalyzer().analyze(
  text,
  languagePack: SpellLanguageRegistry.englishUs,
  maxIssues: 200,
);
final summary = WritingAnalysisDiagnosticSummary.fromResult(
  result,
  rules: WritingRuleRegistry.builtIns,
);
final reportText = summary.toPlainText();
```

The summary includes language ID, complete/limited status, capture limit, captured/exact/uncaptured counts when available, analyzed rule IDs/display names, and captured/exact per-rule counts. It deliberately excludes editor text, source excerpts, finding messages, replacements, source offsets, personal vocabulary, ignored words, review filters, correction history, timestamps, device identifiers, telemetry, and network metadata. The model itself has no clipboard, persistence, or network side effect. Writing insights exposes an explicit **Copy diagnostic summary** action that copies only the privacy-safe `toPlainText()` representation after user input; it never copies editor text or finding excerpts as part of that action.

## Exact Writing insights diagnostics — V2.8

`WritingAnalysisResult` now exposes exact diagnostics for analyzer-produced results: `totalIssueCount`, immutable `totalIssueCountByRule`, `hasExactIssueTotals`, and `uncapturedIssueCount`. Direct V2.7-style construction can omit these fields for source compatibility.

With `maxIssues: 200`, the analyzer still retains only the globally earliest 200 findings, but it counts every finding observed during the full enabled/supported rule scan. Writing insights can therefore show exact text such as **Showing the first 200 of 1437 findings in review order**, an exact omitted count, per-rule **Total findings: N** metadata, and a `200/1437` captured/total badge.

Exact counts are informational. Search, presets, category filters, automatic-fix filtering, individual fixes, and batch fixes remain scoped to retained findings when a result is truncated. Exact diagnostics do not authorize mutation of uncaptured ranges and do not replace stale-source/overlap/one-step-undo protections.

The diagnostics are local, in-memory, and deterministic. They are not saved in Portable settings or preferences, sent to telemetry, logged remotely, or treated as a CPU-time/document-size security bound. See [API](docs/API.md), [Performance](docs/PERFORMANCE.md), and [Writing rules](docs/WRITING_RULES.md).

## Large-document Writing insights — V2.7

`WritingAnalyzer.analyze()` now accepts an optional positive `maxIssues` argument. Omitting it keeps the historical unbounded behavior. A bounded `WritingAnalysisResult` reports `issueLimit`, `isTruncated`, `isComplete`, and `capturedIssueCount`.

Bounded results keep the same earliest review-order prefix as unbounded analysis even when a later rule yields an earlier source range. Reaching the numerical cap alone is not truncation: `isTruncated` becomes true only after another finding is observed.

The built-in Writing insights dialog captures at most 200 findings. When overflow is proven it displays a limited notice, uses `200+`-style count semantics, and states that search/presets/category/fix filters operate on captured findings only. Batch labels become **Apply captured safe fixes (N)** or **Apply visible captured safe fixes (N)** so a partial result is never presented as a complete whole-document finding set.

Rules are still executed across the supplied text so the globally earliest captured prefix remains correct. The bound limits retained finding objects/dialog workload; it is not a CPU-time or maximum-document-size promise. See [Performance and large-document behavior](docs/PERFORMANCE.md).

## Large-document spelling checks — V2.5

The public `SpellCheckerEngine.check()` method remains an unbounded compatibility API. Callers that need bounded issue capture can use `analyze()`:

```dart
final report = engine.analyze(
  text,
  suggestionLimit: 5,
  maxIssues: 200,
);
```

A bounded report captures at most `maxIssues` `SpellIssue` objects. Reaching the numerical cap alone does **not** mark the report truncated: the engine keeps inspecting tokens until it reaches the end or proves that one additional unknown word exists. Suggestions are not generated for that first overflow issue.

The built-in editor uses a 200-issue cap. A genuinely limited result shows `200+` and an accessible notice. Navigation/highlighting cover the captured prefix. Single fixes remain available, but **Replace all** is hidden because a partial issue list cannot truthfully represent all checked occurrences in the document.

This is an issue/suggestion-work bound, not a maximum document-size promise. See [Performance and large-document behavior](docs/PERFORMANCE.md) for the precise contract and profiling guidance.

## Language selection

Use the compact language selector in the Editor header to choose **English (US)** or **English (UK)**. The selection is stored locally and restored later. Changing language re-checks non-blank editor text using the selected pack and loads that language's saved personal vocabulary and writing-rule choices.

Saved personal vocabulary is isolated by language. A word saved in `en-US` is not automatically accepted in `en-GB`. Version-2 personal-dictionary exports include the language ID so the application can prevent accidental cross-language imports.

SpellChecker does not auto-detect language. Explicit selection is intentional. See [Language packs](docs/LANGUAGE_PACKS.md).

## Writing insights

Select **Writing insights** in the app bar or press `Ctrl+Shift+Enter` / `⌘+Shift+Enter` to run optional local writing rules against the current in-memory editor text.

The built-in rules cover:

- Repeated adjacent words.
- Sentence-start capitalization.
- Repeated interior horizontal spaces.
- Horizontal whitespace before common punctuation.
- Missing following whitespace after commas, semicolons, exclamation marks, and question marks between Unicode letter boundaries.
- Trailing horizontal whitespace at line/document ends.
- Repeated identical punctuation.

These rules are deterministic helpers, not a claim of full natural-language grammar coverage.

### Expanded deterministic mechanics — V2.6

Writing insights now includes **Punctuation spacing** (`punctuation-spacing`) and **Trailing whitespace** (`trailing-whitespace`) for both built-in English packs. Both rules use exact source ranges and empty-string automatic replacements, so individual and batch fixes continue through the existing stale-range-safe `WritingCorrection` APIs.

`Repeated spaces` remains responsible for repeated interior spaces, but deliberately does not emit for a run immediately before common punctuation or at a line/document ending. Those ranges belong to the V2.6 specialized rules. This prevents two automatic rules from proposing incompatible fixes for the same characters while leaving the global V2.1 overlap policy unchanged.

Users whose per-language rule preference is **unset/default** receive the expanded registry defaults. An explicit saved rule list—including an explicit empty list—remains authoritative and is not silently expanded. **Reset rules to defaults** clears the stored override and therefore opted that language back into the then-current six-rule defaults in V2.6; V2.12 now resolves an unset/reset language to the seven-rule default catalogue.

### Review filters — V2.2

Writing insights can now narrow both rule management and findings without persisting review text/state:

- Search rules and findings by rule ID/name/description/category, finding message/source text, or suggested replacement.
- Filter by **Mechanics** and/or **Clarity**.
- Enable **Automatic fixes only** to hide advisory findings.
- Use **Clear review filters** to return to the complete enabled-rule review.
- Rule and finding headers show visible/total counts.

Search text, selected categories, and the automatic-fix filter live only inside the open Writing insights dialog. They are not stored in `shared_preferences` and disappear when the dialog closes.

When filters are active, the batch action becomes **Apply visible safe fixes (N)** and passes only currently visible automatic findings to the same V2.1 `WritingCorrection.applyAll` safety/overlap/undo pipeline.

### Review presets — V2.3

Writing insights adds four stable local review presets:

- **All findings** (`all-findings`) — clears category/fix-only filtering.
- **Mechanics** (`mechanics`) — selects the Mechanics category.
- **Clarity** (`clarity`) — selects the Clarity category.
- **Automatic fixes** (`automatic-fixes`) — shows deterministic automatic findings only.

Presets project into the existing `WritingReviewQuery` state; they do not create a second filtering engine. Free-text search is intentionally retained when changing presets, so a user can combine a preset with a temporary search. Preset selection, search text, category filters, and automatic-fixes-only state are memory-only dialog state and disappear when Writing insights closes.


### Reset rules to defaults — V2.2

**Reset rules to defaults** differs from enabling every current switch. It clears the selected language's persisted writing-rule override key, resolves the current registry defaults in memory, and closes the dialog. This returns that language to the **unset/default** preference state so future default-rule changes can be picked up normally.

If clearing the local override fails, built-in defaults remain active for the current session while SpellChecker reports that the saved override could not be removed; the old override may therefore reappear after restart until storage succeeds.

### Persistent rule choices

Each language has its own locally stored set of enabled writing-rule IDs. V2.1 distinguishes three states:

- No stored preference: use the current built-in default rule set.
- Non-empty stored set: enable exactly those supported rule IDs.
- Empty stored set: explicitly disable all writing rules for that language.

Changing a switch in Writing insights updates the active session immediately. When local preference storage is available, the choice is saved and restored on later launches. A storage failure does not discard the current session choice; the editor reports that persistence is unavailable.

### Safe individual fixes

A finding exposes **Apply safe fix** only when the rule provides a deterministic replacement. Before mutation, SpellChecker verifies that the source range still contains the exact text that was analysed. A stale finding is refused instead of being applied to changed text.

### Apply all safe fixes

When one or more findings have automatic replacements, Writing insights exposes **Apply all safe fixes (N)**.

Batch correction follows a deterministic safety contract:

1. Findings are ordered by source start, then end, then rule ID.
2. Advisory findings without replacements are skipped.
3. Stale findings whose source range no longer matches are skipped.
4. If automatic fixes overlap, the earliest deterministic finding is retained and later overlapping findings are skipped.
5. Accepted replacements are applied from the end of the document toward the beginning so checked offsets remain valid.
6. The operation reports how many fixes were applied and how many findings were skipped.
7. The entire batch is recorded as one correction-history entry, so one **Undo correction** restores the document from before the batch.

See [Writing rules](docs/WRITING_RULES.md).

## Portable settings — V2.3

Open **Portable settings** from the app bar to copy or import a versioned preferences document.

The current format is:

```json
{
  "format": "spellchecker-settings",
  "version": 1,
  "languageId": "en-US",
  "suggestionLimit": 5,
  "writingRuleOverrides": {
    "en-US": ["sentence-capitalization"],
    "en-GB": []
  }
}
```

Only durable non-document preferences are transferred:

- Selected built-in language ID.
- Suggestion count (1–10).
- Complete set of **explicit** per-language writing-rule overrides.

Override semantics are preserved exactly: a missing language key means **unset/use current registry defaults**, while a present empty array means **explicitly disable all rules** for that language. Valid well-formed unknown future rule IDs are preserved for forward compatibility; malformed IDs, unsupported languages/formats/versions, malformed structures, and invalid suggestion limits are rejected.

Portable settings deliberately exclude editor text, personal dictionary words, ignored session words, spelling findings, writing findings, and correction/undo history. Export copies JSON only when the user presses **Copy settings JSON**. Import reads user-pasted JSON locally; it does not contact a server.

Import is persistence-first. SpellChecker snapshots the previous portable preference document, writes the imported language/limit/complete override map, and performs a best-effort rollback if any local write fails. `shared_preferences` does not provide multi-key transactions, so rollback is documented as best effort rather than atomic. The live editor state changes only after persistence succeeds. Target-language personal vocabulary is loaded separately and preserved; editor text remains unchanged, stale issue/correction state is cleared, and non-blank text is rechecked with the imported language.


## Main workflow

1. Type or paste text into the editor.
2. Choose the explicit spelling language.
3. Select **Check spelling** or press `Ctrl+Enter` / `⌘+Enter`.
4. Checked issues receive inline underlines and appear in the Results panel.
5. Use `F7` / **Next issue** or `Shift+F7` / **Previous issue** to move through issues.
6. Select a suggestion chip to replace one spelling occurrence.
7. When an unknown word occurs more than once, use **Replace all…** for checked matching occurrences.
8. Open **Writing insights** or press `Ctrl/⌘+Shift+Enter` for local writing-rule review.
9. Enable or disable rules for the selected language; V2.1 saves those choices locally.
10. Apply one safe writing fix or **Apply all safe fixes**.
11. Use snackbar **Undo** or **Undo correction** to restore the latest spelling or writing correction. A batch writing fix is one undo entry.
12. Select **Save word** to persist valid custom vocabulary for the selected language.
13. Select **Ignore once** for a session-only spelling exception.
14. Open **Manage personal dictionary** to add/remove words, import/export vocabulary, clear saved words, or configure suggestions per issue.
15. Use **Clear ignored session words** to restore temporary ignored-word checks without deleting saved settings.

## Keyboard shortcuts

| Shortcut | Action |
| --- | --- |
| `Ctrl+Enter` | Run spelling check on Windows/Linux/web keyboard layouts |
| `⌘+Enter` | Run spelling check on macOS keyboard layouts |
| `Ctrl+Shift+Enter` | Open Writing insights on Windows/Linux/web keyboard layouts |
| `⌘+Shift+Enter` | Open Writing insights on macOS keyboard layouts |
| `F7` | Move to the next spelling issue |
| `Shift+F7` | Move to the previous spelling issue |

Issue navigation wraps from the final spelling issue to the first and vice versa.

## Correction safety and undo

Spelling and writing findings include source offsets from a specific analysis snapshot. Before applying an automatic correction, SpellChecker verifies that the text at those offsets still matches the checked source text. If it does not, the correction is refused or skipped.

Programmatic spelling and writing corrections are stored in one bounded in-memory correction stack. Spelling **Replace all** and Writing insights **Apply all safe fixes** are each recorded as one correction, so one Undo restores the state from before the corresponding bulk operation. Manual typing starts a new editing history and clears the correction-specific undo stack.

## Personal dictionary format

Current language-aware exports use version 2:

```json
{
  "version": 2,
  "language": "en-US",
  "words": [
    "flutter",
    "open-source",
    "writer's"
  ]
}
```

The codec remains backward-compatible with version-1 SpellChecker objects, JSON arrays, and newline/comma-separated word lists. Imported entries are normalized according to the selected language pack, duplicates are removed, and invalid entries are rejected. A version-2 export with an unsupported or mismatched language is not silently reinterpreted.

## Local persistence

SpellChecker currently stores these settings locally through `shared_preferences`:

- Selected language ID.
- Personal dictionary words, namespaced by language.
- Suggestion-count preference.
- Enabled writing-rule IDs, namespaced by language.

V2.3 can copy/import a user-triggered portable representation of the selected language, suggestion count, and explicit writing-rule override map. The transfer document itself is not automatically persisted as a document or sent anywhere; import writes those values back through the same local preference adapter.

SpellChecker does **not** persist editor documents, spelling result lists, writing-analysis findings, ignored words, active issue positions, or correction undo snapshots.

## Requirements

- Flutter stable
- Dart SDK `>=3.8.0 <4.0.0`
- A supported Flutter development environment

Check the local toolchain:

```bash
flutter doctor
flutter --version
dart --version
```

## Clone and run

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter run -d chrome
```

The repository includes Flutter web host files. The Dart/Flutter application code is platform-neutral; additional Flutter host runners can be generated with Flutter tooling when packaging for other supported targets.

## Quality checks

Run the core validation used by CI:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Check formatting before committing:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Build the release web application when preparing a release:

```bash
flutter build web --release
```

## Project structure

```text
SpellChecker/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   ├── workflows/
│   ├── CODEOWNERS
│   ├── dependabot.yml
│   └── pull_request_template.md
├── docs/
│   ├── ACCESSIBILITY.md
│   ├── API.md
│   ├── ARCHITECTURE.md
│   ├── DEVELOPMENT.md
│   ├── LANGUAGE_PACKS.md
│   ├── PRIVACY.md
│   ├── RELEASING.md
│   ├── ROADMAP.md
│   ├── TESTING.md
│   ├── TROUBLESHOOTING.md
│   ├── USER_GUIDE.md
│   └── WRITING_RULES.md
├── lib/
│   ├── app.dart
│   ├── language.dart
│   ├── main.dart
│   ├── spell_checker.dart
│   ├── writing.dart
│   ├── core/
│   │   ├── edit_distance.dart
│   │   ├── personal_dictionary_codec.dart
│   │   ├── settings_transfer_codec.dart
│   │   ├── spell_checker_engine.dart
│   │   ├── spell_issue.dart
│   │   ├── spell_language_pack.dart
│   │   ├── spell_suggestion.dart
│   │   ├── spell_suggestion_ranker.dart
│   │   ├── text_correction.dart
│   │   └── text_statistics.dart
│   ├── data/
│   │   ├── english_dictionary.dart
│   │   ├── english_dictionary_extension.dart
│   │   ├── english_gb_dictionary.dart
│   │   └── english_word_frequencies.dart
│   ├── features/editor/
│   │   ├── dictionary_manager_dialog.dart
│   │   ├── settings_transfer_dialog.dart
│   │   ├── spell_check_editing_controller.dart
│   │   ├── spell_checker_page.dart
│   │   └── writing_insights_dialog.dart
│   ├── storage/
│   │   ├── dictionary_preferences.dart
│   │   └── settings_transfer_service.dart
│   └── writing/
│       ├── rules/
│       ├── writing_analyzer.dart
│       ├── writing_correction.dart
│       ├── writing_issue.dart
│       ├── writing_review_preset.dart
│       ├── writing_review_query.dart
│       └── writing_rule.dart
├── test/
│   ├── dictionary_preferences_test.dart
│   ├── language_dictionary_codec_test.dart
│   ├── language_pack_test.dart
│   ├── language_preferences_test.dart
│   ├── personal_dictionary_codec_test.dart
│   ├── spell_check_editing_controller_test.dart
│   ├── spell_checker_test.dart
│   ├── text_correction_test.dart
│   ├── text_statistics_test.dart
│   ├── widget_test.dart
│   ├── writing_analysis_diagnostics_test.dart
│   ├── writing_analysis_diagnostics_widget_test.dart
│   ├── writing_analysis_limit_test.dart
│   ├── writing_analysis_limit_widget_test.dart
│   ├── writing_correction_test.dart
│   ├── writing_preferences_test.dart
│   ├── writing_review_preset_test.dart
│   ├── writing_review_query_test.dart
│   ├── settings_transfer_codec_test.dart
│   ├── settings_transfer_dialog_test.dart
│   ├── settings_transfer_service_test.dart
│   ├── suggestion_ranker_test.dart
│   ├── v23_widget_test.dart
│   ├── writing_rules_test.dart
│   └── writing_widget_test.dart
├── web/
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── SECURITY.md
├── SUPPORT.md
└── pubspec.yaml
```

## Architecture

The application separates presentation, spelling, writing-rule analysis, correction, data, and local persistence:

- `lib/core/` contains reusable spelling/language/correction primitives.
- `lib/writing/` contains the local writing-rule plugin contract, analyzer, issue model, built-in rules, and safe corrections.
- `lib/features/editor/` contains the editor, spelling results, language selection, dictionary management, and Writing insights UI.
- `lib/data/` contains bundled dictionaries and ranking data.
- `lib/storage/` owns device-local preferences used by the application UI.
- `lib/spell_checker.dart`, `lib/language.dart`, and `lib/writing.dart` are public reusable API barrels.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Core API examples

Spelling:

```dart
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine();
final text = 'Helo Flutter';
final issues = engine.check(text, suggestionLimit: 3);

if (issues.isNotEmpty && issues.first.suggestions.isNotEmpty) {
  final corrected = TextCorrection.replaceOne(
    text,
    issues.first,
    issues.first.suggestions.first,
  );
  print(corrected.text);
}
```

Writing analysis and a batch correction:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

final analyzer = WritingAnalyzer();
final pack = SpellLanguageRegistry.englishUs;
final analysis = analyzer.analyze(
  'hello  world!!',
  languagePack: pack,
  maxIssues: 200,
);

print(analysis.capturedIssueCount);
print(analysis.totalIssueCount); // exact analyzer-produced total in V2.8

final corrected = WritingCorrection.applyAll(
  'hello  world!!',
  analysis.issues,
);
print(corrected.text); // Hello world!
```

See [docs/API.md](docs/API.md) for the public contracts.

## Privacy and storage

Spell checking and Writing insights remain local. The project contains no cloud spelling/grammar API, analytics SDK, advertising SDK, authentication system, or telemetry pipeline.

Editor text is not persisted by SpellChecker. Personal words, selected language, suggestion count, and writing-rule IDs are stored locally through `shared_preferences`. Ignored words, analysis findings, and correction undo snapshots remain in memory only. Import/export is user initiated and uses pasted text or the local clipboard.

See [docs/PRIVACY.md](docs/PRIVACY.md).

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [Language packs](docs/LANGUAGE_PACKS.md)
- [Writing rules](docs/WRITING_RULES.md)
- [API reference](docs/API.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Development setup](docs/DEVELOPMENT.md)
- [Testing](docs/TESTING.md)
- [Performance and large-document behavior](docs/PERFORMANCE.md)
- [Accessibility](docs/ACCESSIBILITY.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Roadmap](docs/ROADMAP.md)
- [Release procedure](docs/RELEASING.md)
- [Privacy](docs/PRIVACY.md)
- [Contributing](CONTRIBUTING.md)
- [Support](SUPPORT.md)
- [Security policy](SECURITY.md)
- [Governance](GOVERNANCE.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Changelog](CHANGELOG.md)
- [Detailed engineering change ledger](what_changed.md)

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request. Keep spelling and writing-rule logic independent from UI code, include regression tests for behavior changes, preserve deterministic correction safety, preserve keyboard/accessibility behavior, keep user text local by default, and update documentation for user-visible changes.

## Security

Do not publish exploitable security details in normal public issues. Follow [SECURITY.md](SECURITY.md) for responsible reporting guidance.

## Support development

If SpellChecker is useful to you and you want to support its open-source development, you can [buy Sanskar a coffee](https://buymeacoffee.com/sanskarIN). Financial support is optional and does not change access to the MIT-licensed project, issue handling, or contribution review.

## License

SpellChecker is released under the [MIT License](LICENSE).

Copyright © 2026 Sanskar.
