# Performance and large-document behavior

SpellChecker is designed to keep spelling and deterministic writing analysis local. Performance work must preserve correctness, privacy, deterministic ordering, source-range safety, and the existing public compatibility contracts.

## V2.5 bounded spelling analysis

`SpellCheckerEngine.analyze` adds an optional `maxIssues` bound for callers that need to avoid generating and retaining an unbounded number of spelling suggestions/results.

```dart
final report = engine.analyze(
  text,
  suggestionLimit: 5,
  maxIssues: 200,
);
```

`SpellCheckReport` exposes:

```text
issues                 captured spelling issues, in source order
scannedTokenCount      tokens inspected before completion/truncation proof
truncated              true only when an additional uncaptured issue exists
issueLimit             requested capture limit, or null for unbounded analysis
complete               convenience inverse of truncated
capturedIssueCount     captured issue count
```

A positive `maxIssues` is required when a bound is supplied. `null` means unbounded issue capture and preserves the historical `check()` behavior.

## What the bound guarantees

When the issue cap has not been reached, analysis behaves normally.

After the cap is reached, SpellChecker does not immediately claim truncation. It continues token inspection until one of these conditions occurs:

1. The token stream ends. The report is complete because no additional spelling issue exists.
2. One additional unknown token is encountered. The report becomes truncated and returns immediately.

The overflow issue is not materialized as a `SpellIssue` and no suggestions are generated for it.

This means `truncated == true` is evidence of at least one additional spelling issue, not merely evidence that the configured count happened to equal the number captured.

## What remains unbounded

The V2.5 bound is an **issue-capture/suggestion-work bound**, not a document byte/character/token hard limit.

To distinguish an exact-N complete result from a genuinely truncated result, the engine can continue inexpensive tokenization/known-word checks after N captured issues until it finds one additional unknown word or reaches the end of the text.

Callers that require a strict input-size policy should enforce that policy separately before invoking SpellChecker. Do not reinterpret `maxIssues` as a maximum document length.

## Editor policy

The built-in Flutter editor uses:

```text
maximum captured spelling issues: 200
```

When more than 200 spelling issues exist:

- The Results badge displays `200+`.
- The Results panel explains that only the first 200 issues were captured.
- Inline highlights and F7/Shift+F7 navigation cover only the captured issues.
- Single-occurrence corrections remain available.
- Personal-dictionary and ignore actions remain available.
- **Replace all** is hidden for limited results because the captured occurrence set is incomplete.

The UI does not label a limited result as a complete count.

## Why bulk replacement is disabled for limited results

`TextCorrection.replaceAll` intentionally operates on checked issue ranges rather than searching/replacing arbitrary text. This protects case handling and stale-range safety.

A bounded result set intentionally omits later issue ranges. Calling that partial mutation “Replace all” would be misleading and could leave unchecked occurrences behind. V2.5 therefore refuses to expose the bulk action when the current result report is truncated.

A future whole-document replacement design would need a separate complete-range discovery/safety contract rather than weakening this rule.

## Suggestion ranking and caching

V2.4 ranker behavior remains unchanged:

- Candidate eligibility and maximum edit distance are decided before ranking.
- The configured ranker orders eligible candidates.
- The engine provides a lexical final tie-break.
- Suggestion results are cached by normalized queried word for the engine lifetime/state epoch.
- Personal-dictionary mutation clears the suggestion cache.

V2.5 bounded analysis reuses that cache and avoids asking for suggestions for the first proven overflow issue.

## Profiling guidance

Use synthetic, non-sensitive documents for profiling.

Useful scenarios include:

- Mostly-correct long documents.
- Repeated unknown words, which exercise suggestion caching.
- Many distinct unknown words, which exercise candidate generation/ranking.
- A mix of correct and incorrect Unicode words.
- Inputs that stop just below, exactly at, and above the issue cap.
- US and UK language packs.
- Different suggestion-count preferences.

Measure separately when practical:

```text
tokenization/known-word scan
candidate edit-distance work
ranking
suggestion materialization
widget rendering/scrolling
```

Do not commit machine-specific timing thresholds as correctness tests unless the project has a stable controlled benchmark environment. Timing can vary with Flutter/Dart version, runner hardware, browser/runtime, debug/profile/release mode, and dictionary size.

## Regression tests

V2.5 protects performance semantics with deterministic tests instead of wall-clock assumptions:

