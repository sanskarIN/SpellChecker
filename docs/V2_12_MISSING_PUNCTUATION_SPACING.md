# V2.12 — Missing punctuation spacing and Unicode boundaries

Status: implemented on the V2.12 release branch.

Release identity: `2.12.0+17` / `2.12.0`.

V2.12 completes the production prerequisite that was absent from the earlier Unicode-boundary experiment: the repository now contains, exports, registers, tests, documents, and ships a real `MissingPunctuationSpaceRule`.

## User-visible behavior

The new built-in rule has the stable ID:

```text
missing-punctuation-space
```

Its Writing insights label is:

```text
Missing punctuation space
```

For English language packs, the rule detects a selected punctuation mark between letter boundaries when no whitespace follows the punctuation.

Examples that produce a finding:

```text
Hello,world
word;next
Really!yes
Question?answer
café,naive
```

The replacement owns only the punctuation mark and inserts one trailing space:

```text
,  -> , 
;  -> ; 
!  -> ! 
?  -> ? 
```

The source issue remains exact:

```dart
text.substring(issue.start, issue.end) == issue.originalText
```

and `issue.originalText` is the punctuation mark itself.

## Deliberate scope

V2.12 intentionally does not treat every punctuation character as an automatic missing-space boundary.

The rule includes:

```text
, ; ! ?
```

The rule excludes:

```text
. :
```

This avoids claiming automatic ownership of common dot-connected and colon-connected constructs such as domains, versions, schemes, times, labels, and other syntax without a richer parser.

The rule also requires letters on both sides of the punctuation boundary. Numeric-only and symbol-only boundaries are outside this deterministic rule.

Repeated punctuation remains owned by `repeated-punctuation`; inputs such as `Really!!yes` and `What??now` do not create a competing missing-space issue.

## Unicode source-boundary contract

The predecessor boundary is Unicode-aware:

```text
Letter + zero or more combining marks
```

In Dart regular-expression terms, V2.12 uses the equivalent of:

```text
\p{L}\p{M}*
```

before the optional horizontal pre-punctuation whitespace and selected punctuation.

This means decomposed text such as:

```text
cafe\u0301,naive
```

is treated as a normal letter cluster before the comma rather than stopping at the combining mark.

The rule still rejects a combining mark that appears without a preceding Unicode letter. Combining marks extend a letter cluster; they do not establish a word boundary by themselves.

The following-letter check is also Unicode-aware and is implemented as a lookahead. The lookahead prevents the rule from consuming or claiming the following word's source range. Regression coverage includes a non-BMP following letter so UTF-16 source offsets remain explicit.

## Interaction with `punctuation-spacing`

`punctuation-spacing` owns horizontal whitespace immediately before common punctuation.

`missing-punctuation-space` owns only the selected punctuation mark when the following space is missing.

For:

```text
Hello ,world
```

the two issues are adjacent rather than overlapping:

```text
punctuation-spacing        -> owns the space before the comma
missing-punctuation-space  -> owns the comma
```

`WritingCorrection.applyAll` can therefore apply both fixes safely and deterministically:

```text
Hello ,world
Hello, world
```

The same ownership rule is tested with decomposed Unicode text.

## Registry and public API

V2.12 increases the built-in writing-rule registry from six rules to seven.

The complete stable built-in ID set is:

```text
repeated-word
sentence-capitalization
repeated-space
punctuation-spacing
missing-punctuation-space
trailing-whitespace
repeated-punctuation
```

`MissingPunctuationSpaceRule` is exported through:

```dart
import 'package:spellchecker/writing.dart';
```

and `WritingRuleRegistry.byId('missing-punctuation-space')` resolves it.

The rule supports the English language code `en`, so it runs for both built-in `en-US` and `en-GB` packs.

## Preference compatibility

The existing per-language rule preference contract is unchanged.

For users with no stored writing-rule override, `WritingRuleRegistry.defaultEnabledRuleIds` now contains the seventh rule, so V2.12 enables it by default.

For users with an explicit stored rule set, the application continues to respect that exact stored selection after intersecting it with supported rules. V2.12 does not silently rewrite an explicit old preference into the new default set.

Resetting writing rules to defaults clears the stored override and therefore opts the language back into the current registry defaults, including `missing-punctuation-space`.

## Correction safety

The new rule uses the existing correction safety boundary rather than introducing a second mutation path.

Individual fixes still require:

- a non-null deterministic replacement,
- a valid current source range,
- exact equality between the current substring and `originalText`.

Batch fixes still:

- sort candidates deterministically,
- reject stale ranges,
- reject advisory findings,
- skip overlapping accepted edits,
- apply accepted edits from the end of the document toward the beginning,
- report applied and skipped counts,
- create one editor undo entry.

## Benchmark contract

The deterministic analysis benchmark records analyzed writing-rule IDs and exact totals by rule. V2.12 updates the expected workload identity to include:

```text
missing-punctuation-space
```

Zero-finding benchmark input must still materialize an exact zero for every analyzed rule, including the new rule.

## Regression coverage

V2.12 adds dedicated unit coverage for:

- commas,
- semicolons,
- exclamation marks,
- question marks,
- already-spaced punctuation,
- period/colon exclusions,
- letter-boundary requirements,
- repeated-punctuation ownership,
- punctuation-only source ownership,
- optional pre-punctuation horizontal whitespace,
- both built-in English variants.

Unicode regression coverage includes:

- one decomposed combining mark,
- multiple combining marks,
- punctuation ownership with pre-punctuation whitespace,
- batch composition with `punctuation-spacing`,
- a combining mark without a preceding letter,
- period/colon exclusions with combining marks,
- a non-BMP following letter and stable UTF-16 source offsets.

Widget regression coverage verifies:

- the rule is visible and enabled by default,
- a mixed punctuation batch is corrected through Writing insights,
- the entire batch remains one-step undoable,
- disabling the new rule persists an explicit per-language selection,
- disabling it does not disable unrelated built-in defaults.

## Validation gate

The V2.12 branch is not ready to merge until the canonical repository CI gate succeeds on the final head commit:

```text
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test
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

The permanent V2.12 tree must not retain one-time formatter/release helper workflows.

## Release files

The V2.12 release synchronization includes:

- `pubspec.yaml`
- About-dialog release identity
- `CHANGELOG.md`
- `README.md`
- `docs/ROADMAP.md`
- `docs/WRITING_RULES.md`
- testing/development/performance/API documentation where the seven-rule workload is relevant
- `what_changed.md`

The implementation, tests, docs, and release metadata are expected to land together so V2.12 cannot repeat the earlier state where documentation/tests existed without the production prerequisite.
