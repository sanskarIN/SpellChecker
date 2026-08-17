# Release History and Validation Records

This page indexes release-specific documentation without turning historical records into current-state documentation. For current behavior, begin with [Documentation home](README.md), [Feature reference](FEATURES.md), [User guide](USER_GUIDE.md), and [Public API](API.md).

## Current package release

Current package version: `3.1.1+24`.

V3.1 is the multilingual spelling foundation release line. It keeps the V3.0 six-target cross-platform build contract while expanding built-in offline spelling from two English variants to eight language packs. V3.1.1 is a hardening patch for strict language-namespace persistence, Unicode-scalar ranking consistency, and evergreen documentation truthfulness.

## V3.1

- [V3.1 multilingual foundation](V3_1_MULTILINGUAL_FOUNDATION.md) — six new offline spelling packs, Unicode/affix behavior, persistence isolation, writing-rule boundary, lexicon scope, and validation requirements.

## V3.0

- [V3.0 cross-platform foundation](V3_0_CROSS_PLATFORM_FOUNDATION.md) — platform runner generation, stable application identity, multi-OS CI/release builds, signing boundaries, documentation migration, and validation requirements.

V3.0 changes the platform/release surface rather than the deterministic spelling/writing algorithms or local privacy model.

## V2.16

- [V2.16 bug audit](V2_16_BUG_AUDIT.md) — final pre-release repository-wide correctness audit.
- [V2.16 final validation](V2_16_FINAL_VALIDATION.md) — release-candidate validation record.
- [Post-V2.16 audit — 2026-08-16](POST_V216_AUDIT_2026_08_16.md) — post-release repository audit, additional Unicode/quoted-boundary fixes, BMC visibility verification, and optional follow-up directions.

Key V2.16 themes include unrestricted Unicode-scalar Damerau-Levenshtein correctness, decomposed-Unicode handling, strict import metadata, truthful preference write failure handling, startup preference/result synchronization, and final stabilization of the ten-rule writing catalogue.

## V2.15

- [Unmatched curly brace](V2_15_UNMATCHED_CURLY_BRACE.md) — design and behavior for the tenth built-in writing rule.
- [V2.15 final validation](V2_15_FINAL_VALIDATION.md) — validation evidence for the ten-rule catalogue and compatibility behavior.

V2.15 added advisory literal curly-brace balancing while preserving explicit older writing-rule overrides.

## V2.14

- [Unmatched square bracket](V2_14_UNMATCHED_SQUARE_BRACKET.md) — design and behavior for literal square-bracket balancing.
- [V2.14 final validation](V2_14_FINAL_VALIDATION.md) — validation evidence for the nine-rule historical catalogue.

## V2.13

- [Unmatched parenthesis](V2_13_UNMATCHED_PARENTHESIS.md) — design and behavior for advisory parenthesis balancing.
- [V2.13 final validation](V2_13_FINAL_VALIDATION.md) — validation evidence for the eight-rule historical catalogue.

## V2.12

- [Missing punctuation spacing and Unicode boundaries](V2_12_MISSING_PUNCTUATION_SPACING.md) — punctuation-only source ownership and decomposed combining-mark boundaries.
- [V2.12 final validation](V2_12_FINAL_VALIDATION.md) — validation evidence for that release.

## V2.11

- [V2.11 accessibility](V2_11_ACCESSIBILITY.md) — keyboard-first Writing insights review, Ctrl/Command+F search focus, Escape semantics, and live count announcements.

Current accessibility behavior is summarized in the evergreen [Accessibility](ACCESSIBILITY.md) and [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md) pages.

## V2.10

- [V2.10 benchmark](V2_10_BENCHMARK.md) — deterministic synthetic large-document benchmark design, report format, and execution notes.

Current benchmark usage is documented in [Performance](PERFORMANCE.md).

## V2.9

- [V2.9 diagnostic summary](V2_9_DIAGNOSTIC_SUMMARY.md) — privacy-safe writing-analysis diagnostic summary design and contract.

Current API behavior is documented in [Public API](API.md) and [Examples](EXAMPLES.md).

## Earlier history

For earlier versions and the cumulative change narrative, use:

- [CHANGELOG.md](../CHANGELOG.md) — release/change log.
- [what_changed.md](../what_changed.md) — extended historical development notes.

Those files are historical references. They should not be treated as the shortest source of truth for current behavior.

## How to read historical documents

A release-specific file captures the project at a particular point in time. For example, a V2.13 document may correctly describe an eight-rule default registry because that was the release state then. The current registry has ten rules.

When historical and evergreen documents differ:

1. use the historical file to understand that release's design, migration, and validation decisions;
2. use evergreen topic docs for current `main` behavior;
3. use the code and tests as the final implementation source of truth when preparing a new change.

Do not rewrite a historical validation file solely to make old counts or release claims match a later release.

## Validation lineage

The project intentionally keeps focused validation records for major behavior additions so maintainers can answer questions such as:

- which compatibility states were tested when a new rule entered defaults;
- which source-range ownership contract was intended;
- whether a rule was advisory or automatically fixable;
- which bounded-analysis behavior was validated;
- which Unicode/stress/accessibility cases were part of a release gate.

Evergreen docs should link to these records only when historical design evidence is useful; they should not require ordinary users to read them.

## Creating a new historical record

When a future release adds a significant contract, create a release-specific document only if it adds durable review value beyond `CHANGELOG.md`. Good candidates include:

- a new persisted format or migration;
- a new public API compatibility boundary;
- a new analysis algorithm with source ownership constraints;
- a major accessibility contract;
- a benchmark format change;
- a repository-wide bug/security audit;
- a final release-validation evidence record.

Also update the evergreen page that describes the resulting current behavior and add the new historical record to this index.
