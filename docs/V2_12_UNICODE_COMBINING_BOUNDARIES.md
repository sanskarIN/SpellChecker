# V2.12 Unicode combining-mark writing boundaries

SpellChecker V2.12 hardens the V2.11 `missing-punctuation-space` source boundary for canonically equivalent Unicode text that uses combining marks.

## Problem

V2.11 correctly handles precomposed text such as:

```text
café,naïve
```

The visually equivalent decomposed form can encode the accented letter as a base letter followed by one or more combining marks:

```text
cafe\u0301,naive
```

A boundary matcher that accepts only a bare Unicode letter immediately before optional whitespace and punctuation can miss this decomposed form because the combining mark sits between the base letter and punctuation.

## V2.12 boundary contract

The preceding word-side cluster is now:

```text
Unicode letter + zero or more Unicode combining marks
```

followed by:

```text
zero or more horizontal spaces/tabs
+ selected punctuation
+ immediate Unicode letter
```

The selected punctuation scope remains unchanged from V2.11:

```text
, ; ? !
```

The production matcher therefore accepts the equivalent shapes:

```text
café,naïve
cafe\u0301,naive
cafe\u0301 ,naive
```

while retaining the same punctuation-only automatic correction ownership.

## Multiple combining marks

The preceding cluster can contain more than one combining mark. A synthetic example such as:

```text
a\u0301\u0327;word
```

still owns only the semicolon for the finding and replacement.

A combining mark without a preceding Unicode letter is not treated as a word boundary.

## Source offsets

Dart/Flutter source ranges remain UTF-16 code-unit offsets.

The matcher consumes the complete preceding base-letter-plus-mark cluster only to locate the punctuation correctly. The resulting `WritingIssue` still uses:

```text
originalText = punctuation character
replacement  = punctuation character + one horizontal space
```

No combining mark enters the issue's owned range.

This keeps stale-source validation, correction caret calculation, and batch overlap behavior compatible with V2.11.

## Composition with pre-punctuation whitespace cleanup

The V2.11 composition contract remains unchanged. For decomposed text with a stray pre-punctuation space:

```text
cafe\u0301 ,naive
```

`punctuation-spacing` owns the space before the comma and `missing-punctuation-space` owns the comma. Their source ranges remain adjacent rather than overlapping, so `WritingCorrection.applyAll` can produce:

```text
cafe\u0301, naive
```

without rewriting or normalizing the user's Unicode sequence.

## Normalization policy

V2.12 does not normalize editor text from decomposed form to precomposed form or vice versa.

The rule recognizes both representations while preserving the exact source text and source offsets supplied by the caller. This avoids an unrelated document-wide normalization mutation and keeps automatic fixes narrowly scoped.

## Exclusions preserved

V2.12 does not broaden the V2.11 punctuation grammar. Periods and colons remain excluded, including in decomposed text, and the existing numeric/non-letter/repeated-punctuation ownership exclusions remain intact.

## Public API and compatibility

V2.12 changes no public constructor or stable rule ID.

`MissingPunctuationSpaceRule` remains exported through `package:spellchecker/writing.dart` with stable ID:

```text
missing-punctuation-space
```

The built-in registry remains seven rules. Preference keys and explicit stored rule sets are unchanged. The V2.10 benchmark's analyzed writing-rule ID set is unchanged from V2.11, so this release changes rule matching behavior without changing the default rule-count workload identity.

## Privacy and security

The change is an in-process Unicode boundary match over text already supplied to the local `WritingAnalyzer`.

It adds no:

- network request;
- telemetry or analytics;
- account behavior;
- persistence key;
- document history;
- runtime dependency;
- dynamic rule/plugin loading;
- automatic Unicode normalization of user text.

## Regression contract

V2.12 coverage verifies:

- a decomposed accented letter before punctuation is detected;
- multiple combining marks are supported;
- exact UTF-16 punctuation offsets remain correct;
- pre-punctuation whitespace composition remains adjacent and batch-safe;
- a combining mark alone is not treated as a word boundary;
- period and colon exclusions remain intact with combining marks;
- the complete pre-existing Flutter test suite remains green;
- benchmark smoke remains threshold-free and compatible with the unchanged seven-rule workload.
