# V2.16 Final Validation

Release candidate: `2.16.0+21` / About `2.16.0`.

V2.16 is SpellChecker's final planned implementation milestone and repository-wide stabilization audit. The acceptance standard is not an impossible claim that no future bug can exist; it is that every reproducible defect found during this audit is fixed with a permanent regression and that the exact final tree passes all repository and release-mode gates.

## Functional bug-audit boundary

The permanent audit is recorded in `docs/V2_16_BUG_AUDIT.md`. It covers Unicode-scalar/unrestricted Damerau-Levenshtein correctness, scalar suggestion eligibility, decomposed Unicode word clusters and common Latin composition, text statistics, strict dictionary/settings imports, failed preference writes, startup check/rule/session synchronization, Unicode-safe case correction, and deterministic startup widget behavior.

The ten-rule Writing insights catalogue, explicit historical rule preferences, Portable Settings format version 1, editor UTF-16 source-range contract, and direct runtime dependency boundary remain unchanged.

## Accepted functional CI

Permanent CI run `31879869993` validated helper-free functional head `33f3ee4577f69d260ddea9cc88fa3895e567a7a4` before release synchronization.

Results:
- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

Earlier red full-suite runs were actively diagnosed. The final startup Ignore regression was hardened after annotations identified an off-screen missed hit test and an inappropriate `pumpAndSettle()` while preference restoration was intentionally unresolved. The accepted functional run above includes those deterministic corrections.

## Release synchronization requirements

The synchronized release tree must contain package `2.16.0+21`, About `2.16.0`, updated `what_changed.md`, changelog/README/web metadata, maintained public docs, and no `docs/V2_16_FINAL_STABILIZATION_SCOPE.md`. Disposable synchronizers/formatters/diagnostics must be absent before final permanent CI.

## Remaining acceptance gates

The exact synchronized candidate must pass package-aware canonical formatting, permanent CI, an independent `flutter build web --release` gate with release/dependency/helper assertions, another exact-head permanent CI after evidence recording, normal merge preserving granular history, merged-main CI, and a documentation-only post-merge evidence PR with its own CI and normal merge. Final `main` must be green.
