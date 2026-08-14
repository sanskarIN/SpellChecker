# What Changed

This file is the detailed implementation ledger for SpellChecker releases. It complements `CHANGELOG.md`: the changelog is release-oriented, while this document records the engineering behavior, compatibility boundaries, validation evidence, and permanent file-level changes that define the release.

## V2.7 — Bounded Writing Analysis & Large-Document Review Safety

Release version: `2.7.0+12`

About version: `2.7.0`

V2.7 extends the large-document safety work from spelling into the optional local Writing insights subsystem. The release deliberately bounds **retained writing findings** while preserving global deterministic review ordering, existing rule execution, correction safety, persistence compatibility, and local-only privacy behavior.

### Public bounded-analysis API

`WritingAnalyzer.analyze()` now accepts an optional named `int? maxIssues` parameter.

- `maxIssues == null` preserves the historical unbounded result-capture behavior.
- A supplied limit must be greater than zero.
- Zero or negative values throw `ArgumentError` before rule analysis.
- Existing source code that omits the parameter remains compatible.

`WritingAnalysisResult` adds immutable bounded-analysis metadata:

- `issueLimit` — the requested positive limit, or `null` for unbounded analysis.
- `isTruncated` — true only after at least one finding beyond the retained set has been observed.
- `isComplete` — convenience inverse of `isTruncated`.
- `capturedIssueCount` — the number of retained `WritingIssue` objects.

The existing `issues`, `analyzedRuleIds`, `languageId`, `isClean`, and `issueCountByRule` APIs remain available. In a truncated result, `issueCountByRule` describes the retained findings rather than pretending to be a whole-document per-rule total.

The result constructor rejects inconsistent bounded metadata. A non-positive `issueLimit` is invalid, and a result cannot claim `isTruncated == true` without declaring an issue limit.

### Global deterministic prefix preservation

A bounded analysis cannot simply stop after the first N values yielded by registered rules. Rule execution order is not the same thing as global review order: one rule can yield a finding near the end of the document and a later rule can yield a finding near the beginning.

V2.7 therefore introduces a private bounded ordered collector. It uses the same comparator as unbounded `WritingAnalyzer` results:

1. source `start` ascending;
2. severity ordering used by the existing analyzer;
3. `ruleId` ascending as the deterministic final tie-breaker.

While fewer than N findings are retained, new findings are inserted into their sorted position. Once the collector is full, an additional finding proves truncation. If that finding belongs before the current worst retained item, it is inserted and the worst item is removed. Otherwise it is discarded.

This guarantees that the retained bounded list equals the first N findings of the corresponding fully sorted unbounded analysis without storing the complete finding list.

### Exact-at-limit completeness

V2.7 keeps the same truthful truncation philosophy used by bounded spelling analysis: reaching a numerical cap is not, by itself, proof that data was omitted.

If exactly N findings exist for `maxIssues: N`, the result remains complete. `isTruncated` becomes true only after another finding is actually observed.

### What the bound does and does not bound

The V2.7 collector bounds retained `WritingIssue` objects and downstream dialog rendering/filtering work for the retained set.

It does **not** stop enabled rules after N findings. Every supported/enabled rule is still invoked across the supplied text so later rules can contribute earlier globally ordered findings and so exact-at-limit completeness can be distinguished from genuine overflow.

Therefore V2.7 does not claim to bound:

- document characters or lines;
- total rule matches that may be scanned;
- rule execution time;
- CPU work of arbitrary custom rules;
- plugin execution time;
- memory used internally by a custom rule implementation.

Applications that process untrusted very large documents or third-party rules still need their own input-size, execution-time, isolation, or plugin-trust policy.

### Built-in Writing insights policy

`WritingInsightsDialog` now accepts a positive `maxIssues` parameter and defaults it to `WritingInsightsDialog.defaultMaxIssues`, which is 200.

The editor continues to construct the dialog through the existing workflow, so normal users receive the 200-finding policy without a second settings surface or a persistence change.

When an additional finding beyond the limit is proven, the dialog:

- shows a limited-analysis explanatory card;
- exposes that explanation through a semantic container/live region;
- uses limited-count semantics instead of presenting the retained count as complete;
- states that review filters and batch actions use captured findings only;
- uses **Apply captured safe fixes (N)** when no review filter is active;
- uses **Apply visible captured safe fixes (N)** when filters are active;
- says **No matching captured findings** when active filters hide every retained finding while additional uncaptured findings may still exist.

When the result is complete, the historical **Apply all safe fixes** and **Apply visible safe fixes** wording remains unchanged.

### Review/filter compatibility

