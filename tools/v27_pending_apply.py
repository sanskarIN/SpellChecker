# commit-message: docs: record complete V2.7 engineering changes
from pathlib import Path

path = Path('what_changed.md')
text = path.read_text()
marker = '## V2.6 — Deterministic Writing Rule Expansion\n'
if text.count(marker) != 1:
    raise SystemExit('Expected exactly one V2.6 ledger marker.')
if '## V2.7 — Bounded Writing Analysis & Large-Document Review Safety' in text:
    raise SystemExit('V2.7 ledger already exists.')
section = '''## V2.7 — Bounded Writing Analysis & Large-Document Review Safety

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

'''
text = text.replace(marker, section + marker)
path.write_text(text)
