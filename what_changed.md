# What Changed

This file is the detailed implementation ledger for SpellChecker releases. It complements `CHANGELOG.md`: the changelog is release-oriented, while this document records the engineering behavior, compatibility boundaries, validation evidence, and permanent file-level changes that define the release.

## V2.6 — Deterministic Writing Rule Expansion

Release version: `2.6.0+11`

About version: `2.6.0`

V2.6 expands the deterministic local Writing insights catalogue while preserving the existing V2.0–V2.5 spelling, review, preference, portability, ranking, bounded-analysis, privacy, and correction contracts.

### New built-in writing rules

#### `punctuation-spacing`

Public class: `PunctuationSpacingRule`

The rule finds horizontal whitespace immediately before supported punctuation and proposes deletion of exactly that whitespace range.

Supported punctuation:

- comma `,`
- period `.`
- semicolon `;`
- colon `:`
- exclamation mark `!`
- question mark `?`

The rule is intentionally conservative. It does not rewrite punctuation, does not add punctuation, and does not attempt natural-language grammar inference. It only removes the source whitespace that is directly before one of the supported punctuation marks.

The finding uses the exact whitespace range as `originalText`, with an empty-string replacement. This means `WritingCorrection.apply()` and `WritingCorrection.applyAll()` can use the existing stale-range contract without any special correction path.

The stable rule ID is `punctuation-spacing`. Because writing-rule IDs participate in persisted per-language preferences, the ID is treated as a compatibility identifier and must not be renamed casually.

#### `trailing-whitespace`

Public class: `TrailingWhitespaceRule`

The rule finds horizontal whitespace at line endings and at the end of the document and proposes deletion of exactly that whitespace.

The line-ending behavior is deliberately CRLF-safe. For text using `\r\n`, the issue range ends before the carriage return/newline sequence rather than consuming any line-ending character. For LF input, the issue ends before `\n`. At document end, the issue ends at `text.length`.

The rule does not remove indentation at the beginning of a line and does not treat ordinary interior single spaces as trailing whitespace.

The stable rule ID is `trailing-whitespace`.

### Repeated-space ownership refinement

`RepeatedSpaceRule` remains the rule for runs of two or more horizontal spaces inside prose, but V2.6 narrows its ownership so it does not also claim ranges that the two specialized spacing rules own.

A repeated-space match is now skipped when the run is immediately before supported punctuation, immediately before a line ending, or at document end.

This prevents multiple automatic rules from competing for the same source whitespace. The ownership boundary is intentional:

- interior multi-space prose -> `repeated-space`
- horizontal whitespace before supported punctuation -> `punctuation-spacing`
- horizontal whitespace at line/document end -> `trailing-whitespace`

This design was chosen after the first V2.6 validation run exposed a real overlap interaction. The initial implementation allowed both `repeated-space` and a specialized spacing rule to report the same range. Depending only on lexical rule-ID ordering would have made batch results unnecessarily coupled to identifier ordering. The production rule boundary was therefore corrected so the specialized rules exclusively own their ranges.

### Registry and public API integration

Both new rules are exported from `package:spellchecker/writing.dart`.

`WritingRuleRegistry.builtIns` now contains six built-in rules:

1. `repeated-word`
2. `sentence-capitalization`
3. `repeated-space`
4. `repeated-punctuation`
5. `punctuation-spacing`
6. `trailing-whitespace`

`WritingRuleRegistry.defaultEnabledRuleIds` continues to derive from the built-in registry. This means a language whose writing-rule preference is unset receives the current six-rule default set, subject to language support.

Existing explicit persisted rule preferences are not rewritten. A stored non-empty set still enables exactly the stored supported IDs. A stored empty list still means explicitly disable all writing rules. Reset-to-defaults still clears the stored override so the current registry default can apply.

### Language eligibility

The two V2.6 rules declare support for the `en` language code through the existing `WritingRule.supports()` contract. They therefore run for both built-in English packs:

- English (US), `en-US`
- English (UK), `en-GB`

No language auto-detection was added. The selected language remains explicit and locally persisted.

### Writing insights behavior

Writing insights automatically renders the two new built-in rules because its rule-management UI is driven by the analyzer registry rather than hard-coded rule labels.

The two rules therefore participate in the existing workflows without a separate UI subsystem:

- per-language enable/disable switches
- Mechanics category filtering
- free-text review search
- Automatic fixes filtering/preset
- visible/total rule counts
- visible/total finding counts
- individual `Apply safe fix`
- `Apply all safe fixes`
- filtered `Apply visible safe fixes`
- stale-source refusal
- deterministic overlap handling
- one-step correction undo
- `Ctrl/Command+Shift+Enter` Writing insights keyboard workflow

Both rules use the existing Mechanics category default from `WritingRule`, so the public category contract remains source-compatible.

### Correction and undo behavior

No new correction engine was introduced.

The new rules produce ordinary immutable `WritingIssue` instances with deterministic replacements. `WritingCorrection.apply()` validates the exact current source substring before applying an individual fix. `WritingCorrection.applyAll()` continues to validate every candidate, skip stale/advisory/overlapping findings, choose deterministic non-overlapping fixes, and apply accepted replacements from the end of the document toward the beginning.

A Writing insights batch remains one editor correction-history entry. One `Undo correction` restores the complete pre-batch text.

### Persistence compatibility

V2.6 does not change any persisted format or preference key.

The existing per-language writing-rule key remains:

`spellchecker.writing_rule_ids.v1.<language-id>`

The existing language, personal dictionary, suggestion-limit, Portable settings, and writing-rule preference semantics are preserved.

A user upgrading with no stored writing-rule override receives the current six-rule defaults. A user with an explicit stored rule list keeps that explicit list. A user who explicitly disabled all rules keeps the empty override.

No migration is required because V2.6 adds new stable rule IDs without renaming existing IDs.

### Portable settings compatibility

The Portable settings codec format is unchanged.

Explicit per-language writing-rule override maps continue to preserve well-formed unknown rule IDs for forward compatibility. Therefore a V2.6 rule ID can already move through the existing preference-transfer mechanism without a format-version increase.

Editor text, personal vocabulary, ignored words, findings, and correction history remain excluded from Portable settings.

### Spelling compatibility

V2.6 does not change the spelling engine, dictionary formats, tokenization, language selection, suggestion ranking, or bounded analysis APIs.

The V2.4 injectable `SpellSuggestionRanker` contract remains unchanged.

The V2.5 `SpellCheckReport`/`SpellCheckerEngine.analyze()` bounded-analysis contract remains unchanged.

The built-in editor still captures at most 200 spelling issues, reports genuine truncation as `200+`, and suppresses Replace all when the checked occurrence set is incomplete.

### Runtime dependency boundary

V2.6 adds no runtime package.

The direct runtime dependency set remains:

- Flutter SDK
- `shared_preferences`

`pubspec.lock` remained unchanged after `flutter pub get` in the release gate.

### Privacy boundary

V2.6 adds no network request, remote grammar service, remote spelling service, telemetry, analytics, advertising, account system, document upload, background upload, or cloud rewriting behavior.

The new rules analyze the current editor string in memory only when Writing insights analysis is requested through the existing workflow.

The new findings are not persisted. Review search/preset/filter state remains transient. Correction history remains in memory.

### Security boundary

V2.6 does not add dynamic plugin loading, executable rule packages, remote rule downloads, network-fetched dictionaries, or runtime code evaluation.

The public `WritingRule` contract remains an in-process API. The built-in V2.6 rules operate only on the supplied string and language-pack metadata and return immutable issue data.

Automatic fixes remain protected by the existing exact-source validation before mutation.

### Accessibility behavior

The two new rules use normal Writing insights rule/finding components, so they inherit the existing semantic labels, category metadata, focus behavior, switch controls, finding messages, and safe-fix controls.

The enlarged six-rule catalogue exposed a test assumption that a fixed `-600` drag was always enough to materialize the batch action in the lazy `ListView`. The production dialog was not converted into an eager list. Instead, the legacy widget tests were hardened to scroll through the actual dialog `Scrollable` until the keyed batch action is visible before tapping it.

This preserves the production lazy-list behavior while making the regression tests resilient to catalogue growth.

### Test coverage added or expanded

`test/v26_writing_rules_test.dart` adds focused V2.6 coverage for:

- specialized punctuation-spacing ownership
- trailing-whitespace behavior
- CRLF/LF/document-end source ranges
- exact individual source-range correction
- stale individual correction refusal
- interaction with repeated punctuation
- deterministic batch composition
- Writing insights exposure of both new rule switches
- automatic batch application of the new mechanics
- one-step undo restoration

