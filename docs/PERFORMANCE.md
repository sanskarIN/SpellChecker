# Performance and Benchmarking

SpellChecker uses bounded result retention and deterministic synthetic benchmark tooling to keep large-document behavior measurable without turning performance measurements into user telemetry or unsafe correctness shortcuts.

## Performance model

The bundled application applies these review capture limits:

```text
spelling issues: 200
writing findings: 200
```

These limits bound retained issue/finding objects and related UI work. They do **not** mean analysis stops after 200 source tokens/characters or that the application guarantees a fixed CPU-time/memory budget.

## Bounded spelling behavior

`SpellCheckerEngine.analyze(..., maxIssues: N)` retains at most N spelling issues.

After retaining N unknown words, it continues scanning only until:

- the token stream ends, producing a complete result at exactly the cap; or
- another unknown word is found, proving truncation.

The overflow word used only to prove truncation does not receive suggestions. This bounds expensive suggestion generation to retained issues.

Implication: a spelling result at the numerical limit may still be complete.

## Bounded writing behavior

`WritingAnalyzer.analyze(..., maxIssues: N)` retains the globally earliest N findings according to deterministic review ordering.

It cannot stop rule execution after N yielded values because:

- rules execute separately;
- later rules can yield earlier source positions;
- exact overall/per-rule totals are part of analyzer-produced diagnostics.

Therefore every enabled/supported rule still scans the supplied source, while the bounded collector limits retained finding objects.

Implication: writing `maxIssues` is a retained-result bound, not a rule-runtime bound.

## Suggestion cost

Spelling suggestions can be the most expensive spelling path because edit distance and ranking are performed for unknown captured words.

The engine reduces work by:

1. normalizing the target;
2. splitting recognized affixes where applicable;
3. indexing immutable base-dictionary suggestion candidates by Unicode-scalar length when an engine is created;
4. visiting only base-dictionary length buckets that can fall within the language pack's maximum edit-distance bound;
5. applying the same Unicode-scalar candidate length guard to visited base/personal candidates;
6. calculating unrestricted scalar Damerau-Levenshtein only for remaining candidates;
7. ranking eligible candidates deterministically;
8. caching detailed suggestions by normalized unknown word.

The length index is an implementation optimization, not a ranking change: candidates whose scalar-length difference exceeds the maximum edit distance could never qualify. Personal-dictionary candidates remain dynamic and are checked directly because that set can change after engine construction.

Personal-dictionary changes clear the suggestion cache because candidate membership changes.

## Writing-rule cost

Built-in rules are deterministic local scans. Their complexity differs by rule shape:

- regular-expression/token rules generally scan the source/token stream;
- structural delimiter rules iteratively balance literal delimiters and must remain stack-safe for deep input;
- bounded analysis still counts every yielded finding to preserve exact totals.

Do not assume that lowering the writing capture limit proportionally lowers analysis runtime.

## Benchmark entry point

```bash
dart run tool/benchmark_large_document.dart
```

The command wraps the reusable benchmark components under `tool/benchmark/`.

## Standard synthetic scenario

The benchmark's standard chunk is:

```text
hello wrld  this is is a sentence !! next sentence??  
```

The scenario repeats that chunk with newline separators. It intentionally contains both spelling and writing findings.

Default scenario name:

```text
large-document-v2.10
```

The historical name is retained for report identity compatibility even though the current application/writing registry has evolved after V2.10.

The current standard chunk is English/Latin-script synthetic input. The CLI accepts every registered built-in language ID so tokenization/spelling behavior can be exercised with any current pack, but results for non-English packs are not semantically equivalent to the English Writing-insights workload. Do not compare timings between different language IDs as if they were the same benchmark population.

## Benchmark options

```text
--repeats=N          Synthetic chunk repetitions (default: 2000)
--warmup=N           Unmeasured warmup iterations (default: 1)
--iterations=N       Measured iterations (default: 5)
--spelling-limit=N   Captured spelling issue limit (default: 200)
--writing-limit=N    Captured writing finding limit (default: 200)
--suggestions=N      Suggestions requested per spelling issue (default: 5)
--language=ID        Any built-in language ID (default: en-US)
--json               Print versioned JSON report
--help               Print help
```

Validation:

- repeats > 0;
- warmup >= 0;
- measured iterations > 0;
- spelling/writing limits > 0;
- suggestions >= 0;
- language option must be non-blank and command execution validates it against `SpellLanguageRegistry.builtIns`;
- duplicate/unknown/malformed options fail.