V2.2 search, category filters, automatic-fixes-only review, and V2.3 presets still reuse `WritingReviewQuery`. V2.7 does not create a second filtering engine.

For a truncated analysis, those controls filter the captured prefix only. This scope is communicated in the dialog rather than implying a query has inspected findings that were intentionally not retained.

Review search text, selected categories, automatic-fix state, and preset selection remain transient dialog state and are not persisted.

### Correction and undo compatibility

V2.7 does not create a new correction engine.

Individual captured automatic findings still use `WritingCorrection.apply()`. Captured batch findings still use `WritingCorrection.applyAll()` with the established contracts:

- replacement must exist;
- source range must remain valid;
- current source text must still equal `originalText` exactly;
- advisory findings are skipped;
- overlapping automatic fixes are resolved conservatively/deterministically;
- accepted replacements are applied end-to-start;
- the entire accepted batch is one correction-history entry.

One **Undo correction** therefore restores the complete pre-batch editor text even when the batch originated from a limited captured result.

### Writing-rule compatibility

V2.7 adds no writing-rule ID and changes no built-in rule behavior. The V2.6 six-rule catalogue remains:

- `repeated-word`
- `sentence-capitalization`
- `repeated-space`
- `punctuation-spacing`
- `trailing-whitespace`
- `repeated-punctuation`

The V2.6 specialized spacing ownership boundary remains unchanged.

### Persistence and Portable settings compatibility

V2.7 changes no persistence key, persisted structure, or transfer-format version.

Per-language writing-rule preferences still distinguish unset/default, explicit non-empty, and explicit empty/disable-all states. Personal vocabulary, selected language, suggestion count, and Portable settings behavior are unchanged.

The writing-analysis limit is an API/editor policy, not a new durable user preference, so it is not added to Portable settings.

### Spelling/ranking compatibility

V2.7 does not change the spelling engine or the V2.5 `SpellCheckReport` contract. The editor's existing first-200 spelling issue policy remains independent from the first-200 Writing insights finding policy.

V2.4 suggestion-ranker extensibility and default deterministic ordering remain unchanged.

### Runtime dependency boundary

V2.7 adds no runtime package. Direct runtime dependencies remain Flutter and `shared_preferences`; release validation must confirm `pubspec.lock` stability unless an independent dependency change is intentionally reviewed.

### Privacy boundary

Writing analysis remains local and in memory. V2.7 adds no network request, cloud spelling/grammar service, telemetry, analytics, advertising, account system, remote document upload, or background analysis/upload behavior.

The limit and truncation metadata are not persisted. Captured findings can contain source excerpts just like pre-V2.7 `WritingIssue` values and must not be logged/exported by default.

### Security boundary

The bounded collector is a retained-result safety mechanism, not a sandbox or execution timeout. No remote/dynamic rule loading is introduced. Built-in rules remain source-controlled deterministic local code, and automatic corrections retain stale-source validation.

### Accessibility behavior

The limited-result message is semantically announced and gives the captured count/limit plus captured-only filter/batch scope. Limited states avoid relying on color alone. Existing keyboard access, rule switches, review controls, safe-fix buttons, dialog scrolling, and `Ctrl/Command+Shift+Enter` access remain available.

### Focused core coverage

`test/writing_analysis_limit_test.dart` covers:

- unbounded compatibility;
- invalid non-positive limits;
- exact-at-limit completeness;
- true overflow/truncation;
- global sorted-prefix equivalence;
- later-rule displacement of worse retained findings;
- captured per-rule counts;
- result metadata invariants;
- immutable captured issue lists;
- deliberately out-of-order custom-rule streams.

### Focused widget coverage

`test/writing_analysis_limit_widget_test.dart` covers:

- the built-in default limit of 200;
- a synthetic low limit that produces a real truncated dialog state;
- visible limited-result explanation;
- **Apply captured safe fixes** behavior;
- returned captured finding ranges;
- filtered **No matching captured findings** wording;
- explicit warning that uncaptured findings may still exist.

### Validation defects caught during development

The first new V2.7 test files required canonical Dart formatting; a disposable formatter gate committed only those formatter changes.

The first analyzer pass then found nine `prefer_const_constructors` lints in the synthetic core tests. Those were fixed in a test-only commit without changing production behavior.

After formatting/analyzer were green, the full suite exposed one viewport-dependent widget assertion. The test had scrolled the lazy dialog to the limited-result notice and then expected a standalone `2+` text widget that was no longer necessarily built in that viewport. The stronger behavioral assertions—the proven-overflow notice, captured batch label, returned captured ranges, and limited filtered state—were retained, while the brittle viewport-specific badge assertion was removed in a dedicated test-only commit.