`test/writing_rules_test.dart` expands the built-in rule/analyzer contract coverage for:

- punctuation-spacing matches
- punctuation-spacing non-matches
- trailing-whitespace matches
- trailing-whitespace non-matches
- six default analyzed rule IDs
- default-enable behavior
- registry lookup by the new stable IDs
- English US/UK support

`test/writing_widget_test.dart` keeps the established writing workflows and now uses resilient scrolling for the enlarged lazy rule list.

### Validation history

The first read-only V2.6 Core Gate exposed the overlapping whitespace ownership described above. Source formatting and analyzer were already clean, but the focused test demonstrated that an automatic batch could leave a single terminal space because `repeated-space` and a specialized rule competed for the same source range.

The production rule boundary and focused expectations were corrected. The next core run passed the focused V2.6 tests but exposed two legacy widget tests whose fixed scroll distance no longer built/reached the batch button after the rule catalogue grew from four switches to six. The legacy tests were corrected to scroll the real lazy dialog until the keyed action is visible.

The final read-only Core Gate run `31379698591` then passed:

- dependency resolution
- runner formatting
- `flutter analyze`
- focused V2.6 tests
- the complete legacy writing subsystem suite
- the complete project test suite
- `flutter build web --release`

The first release-materialization gate run `31380142709` passed the full source/tests/build candidate, including all 150 project tests and the release web build, but the final hygiene assertion intentionally blocked the commit. The helper had been deleted from the working tree, while the audit queried `git ls-files` before staging the deletion, so the index still listed the helper path.

The release gate was corrected to stage the complete candidate with `git add -A` before checking tracked V2.6 helper/workflow residue. The audit therefore reflects the actual tree that would be committed rather than the pre-stage index.

Corrected Release Gate run `31380448117` passed every step:

- checkout of the V2.6 feature branch
- stable Flutter setup
- guarded one-time release integration
- one-time helper removal
- source/test formatting
- dependency resolution
- lockfile stability
- format verification
- analyzer
- focused V2.6 tests
- complete writing subsystem tests
- complete project regression suite
- release web build
- permanent V2.6 API/docs/web/version/runtime-dependency/hygiene audit
- exact validated-tree commit

The validated helper-free release candidate was committed as `d2686870d8ec89c0fe3154fb2261228b54eb8c01` before this change-ledger commit was added.

### Permanent V2.6 file inventory

The validated V2.6 candidate changed the following permanent files relative to the V2.5 `main` tree:

- `.github/pull_request_template.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `README.md`
- `SECURITY.md`
- `SUPPORT.md`
- `docs/ACCESSIBILITY.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/LANGUAGE_PACKS.md`
- `docs/PRIVACY.md`
- `docs/RELEASING.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `docs/TROUBLESHOOTING.md`
- `docs/USER_GUIDE.md`
- `docs/WRITING_RULES.md`
- `lib/features/editor/spell_checker_page.dart`
- `lib/writing.dart`
- `lib/writing/rules/punctuation_spacing_rule.dart`
- `lib/writing/rules/repeated_space_rule.dart`
- `lib/writing/rules/trailing_whitespace_rule.dart`
- `lib/writing/writing_analyzer.dart`
- `pubspec.yaml`
- `test/v26_writing_rules_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `web/index.html`
- `web/manifest.json`

This `what_changed.md` ledger is itself an additional permanent V2.6 documentation file.

### Files intentionally not changed

V2.6 does not require changes to the spelling dictionaries, personal-dictionary codecs, language registry, settings-transfer codec, persistence key versions, suggestion ranker interfaces, bounded spelling report model, correction core APIs, application entry point, analyzer configuration, license, ignore files, CODEOWNERS, Dependabot configuration, permanent CI workflow, or release workflow.

Those files remain part of the compatibility surface and are intentionally left unchanged rather than churned for release-number-only edits.

### Release invariant

The V2.6 release is considered complete only when the permanent `main` tree contains the helper-free `2.6.0+11` release, both new public rules and exports, the six-rule registry, the refined repeated-space ownership, all focused/legacy regression coverage, synchronized release documentation including this ledger, synchronized web metadata, and no temporary `tools/v26*` or `.github/workflows/v26-*` release-gate artifacts.
