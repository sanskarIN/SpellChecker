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

## Release synchronization evidence

Guarded release synchronization run `31880102715` completed successfully. It:

1. updated About source to `2.16.0` and final-stabilization wording;
2. synchronized `CHANGELOG.md`, README, PR guidance, contributor/security/support surfaces, every maintained documentation surface, web metadata, `docs/V2_16_BUG_AUDIT.md`, `what_changed.md`, and this validation record;
3. committed each permanent release/documentation surface separately;
4. removed `docs/V2_16_FINAL_STABILIZATION_SCOPE.md`;
5. removed `tool/v216_release_sync.py`;
6. removed `.github/workflows/v216-release-sync.yml`;
7. verified the synchronized tree was helper-free before push.

The repository's only two stale historical open PRs were also resolved without merge: #38 was an obsolete V2.3 execution-only gate and #71 was a superseded older missing-punctuation-space feature branch whose completed functionality is already on `main`. Both now carry explicit superseded/completed explanations.

## Final package-aware formatting evidence

Final formatter run `31880158636` completed successfully on the synchronized release tree. It:

1. set up stable Flutter;
2. resolved dependencies with `flutter pub get`;
3. ran `dart format lib test tool`;
4. committed only genuine formatter drift when present;
5. immediately reran canonical formatting in check mode;
6. verified no tracked Dart drift remained;
7. removed `.github/workflows/v216-final-format.yml`;
8. pushed helper-free formatted head `99f493bf98f6c8fed18c757154b72c1454b0561f`.

A subsequent helper-free ledger-evidence synchronization recorded these concrete release-sync/formatter/hygiene facts in `what_changed.md` and removed its own patcher/workflow. The owner-authored validation update containing this section defines the next exact permanent-CI candidate.

## Remaining acceptance gates

The exact synchronized candidate must now pass permanent CI. Then a one-time independent release gate must repeat formatting, static analysis, the complete Flutter suite, and deterministic benchmark smoke; build the production web application with `flutter build web --release`; run `git diff --check`; verify exact V2.16 release identity, Unicode/unrestricted-distance regressions, strict import and failed-persistence regressions, startup-state/case-correction regressions, ten-rule catalogue identity, documentation/web metadata, direct dependency boundary, generated web outputs, absence of the working-scope file, and zero unexpected V2.16 helper residue; and remove itself after success.

The release-gate cleanup/evidence head must receive another green permanent CI run before PR #83 may merge normally. The implementation merge must then pass default-branch CI. A documentation-only post-merge evidence PR must record the actual final PR head/commit/file counts, implementation merge SHA/tree, merged-main CI, and final evidence merge; it too must pass CI and merge normally. Final `main` must be green before V2.16 is complete.
