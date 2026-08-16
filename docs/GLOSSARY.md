# Glossary

This glossary defines terms used across SpellChecker documentation, code, tests, and issue reports.

## Analysis snapshot

The specific source text and configuration state against which spelling or writing issues were produced. Issue source ranges are only safe to apply to the same current source snapshot unless a correction helper verifies the range still matches.

## Automatic fix

A `WritingIssue` whose `replacement` is non-null. The replacement may be an empty string when deletion is the deterministic correction. Automatic fixes are eligible for individual or batch application after stale-range and overlap validation.

## Advisory finding

A `WritingIssue` whose `replacement` is `null`. It communicates a deterministic finding without claiming a deterministic text mutation. The unmatched parenthesis, square bracket, and curly brace built-ins are advisory.

## Bounded analysis

Analysis that retains no more than a caller-specified number of issues/findings. Bounded spelling and writing results expose metadata indicating whether additional findings existed beyond the captured set.

## Built-in language pack

A `SpellLanguagePack` registered in `SpellLanguageRegistry.builtIns`. Current built-ins are English (US), `en-US`, and English (UK), `en-GB`.

## Captured finding / captured issue

A finding retained in a bounded result and therefore available to the caller/UI. A truncated writing result can know the exact total count while retaining only a prefix for review.

## Correction history

The bundled editor's bounded in-memory stack of pre-correction editing values used by **Undo correction**. It is not durable across application restarts and is not included in transfer formats.

## Current issue

An issue whose source range still points to the same original text in the current source string. `TextCorrection` and `WritingCorrection` verify this before mutation.

## Default enabled rule IDs

`WritingRuleRegistry.defaultEnabledRuleIds`, currently the IDs of all ten built-in writing rules. Defaults apply only when a language has no explicit stored rule override.

## Diagnostic summary

A `WritingAnalysisDiagnosticSummary` derived from a writing-analysis result. Its plain-text form contains counts and rule/language metadata only and intentionally excludes document text, finding excerpts, replacements, and offsets.

## Durable preference

Application configuration stored through `shared_preferences`, such as selected language, suggestion count, per-language personal words, or explicit per-language writing-rule IDs.

## Evergreen documentation

Documentation intended to describe current `main` behavior and updated when the product contract changes. `docs/README.md` lists the evergreen set.

## Explicit writing-rule override

A stored language-specific set of enabled writing-rule IDs. A present empty set means “disable all rules.” Absence of an override means “use current defaults.”

## Finding

A writing-analysis result represented by `WritingIssue`. Documentation often uses “finding” to distinguish writing analysis from spelling “issues,” though both are source-range results.

## Grapheme cluster

A user-perceived character that may contain one or more Unicode scalar values/code points. SpellChecker source offsets are not grapheme indexes.

## Historical document

A release-specific design/audit/validation record that describes the product at a particular point in time. Historical registry sizes or compatibility statements should not be silently rewritten to match later releases.

## Ignored word

A normalized word accepted by the current `SpellCheckerEngine` ignored-word set for the session/engine lifetime. Ignored words are not durable preferences.

## Issue limit

The maximum number of issues/findings retained by a bounded analysis call. A numerical limit being reached does not itself prove truncation; another finding must exist beyond the retained set.

## Language code

A broad code such as `en`. Writing rules can declare eligibility for a language code, which makes them support registered variants with that code.

## Language ID

A registered pack identifier such as `en-US` or `en-GB`. Persistence and transfer formats use these IDs.

## Language pack

`SpellLanguagePack`, the object defining language-specific dictionary data, tokenization, normalization, personal-word validation, frequency metadata, suffix behavior, and suggestion-distance policy.

## Mechanics

One `WritingRuleCategory`. Most built-in rules fall into Mechanics, including capitalization, spacing, punctuation, trailing whitespace, and structural delimiter checks.

## Clarity

One `WritingRuleCategory`. The built-in repeated-word rule is categorized as Clarity.

## Non-BMP character

A Unicode scalar outside the Basic Multilingual Plane and therefore represented by a UTF-16 surrogate pair in Dart strings. Non-BMP tests are important because source offsets use UTF-16 while edit-distance/casing logic may operate on scalar values.

## Normalization

Language-pack-specific conversion of an input token/word into the form used for dictionary lookup, personal-word validation, and comparison.

## Personal dictionary

User-saved vocabulary accepted by the active language's spelling engine and persisted locally by the bundled application. Personal dictionaries are language-specific and use their own export/import format.

## Portable settings

The versioned `spellchecker-settings` JSON format containing selected language, suggestion limit, and explicit per-language writing-rule overrides. It deliberately excludes personal vocabulary and document/session data.

## Public barrel

A Dart library file that re-exports the supported public API surface. SpellChecker has three: `spell_checker.dart`, `language.dart`, and `writing.dart`.

## Review query

A `WritingReviewQuery` containing temporary search/category/automatic-fix filters. The bundled UI does not persist review-query state.

## Rule ID

The stable machine-facing identifier for a `WritingRule`, such as `repeated-word`. Rule IDs participate in preferences, Portable settings, diagnostics, review filtering, and compatibility behavior.

## Scalar / Unicode scalar value

A Unicode code point excluding surrogate code points. Dart exposes string scalar iteration through `runes`. SpellChecker's unrestricted Damerau-Levenshtein and selected casing/length logic operate on scalar values.

## Session mode

Application behavior that continues without claiming durable persistence when preference storage is unavailable. In-memory spelling can still work even when saved settings cannot be read/written.

## Source ownership

The exact substring range a spelling/writing issue claims. For writing rules, `text.substring(issue.start, issue.end)` must match `issue.originalText` for the analyzed source snapshot.

## Spell issue

An occurrence-specific `SpellIssue` representing an unknown word, its UTF-16 source range, suggestions, and optional language ID.

## Suggestion ranker

A `SpellSuggestionRanker` strategy that orders already-eligible spelling candidates. Rankers should be deterministic and side-effect-free.

## Transient state

Application state deliberately not persisted, including editor text, ignored words, findings, active review search/filters, and correction history.

## Truncated result

A bounded result for which at least one additional issue/finding exists beyond the captured set.

## UTF-16 offset

A zero-based position measured in Dart string UTF-16 code units. SpellChecker spelling/writing source ranges use UTF-16 offsets so they can be passed to `String.substring`/`replaceRange` and Flutter editing APIs.

## Writing analyzer

`WritingAnalyzer`, the deterministic coordinator that selects supported/enabled rules, gathers findings, sorts/retains them in review order, and reports result metadata/exact totals.

## Writing insights

The bundled Flutter dialog that exposes local writing-rule review, rule switches, presets, search, filters, safe corrections, limited-result messaging, and diagnostic-summary copying.

## Writing rule

An implementation of the `WritingRule` plugin contract. A rule has a stable ID, display metadata, language eligibility, category, and deterministic `analyze` method returning zero or more `WritingIssue` objects.
