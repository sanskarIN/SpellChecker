# V2.10 deterministic large-document benchmark

SpellChecker V2.10 adds developer-run benchmark tooling for repeatable observation of bounded spelling and writing-analysis behavior on generated synthetic text.

## Goals

The benchmark exists to make controlled performance comparisons easier while preserving the project's existing correctness and privacy boundaries. It is intentionally separate from the application runtime and from public package APIs.

The benchmark is designed to provide:

- a source-controlled deterministic synthetic corpus shape;
- a fixed benchmark spelling dictionary and frequency map;
- configurable bounded spelling and writing-analysis workloads;
- configurable warmup and measured iterations;
- fresh analysis state for each sample;
- immutable outcome/timing samples;
- min/median/max elapsed-time summaries;
- stable versioned JSON output;
- readable terminal output;
- deterministic analysis-outcome consistency checks across measured samples.

## Run it

From a dependency-resolved checkout:

```bash
dart run tool/benchmark_large_document.dart \
  --repeats=2000 \
  --warmup=1 \
  --iterations=5 \
  --spelling-limit=200 \
  --writing-limit=200 \
  --suggestions=5 \
  --language=en-US
```

Add `--json` for the machine-readable version-1 report.

Use `--help` for the complete option list.

Supported language IDs are currently:

```text
en-US
en-GB
```

## Synthetic corpus

`AnalysisBenchmarkScenario.standardChunk` is repeated the configured number of times with a newline between repetitions. The benchmark does not accept a document path or read editor state.

Scenario metadata records only:

- scenario name;
- repetition count;
- source-controlled chunk character count;
- generated character count;
- spelling capture limit;
- writing capture limit;
- suggestion limit.

The report does not serialize the chunk or generated corpus text.

## Stable spelling workload

The benchmark runner supplies a fixed source-controlled dictionary and frequency map to `SpellCheckerEngine`.

This is deliberate. Bundled dictionaries can legitimately grow between releases; using the whole bundled vocabulary would allow a dictionary-content change to silently turn a benchmark misspelling into a known word and change the measured workload. The fixed benchmark metadata keeps spelling eligibility stable unless the benchmark contract itself is intentionally changed.

The selected language pack still owns tokenization, normalization, suffix rules, suggestion-distance policy, language identity, and other language-aware behavior.

## Fresh sample state

Every warmup and measured sample creates a new:

- `SpellCheckerEngine`;
- `WritingAnalyzer`.

This avoids carrying the spelling suggestion cache or mutable session state from one measured iteration into the next.

Warmup samples are discarded. Measured samples enter `AnalysisBenchmarkSummary`.

## Outcome consistency

Elapsed times are allowed to vary. Analysis outcomes are not.

All measured samples must agree on:

- spelling scanned token count;
- spelling captured issue count;
- spelling truncation state;
- writing captured finding count;
- writing exact total finding count;
- writing truncation state;
- sorted analyzed writing-rule IDs;
- sorted exact per-rule finding totals.

The benchmark sample contains an exact per-rule entry for every analyzed writing rule. If `WritingAnalyzer` has no finding for an analyzed rule, the runner materializes that rule with a total of `0` rather than omitting it. Sample construction rejects incomplete or extra rule-total entries, and the complete per-rule map must sum to the exact overall writing total.

If those values change between measured samples, summary construction fails with an argument error. That is treated as a determinism/correctness problem rather than being hidden by timing aggregation.

## Timing aggregation

The summary reports spelling and writing minimum, median, and maximum elapsed microseconds.

For an odd sample count, the median is the middle sorted value. For an even sample count, the median is the integer midpoint average of the two middle values.

These values are descriptive and machine-dependent. They can change with:

- processor and memory characteristics;
- operating system and scheduler activity;
- Flutter/Dart versions;
- runtime/build mode;
- other process load;
- repository changes that legitimately alter analysis work.

Normal CI therefore does **not** enforce a timing threshold.

## JSON format version 1

The JSON report contains:

- `formatVersion`;
- language ID;
- scenario shape metadata;
- warmup/measured iteration counts;
- spelling/writing min/median/max timings;
- deterministic analysis outcome metadata, including analyzed writing-rule IDs and a complete exact per-rule total map (including explicit zero totals);
- individual measured timing/outcome samples.

It does not contain corpus text.

A future incompatible JSON shape change must advance the format version and document consumer impact.

## Human-readable report

Without `--json`, the CLI prints the same core scenario shape, analysis outcome, and aggregate timing information in plain text. It ends with a reminder that timings are machine-dependent and the corpus is synthetic.

## CI and release behavior

Permanent CI and tagged-release validation include tracked Dart under `tool/` in formatter checks and run a very small benchmark command:

```bash
dart run tool/benchmark_large_document.dart \
  --repeats=4 \
  --warmup=0 \
  --iterations=1 \
  --spelling-limit=2 \
  --writing-limit=5 \
  --suggestions=0 \
  --language=en-US \
  --json
```

This is an execution/report smoke test. Its elapsed values are not compared with thresholds.

## Privacy boundary

The benchmark does not automatically read or serialize:

- editor documents;
- clipboard contents;
- personal dictionary entries;
- ignored session words;
- persisted preferences;
- correction history;
- raw spelling issue text;
- raw writing finding messages/excerpts;
- arbitrary local files.

It does not automatically save or upload the report. A developer may explicitly redirect CLI output or use external tooling, and is responsible for handling that output appropriately.

## Runtime/API compatibility

V2.10 benchmark classes live under `tool/` and are intentionally not exported by `package:spellchecker/spell_checker.dart`, `package:spellchecker/language.dart`, or `package:spellchecker/writing.dart`.

The milestone does not add a runtime package dependency, persisted key, transfer-format version, writing-rule ID, language ID, network request, account behavior, analytics, or telemetry.

## Regression coverage

Focused tests cover:

- deterministic corpus construction;
- scenario metadata and corpus-text exclusion;
- argument validation;
- sample/result invariants, including complete per-rule totals;
- explicit zero totals for analyzed rules with no findings;
- immutable sample snapshots;
- odd/even median aggregation;
- stable analysis-outcome enforcement;
- bounded spelling/writing runner behavior;
- both built-in language packs;
- CLI default/custom parsing;
- malformed/duplicate/unsupported arguments;
- human and JSON report privacy boundaries;
- help/error exit behavior;
- an end-to-end small JSON benchmark command.
