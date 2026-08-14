# V2.9 writing-analysis diagnostic summary

SpellChecker V2.9 introduces a deterministic, privacy-safe summary layer over the exact writing-analysis diagnostics added in V2.8.

## Purpose

The summary is intended for bug reports, performance investigations, support discussions, and reproducible comparisons where users or maintainers need to share analysis metadata without sharing the document being checked.

## Data included

A `WritingAnalysisDiagnosticSummary` contains only:

- the active language-pack ID;
- whether the result is complete or limited;
- the captured finding count;
- the exact total finding count when available;
- the exact uncaptured finding count when available;
- the configured capture limit, if any;
- stable analyzed rule IDs;
- rule display names supplied by the caller;
- captured per-rule counts;
- exact per-rule totals when available.

Rule rows are sorted lexically by stable rule ID before formatting. The same result and rule metadata therefore produce the same plain-text output regardless of set or iterable insertion order.

## Data excluded

The formatter does not read or serialize:

- editor text;
- source excerpts;
- finding messages;
- replacement text;
- source offsets;
- personal dictionary entries;
- ignored session words;
- review search text or filter state;
- correction history;
- timestamps, device identifiers, telemetry, or network metadata.

The plain-text format ends with an explicit privacy line reminding users that only counts and rule metadata are present.

## Compatibility

Analyzer-produced V2.8 results expose exact total diagnostics. Directly constructed compatibility `WritingAnalysisResult` values may omit those fields. V2.9 does not guess missing values: total and uncaptured counts are rendered as `unavailable`, and per-rule rows explicitly state that their exact total is unavailable.

No V2.8 constructor, analyzer, capture-limit, ordering, correction, persistence, or writing-rule contract is changed by this feature.

## Public API

The implementation lives in:

`lib/writing/writing_analysis_diagnostic_summary.dart`

The two public models are:

- `WritingAnalysisDiagnosticSummary`
- `WritingRuleDiagnosticSummary`

`WritingAnalysisDiagnosticSummary.fromResult(...)` constructs the metadata snapshot and `toPlainText()` produces its deterministic shareable representation.

## Example shape

```text
SpellChecker writing analysis diagnostics
Format version: 1
Language: en-US
Analysis status: limited
Captured findings: 200
Total findings: 1437
Uncaptured findings: 1237
Capture limit: 200
Rule totals:
- Repeated spaces [repeated-space]: 40/221 captured/total
...
Privacy: counts and rule metadata only; editor text and finding excerpts are excluded.
```

The example is illustrative; rule order in real output is always lexical by rule ID.

## Testing contract

V2.9 regression coverage verifies that:

- bounded exact totals are represented correctly;
- rule output order is deterministic;
- document text and finding messages are absent from the export;
- compatibility results without exact V2.8 totals are represented without guessing;
- an empty analyzer result has a stable explicit empty-rule section.

## Privacy and security

The summary model/formatter adds no network request, persistence format, clipboard side effect, account behavior, telemetry, runtime dependency, background processing, or document retention by itself. Writing insights provides an explicit **Copy diagnostic summary** action that copies only `toPlainText()` output after the user selects it; the UI does not copy raw findings or editor text.