Permanent CI run `31487337689` (CI #181) then passed dependency resolution, formatting, analyzer, and the complete project test suite on functional head `a7f5414d811f0f74fee1bca9b5991517bc17e7d5` before release metadata/documentation changes began.

Subsequent guarded documentation transformations run through a disposable V2.7 helper gate that deletes the pending helper, formats source/tests, resolves dependencies, runs analyzer, checks the diff, and refuses to commit helper residue.

### V2.7 permanent file scope before final release validation

The release intentionally changes these implementation/test surfaces:

- `lib/writing/writing_analyzer.dart`
- `lib/features/editor/writing_insights_dialog.dart`
- `lib/features/editor/spell_checker_page.dart` (About metadata only after functional freeze)
- `test/writing_analysis_limit_test.dart`
- `test/writing_analysis_limit_widget_test.dart`
- `pubspec.yaml`

Release/documentation surfaces synchronized for V2.7 include:

- `README.md`
- `CHANGELOG.md`
- `what_changed.md`
- `.github/pull_request_template.md`
- `docs/ROADMAP.md`
- `docs/WRITING_RULES.md`
- `docs/PERFORMANCE.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/TESTING.md`
- `docs/USER_GUIDE.md`
- `docs/ACCESSIBILITY.md`
- `docs/TROUBLESHOOTING.md`
- `docs/LANGUAGE_PACKS.md`
- `docs/PRIVACY.md`
- `docs/RELEASING.md`
- `SECURITY.md`
- `SUPPORT.md`
- `CONTRIBUTING.md`
- `web/index.html`
- `web/manifest.json`

### Files intentionally not redesigned in V2.7

The release does not require a new personal-dictionary codec, settings-transfer version, preference key family, language pack, spelling dictionary, suggestion ranker, writing rule ID/category/preset, correction result model, application entry point, CI dependency, analyzer configuration, license, CODEOWNERS policy, Dependabot rule, or runtime package.

Those surfaces remain compatibility boundaries and should not be churned solely to mention the release number.

### V2.7 release invariant

V2.7 is complete only when the exact final PR head passes permanent CI, an exact-tree release gate passes `flutter build web --release` plus full formatting/analyzer/tests/hygiene assertions, `what_changed.md` contains the final validation evidence, the helper PR is closed unmerged, and merged `main` is byte-identical to the exact CI-green release head with no `tools/v27*` or `.github/workflows/v27-*` disposable artifact.

### Final V2.7 release-gate evidence

Read-only V2.7 Final Release Gate run `31489335300` validated candidate `a09c1ba18e25ae3afafec346d172de26cd258a41` and passed every configured stage:

- stable Flutter setup and dependency resolution;
- `pubspec.lock` stability in the working tree and against V2.6 `main`;
- canonical formatting and `git diff --check`;
- `flutter analyze`;
- focused `writing_analysis_limit_test.dart`;
- focused `writing_analysis_limit_widget_test.dart`;
- the complete project test suite;
- `flutter build web --release`;
- `2.7.0+12` package and `2.7.0` About identity assertions;
- bounded analyzer/result/dialog/test API markers;
- changelog/README/roadmap/technical/user/accessibility/privacy/security/support/release/PR-template/ledger markers;
- web manifest JSON validity;
- unchanged direct runtime dependency set (`flutter`, `shared_preferences`);
- zero `tools/v27*` or `.github/workflows/v27-*` path in the permanent feature diff.

This evidence was recorded after the successful gate, so the final documentation-complete head must be revalidated before merge. The release may not rely on this earlier SHA alone.

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

## V2.9 zero-error hardening audit — 2026-08-14

This audit continues from the merged V2.9 diagnostic-summary baseline at commit `5b16c18c1dba9a9c1a1e1522199467c319254d10`. The work was intentionally split into small implementation, regression-test, formatting, configuration, workflow, dependency, and documentation commits for reviewability.

### Production correctness fixes

- Replaced `SpellCheckReport` debug-only constructor assertions with runtime validation so invalid report metadata is rejected in release builds as well as debug builds. Runtime checks cover negative scanned-token counts, non-positive limits, truncated reports without limits, captured issue counts above the declared limit, and scanned-token counts smaller than captured issue counts.
- Made `SpellLanguagePack.recognizedSuffixes` a defensive immutable snapshot so caller-owned list mutation cannot change pack behavior after construction.
- Normalized custom `SpellCheckerEngine.wordFrequencies` keys through the active language pack, discarded empty normalized keys, and retained the best/lower rank when multiple source keys normalize to the same word.
- Tightened sentence-capitalization boundary detection so terminal punctuation must be followed by separating whitespace before the next token; dot-connected text such as `example.com` no longer creates a false sentence boundary.
- Strengthened `WritingAnalysisResult` runtime consistency checks so captured findings must belong to analyzed rules and the result language, and exact per-rule totals may contain only analyzed rule IDs.
- Made `WritingAnalyzer` reject duplicate configured rule IDs before analysis so enablement, persistence, ordering, and diagnostics cannot become ambiguous.
- Preserved Flutter's native active IME composing span while text composition is in progress instead of replacing it with custom spelling-highlight spans.
- Made `TextStatistics` word counting Unicode-letter aware with the same supported internal apostrophe/hyphen token forms used by spelling tokenization.
- Corrected the About dialog release version from stale `2.8.0` to `2.9.0`.

### Regression coverage added

- Added release-mode constructor-invariant tests for `SpellCheckReport`.
- Added immutable recognized-suffix configuration coverage.
- Added custom frequency-key normalization and normalized-duplicate ranking coverage.
- Added dot-connected sentence-boundary coverage.
- Added `WritingAnalysisResult` analyzed-rule/language/per-rule-total ownership coverage.
- Added duplicate writing-rule-ID rejection coverage.
- Added active IME composition rendering coverage in the spell-check editing controller.
- Added Unicode text-statistics coverage.
- Added V2.9 About-dialog version coverage.

### Toolchain and dependency hygiene

- Synchronized analyzer exclusions with the Flutter 3.47 project/tooling layout used by CI.
- Applied the exact Dart 3.13 formatter output required by CI.
- Refreshed `pubspec.lock` with Flutter 3.47 so `flutter pub get` no longer dirties the tracked lockfile. The refresh includes `matcher 0.12.20`, `meta 1.19.0`, `test_api 0.7.12`, and `vector_math 2.4.2`.

### Workflow cleanup

- Removed obsolete one-time V2.2, V2.3, and V2.8 reconciliation workflows from the permanent tree. Those workflows had write permissions and their own release-tree checks stated that disposable helper workflows must not remain after reconciliation.
- Restored the permanent workflow directory to the normal `ci.yml` and tagged `release.yml` workflows after each temporary diagnostic/synchronization helper completed.

### V2.9 release/documentation synchronization

- Updated README current-release metadata to `2.9.0+14` and documented the public privacy-safe writing-analysis diagnostic summary.
- Added the missing `2.9.0` changelog entry.
- Updated API documentation for V2.9, six built-in writing-rule IDs, runtime model invariants, Unicode statistics, immutable language configuration, normalized custom frequencies, and `WritingAnalysisDiagnosticSummary`.
- Advanced release instructions from the stale V2.8 candidate/tag to `2.9.0+14` / `v2.9.0`, and added the lockfile-clean verification requirement.
- Updated architecture, language-pack, privacy, testing, troubleshooting, user-guide, writing-rule, accessibility, performance, contribution, security, support, issue-template, and pull-request-template documentation to match the V2.9 implementation and hardening contracts.
- Kept the V2.9 diagnostic-summary privacy contract exact: the model contains counts/rule/language metadata only and has no automatic clipboard, persistence, telemetry, or network side effect.

### Repository-wide audit coverage

The audit explicitly inspected the complete tracked project surface rather than only files already failing CI: top-level Dart barrels/startup, every core engine/model/codec/statistics file, all bundled dictionary/frequency data, both storage adapters, every writing model/analyzer/rule, every editor widget/controller/dialog, every test file, all GitHub templates/workflows/metadata, root governance/release/security/support files, all documentation files, and the tracked web host files. Files with no demonstrated defect or drift were intentionally left unchanged.

### Validation evidence

Before this audit-log commit, the repair branch passed the permanent CI format/analyze/full-test workflow on the code/configuration hardening head. This final release-validator run then completed all release-sensitive checks on the synchronized V2.9 candidate using Flutter stable / Dart from the CI toolchain:

```text
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build web --release
```

All commands above completed successfully before this section was committed. A final ordinary CI run is required again after removing the one-time validator so the permanent-tree head is independently checked with the repository's normal workflow.

### Result

The audited candidate has no known remaining formatter error, analyzer diagnostic, failing automated test, lockfile drift, or release-web build failure. This is a verified zero-failure state for the repository's automated gates and the audited invariants above; it is not a claim that any non-trivial software can be mathematically guaranteed to contain zero undiscovered future bugs.
