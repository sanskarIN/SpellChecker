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
