# V2.11 missing punctuation space rule

SpellChecker V2.11 expands the deterministic local writing-rule catalogue with `missing-punctuation-space`.

## Purpose

The rule catches selected punctuation marks that are directly surrounded by letters and therefore have no space after the punctuation:

```text
Hello,world
Try;again
Really?Yes
Great!Next
```

It proposes:

```text
Hello, world
Try; again
Really? Yes
Great! Next
```

## Stable rule metadata

```text
ID: missing-punctuation-space
Name: Missing punctuation space
Category: Mechanics
Severity: info
Automatic fix: yes
Language family: English
```

The rule supports both built-in English packs through the existing language-family support contract:

```text
en-US
en-GB
```

## Punctuation scope

V2.11 intentionally recognizes only:

```text
,
;
?
!
```

Periods are excluded because direct letter/period/letter sequences are common in domains and abbreviations, for example `example.com`.

Colons are excluded because direct letter/colon/letter sequences can occur in URI-like schemes such as `mailto:user@example.com`, while digit/colon/digit is common in times.

This conservative scope favors deterministic low-false-positive mechanics over a broad grammar claim.

## Letter-boundary requirement

A finding is produced only when the punctuation is directly surrounded by Unicode letters.

Examples that are intentionally ignored include:

```text
1,000
value,_name
word;9
?word
word!
```

Unicode letters are supported, for example:

```text
café,naïve
Résumé!Encore
```

Source offsets remain Dart/Flutter UTF-16 string offsets, matching the rest of SpellChecker's correction model.

## Repeated punctuation ownership

Repeated punctuation is deliberately outside this rule's ownership:

```text
Really??Yes
Great!!Next
No,,Maybe
Wait;;Again
```

The new rule requires a letter on each side of the punctuation character. In a repeated punctuation run at least one adjacent character is punctuation, so `RepeatedPunctuationRule` remains the specialized owner.

After a repeated-punctuation correction, a fresh analysis can report a newly exposed missing-space boundary if appropriate.

## Source-range ownership

The automatic issue owns the punctuation character itself, not a zero-length insertion range.

For:

```text
Hello,world
```

The finding owns only:

```text
,
```

and replaces it with:

```text
, 
```

This preserves the existing stale-source validation contract because `WritingCorrection` can verify that the exact original punctuation character is still present before mutation.

## Composition with punctuation-spacing

The existing `punctuation-spacing` rule owns horizontal whitespace immediately **before** supported punctuation.

The V2.11 rule owns the punctuation character when a space is missing **after** it.

For:

```text
Hello ,world
```

The two fixes are adjacent, not overlapping:

```text
punctuation-spacing        -> owns the space before the comma
missing-punctuation-space  -> owns the comma itself
```

`WritingCorrection.applyAll` can therefore apply both in one safe deterministic batch and produce:

```text
Hello, world
```

No special widget bypass or raw string replacement is needed.

## Bounded analysis and exact diagnostics

The new rule participates in the existing V2.7/V2.8 bounded writing-analysis contracts.

With `maxIssues`, captured findings remain bounded while `WritingAnalyzer` still computes the exact total and exact per-rule totals. For a result containing more V2.11 findings than the capture limit:

- `capturedIssueCount` remains bounded;
- `totalIssueCount` remains exact;
- `totalIssueCountByRule['missing-punctuation-space']` remains exact;
- `uncapturedIssueCount` remains exact;
- filters/fixes remain captured-only when the result is truncated.

## Preferences and defaults

V2.11 adds the rule to `WritingRuleRegistry.builtIns` and therefore to `defaultEnabledRuleIds`.

Preference semantics remain unchanged:

```text
missing key       -> current registry defaults, including the V2.11 rule
stored ID list    -> exact explicit enabled-rule set
stored empty list -> explicit disable-all
```

Users with an explicit stored per-language rule list do not silently receive a newly added ID unless their stored choice or reset-to-defaults behavior enables it according to the existing persistence contract.

## Benchmark workload visibility

V2.10 benchmark reports already record sorted analyzed writing-rule IDs and exact per-rule totals specifically so registry evolution is visible.

V2.11 advances the default benchmark writing workload from six to seven analyzed rules by adding:

```text
missing-punctuation-space
```

Benchmark tests advance the expected sorted rule list. A cross-version timing comparison should therefore treat V2.10 and V2.11 as different writing workloads unless the enabled rule set is controlled explicitly in a future benchmark extension.

## Public API

`MissingPunctuationSpaceRule` is exported by `package:spellchecker/writing.dart` like the other built-in rules.

The stable ID is `missing-punctuation-space`.

V2.11 does not change the `WritingRule`, `WritingIssue`, `WritingAnalysisResult`, `WritingCorrection`, language-pack, storage, or diagnostic-summary constructor signatures.

## Privacy and security

The rule runs locally against the in-memory text already supplied to `WritingAnalyzer`.

It adds no:

- network request;
- telemetry;
- analytics;
- account behavior;
- persistence key;
- document history;
- runtime package dependency;
- dynamic rule download or execution.

Findings remain ordinary in-memory `WritingIssue` values and follow the existing privacy/source-range safety contracts.

## Regression contract

V2.11 tests cover:

- stable ID/name/category/language support;
- comma/semicolon/question/exclamation findings;
- consecutive eligible boundaries such as `one,two,three`;
- Unicode letter boundaries;
- already-spaced punctuation;
- period/colon exclusions;
- numeric/non-letter exclusions;
- repeated-punctuation ownership;
- exact source-range/correction behavior;
- default registry/analyzer inclusion;
- explicit single-rule enablement;
- bounded exact diagnostics;
- adjacent batch composition with `punctuation-spacing`;
- V2.10 benchmark seven-rule workload visibility.
