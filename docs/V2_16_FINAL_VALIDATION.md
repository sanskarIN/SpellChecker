# V2.16 Final Validation

Release identity: package `2.16.0+21`; About `2.16.0`.

V2.16 is SpellChecker's final planned implementation milestone and repository-wide stabilization audit. The acceptance standard is not an impossible claim that no future bug can exist; it is that every reproducible defect found during this audit is fixed with a permanent regression and that the exact release trees pass the repository and release-mode gates recorded below.

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

Earlier red full-suite runs were actively diagnosed rather than repeatedly rerun until green. The final startup Ignore regression was hardened after annotations identified an off-screen missed hit test and an inappropriate `pumpAndSettle()` while preference restoration was intentionally unresolved. The accepted functional run above includes those deterministic corrections.

## Release synchronization evidence

Guarded release synchronization run `31880102715` completed successfully. It:

1. updated About source to `2.16.0` and final-stabilization wording;
2. synchronized `CHANGELOG.md`, README, PR guidance, contributor/security/support surfaces, every maintained documentation surface, web metadata, `docs/V2_16_BUG_AUDIT.md`, `what_changed.md`, and this validation record;
3. committed each permanent release/documentation surface separately;
4. removed `docs/V2_16_FINAL_STABILIZATION_SCOPE.md`;
5. removed `tool/v216_release_sync.py`;
6. removed `.github/workflows/v216-release-sync.yml`;
7. verified the synchronized tree was helper-free before push.

The repository's two stale historical open PRs were also resolved without merge: #38 was an obsolete V2.3 execution-only gate and #71 was a superseded older missing-punctuation-space feature branch whose completed functionality is already on `main`. Both carry explicit superseded/completed explanations.

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

A subsequent helper-free ledger-evidence synchronization recorded the release-sync/formatter/hygiene facts in `what_changed.md` and removed its own patcher/workflow.

## Synchronized-candidate permanent CI

Permanent CI run `31880290563` validated synchronized owner-authored head `b96a5a390ccf010d45d9f9e18046c871b3097acc`.

Results:
- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

This established that package/About metadata, final documentation, web metadata, and the complete V2.16 regression set remained green after synchronization.

## Independent release-mode validation

The first one-time release-gate run `31880458485` independently passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, deterministic benchmark smoke, `flutter build web --release`, and `git diff --check`. Its final helper-residue assertion then produced a false positive because it searched the entire repository for helper-like filename tokens and incorrectly classified the permanent regression file `test/v216_startup_preference_sync_widget_test.dart` as disposable merely because its filename contains `sync`.

The gate assertion was corrected to inspect disposable helper locations only (`tool/` and `.github/workflows/`). Corrected independent release-gate run `31880650266` then passed end-to-end:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed;
- `flutter build web --release`: passed;
- `git diff --check`: passed;
- package version `2.16.0+21`: verified;
- About version `2.16.0`: verified;
- exactly ten built-in writing-rule constructors: verified;
- unrestricted Damerau-Levenshtein last-seen recurrence and canonical `CA` → `ABC` distance-2 regression: verified;
- astral Unicode edit-distance regressions: verified;
- decomposed combining-mark tokenization and Latin composition regressions: verified;
- strict personal-dictionary version regression: verified;
- duplicate Portable Settings rule-ID regression: verified;
- failed preference-write and failed migration-write regressions: verified;
- startup spelling-refresh, Writing-insights loading, and Ignore-once loading regressions: verified;
- deterministic startup Ignore hit-test behavior: verified;
- Unicode-safe astral and uncased-script correction regressions: verified;
- V2.16 `what_changed.md`, changelog, README, bug-audit/final-validation docs, and web-manifest metadata: verified;
- direct runtime dependencies remain only Flutter and `shared_preferences`: verified;
- release web `index.html` and `main.dart.js`: verified;
- superseded working-scope file: absent;
- unexpected disposable V2.16 helpers outside the current one-time gate: none found.

The corrected gate removed itself and pushed cleanup commit `e5ad4f78f3921ef1f5ae578c70a1193092ceba82` on the V2.16 implementation branch.

## Implementation merge and merged-main evidence

PR #83, **V2.16 final stabilization and bug audit**, was normally merged while the corrected release-gate rerun was still executing. Its exact merge boundary was:

- final PR head at merge: `c89e799a420246e94071a7c6a811ebde400af399`;
- branch commits preserved: 89;
- permanent changed files at implementation merge: 45;
- additions: 996;
- deletions: 64;
- implementation merge commit: `262859ac5f2058fc6dc71141e7edb26650e1385a`;
- implementation merge tree: `52b7cb9359da883e637428ad503b8eb4fc090fe4`.

Because the merge occurred before the corrected gate self-cleanup commit existed, the implementation merge tree temporarily retained `.github/workflows/v216-release-gate.yml`. This was a repository-hygiene issue only: the workflow is a disposable validation artifact, not runtime application code, test logic, dependency configuration, persistence format, or release metadata.

Post-implementation-merge `main` CI run `31880508903` passed on exact merge `262859ac5f2058fc6dc71141e7edb26650e1385a`:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

The successful corrected release gate later proved the same release candidate also passed the release-mode web build and exact audit assertions.

## Final post-merge cleanup/evidence boundary

Branch `v2.16-post-merge-validation-2026-08-15` was created directly from implementation merge `262859ac5f2058fc6dc71141e7edb26650e1385a`.

Its permanent purpose is deliberately narrow:

1. delete the accidentally merged disposable `.github/workflows/v216-release-gate.yml`;
2. record the actual synchronized-candidate, release-gate, implementation-merge, and merged-main evidence in this validation record;
3. record the same final engineering evidence in `what_changed.md`.

The cleanup changes no Dart production source, regression behavior, package/About identity, dependency, preference key, Portable Settings format, personal-dictionary format, web application source, document persistence, telemetry/network behavior, or writing-rule catalogue.

This cleanup/evidence branch must pass the repository's full permanent CI before normal merge. Its merge must then receive one final default-branch CI run. Only that final green, helper-free `main` is the accepted V2.16 project endpoint.

## Publication boundary

The repository still has no Git tags and no GitHub Releases. V2.16 does not invent the project's first publication/tagging convention; publication remains an explicit maintainer decision separate from this final stabilization milestone.
