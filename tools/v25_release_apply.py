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


# ---------------------------------------------------------------------------
# Package + editor integration.
# ---------------------------------------------------------------------------
replace_once(
    'pubspec.yaml',
    'version: 2.4.0+9',
    'version: 2.5.0+10',
    'package version',
)

page = Path('lib/features/editor/spell_checker_page.dart')
page_text = page.read_text()

old = '  static const int _maxCorrectionUndoDepth = 20;'
new = (
    '  static const int _maxCorrectionUndoDepth = 20;\n'
    '  static const int _maxVisibleSpellingIssues = 200;'
)
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: correction-depth marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '  bool _hasChecked = false;\n  bool _preferencesLoaded = false;'
new = (
    '  bool _hasChecked = false;\n'
    '  bool _spellingResultsTruncated = false;\n'
    '  bool _preferencesLoaded = false;'
)
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: checked-state marker mismatch')
page_text = page_text.replace(old, new, 1)

reset_marker = '      _hasChecked = false;'
reset_count = page_text.count(reset_marker)
if reset_count < 5 or reset_count > 10:
    raise RuntimeError(
        f'spell_checker_page.dart: unexpected checked-state reset count {reset_count}'
    )
page_text = page_text.replace(
    reset_marker,
    reset_marker + '\n      _spellingResultsTruncated = false;',
)