Unlike the application UI, benchmark suggestion count can be zero so timing can isolate analysis with no suggestion generation.

## CI smoke scenario

CI/release use a deliberately tiny deterministic command to validate the benchmark pipeline rather than measure meaningful speed:

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

This smoke test answers “does the tool/options/scenario/analysis/report pipeline still work?” not “is this commit fast enough on all computers?”

## Human-readable benchmark

Use defaults or explicit controlled options:

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

Record exact command, Flutter/Dart versions, OS/hardware, commit SHA, and whether the environment was otherwise busy when comparing runs.

## JSON report

Add `--json` for machine-readable/versioned report output:

```bash
dart run tool/benchmark_large_document.dart --json
```

The report contains benchmark/scenario/configuration/outcome/timing metadata. It is based on synthetic source and analysis counts, not user documents.

Do not parse human-readable output when the versioned JSON reporter is available for automation.

## Benchmark component architecture

```text
tool/benchmark_large_document.dart
  -> analysis_benchmark_command.dart
  -> analysis_benchmark_options.dart
  -> analysis_benchmark_scenario.dart
  -> analysis_benchmark_runner.dart
  -> analysis_benchmark_result.dart
  -> analysis_benchmark_reporter.dart
```

Tests separately cover command, option parsing, scenario identity, runner, result invariants, and reporter behavior.

## Determinism requirements

Benchmark correctness depends on stable scenario/configuration/outcome identity.

Across measured iterations with identical configuration, analysis outcomes must remain deterministic. A timing tool that produces changing issue counts/order/state is exposing a correctness problem, not merely variance.

Suggestion rankers used by the engine should also be deterministic; the engine supplies lexical fallback for custom ranker ties.

## What timing means

Elapsed time is environment-sensitive. Comparisons are meaningful only when the major variables are controlled:

- same commit/tool code except intended change;
- same Flutter/Dart version;
- same hardware/OS/power mode;
- same benchmark options;
- same language pack/rule registry;
- similar system load;
- appropriate warmup.

Do not compare unrelated developer machines and conclude a regression from raw milliseconds alone.

## No universal performance threshold

The project intentionally does not put a fixed millisecond threshold in CI because hosted runners and local machines vary.

CI validates correctness/executability. Performance investigation is comparative and controlled.

If a future regression threshold is introduced, it should use a stable environment/statistical policy and distinguish infrastructure noise from application regression.

## Benchmark changes that require review

Changing any of these can invalidate historical comparisons:

- standard chunk;
- default repeats;
- capture limits;
- suggestion limit;
- language;
- scenario name;
- warmup/iteration model;
- report schema;
- built-in language dictionary/frequency data;
- default suggestion ranker;
- writing-rule registry/defaults;
- spelling/writing analysis semantics.

When such changes are intentional, document the comparability boundary rather than presenting before/after numbers as the same workload.

## Large-document correctness before speed

Performance changes must preserve:

- Unicode correctness;
- exact UTF-16 source ownership;
- deterministic suggestion ordering;
- spelling truncation proof semantics;
- globally earliest bounded writing prefix;
- exact writing totals;
- stale-safe correction;
- overlap-safe batch mutation;
- preference/format compatibility.

Do not weaken a correctness invariant solely to improve benchmark numbers without an explicit API/product design change.

## Profiling guidance

When investigating a slowdown, separate:

- tokenization/normalization;
- dictionary membership;
- base-candidate length-bucket lookup;
- suggestion candidate distance/ranking;
- repeated unknown-word cache behavior;
- writing rule scans;
- bounded collector insertion/ordering;
- Flutter widget rendering (not measured by the CLI benchmark);
- preference/clipboard operations (outside analysis benchmark).

The CLI benchmark measures reusable analysis, not full browser UI paint/input latency.

## Privacy

The benchmark uses generated synthetic text and local timing/result metadata. It is not telemetry and does not send reports anywhere automatically.

Do not substitute private production documents into public benchmark artifacts. If a real document is required for local debugging, do not commit/share it without appropriate authorization.

## Historical benchmark record

The V2.10 benchmark design/validation record is preserved at [V2_10_BENCHMARK.md](V2_10_BENCHMARK.md). Use this page for current tooling behavior.

## Related documentation

- [Testing](TESTING.md)
- [Development](DEVELOPMENT.md)
- [Architecture](ARCHITECTURE.md)
- [Writing rules](WRITING_RULES.md)
- [Public API](API.md)
