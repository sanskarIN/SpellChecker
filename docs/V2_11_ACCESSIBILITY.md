# V2.11 keyboard-first Writing insights accessibility

Release version: `2.11.0+16`

About version: `2.11.0`

SpellChecker V2.11 hardens the existing local Writing insights workflow for keyboard-only and assistive-technology review without changing writing-rule semantics, persistence formats, correction behavior, or document privacy boundaries.

## Goals

V2.11 focuses on the review dialog itself:

- make the existing search control directly reachable from the keyboard;
- give Escape deterministic behavior that preserves transient review work before closing the dialog;
- expose changing rule/finding counts as concise live semantic state;
- keep limited-result semantics truthful when only a captured prefix is reviewable;
- enforce the Writing insights capture bound in release builds rather than only through a debug assertion;
- add focused keyboard and semantics regression coverage for these behaviors.

The milestone also carries a V2.10 benchmark correctness repair: benchmark samples now contain one exact per-rule total for every analyzed writing rule, including explicit zero totals.

## Writing insights search shortcut

While Writing insights is open:

```text
Ctrl+F      Focus Search rules and findings
Command+F   Focus Search rules and findings on macOS-style keyboards
```

The shortcut does not create a second search model. It moves focus to the existing `Search rules and findings` `TextField`, so typing, clearing, filtering, and persistence behavior remain exactly the same as the existing review search.

Pointer/touch users can continue selecting the search field normally. The shortcut is supplementary rather than the only path to search.

## Escape behavior

Escape is deliberately two-stage:

1. If any transient review query is active, Escape clears the complete transient query and keeps Writing insights open.
2. If the query is already empty, Escape closes Writing insights through the same result path as the normal **Close** action.

The transient query consists of:

- free-text review search;
- selected review categories;
- **Automatic fixes only** state.

After clearing an active query with Escape, focus returns to the search field so a keyboard user can immediately enter a new query or press Escape again to close.

Clearing review filters does **not** reset enabled writing-rule switches. Rule switches remain the existing per-language preference model and are returned/persisted only through the established dialog result flow.

## Live rule-count semantics

The visible/total rule count is wrapped in a live semantic node with a concise label shaped as:

```text
N visible rules of M
```

The visual `N/M` text remains present for sighted users but is excluded from nested semantics to avoid duplicate announcements.

The count reflects the current transient review query. It does not imply that hidden rules are disabled.

## Live finding-count semantics

The finding-count semantic node is also a live region. Its label distinguishes complete and bounded analysis states.

For a complete result:

```text
N visible findings of M captured findings.
```

For a limited result with exact totals:

```text
N visible findings. C captured of T total findings.
```

For a compatibility limited result without an exact total:

```text
N visible findings. C captured findings, with additional uncaptured findings.
```

These labels intentionally distinguish:

- findings visible under the current query;
- findings retained by the analyzer capture limit;
- the exact whole-analysis total when available.

Search/filter changes therefore cannot make a captured-only subset sound like a whole-document result.

## Existing limited-result notice

The existing limited-analysis notice remains a semantic live region and continues to explain that review filters and batch actions operate on captured findings only.

V2.11 does not alter the V2.7/V2.8 bounded-analysis contract:

- the analyzer retains the globally earliest configured prefix;
- exact totals can describe uncaptured findings;
- search and review operate only on retained findings;
- automatic mutations never target uncaptured source ranges;
- stale-source and overlap validation remain mandatory.

## Release-safe capture-bound validation

`WritingInsightsDialog.maxIssues` must be positive.

Prior to V2.11, the dialog constructor enforced this only with a Dart `assert`, which disappears in release builds. V2.11 validates the value at runtime and throws `ArgumentError` for zero or negative values.

The built-in application still uses the existing default of 200 captured Writing insights findings.

## Benchmark exact-rule-total repair

V2.10 benchmark output describes exact per-rule finding totals for the analyzed rule set. The raw `WritingAnalyzer` result intentionally omits map entries for rules that produce zero findings, so the benchmark runner now materializes a complete benchmark-specific map:

- every analyzed rule ID is present;
- rules with no findings have exact total `0`;
- no non-analyzed rule ID is accepted;
- every value is non-negative;
- per-rule totals must sum to the exact overall writing total.

This change affects only developer benchmark metadata under `tool/`. It does not change the public `WritingAnalysisResult` compatibility contract.

## Privacy and persistence

V2.11 adds no document persistence, account behavior, analytics, telemetry, remote logging, cloud spelling/grammar service, AI rewriting, background upload, or application network request.

Keyboard shortcuts and live semantic labels operate only on state already held by the local Writing insights dialog. They do not create a keystroke history.

The live labels contain counts/state, not editor text, finding excerpts, replacements, personal dictionary entries, or source offsets.

The benchmark repair continues using the generated synthetic benchmark corpus and does not read editor documents.

No persisted preference key or transfer format changes in V2.11.

## Compatibility

V2.11 preserves:

- existing built-in writing-rule IDs and defaults;
- per-language writing-rule preference meaning;
- review presets and query matching semantics;
- Portable settings format;
- personal dictionary format;
- language IDs;
- spelling and writing correction stale-range protections;
- correction undo behavior;
- V2.7 bounded writing-analysis semantics;
- V2.8 exact analyzer diagnostics;
- V2.9 privacy-safe diagnostic summaries/copy action;
- V2.10 benchmark command-line arguments and report format version.

`WritingInsightsDialog` is an application integration widget rather than a public package barrel API. Its constructor no longer needs to be `const` because release-safe validation is performed at construction time.

## Regression coverage

Focused V2.11 tests verify:

- a non-positive Writing insights issue limit is rejected at runtime;
- `Ctrl+F` focuses the existing review search field;
- Escape clears active free-text review search before closing;
- Escape clears category and automatic-fix filters together;
- after query clearing, the dialog remains open and search focus is restored;
- a second Escape with no query closes the dialog;
- visible rule counts expose live semantic labels;
- visible finding counts expose live semantic labels;
- limited exact diagnostics announce captured versus total findings truthfully;
- filtering updates semantic count labels;
- benchmark samples reject incomplete exact rule-total maps;
- benchmark runner output includes explicit zero totals for analyzed rules with no findings.

The permanent CI gate remains responsible for formatter, analyzer, full Flutter test, and benchmark CLI smoke validation. Release validation must additionally keep the lockfile stable and prove a release web build succeeds before the milestone is considered release-ready.