old = '''  void _checkText({int? preferredOffset}) {
    final text = _controller.text;
    final issues = _engine.check(text, suggestionLimit: _suggestionLimit);
    final activeIndex = _chooseActiveIssueIndex(issues, preferredOffset);

    setState(() {
      _statistics = TextStatistics.fromText(text);
      _issues = issues;
      _activeIssueIndex = activeIndex;
      _hasChecked = true;
    });
    _controller.setIssues(issues, activeIssueIndex: activeIndex);
  }
'''
new = '''  void _checkText({int? preferredOffset}) {
    final text = _controller.text;
    final report = _engine.analyze(
      text,
      suggestionLimit: _suggestionLimit,
      maxIssues: _maxVisibleSpellingIssues,
    );
    final issues = report.issues;
    final activeIndex = _chooseActiveIssueIndex(issues, preferredOffset);

    setState(() {
      _statistics = TextStatistics.fromText(text);
      _issues = issues;
      _activeIssueIndex = activeIndex;
      _hasChecked = true;
      _spellingResultsTruncated = report.truncated;
    });
    _controller.setIssues(issues, activeIssueIndex: activeIndex);
  }
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: _checkText marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''                    hasChecked: _hasChecked,
                    inputIsBlank: _controller.text.trim().isEmpty,
'''
new = '''                    hasChecked: _hasChecked,
                    resultsTruncated: _spellingResultsTruncated,
                    issueLimit: _maxVisibleSpellingIssues,
                    inputIsBlank: _controller.text.trim().isEmpty,
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: ResultsPanel call marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''    required this.hasChecked,
    required this.inputIsBlank,
'''
new = '''    required this.hasChecked,
    required this.resultsTruncated,
    required this.issueLimit,
    required this.inputIsBlank,
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: ResultsPanel constructor marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''  final bool hasChecked;
  final bool inputIsBlank;
'''
new = '''  final bool hasChecked;
  final bool resultsTruncated;
  final int issueLimit;
  final bool inputIsBlank;
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: ResultsPanel field marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''                  Semantics(
                    liveRegion: true,
                    label:
                        '${widget.issues.length} spelling ${widget.issues.length == 1 ? 'issue' : 'issues'} found',
                    child: Badge(
                      label: Text('${widget.issues.length}'),
                      child: const Icon(Icons.rule),
                    ),
                  ),
'''
new = '''                  Semantics(
                    liveRegion: true,
                    label: widget.resultsTruncated
                        ? 'At least ${widget.issues.length} spelling issues found. Results are limited.'
                        : '${widget.issues.length} spelling ${widget.issues.length == 1 ? 'issue' : 'issues'} found',
                    child: Badge(
                      label: Text(
                        widget.resultsTruncated
                            ? '${widget.issues.length}+'
                            : '${widget.issues.length}',
                      ),
                      child: const Icon(Icons.rule),
                    ),
                  ),
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: result badge marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
'''
new = '''            if (widget.resultsTruncated) ...<Widget>[
              const SizedBox(height: 8),
              _ResultLimitNotice(issueLimit: widget.issueLimit),
            ],
            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: result content marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''            occurrenceCount: widget.occurrenceCount(issue),
            isActive: isActive,
'''
new = '''            occurrenceCount: widget.occurrenceCount(issue),
            allowReplaceAll: !widget.resultsTruncated,
            isActive: isActive,
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: IssueTile call marker mismatch')
page_text = page_text.replace(old, new, 1)

notice = '''class _ResultLimitNotice extends StatelessWidget {
  const _ResultLimitNotice({required this.issueLimit});

  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message =
        'Showing the first $issueLimit spelling issues. More unknown words exist later in the document. Replace all is unavailable for limited results; use single fixes or check a smaller section.';
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

'''
marker = 'class _IssueTile extends StatelessWidget {'
if page_text.count(marker) != 1:
    raise RuntimeError('spell_checker_page.dart: IssueTile class marker mismatch')
page_text = page_text.replace(marker, notice + marker, 1)

old = '''    required this.occurrenceCount,
    required this.isActive,
'''
new = '''    required this.occurrenceCount,
    required this.allowReplaceAll,
    required this.isActive,
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: IssueTile constructor marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''  final int occurrenceCount;
  final bool isActive;
'''
new = '''  final int occurrenceCount;
  final bool allowReplaceAll;
  final bool isActive;
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: IssueTile fields marker mismatch')
page_text = page_text.replace(old, new, 1)

old = "if (occurrenceCount > 1)\n                      Chip(label: Text('$occurrenceCount occurrences'))"
new = """if (occurrenceCount > 1)
                      Chip(
                        label: Text(
                          allowReplaceAll
                              ? '$occurrenceCount occurrences'
                              : '$occurrenceCount captured occurrences',
                        ),
                      )"""
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: occurrence chip marker mismatch')
page_text = page_text.replace(old, new, 1)

old = '''                  if (occurrenceCount > 1) ...<Widget>[
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
'''
new = '''                  if (occurrenceCount > 1 && allowReplaceAll) ...<Widget>[
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
'''
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: replace-all marker mismatch')
page_text = page_text.replace(old, new, 1)

if page_text.count("applicationVersion: '2.4.0'") != 1:
    raise RuntimeError('spell_checker_page.dart: About version marker mismatch')
page_text = page_text.replace("applicationVersion: '2.4.0'", "applicationVersion: '2.5.0'", 1)

old = 'deterministic extensible suggestion ranking, categorized local writing rules'
new = 'deterministic extensible suggestion ranking, bounded large-document spelling results, categorized local writing rules'
if page_text.count(old) != 1:
    raise RuntimeError('spell_checker_page.dart: About description marker mismatch')
page_text = page_text.replace(old, new, 1)

page.write_text(page_text)

# ---------------------------------------------------------------------------
# README + changelog + roadmap.
# ---------------------------------------------------------------------------
replace_once(
    'README.md',
    '- Stable lexical tie-breaking for custom ranker ties.\n',
    '- Stable lexical tie-breaking for custom ranker ties.\n- Bounded large-document spelling analysis with an explicit first-200 issue UI policy and safe limited-result messaging.\n',
    'README highlight',
)

old_release = '''`2.4.0+9`

Version 2.4 is the **Suggestion Ranking Extensibility & Determinism** release. It preserves the existing spelling candidate eligibility, Damerau-Levenshtein thresholds, default ranking order, metadata, language packs, V2.3 Portable settings/review presets, and all correction-safety behavior while extracting suggestion ordering into a public injectable strategy. Custom rankers receive normalized target/language context plus candidate distance, prefix, frequency, and source metadata; the engine applies a final lexical tie-break so equal custom scores remain deterministic. No user preference, transfer format, or runtime dependency changes in V2.4.
'''
new_release = '''`2.5.0+10`

Version 2.5 is the **Bounded Analysis & Large-Document Safety** release. It keeps V2.4 suggestion-ranker extensibility and every existing spelling/writing/persistence contract while adding public `SpellCheckReport` metadata and `SpellCheckerEngine.analyze()` for optional bounded issue capture. The built-in editor captures at most 200 spelling issues, labels genuinely truncated results as `200+`, and disables **Replace all** when the checked occurrence set is incomplete. No persistence format, network behavior, or runtime dependency changes in V2.5.
'''
replace_once('README.md', old_release, new_release, 'README current release')

bounded_readme = '''## Large-document spelling checks — V2.5

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
'''
insert_before('README.md', '## Language selection\n', bounded_readme, 'README V2.5 section')

changelog_entry = '''## [2.5.0] - 2026-08-09

### Added

- Public immutable `SpellCheckReport` with captured issues, scanned-token count, truncation state, issue limit, completeness, and captured-count metadata.
- Public `SpellCheckerEngine.analyze()` API with optional positive `maxIssues` capture bound.
- Dedicated `docs/PERFORMANCE.md` contract for large-document behavior and profiling.
- End-to-end widget coverage for the 200-issue editor cap and limited-result bulk-action safety.

### Changed

- Package version advances to `2.5.0+10`; About version advances to `2.5.0`.
- Historical `SpellCheckerEngine.check()` remains unbounded and delegates to `analyze()` without a cap.
- After a bounded analysis reaches its capture cap, the engine scans only until it either reaches the token-stream end or proves that one additional unknown token exists.
- The proven overflow issue is not materialized and receives no suggestion generation.
- The built-in editor captures at most 200 spelling issues and renders a `200+` badge only when an additional issue is actually proven.
- Limited results show an accessible explanation and label repeated words as captured occurrences.
- **Replace all** is hidden when spelling results are truncated because the checked occurrence set is incomplete.

### Compatibility, performance, security, and privacy

- Inputs with exactly the configured issue count remain complete when no later issue exists.
- Single-occurrence correction, navigation, highlighting, personal-dictionary actions, ignored-word behavior, V2.4 suggestion ranking, V2.3 Portable settings, and writing workflows remain compatible.
- `maxIssues` bounds captured issues/expensive suggestion materialization; it is not represented as a hard document-length bound.
- `SpellCheckReport` remains memory-only and adds no persistence, telemetry, network request, logging, background upload, or runtime dependency.
'''
insert_before('CHANGELOG.md', '## [2.4.0] - 2026-08-08\n', changelog_entry, 'V2.5 changelog')

roadmap_section = '''## 2.5 — Bounded analysis and large-document safety

Status: implemented.

- [x] Public immutable `SpellCheckReport` analysis metadata.
- [x] Backward-compatible unbounded `check()` behavior.
- [x] Optional positive `maxIssues` capture bound on `analyze()`.
- [x] Truncation reported only after an additional unknown token is proven.
- [x] No suggestion generation for the proven overflow issue.
- [x] Built-in editor cap of 200 captured spelling issues.
- [x] `200+` result badge and accessible limited-result notice.
- [x] Captured-occurrence wording for limited results.
- [x] Bulk Replace all suppression for incomplete checked occurrence sets.
- [x] Focused core and widget regression coverage.
- [x] Dedicated performance/profiling documentation.
- [x] No persistence/network/runtime-dependency expansion.
'''
insert_before('docs/ROADMAP.md', '## Future 2.x direction\n', roadmap_section, 'V2.5 roadmap')

# ---------------------------------------------------------------------------
# API / architecture / developer / testing documentation.
# ---------------------------------------------------------------------------
append_section(
    'docs/API.md',
    '# V2.5 bounded spelling-analysis APIs',
    '''# V2.5 bounded spelling-analysis APIs

## `SpellCheckReport`

`SpellCheckReport` is exported through `package:spellchecker/spell_checker.dart` and is an in-memory immutable report value.

```dart
final report = engine.analyze(text, maxIssues: 200);
```

Fields/getters:

```text
issues                 immutable captured SpellIssue list
scannedTokenCount      tokens inspected before completion/truncation proof
truncated              true only when another uncaptured issue is proven
issueLimit             requested positive capture bound, or null
complete               !truncated
capturedIssueCount     issues.length
```

The report does not claim `scannedTokenCount` is the document's total token count when `truncated` is true; analysis returns at the first proven overflow unknown token.

## `SpellCheckerEngine.analyze`

```dart
SpellCheckReport analyze(
  String text, {
  int suggestionLimit = 5,
  int? maxIssues,
})
```

`maxIssues == null` performs unbounded issue capture. A supplied value must be greater than zero or `ArgumentError` is thrown.

The engine captures issues in source order. Once the cap is full it continues token inspection without materializing further issues until it reaches the end or sees one more unknown token. That overflow token proves truncation and causes immediate return without suggestion generation for the overflow issue.

## `check()` compatibility

```dart
List<SpellIssue> check(String text, {int suggestionLimit = 5})
```

The historical method remains public and unbounded. It delegates to `analyze()` with no issue cap and returns the report's immutable issue list. Existing call sites do not need to opt into V2.5 bounds.

## Safety boundary

`maxIssues` does not weaken language normalization, known-word checks, source offsets, suggestion ranking, edit-distance thresholds, stale correction protection, or personal/ignored dictionary behavior. It controls issue capture/suggestion work only.''',
)

append_section(
    'docs/ARCHITECTURE.md',
    '# V2.5 bounded analysis boundary',
    '''# V2.5 bounded analysis boundary

V2.5 separates **analysis completeness metadata** from the historical list-returning spell-check API.

```text
editor/caller
    |
    v
SpellCheckerEngine.analyze(text, maxIssues: N)
    |
    +-- tokenization + known-word checks
    |
    +-- captured issues (<= N) -> suggestions/ranker/cache
    |
    +-- after N, inspect until end or first additional unknown
    |
    v
SpellCheckReport
```

Only captured issues enter suggestion generation and UI highlighting. The first overflow unknown proves truncation but is not converted into a `SpellIssue`.

The built-in editor selects `N = 200`. This is a presentation/performance policy, not a persisted preference or public engine default. Other callers can choose another positive cap or remain unbounded.

When the editor report is truncated, bulk Replace all is withheld because `TextCorrection.replaceAll` intentionally mutates checked ranges from the current issue list. Single checked-range corrections remain safe.

No new storage layer, isolate/background worker, network boundary, dynamic plugin loader, or document cache is introduced.''',
)

append_section(
    'docs/DEVELOPMENT.md',
    '## V2.5 bounded-analysis development contract',
    '''## V2.5 bounded-analysis development contract

When changing spelling-analysis performance behavior:

- Keep `check()` source-compatible and unbounded unless a future breaking release explicitly changes the contract.
- Reject non-positive explicit issue caps.
- Preserve source-order captured issues.
- Do not mark a result truncated merely because `issues.length == maxIssues`.
- Do not generate suggestions for the first proven overflow issue.
- Keep report issue lists immutable.
- Preserve V2.4 ranking/candidate eligibility semantics for captured issues.
- Do not expose Replace all from an incomplete checked issue set.
- Use synthetic text in performance/regression tests.
- Prefer deterministic work-count/state assertions over wall-clock thresholds on shared CI hardware.
- Update `docs/PERFORMANCE.md` when changing the meaning of a bound or the editor cap.''',
)

append_section(
    'docs/TESTING.md',
    '## V2.5 bounded-analysis coverage',
    '''## V2.5 bounded-analysis coverage

Focused core coverage lives in:

```bash
flutter test test/spell_check_report_test.dart
```

It protects unbounded `check()` compatibility, exact-cap completeness, proven-overflow truncation, skipped overflow suggestion generation, positive-cap validation, scanned-token metadata, and immutable report issues.

Focused editor coverage lives in:

```bash
flutter test test/bounded_analysis_widget_test.dart
```

It uses 201 repeated synthetic unknown tokens to prove the `200+` limited-results state, accessible warning text, captured-occurrence wording, and absence of Replace all. A small two-occurrence complete result separately proves that Replace all remains available when results are complete.

Do not replace these deterministic invariants with timing thresholds. See `docs/PERFORMANCE.md` for profiling guidance.''',
)

append_section(
    'docs/USER_GUIDE.md',
    '# Large documents and limited spelling results — V2.5',
    '''# Large documents and limited spelling results — V2.5

SpellChecker can accept long editor text, but the built-in Results panel intentionally captures at most the first 200 spelling issues per check.

If more unknown words exist, the badge shows **200+** and the Results panel explains that later issues were not captured. Inline underlines and F7/Shift+F7 navigation then cover the captured issues only.

You can still:

- Apply a single suggestion.
- Save a captured word to the personal dictionary.
- Ignore a captured word for the current session.
- Re-run spelling after edits.

**Replace all** is intentionally unavailable while results are limited. A partial checked issue list does not contain every matching source range, so presenting a partial mutation as “all” would be misleading. Work on a smaller section or apply single fixes, then check again.

A result that happens to contain exactly 200 issues is not automatically labeled limited. The `200+` state appears only after SpellChecker proves that another unknown word exists.''',
)

append_section(
    'docs/ACCESSIBILITY.md',
    '## V2.5 limited-result accessibility',
    '''## V2.5 limited-result accessibility

The limited spelling-result state must not rely on the `+` badge alone.

When results are truncated, the Results panel provides a live-region semantic message and visible explanatory text stating that only the first 200 spelling issues were captured and that Replace all is unavailable. Repeated-word chips use “captured occurrences” wording so screen-reader and visual users receive the same incompleteness signal.

Keyboard issue navigation remains available across captured issues. Do not expose a keyboard-only bulk action that bypasses the limited-result Replace all restriction.''',
)

append_section(
    'docs/TROUBLESHOOTING.md',
    '## Results show 200+ — V2.5',
    '''## Results show 200+ — V2.5

`200+` means SpellChecker captured 200 spelling issues and then found at least one additional unknown word later in the text.

This is not a crash or storage problem. Single fixes and captured-issue navigation still work. Replace all is hidden because the checked occurrence set is incomplete.

If you need to review later portions, fix/ignore/save some early issues and check again, or temporarily check a smaller section of the document. Do not interpret the 200 captured issues as the total number of issues in the document.

If fewer than 200 issues are shown without `+`, the result completed normally.''',
)

# ---------------------------------------------------------------------------
# Privacy / security / support / contributor / release contracts.
# ---------------------------------------------------------------------------
append_section(
    'docs/PRIVACY.md',
    '## V2.5 bounded-analysis privacy behavior',
    '''## V2.5 bounded-analysis privacy behavior

`SpellCheckReport` is memory-only. It can contain spelling issue words, source offsets, and suggestions and therefore follows the same private document-state rules as prior `SpellIssue` lists.

The 200-issue editor cap does not upload skipped text, log overflow words, persist report metadata, or send performance telemetry. The overflow word used to prove truncation is inspected locally and is not materialized into a persisted/report issue.

V2.5 introduces no document persistence, analytics, remote logging, account system, cloud spelling/grammar service, background upload, or new runtime package.''',
)

append_section(
    'SECURITY.md',
    '## V2.5 bounded-analysis safety boundary',
    '''## V2.5 bounded-analysis safety boundary

A spelling issue cap is a resource/UX boundary, not permission to weaken correction safety. Captured issues retain exact checked source ranges and all existing stale-source validation.

When a report is truncated, the built-in editor hides Replace all because the checked issue list is incomplete. Do not re-enable bulk mutation by searching raw text from the widget or by treating uncaptured matches as checked ranges.

`maxIssues` must be positive when supplied. The bound does not execute imported data, alter ranker trust, add network processing, or persist document-derived report metadata.''',
)

append_section(
    'SUPPORT.md',
    '# V2.5 large-document reports',
    '''# V2.5 large-document reports

For a `200+` or bounded-analysis bug, use synthetic text and include:

- Whether the report/UI showed `200+`.
- The configured/API `maxIssues` when using the library directly.
- Captured issue count.
- `truncated`, `complete`, and `scannedTokenCount` for API reports when relevant.
- Whether Replace all was incorrectly visible/hidden.
- Selected language and suggestion count.

Do not attach a private large document. A repeated synthetic token sequence is sufficient for limit-state bugs.''',
)

append_section(
    'CONTRIBUTING.md',
    '## V2.5 performance and bounded-analysis changes',
    '''## V2.5 performance and bounded-analysis changes

Changes to issue limits, scan termination, candidate generation, caching, ranking, or large-result rendering should include deterministic regression coverage and an update to `docs/PERFORMANCE.md`.

Do not use private documents as benchmark fixtures. Do not describe `maxIssues` as a hard document-size bound. Do not expose Replace all on a truncated issue report unless a future design supplies a separate complete-range safety contract.''',
)

replace_once(
    'docs/RELEASING.md',
    'Current V2.4 release:\n\n```text\n2.4.0+9\n```',
    'Current V2.5 release:\n\n```text\n2.5.0+10\n```',
    'release current version',
)
replace_once(
    'docs/RELEASING.md',
    'git tag -a v2.4.0 -m "SpellChecker v2.4.0"\ngit push origin v2.4.0',
    'git tag -a v2.5.0 -m "SpellChecker v2.5.0"\ngit push origin v2.5.0',
    'release tag example',
)
append_section(
    'docs/RELEASING.md',
    '## V2.5 bounded-analysis release checks',
    '''## V2.5 bounded-analysis release checks

Before tagging V2.5-compatible code, verify:

1. `SpellCheckerEngine.check()` still matches unbounded `analyze()` results.
2. Exact-cap inputs without later unknowns remain complete.
3. Overflow inputs prove truncation without suggestion generation for the overflow issue.
4. The editor displays `200+` only for proven truncation.
5. The limited-results notice is visible and exposed to semantics.
6. Replace all is absent for limited results and still present for complete repeated-issue results.
7. `docs/PERFORMANCE.md` matches the implementation.
8. No new runtime dependency/persistence/network behavior was introduced unintentionally.
9. Formatting, analyzer, focused V2.5 tests, complete tests, and `flutter build web --release` pass on the exact release tree.''',
)

# ---------------------------------------------------------------------------
# Web/PWA and PR-review metadata.
# ---------------------------------------------------------------------------
replace_once(
    'web/index.html',
    'Writing insights review presets, portable non-document preferences, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and one-step undo.',
    'Writing insights review presets, portable non-document preferences, bounded large-document spelling results, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and one-step undo.',
    'web description',
)
replace_once(
    'web/manifest.json',
    'Writing insights review presets, portable non-document preferences, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and undo-friendly corrections.',
    'Writing insights review presets, portable non-document preferences, bounded large-document spelling results, filtered batch-safe local fixes, reset-to-default rule management, keyboard workflows, and undo-friendly corrections.',
    'manifest description',
)

append_section(
    '.github/pull_request_template.md',
    '## V2.5 bounded-analysis / performance',
    '''## V2.5 bounded-analysis / performance

Complete when relevant.

- [ ] Historical unbounded `check()` behavior remains compatible.
- [ ] Explicit issue limits are positive and truncation is proven rather than inferred from equality with the cap.
- [ ] Overflow issues do not receive unnecessary suggestion generation.
- [ ] Limited UI results are visibly/semantically identified.
- [ ] Bulk correction is not exposed for an incomplete checked occurrence set.
- [ ] Performance tests use synthetic data and deterministic invariants rather than unstable wall-clock thresholds.
- [ ] `docs/PERFORMANCE.md` is updated when the performance contract changes.''',
)

print('V2.5 release transform applied successfully.')