- Unbounded `analyze()` matches historical `check()` output.
- Exactly reaching the issue cap remains complete when no later issue exists.
- A later overflow issue sets `truncated`.
- Suggestions are not generated for the proven overflow issue.
- Non-positive caps are rejected.
- Report issue lists are immutable.
- The editor renders the limited-results state for 201 synthetic unknown tokens.
- The editor suppresses **Replace all** for limited results.
- Small complete result sets retain **Replace all**.

## Privacy

Bounded analysis does not add persistence, telemetry, remote logging, network requests, background uploads, or document history.

`SpellCheckReport` is an in-memory analysis value. It can contain `SpellIssue` source words and offsets and therefore must not be logged or persisted by default.

## Future work

Potential follow-up profiling work includes:

- Dedicated benchmark targets for controlled environments.
- Candidate-index structures that reduce dictionary scans while preserving deterministic output.
- Incremental re-checking after local text edits.
- Background/isolate execution where platform behavior and cancellation semantics can be defined safely.
- Explicit caller-configurable document-size policies.

Any optimization must preserve source offsets, language normalization, suggestion correctness, deterministic ranking, stale-correction protection, and privacy boundaries.

## V2.7 bounded Writing insights analysis

Writing analysis now supports an optional retained-finding bound:

```dart
final result = analyzer.analyze(
  text,
  languagePack: pack,
  enabledRuleIds: enabledIds,
  maxIssues: 200,
);
```

`null` preserves unbounded finding capture. A supplied bound must be positive.

The collector stores at most the requested number of `WritingIssue` objects and maintains the analyzer's global review ordering: source start, severity ordering, then rule ID. If a later rule yields an earlier finding, that finding can replace a worse retained item. Bounded results therefore equal the first N items of the corresponding unbounded sorted result.

The analyzer does **not** stop running rules after N findings. It must inspect all enabled/supported rule streams to know whether a later rule contributes an earlier result and to distinguish an exact-N complete result from a genuinely truncated result. `maxIssues` is therefore a retained-finding memory/UI bound, not a CPU-time, rule-invocation, character, line, or document-size bound.

The built-in Writing insights policy is 200 captured findings. A `200+`-style limited state appears only when another finding beyond the cap has actually been observed. Search, presets, category filters, automatic-fix filtering, and batch actions operate only on the captured prefix when analysis is truncated.

For profiling, measure writing-rule execution and bounded-result maintenance separately. Synthetic workloads should cover many findings from one rule, many enabled rules, out-of-order custom-rule yields, exact-at-limit documents, and true overflow. Avoid wall-clock correctness thresholds unless the runner environment is explicitly controlled.

## V2.8 exact writing-analysis diagnostics

V2.8 adds exact deterministic finding counts to analyzer-produced writing results. These counters improve observability of bounded Writing insights without converting the V2.7 finding-retention bound into a CPU or wall-clock limit.

For each enabled/supported rule, the analyzer continues consuming the rule's findings across the supplied text. Every yielded finding increments the overall and per-rule counters. Only the retained result path is bounded by `maxIssues`.

For example, with `maxIssues: 200`, a result can report:

```text
capturedIssueCount: 200
totalIssueCount: 1437
uncapturedIssueCount: 1237
```

The analyzer still retains at most 200 `WritingIssue` objects for the bounded result while counting the remaining 1,237 findings as integers.

### What is bounded

- retained `WritingIssue` objects in the result;
- retained finding list sorting/storage after the bounded collector reaches capacity;
- downstream Writing insights rendering/filtering/fix candidate work over the retained set.

### What is not bounded by V2.8 diagnostics

- characters, tokens, or lines supplied to an arbitrary writing rule;
- rule scan time;
- wall-clock duration;
- CPU usage of third-party/custom rule implementations;
- allocations performed internally by a custom rule;
- number of findings a rule may yield before the analyzer finishes counting them.

Exact totals therefore describe **observed findings**, not a resource budget.

### Benchmarking guidance

When profiling very large documents:

1. use synthetic/non-sensitive generated text;
2. record document size separately from finding count;
3. record active language and enabled rule IDs;
4. record `capturedIssueCount`, `totalIssueCount`, and per-rule exact totals;
5. measure elapsed time externally in a benchmark harness rather than embedding timing telemetry in production results;
6. compare unbounded and bounded retention separately from total rule-scan cost;
7. avoid treating one device/browser measurement as a correctness guarantee.

V2.8 intentionally does not persist benchmark data or document-derived diagnostic totals.
