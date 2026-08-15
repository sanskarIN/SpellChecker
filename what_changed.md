# What Changed

## V2.16 — Final Stabilization and Bug Audit

Release identity: package `2.16.0+21`; About `2.16.0`.

V2.16 is the final planned implementation milestone. It keeps the ten-rule Writing insights catalogue unchanged and focuses on repository-wide correctness, durability, Unicode, startup-state, import-validation, and test-determinism defects. The release fixes every reproducible defect found during this final audit; it does not claim that no future defect can ever exist.

### Unicode scalar and edit-distance correctness
- `damerauLevenshteinDistance` now operates on Unicode scalar values instead of UTF-16 code units.
- The implementation now uses unrestricted Damerau-Levenshtein distance rather than the restricted optimal-string-alignment recurrence; `CA` → `ABC` is locked at distance 2.
- Astral insertion, deletion, substitution, transposition, and interacting-edit regressions protect scalar behavior.
- Suggestion maximum-distance selection, candidate length filtering, and prefix comparison now use the same scalar model.

### Decomposed Unicode word handling
- English tokenization treats a Unicode letter plus following combining marks as one word cluster.
- Common decomposed Latin accent sequences represented by bundled English loanwords are deterministically composed without a new dependency.
- Precomposed/decomposed forms such as café, façade, jalapeño, naïve, and résumé resolve consistently.
- Text statistics uses the same combining-mark word boundary while preserving the historical UTF-16 character-count contract.

### Strict local data validation
- A present non-integer personal-dictionary `version` is rejected instead of being silently treated as legacy V1; a genuinely omitted version remains backward-compatible.
- Portable Settings rejects duplicate writing-rule IDs instead of silently collapsing them into a set.
- Portable Settings remains format version 1 and remains document/vocabulary-free.

### Truthful local persistence
- Every language, personal-word, writing-rule, suggestion-limit, removal, and legacy-migration preference write checks the `SharedPreferences` boolean result.
- A platform-reported failed write/remove now throws, allowing existing UI/service error paths to report storage unavailability rather than claiming success.

### Startup-state synchronization
- If spelling was checked before preferences finished restoring, successful restoration now reruns that check under the saved language, personal dictionary, rule choices, and suggestion limit.
- Writing Insights refuses to mutate rule state while restoration is pending and reports the shared loading status.
- Ignore-once likewise refuses to mutate the temporary startup engine, preventing ignored session words from disappearing when the restored engine replaces it.

### Unicode-safe correction casing
- `TextCorrection.matchCase` no longer indexes surrogate halves.
- Upper/title-case preservation operates on complete scalars and requires actual cased characters, preventing astral lowercase or uncased scripts from being misclassified as uppercase.

### Final test nondeterminism removed
- Full-suite diagnostics found that the new startup Ignore regression sometimes tapped an off-screen lazy control; it now uses `ensureVisible` before activation.
- A second diagnostic found `pumpAndSettle()` could time out because the test intentionally left preference restoration pending; the regression now pumps one bounded frame instead.
- The accepted helper-free functional CI therefore validates the deterministic version of the regression, not a lucky rerun.

### Audited stable contracts intentionally unchanged
- The built-in Writing insights catalogue remains ten rules; explicit historical rule overrides remain authoritative.
- Writing-analysis zero-count maps remain sparse while diagnostic summaries reconstruct analyzed zero rows.
- Personal-dictionary missing-version legacy V1 compatibility remains supported.
- Editor source ranges remain UTF-16 offsets even though similarity algorithms use Unicode scalars.
- Direct runtime dependencies remain Flutter and `shared_preferences`.

### Permanent regression coverage
- `test/edit_distance_test.dart`
- `test/spell_checker_test.dart`
- `test/language_pack_test.dart`
- `test/text_statistics_test.dart`
- `test/personal_dictionary_codec_test.dart`
- `test/settings_transfer_codec_test.dart`
- `test/dictionary_preferences_test.dart`
- `test/text_correction_test.dart`
- `test/v216_startup_preference_sync_widget_test.dart`
- `test/widget_test.dart` release-identity coverage.

### Privacy, runtime, and release boundary
- No telemetry, account system, cloud grammar/spelling service, document upload, hidden clipboard behavior, new application-network request, preference-key family, Portable Settings version, or runtime dependency was added.
- Package identity advances to `2.16.0+21`; About identity advances to `2.16.0` only after the functional bug-fix candidate passed permanent CI.
- Permanent functional CI run `31879869993` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on helper-free head `33f3ee4577f69d260ddea9cc88fa3895e567a7a4`.
- Final release-mode build, synchronized-candidate CI, implementation merge/main CI, and documentation-only post-merge evidence are recorded in `docs/V2_16_FINAL_VALIDATION.md` as they become concrete.


## V2.15 — Unmatched Curly Brace Diagnostics

Release identity: package `2.15.0+20`; About `2.15.0`.

### Production rule and public API
- Added `lib/writing/rules/unmatched_curly_brace_rule.dart` with public `UnmatchedCurlyBraceRule`.
- Stable rule ID is `unmatched-curly-brace`; display name is `Unmatched curly brace`.
- Exported the rule through `package:spellchecker/writing.dart`.
- Registered it as the tenth built-in/default rule in `WritingRuleRegistry` after the V2.14 square-bracket rule.
- The rule supports language code `en`, so both built-in `en-US` and `en-GB` packs are eligible.

### Deterministic scanner and source ownership
- The implementation scans literal UTF-16 code-unit indexes iteratively from left to right.
- `{` pushes its source index; `}` consumes the most recent available opening; a closing brace with an empty opening stack is unmatched immediately; openings remaining after the scan are unmatched.
- Unmatched indexes are source-sorted before issue emission.
- Every issue owns exactly one ASCII brace: `start` is the brace UTF-16 offset, `end == start + 1`, and `originalText` is `{` or `}`.
- Non-BMP regression coverage verifies that the `}` in `😀}` begins at UTF-16 offset 2.
- Parenthesis, square-bracket, and curly-brace rules are independent delimiter families and do not claim each other's characters.

### Advisory-only correction boundary
- Findings are warning-level with no replacement and `hasAutomaticFix == false`.
- SpellChecker does not guess whether the correct edit is insertion, deletion, movement, or a larger rewrite.
- **Automatic fixes only** excludes curly-brace findings.
- A curly-brace-only document exposes no apply-all safe-fix action.
- `WritingCorrection.applyAll` skips the advisory finding while applying independent deterministic fixes such as repeated-space corrections.

### Catalogue and preference compatibility
- The built-in/default writing catalogue expands from nine rules to ten.
- Unset preferences continue to mean “follow current registry defaults,” now all ten supported rules.
- **Reset rules to defaults** clears the explicit per-language override and therefore adopts the current ten-rule registry.
- Explicit V2.14 nine-rule overrides remain exactly nine rules and do not silently gain `unmatched-curly-brace`.
- Older explicit sets and explicit empty/disable-all sets remain authoritative.
- Preference key family `spellchecker.writing_rule_ids.v1.<language>` is unchanged.

### Portable settings compatibility
- Portable settings format/version is unchanged.
- A V2.14 explicit nine-rule override round-trips unchanged and excludes the V2.15 ID.
- An explicit ten-rule V2.15 set round-trips with `unmatched-curly-brace` intact.
- An unset override remains unset rather than being serialized as a frozen ten-rule list.

### Bounded exact analysis
- Curly-brace findings use the existing bounded `WritingAnalysisResult` model.
- Exactly-at-limit results remain complete; truncation is true only when at least one additional finding exists.
- `totalIssueCount` and `totalIssueCountByRule['unmatched-curly-brace']` remain exact even when retained findings are bounded.
- Global bounded ordering still retains the earliest source-ordered findings across all enabled writing rules.

### Privacy-safe diagnostics
- `WritingAnalysisDiagnosticSummary` includes the stable curly-brace rule metadata and captured/total counts.
- Focused regressions verify private surrounding editor phrases are not copied into diagnostic summaries.
- No finding excerpt, replacement text, source document, telemetry payload, or network request was added.

### Benchmark and stress coverage
- Benchmark writing-rule identity now contains ten stable sorted IDs including `unmatched-curly-brace`.
- Clean benchmark workloads materialize an explicit zero for the new rule.
- A controlled benchmark corpus verifies captured count 1, exact total 1, per-rule total 1, and no truncation.
- Iterative stress tests cover 5,000 balanced nesting levels and 5,000 unmatched opening braces without recursive scanning.

### Writing insights and review integration
- The rule participates in the existing Mechanics category, rule search, finding search, exact visible/captured/total semantics, rule switch, per-language persistence, reset-to-defaults, Portable settings, and advisory presentation.
- Searching `curly brace` matches the rule/finding metadata.
- **Automatic fixes only** truthfully hides the advisory finding.
- Explicit disable of `unmatched-curly-brace` persists while other current defaults remain enabled.

### Catalogue-expansion widget regression hardening
- Adding the tenth rule exposed a historical widget-test assumption in `test/writing_widget_test.dart`, not a production editor failure.
- The shared lazy-build helper received a larger bounded search budget for the taller Writing insights catalogue.
- The actual blocker was an eager `find.text('Apply safe fix').first`: `.first` was evaluated while the lazy item had zero matches, so the test threw before scrolling could build it.
- The regression now scrolls using the zero-or-more base finder and selects `.first` only after the target exists.
- Historical V2.14 test titles were made expansion-safe while their exact saved nine-rule compatibility fixtures remain unchanged.

### Focused permanent regression files
- `test/unmatched_curly_brace_rule_test.dart`
- `test/v215_unmatched_curly_brace_integration_test.dart`
- `test/v215_bounded_curly_brace_analysis_test.dart`
- `test/v215_writing_diagnostic_summary_test.dart`
- `test/v215_curly_brace_stress_test.dart`
- `test/v215_review_query_curly_brace_test.dart`
- `test/v215_benchmark_curly_brace_test.dart`
- `test/v215_settings_transfer_rule_compatibility_test.dart`
- `test/v215_rule_preference_compatibility_widget_test.dart`
- `test/v215_unmatched_curly_brace_widget_test.dart`
- current catalogue coverage in `test/writing_rules_test.dart` and `test/analysis_benchmark_runner_test.dart`
- expansion-safe historical V2.14 registry/preferences/settings regressions
- shared lazy Writing insights finder regression in `test/writing_widget_test.dart`.

### Deliberate parser limitation
- `UnmatchedCurlyBraceRule` is a literal delimiter balancer, not a programming-language, template-language, Markdown, mathematics, URL, citation, quotation, or domain-specific parser.
- V2.15 does not heuristically suppress braces inside code-like/template-like text. A future syntax-aware exclusion requires an explicit parser/ownership contract and corpus rather than guessed mutation.

### Runtime, privacy, and format boundary
- No runtime dependency was added; direct application dependencies remain Flutter and `shared_preferences`.
- No new application-network behavior, cloud grammar service, telemetry, account flow, background upload, hidden clipboard action, or document persistence was added.
- No preference-key family, Portable-settings format version, diagnostic-summary format version, or correction-engine fork was added.

### Functional validation evidence
- Permanent CI run `31876071657` passed package resolution, canonical Dart formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on owner-authored V2.15 head `d82a8e68a0fce15601f8dfe3ae56a17580e41363`.
- Earlier red runs were retained as engineering evidence: the first stopped at canonical formatting; later runs exposed and isolated the lazy `.first` widget-test bug described above. No release identity was stamped until the corrected ten-rule implementation passed the complete functional gate.


### Final V2.15 validation and merged-main evidence
- Permanent synchronized-candidate CI run `31876478606` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on owner head `759834f3d6680f10e8f03a85410a1fb7ca8d8b53`.
- Independent release-gate run `31876609678` repeated those checks, passed `flutter build web --release` and `git diff --check`, verified package/About identity, public export/registration/stable ID, exactly ten built-in rule constructors, focused regressions, explicit V2.14 preference and Portable-settings compatibility, `what_changed.md`/README/changelog/docs/manifest identity, unchanged direct runtime dependencies, generated web outputs, and zero unexpected V2.15 helper residue. The gate removed itself in cleanup commit `3f00e356685762874cda279e4a24f9deeee3c2d8`.
- The release-gate evidence update received final green permanent PR CI run `31876743735` on exact final PR #81 head `7a5f851f719f740267c092b5705be8c6b4bba2f6`.
- PR #81 contained 81 branch commits and 46 permanent changed files, with 1,387 additions and 22 deletions at the implementation merge boundary.
- PR #81 merged normally as `31450fc9223f3f958c18c887c0a7047cb01a9ac8`, preserving the complete 81-commit granular history rather than squashing it.
- The final PR tree and implementation merge tree are both `4554f793c446ae22bcddd6d76776f313bc30950d`, proving the already-green candidate was merged without tree changes.
- Post-merge `main` CI run `31876830663` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the implementation merge.
- The documentation-only post-merge evidence follow-up changes only `docs/V2_15_FINAL_VALIDATION.md` and `what_changed.md`; it changes no production source, test logic, dependency, package/About identity, persistence format, web build input, preference behavior, Portable-settings format, or runtime behavior. The follow-up itself must pass permanent CI and merge normally before the final default-branch acceptance run.

This file is the detailed implementation ledger for SpellChecker releases. It complements `CHANGELOG.md`: the changelog is release-oriented, while this document records the engineering behavior, compatibility boundaries, validation evidence, and permanent file-level changes that define the release.

## V2.14 — Unmatched Square Bracket Diagnostics

Release version: `2.14.0+19`

About version: `2.14.0`

V2.14 expands the deterministic local writing catalogue from eight to nine built-in rules with a second deliberately advisory structural diagnostic. The production tree adds the public `UnmatchedSquareBracketRule`, registry/export integration, one-character UTF-16 source ownership, compatibility-preserving preference behavior, bounded/exact diagnostics, privacy-safe diagnostic-summary coverage, benchmark identity, review/editor integration, deep stress coverage, release identity, and synchronized documentation.

### Production rule and public API

- Adds `lib/writing/rules/unmatched_square_bracket_rule.dart`.
- Stable ID: `unmatched-square-bracket`.
- Public class: `UnmatchedSquareBracketRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering built-in `en-US` and `en-GB` packs.
- Category: Mechanics through the source-compatible `WritingRule` default.
- Severity: warning.
- Default registry size moves from eight rules to nine.
- `WritingRuleRegistry.byId('unmatched-square-bracket')` resolves the built-in rule.

### Deterministic balancing and source ownership

The rule performs an iterative left-to-right scan of literal `[` and `]` code units. Openings are retained on a stack. A closing bracket consumes the most recent unmatched opening when possible; otherwise the closing character is unmatched. Remaining openings are unmatched after the scan, and final findings are emitted in ascending source order.

Every issue owns exactly one bracket character. `start` and `end` are UTF-16 offsets with `end == start + 1`, and `originalText` is `[` or `]`. A non-BMP regression verifies that `😀]` reports the closing bracket at UTF-16 offset 2. Nested square brackets are accepted; malformed ordering such as `]middle[` yields both findings in source order. Parentheses remain independent under the V2.13 rule, and curly braces are outside V2.14 ownership.

The scanner is non-recursive. Stress regressions cover 5,000 balanced nesting levels and 5,000 unmatched openings.

### Advisory-only correction boundary

V2.14 does not guess an automatic edit. An unmatched square bracket may require inserting an opposite bracket, deleting the reported character, moving text, or rewriting a larger expression. The issue therefore leaves `replacement` null and `hasAutomaticFix` false.

Writing insights keeps the finding reviewable under Mechanics, while **Automatic fixes only** removes it from the visible finding set. A document containing only this advisory finding does not expose **Apply all safe fixes**. `WritingCorrection.applyAll` skips the advisory issue, increments the skipped count, and can still apply independent deterministic fixes in the same batch.

### Preference and Portable-settings compatibility

The storage key family remains `spellchecker.writing_rule_ids.v1.<language>`, and Portable settings remains format version 1.

- Unset rule preferences resolve to the current nine-rule default set.
- **Reset rules to defaults** clears the stored override and therefore adopts all nine current defaults.
- An explicit V2.13 eight-rule set remains exactly eight rules and does not silently gain `unmatched-square-bracket`.
- Older explicit sets and explicit empty/disable-all behavior remain authoritative.
- Portable settings round-trip an old explicit V2.13 eight-rule set unchanged and preserve `unmatched-square-bracket` when explicitly present in a V2.14 nine-rule set.

### Bounded analysis, diagnostics, and benchmark integration

The rule reuses the existing analyzer/result contracts without format changes. Exact-at-limit analysis remains complete; overflow retains the globally earliest source-ordered prefix while `totalIssueCount` and `totalIssueCountByRule` report exact totals. Privacy-safe diagnostic summaries add the new stable rule name/ID/count row but continue to exclude editor text, finding excerpts, messages, replacements, and offsets.

The deterministic benchmark workload identity now has nine sorted rule IDs. Zero-finding benchmark samples materialize an explicit zero for `unmatched-square-bracket`; a focused controlled corpus asserts an exact count of one. Benchmark timings remain observational rather than correctness thresholds.

### UI and regression hardening

The ninth rule participates in the existing lazy Writing insights list, search, Mechanics category, automatic-fix filter, per-language rule switches, reset workflow, and preference persistence. The V2.14 widget suite verifies default-enabled behavior, advisory-only presentation, automatic-fix filtering, and explicit-disable persistence.

Catalogue growth also removed the remaining fixed `-1400` findings-list drag from the core widget suite. Tests now build the exact safe-fix action they intend to use, avoiding historical pixel assumptions as the registry evolves.

Permanent focused coverage includes:

- `test/unmatched_square_bracket_rule_test.dart`
- `test/v214_unmatched_square_bracket_integration_test.dart`
- `test/v214_unmatched_square_bracket_widget_test.dart`
- `test/v214_rule_preference_compatibility_widget_test.dart`
- `test/v214_settings_transfer_rule_compatibility_test.dart`
- `test/v214_writing_diagnostic_summary_test.dart`
- `test/v214_bounded_square_bracket_analysis_test.dart`
- `test/v214_square_bracket_stress_test.dart`
- `test/v214_review_query_square_bracket_test.dart`
- `test/v214_benchmark_square_bracket_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/widget_test.dart`

### Deliberate parser limitation

`UnmatchedSquareBracketRule` is a literal delimiter balancer, not a Markdown, programming-language, URL, citation, quotation, mathematical, or domain-specific parser. V2.14 does not suppress square brackets based on surrounding syntax. Syntax-aware exclusions require a future explicit parsing contract and corpus rather than heuristic mutation.

### Release, privacy, dependency, and validation boundary

Package identity advances to `2.14.0+19`; About identity advances to `2.14.0`. V2.14 adds no runtime dependency, new preference key, Portable-settings format change, network request, telemetry, account, cloud writing service, background upload, document persistence, hidden clipboard action, or correction-engine fork.

Before release metadata synchronization, permanent CI run `31872367596` passed package-aware formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the functional nine-rule implementation. The final release candidate must repeat those checks after release synchronization and also pass a release-mode web build plus version/export/registry/manifest/dependency/helper-residue assertions.

### Final V2.14 validation and merged-main evidence

After release metadata and documentation synchronization, permanent synchronized-candidate CI run `31872668004` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on the V2.14 release tree.

Independent release-gate run `31872872493` repeated those checks, built the production web application with `flutter build web --release`, passed `git diff --check`, and verified package/About identity, the public `UnmatchedSquareBracketRule` export, built-in registration, stable rule ID, exactly nine built-in constructors, focused V2.14 regression files, explicit V2.13 preference compatibility, `what_changed.md`, changelog/README/web-manifest metadata, unchanged direct runtime dependencies, generated web outputs, absence of the superseded working-scope document, and zero unexpected V2.14 helper residue. The one-time gate removed itself in cleanup commit `d408e0d923ee5f45ac625098d0cc75de6e60bbd5`.

The release-gate evidence update received final green permanent PR CI run `31873000788` on exact PR head `199e8f6c17a659c2eb5d7fd54a3fde9187f333df`. PR #79 contained 60 branch commits and 45 permanent changed files and was merged with a normal merge commit, preserving that granular history. The V2.14 implementation merge commit is `ae2e66669747b44b408297f663d500f86c254369`.

Post-merge `main` CI run `31873077140` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the implementation merge. The merge tree `c859fdb14f1867b84773300fa6db1c8c8d205845` is identical to the already-green final PR tree.

A documentation-only post-merge evidence change records these now-known merge/main-CI identifiers in both the validation record and this engineering ledger. It changes no production source, test logic, dependency, release identity, persistence format, web build input, or runtime behavior; the evidence change is itself required to pass permanent CI before the repository's final V2.14 default-branch head is accepted.


## V2.13 — Unmatched Parenthesis Diagnostics

Release version: `2.13.0+18`

About version: `2.13.0`

V2.13 expands the deterministic local writing catalogue from seven to eight built-in rules with an intentionally advisory structural diagnostic. The production tree now contains the public `UnmatchedParenthesisRule`, registry/export integration, exact source ownership, compatibility-preserving preference behavior, bounded/exact diagnostics, benchmark identity, UI/filter integration, stress coverage, release identity, and synchronized documentation.

### Production rule and public API

- Adds `lib/writing/rules/unmatched_parenthesis_rule.dart`.
- Stable ID: `unmatched-parenthesis`.
- Public class: `UnmatchedParenthesisRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering built-in `en-US` and `en-GB` packs.
- Category: Mechanics through the source-compatible `WritingRule` default.
- Severity: warning.
- Default registry size moves from seven rules to eight.
- `WritingRuleRegistry.byId('unmatched-parenthesis')` resolves the built-in rule.

### Deterministic balancing and source ownership

The rule performs an iterative left-to-right scan of literal `(` and `)` code units. Openings are retained on a stack. A closing parenthesis consumes the most recent unmatched opening when possible; otherwise the closing character is unmatched. Remaining openings are unmatched after the scan. Findings are emitted in ascending source order.

Every issue owns exactly one parenthesis character. `start` and `end` are UTF-16 offsets with `end == start + 1`, and `originalText` is `(` or `)`. A dedicated non-BMP regression verifies that `😀)` reports the closing parenthesis at offset 2 rather than confusing Unicode scalar and UTF-16 indexing.

Nested balanced text is clean. Malformed ordering such as `)middle(` yields both findings in source order. Square/curly brackets are outside the rule's scope. The scanner is non-recursive; stress regressions cover 5,000 balanced nesting levels and 5,000 unmatched openings.

### Advisory-only correction boundary

V2.13 does not guess an automatic edit. An unmatched parenthesis might require inserting an opposite delimiter, deleting the reported character, moving text, or rewriting a larger phrase. The issue therefore leaves `replacement` null and `hasAutomaticFix` false.

Writing insights keeps the finding reviewable under Mechanics, while **Automatic fixes only** removes it from the visible finding set. A document containing only this advisory finding does not expose an **Apply all safe fixes** button. `WritingCorrection.applyAll` skips the advisory issue, increments the skipped count, and can still apply independent deterministic fixes in the same batch.

### Preference and Portable-settings compatibility

The storage key family remains `spellchecker.writing_rule_ids.v1.<language>`, and Portable settings remains format version 1.

- Unset rule preferences resolve to the current eight-rule default set.
- **Reset rules to defaults** clears the stored override and therefore adopts all eight defaults.
- An explicit V2.12 seven-rule set remains exactly seven rules and does not silently gain `unmatched-parenthesis`.
- Explicit empty/disable-all behavior remains unchanged.
- Portable settings round-trip an old explicit seven-rule set unchanged and preserve `unmatched-parenthesis` when it is explicitly present in an eight-rule set.

### Bounded analysis, diagnostics, and benchmark integration

The rule uses the existing analyzer result contract without format changes. Exact-at-limit analysis remains complete; overflow retains the globally earliest source-ordered prefix while `totalIssueCount` and `totalIssueCountByRule` report exact totals. Privacy-safe diagnostic summaries add the new stable rule name/ID/count row but continue to exclude editor text, finding excerpts, messages, replacements, and offsets.

The deterministic benchmark workload identity now has eight sorted rule IDs. Zero-finding benchmark samples materialize an explicit zero for `unmatched-parenthesis`; a focused controlled corpus asserts an exact count of one. Benchmark timings remain observational rather than correctness thresholds.

### UI and regression hardening

The eighth rule increased Writing insights list height. Existing and new widget regressions were hardened to scroll by lazy-build state rather than relying on seven-rule pixel geometry. This preserves the real lazy `ListView` interaction model while keeping bulk-fix, automatic-filter, explicit-override, reset, and advisory-only behavior testable.

Permanent focused coverage includes:

- `test/unmatched_parenthesis_rule_test.dart`
- `test/v213_unmatched_parenthesis_integration_test.dart`
- `test/v213_unmatched_parenthesis_widget_test.dart`
- `test/v213_rule_preference_compatibility_widget_test.dart`
- `test/v213_settings_transfer_rule_compatibility_test.dart`
- `test/v213_writing_diagnostic_summary_test.dart`
- `test/v213_bounded_parenthesis_analysis_test.dart`
- `test/v213_parenthesis_stress_test.dart`
- `test/v213_review_query_parenthesis_test.dart`
- `test/v213_benchmark_parenthesis_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `test/widget_test.dart`

### Deliberate parser limitation

`UnmatchedParenthesisRule` is a literal delimiter balancer, not a Markdown, programming-language, URL, quoting, mathematical, or domain-specific parser. V2.13 does not suppress parentheses based on surrounding syntax. Syntax-aware exclusions require a future explicit parsing contract and corpus rather than heuristic mutation.

### Release, privacy, and dependency boundary

Package identity advances to `2.13.0+18`; About identity advances to `2.13.0`. V2.13 adds no runtime dependency, new preference key, Portable-settings format change, network request, telemetry, account, cloud writing service, background upload, document persistence, hidden clipboard action, or correction-engine fork.

Before release metadata was applied, permanent CI run `31869797175` passed package-aware formatting, `flutter analyze`, the full Flutter test suite, and deterministic benchmark smoke on the complete functional eight-rule implementation. The final release candidate must repeat those checks after release synchronization and also pass a release-mode web build plus version/export/manifest/dependency/helper-residue assertions.

### Final V2.13 validation and merged-main evidence

After the release metadata and documentation were synchronized, permanent PR CI run `31870187663` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on owner commit `009dbb69564b1c500543c1b36563c338c3f31ee1`.

Independent release-gate run `31870277817` then repeated those checks, built the production web application with `flutter build web --release`, verified package/About identity, eight-rule registry/export identity, focused regression files, `what_changed.md`, changelog/README/web-manifest metadata, unchanged direct runtime dependencies, generated web outputs, and zero unexpected V2.13 helper residue. The one-time gate removed itself in cleanup commit `6dcba69ee737597e0007e5e67d591c8deb99ca2c`.

The release-gate evidence update received a final green permanent PR CI run `31870395536` on exact PR head `4e68476af57efdea295e9a3488c2df8b335a7ab7`. PR #77 contained 65 branch commits and was merged with a normal merge commit, preserving that granular history. The V2.13 implementation merge commit is `fa01826aa084d858e784bed3d09fa3fdcbfa0760`.

Post-merge `main` CI run `31870480137` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the merge commit. The merge tree `7ed318aa9bdaa3f0532366b4311305f846daea1d` is identical to the already-green final PR tree.

A documentation-only post-merge evidence change records these now-known merge/main-CI identifiers. It changes no production source, test logic, dependency, release identity, persistence format, web build input, or runtime behavior; that evidence change is itself required to pass permanent CI before the repository's final V2.13 default-branch head is accepted.

## V2.12 — Missing Punctuation Spacing & Unicode Boundary Completion

Release version: `2.12.0+17`

About version: `2.12.0`

V2.12 completes the production work that an earlier experimental branch could not safely ship: the repository now contains the actual `MissingPunctuationSpaceRule`, public export, built-in registration, deterministic corrections, Unicode regressions, benchmark integration, user workflow coverage, release identity, and synchronized documentation in the same mergeable tree.

### Production rule and public API

- Adds `lib/writing/rules/missing_punctuation_space_rule.dart`.
- Stable ID: `missing-punctuation-space`.
- Public class: `MissingPunctuationSpaceRule` through `package:spellchecker/writing.dart`.
- Eligibility: language code `en`, covering both built-in `en-US` and `en-GB` packs.
- Default registry size moves from six rules to seven.
- `WritingRuleRegistry.byId('missing-punctuation-space')` resolves the built-in rule.

### Deterministic matching scope

The rule owns a deliberately narrow automatic transformation: selected punctuation between Unicode letters when the following space is missing. Supported punctuation is `,`, `;`, `!`, and `?`. Periods and colons are excluded to avoid claiming common domains, versions, schemes, labels, times, and syntax that require richer parsing.

The predecessor recognizes `Unicode letter + zero or more combining marks`. The following Unicode letter is checked with a lookahead and is not consumed. A combining mark without a preceding letter does not establish a boundary. Repeated punctuation does not create a competing missing-space finding.

### Source ownership and correction composition

Each new finding owns only its punctuation character and replaces it with the same punctuation plus one space. Horizontal whitespace before punctuation remains owned by `punctuation-spacing`.

For `Hello ,world`, the existing rule owns the space and the V2.12 rule owns the comma. Their ranges are adjacent, not overlapping, so `WritingCorrection.applyAll` can safely produce `Hello, world` while retaining stale-range validation, deterministic overlap handling, end-to-start application, applied/skipped counts, and one-step editor undo.

### Preference compatibility

No storage key or transfer-format version changes. An unset/reset language now resolves to the current seven-rule default set. An explicit stored set—including an explicit empty set—remains authoritative and is not silently expanded.

### Regression coverage

- `test/missing_punctuation_space_rule_test.dart`: supported punctuation, exclusions, language eligibility, letter boundaries, repeated-punctuation ownership, and punctuation-only offsets.
- `test/missing_punctuation_space_unicode_test.dart`: decomposed and multiple combining marks, adjacent pre-space composition, mark-alone rejection, period/colon exclusions, and non-BMP following-letter UTF-16 offsets.
- `test/writing_rules_test.dart`: seven-rule registry/default/analyzer integration.
- `test/analysis_benchmark_runner_test.dart`: seven-rule workload identity and exact zero totals.
- `test/v212_missing_punctuation_space_widget_test.dart`: default-enabled rule switch, mixed batch correction, one-step undo, and explicit-disable persistence.

### Release and compatibility boundary

Package identity advances to `2.12.0+17`; About identity advances to `2.12.0`. V2.12 adds no runtime dependency, network call, telemetry, account, background upload, document persistence, new preference key, Portable settings format change, language auto-detection, or correction-engine fork.

### Required final validation

The exact permanent head must pass canonical Dart formatting, `flutter analyze`, the full Flutter test suite, deterministic benchmark smoke, release web build, version/documentation identity assertions, `git diff --check`, and a disposable-helper residue check before merge. The permanent tree must contain neither the formatter helper nor the guarded release-sync helper used during development.

## V2.7 — Bounded Writing Analysis & Large-Document Review Safety

Release version: `2.7.0+12`

About version: `2.7.0`

V2.7 extends the large-document safety work from spelling into the optional local Writing insights subsystem. The release deliberately bounds **retained writing findings** while preserving global deterministic review ordering, existing rule execution, correction safety, persistence compatibility, and local-only privacy behavior.

### Public bounded-analysis API

`WritingAnalyzer.analyze()` now accepts an optional named `int? maxIssues` parameter.

- `maxIssues == null` preserves the historical unbounded result-capture behavior.
- A supplied limit must be greater than zero.
- Zero or negative values throw `ArgumentError` before rule analysis.
- Existing source code that omits the parameter remains compatible.

`WritingAnalysisResult` adds immutable bounded-analysis metadata:

- `issueLimit` — the requested positive limit, or `null` for unbounded analysis.
- `isTruncated` — true only after at least one finding beyond the retained set has been observed.
- `isComplete` — convenience inverse of `isTruncated`.
- `capturedIssueCount` — the number of retained `WritingIssue` objects.

The existing `issues`, `analyzedRuleIds`, `languageId`, `isClean`, and `issueCountByRule` APIs remain available. In a truncated result, `issueCountByRule` describes the retained findings rather than pretending to be a whole-document per-rule total.

The result constructor rejects inconsistent bounded metadata. A non-positive `issueLimit` is invalid, and a result cannot claim `isTruncated == true` without declaring an issue limit.

### Global deterministic prefix preservation

A bounded analysis cannot simply stop after the first N values yielded by registered rules. Rule execution order is not the same thing as global review order: one rule can yield a finding near the end of the document and a later rule can yield a finding near the beginning.

V2.7 therefore introduces a private bounded ordered collector. It uses the same comparator as unbounded `WritingAnalyzer` results:

1. source `start` ascending;
2. severity ordering used by the existing analyzer;
3. `ruleId` ascending as the deterministic final tie-breaker.

While fewer than N findings are retained, new findings are inserted into their sorted position. Once the collector is full, an additional finding proves truncation. If that finding belongs before the current worst retained item, it is inserted and the worst item is removed. Otherwise it is discarded.

This guarantees that the retained bounded list equals the first N findings of the corresponding fully sorted unbounded analysis without storing the complete finding list.

### Exact-at-limit completeness

V2.7 keeps the same truthful truncation philosophy used by bounded spelling analysis: reaching a numerical cap is not, by itself, proof that data was omitted.

If exactly N findings exist for `maxIssues: N`, the result remains complete. `isTruncated` becomes true only after another finding is actually observed.

### What the bound does and does not bound

The V2.7 collector bounds retained `WritingIssue` objects and downstream dialog rendering/filtering work for the retained set.

It does **not** stop enabled rules after N findings. Every supported/enabled rule is still invoked across the supplied text so later rules can contribute earlier globally ordered findings and so exact-at-limit completeness can be distinguished from genuine overflow.

Therefore V2.7 does not claim to bound:

- document characters or lines;
- total rule matches that may be scanned;
- rule execution time;
- CPU work of arbitrary custom rules;
- plugin execution time;
- memory used internally by a custom rule implementation.

Applications that process untrusted very large documents or third-party rules still need their own input-size, execution-time, isolation, or plugin-trust policy.

### Built-in Writing insights policy

`WritingInsightsDialog` now accepts a positive `maxIssues` parameter and defaults it to `WritingInsightsDialog.defaultMaxIssues`, which is 200.

The editor continues to construct the dialog through the existing workflow, so normal users receive the 200-finding policy without a second settings surface or a persistence change.

When an additional finding beyond the limit is proven, the dialog:

- shows a limited-analysis explanatory card;
- exposes that explanation through a semantic container/live region;
- uses limited-count semantics instead of presenting the retained count as complete;
- states that review filters and batch actions use captured findings only;
- uses **Apply captured safe fixes (N)** when no review filter is active;
- uses **Apply visible captured safe fixes (N)** when filters are active;
- says **No matching captured findings** when active filters hide every retained finding while additional uncaptured findings may still exist.

When the result is complete, the historical **Apply all safe fixes** and **Apply visible safe fixes** wording remains unchanged.

### Review/filter compatibility

V2.2 search, category filters, automatic-fixes-only review, and V2.3 presets still reuse `WritingReviewQuery`. V2.7 does not create a second filtering engine.

For a truncated analysis, those controls filter the captured prefix only. This scope is communicated in the dialog rather than implying a query has inspected findings that were intentionally not retained.

Review search text, selected categories, automatic-fix state, and preset selection remain transient dialog state and are not persisted.

### Correction and undo compatibility

V2.7 does not create a new correction engine.

Individual captured automatic findings still use `WritingCorrection.apply()`. Captured batch findings still use `WritingCorrection.applyAll()` with the established contracts:

- replacement must exist;
- source range must remain valid;
- current source text must still equal `originalText` exactly;
- advisory findings are skipped;
- overlapping automatic fixes are resolved conservatively/deterministically;
- accepted replacements are applied end-to-start;
- the entire accepted batch is one correction-history entry.

One **Undo correction** therefore restores the complete pre-batch editor text even when the batch originated from a limited captured result.

### Writing-rule compatibility

V2.7 adds no writing-rule ID and changes no built-in rule behavior. The V2.6 six-rule catalogue remains:

- `repeated-word`
- `sentence-capitalization`
- `repeated-space`
- `punctuation-spacing`
- `trailing-whitespace`
- `repeated-punctuation`

The V2.6 specialized spacing ownership boundary remains unchanged.

### Persistence and Portable settings compatibility

V2.7 changes no persistence key, persisted structure, or transfer-format version.

Per-language writing-rule preferences still distinguish unset/default, explicit non-empty, and explicit empty/disable-all states. Personal vocabulary, selected language, suggestion count, and Portable settings behavior are unchanged.

The writing-analysis limit is an API/editor policy, not a new durable user preference, so it is not added to Portable settings.

### Spelling/ranking compatibility

V2.7 does not change the spelling engine or the V2.5 `SpellCheckReport` contract. The editor's existing first-200 spelling issue policy remains independent from the first-200 Writing insights finding policy.

V2.4 suggestion-ranker extensibility and default deterministic ordering remain unchanged.

### Runtime dependency boundary

V2.7 adds no runtime package. Direct runtime dependencies remain Flutter and `shared_preferences`; release validation must confirm `pubspec.lock` stability unless an independent dependency change is intentionally reviewed.

### Privacy boundary

Writing analysis remains local and in memory. V2.7 adds no network request, cloud spelling/grammar service, telemetry, analytics, advertising, account system, remote document upload, or background analysis/upload behavior.

The limit and truncation metadata are not persisted. Captured findings can contain source excerpts just like pre-V2.7 `WritingIssue` values and must not be logged/exported by default.

### Security boundary

The bounded collector is a retained-result safety mechanism, not a sandbox or execution timeout. No remote/dynamic rule loading is introduced. Built-in rules remain source-controlled deterministic local code, and automatic corrections retain stale-source validation.

### Accessibility behavior

The limited-result message is semantically announced and gives the captured count/limit plus captured-only filter/batch scope. Limited states avoid relying on color alone. Existing keyboard access, rule switches, review controls, safe-fix buttons, dialog scrolling, and `Ctrl/Command+Shift+Enter` access remain available.

### Focused core coverage

`test/writing_analysis_limit_test.dart` covers:

- unbounded compatibility;
- invalid non-positive limits;
- exact-at-limit completeness;
- true overflow/truncation;
- global sorted-prefix equivalence;
- later-rule displacement of worse retained findings;
- captured per-rule counts;
- result metadata invariants;
- immutable captured issue lists;
- deliberately out-of-order custom-rule streams.

### Focused widget coverage

`test/writing_analysis_limit_widget_test.dart` covers:

- the built-in default limit of 200;
- a synthetic low limit that produces a real truncated dialog state;
- visible limited-result explanation;
- **Apply captured safe fixes** behavior;
- returned captured finding ranges;
- filtered **No matching captured findings** wording;
- explicit warning that uncaptured findings may still exist.

### Validation defects caught during development

The first new V2.7 test files required canonical Dart formatting; a disposable formatter gate committed only those formatter changes.

The first analyzer pass then found nine `prefer_const_constructors` lints in the synthetic core tests. Those were fixed in a test-only commit without changing production behavior.

After formatting/analyzer were green, the full suite exposed one viewport-dependent widget assertion. The test had scrolled the lazy dialog to the limited-result notice and then expected a standalone `2+` text widget that was no longer necessarily built in that viewport. The stronger behavioral assertions—the proven-overflow notice, captured batch label, returned captured ranges, and limited filtered state—were retained, while the brittle viewport-specific badge assertion was removed in a dedicated test-only commit.

Permanent CI run `31487337689` (CI #181) then passed dependency resolution, formatting, analyzer, and the complete project test suite on functional head `a7f5414d811f0f74fee1bca9b5991517bc17e7d5` before release metadata/documentation changes began.

Subsequent guarded documentation transformations run through a disposable V2.7 helper gate that deletes the pending helper, formats source/tests, resolves dependencies, runs analyzer, checks the diff, and refuses to commit helper residue.

### V2.7 permanent file scope before final release validation

The release intentionally changes these implementation/test surfaces:

- `lib/writing/writing_analyzer.dart`
- `lib/features/editor/writing_insights_dialog.dart`
- `lib/features/editor/spell_checker_page.dart` (About metadata only after functional freeze)
- `test/writing_analysis_limit_test.dart`
- `test/writing_analysis_limit_widget_test.dart`
- `pubspec.yaml`

Release/documentation surfaces synchronized for V2.7 include:

- `README.md`
- `CHANGELOG.md`
- `what_changed.md`
- `.github/pull_request_template.md`
- `docs/ROADMAP.md`
- `docs/WRITING_RULES.md`
- `docs/PERFORMANCE.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/TESTING.md`
- `docs/USER_GUIDE.md`
- `docs/ACCESSIBILITY.md`
- `docs/TROUBLESHOOTING.md`
- `docs/LANGUAGE_PACKS.md`
- `docs/PRIVACY.md`
- `docs/RELEASING.md`
- `SECURITY.md`
- `SUPPORT.md`
- `CONTRIBUTING.md`
- `web/index.html`
- `web/manifest.json`

### Files intentionally not redesigned in V2.7

The release does not require a new personal-dictionary codec, settings-transfer version, preference key family, language pack, spelling dictionary, suggestion ranker, writing rule ID/category/preset, correction result model, application entry point, CI dependency, analyzer configuration, license, CODEOWNERS policy, Dependabot rule, or runtime package.

Those surfaces remain compatibility boundaries and should not be churned solely to mention the release number.

### V2.7 release invariant

V2.7 is complete only when the exact final PR head passes permanent CI, an exact-tree release gate passes `flutter build web --release` plus full formatting/analyzer/tests/hygiene assertions, `what_changed.md` contains the final validation evidence, the helper PR is closed unmerged, and merged `main` is byte-identical to the exact CI-green release head with no `tools/v27*` or `.github/workflows/v27-*` disposable artifact.

### Final V2.7 release-gate evidence

Read-only V2.7 Final Release Gate run `31489335300` validated candidate `a09c1ba18e25ae3afafec346d172de26cd258a41` and passed every configured stage:

- stable Flutter setup and dependency resolution;
- `pubspec.lock` stability in the working tree and against V2.6 `main`;
- canonical formatting and `git diff --check`;
- `flutter analyze`;
- focused `writing_analysis_limit_test.dart`;
- focused `writing_analysis_limit_widget_test.dart`;
- the complete project test suite;
- `flutter build web --release`;
- `2.7.0+12` package and `2.7.0` About identity assertions;
- bounded analyzer/result/dialog/test API markers;
- changelog/README/roadmap/technical/user/accessibility/privacy/security/support/release/PR-template/ledger markers;
- web manifest JSON validity;
- unchanged direct runtime dependency set (`flutter`, `shared_preferences`);
- zero `tools/v27*` or `.github/workflows/v27-*` path in the permanent feature diff.

This evidence was recorded after the successful gate, so the final documentation-complete head must be revalidated before merge. The release may not rely on this earlier SHA alone.

## V2.6 — Deterministic Writing Rule Expansion

Release version: `2.6.0+11`

About version: `2.6.0`

V2.6 expands the deterministic local Writing insights catalogue while preserving the existing V2.0–V2.5 spelling, review, preference, portability, ranking, bounded-analysis, privacy, and correction contracts.

### New built-in writing rules

#### `punctuation-spacing`

Public class: `PunctuationSpacingRule`

The rule finds horizontal whitespace immediately before supported punctuation and proposes deletion of exactly that whitespace range.

Supported punctuation:

- comma `,`
- period `.`
- semicolon `;`
- colon `:`
- exclamation mark `!`
- question mark `?`

The rule is intentionally conservative. It does not rewrite punctuation, does not add punctuation, and does not attempt natural-language grammar inference. It only removes the source whitespace that is directly before one of the supported punctuation marks.

The finding uses the exact whitespace range as `originalText`, with an empty-string replacement. This means `WritingCorrection.apply()` and `WritingCorrection.applyAll()` can use the existing stale-range contract without any special correction path.

The stable rule ID is `punctuation-spacing`. Because writing-rule IDs participate in persisted per-language preferences, the ID is treated as a compatibility identifier and must not be renamed casually.

#### `trailing-whitespace`

Public class: `TrailingWhitespaceRule`

The rule finds horizontal whitespace at line endings and at the end of the document and proposes deletion of exactly that whitespace.

The line-ending behavior is deliberately CRLF-safe. For text using `\r\n`, the issue range ends before the carriage return/newline sequence rather than consuming any line-ending character. For LF input, the issue ends before `\n`. At document end, the issue ends at `text.length`.

The rule does not remove indentation at the beginning of a line and does not treat ordinary interior single spaces as trailing whitespace.

The stable rule ID is `trailing-whitespace`.

### Repeated-space ownership refinement

`RepeatedSpaceRule` remains the rule for runs of two or more horizontal spaces inside prose, but V2.6 narrows its ownership so it does not also claim ranges that the two specialized spacing rules own.

A repeated-space match is now skipped when the run is immediately before supported punctuation, immediately before a line ending, or at document end.

This prevents multiple automatic rules from competing for the same source whitespace. The ownership boundary is intentional:

- interior multi-space prose -> `repeated-space`
- horizontal whitespace before supported punctuation -> `punctuation-spacing`
- horizontal whitespace at line/document end -> `trailing-whitespace`

This design was chosen after the first V2.6 validation run exposed a real overlap interaction. The initial implementation allowed both `repeated-space` and a specialized spacing rule to report the same range. Depending only on lexical rule-ID ordering would have made batch results unnecessarily coupled to identifier ordering. The production rule boundary was therefore corrected so the specialized rules exclusively own their ranges.

### Registry and public API integration

Both new rules are exported from `package:spellchecker/writing.dart`.

`WritingRuleRegistry.builtIns` now contains six built-in rules:

1. `repeated-word`
2. `sentence-capitalization`
3. `repeated-space`
4. `repeated-punctuation`
5. `punctuation-spacing`
6. `trailing-whitespace`

`WritingRuleRegistry.defaultEnabledRuleIds` continues to derive from the built-in registry. This means a language whose writing-rule preference is unset receives the current six-rule default set, subject to language support.

Existing explicit persisted rule preferences are not rewritten. A stored non-empty set still enables exactly the stored supported IDs. A stored empty list still means explicitly disable all writing rules. Reset-to-defaults still clears the stored override so the current registry default can apply.

### Language eligibility

The two V2.6 rules declare support for the `en` language code through the existing `WritingRule.supports()` contract. They therefore run for both built-in English packs:

- English (US), `en-US`
- English (UK), `en-GB`

No language auto-detection was added. The selected language remains explicit and locally persisted.

### Writing insights behavior

Writing insights automatically renders the two new built-in rules because its rule-management UI is driven by the analyzer registry rather than hard-coded rule labels.

The two rules therefore participate in the existing workflows without a separate UI subsystem:

- per-language enable/disable switches
- Mechanics category filtering
- free-text review search
- Automatic fixes filtering/preset
- visible/total rule counts
- visible/total finding counts
- individual `Apply safe fix`
- `Apply all safe fixes`
- filtered `Apply visible safe fixes`
- stale-source refusal
- deterministic overlap handling
- one-step correction undo
- `Ctrl/Command+Shift+Enter` Writing insights keyboard workflow

Both rules use the existing Mechanics category default from `WritingRule`, so the public category contract remains source-compatible.

### Correction and undo behavior

No new correction engine was introduced.

The new rules produce ordinary immutable `WritingIssue` instances with deterministic replacements. `WritingCorrection.apply()` validates the exact current source substring before applying an individual fix. `WritingCorrection.applyAll()` continues to validate every candidate, skip stale/advisory/overlapping findings, choose deterministic non-overlapping fixes, and apply accepted replacements from the end of the document toward the beginning.

A Writing insights batch remains one editor correction-history entry. One `Undo correction` restores the complete pre-batch text.

### Persistence compatibility

V2.6 does not change any persisted format or preference key.

The existing per-language writing-rule key remains:

`spellchecker.writing_rule_ids.v1.<language-id>`

The existing language, personal dictionary, suggestion-limit, Portable settings, and writing-rule preference semantics are preserved.

A user upgrading with no stored writing-rule override receives the current six-rule defaults. A user with an explicit stored rule list keeps that explicit list. A user who explicitly disabled all rules keeps the empty override.

No migration is required because V2.6 adds new stable rule IDs without renaming existing IDs.

### Portable settings compatibility

The Portable settings codec format is unchanged.

Explicit per-language writing-rule override maps continue to preserve well-formed unknown rule IDs for forward compatibility. Therefore a V2.6 rule ID can already move through the existing preference-transfer mechanism without a format-version increase.

Editor text, personal vocabulary, ignored words, findings, and correction history remain excluded from Portable settings.

### Spelling compatibility

V2.6 does not change the spelling engine, dictionary formats, tokenization, language selection, suggestion ranking, or bounded analysis APIs.

The V2.4 injectable `SpellSuggestionRanker` contract remains unchanged.

The V2.5 `SpellCheckReport`/`SpellCheckerEngine.analyze()` bounded-analysis contract remains unchanged.

The built-in editor still captures at most 200 spelling issues, reports genuine truncation as `200+`, and suppresses Replace all when the checked occurrence set is incomplete.

### Runtime dependency boundary

V2.6 adds no runtime package.

The direct runtime dependency set remains:

- Flutter SDK
- `shared_preferences`

`pubspec.lock` remained unchanged after `flutter pub get` in the release gate.

### Privacy boundary

V2.6 adds no network request, remote grammar service, remote spelling service, telemetry, analytics, advertising, account system, document upload, background upload, or cloud rewriting behavior.

The new rules analyze the current editor string in memory only when Writing insights analysis is requested through the existing workflow.

The new findings are not persisted. Review search/preset/filter state remains transient. Correction history remains in memory.

### Security boundary

V2.6 does not add dynamic plugin loading, executable rule packages, remote rule downloads, network-fetched dictionaries, or runtime code evaluation.

The public `WritingRule` contract remains an in-process API. The built-in V2.6 rules operate only on the supplied string and language-pack metadata and return immutable issue data.

Automatic fixes remain protected by the existing exact-source validation before mutation.

### Accessibility behavior

The two new rules use normal Writing insights rule/finding components, so they inherit the existing semantic labels, category metadata, focus behavior, switch controls, finding messages, and safe-fix controls.

The enlarged six-rule catalogue exposed a test assumption that a fixed `-600` drag was always enough to materialize the batch action in the lazy `ListView`. The production dialog was not converted into an eager list. Instead, the legacy widget tests were hardened to scroll through the actual dialog `Scrollable` until the keyed batch action is visible before tapping it.

This preserves the production lazy-list behavior while making the regression tests resilient to catalogue growth.

### Test coverage added or expanded

`test/v26_writing_rules_test.dart` adds focused V2.6 coverage for:

- specialized punctuation-spacing ownership
- trailing-whitespace behavior
- CRLF/LF/document-end source ranges
- exact individual source-range correction
- stale individual correction refusal
- interaction with repeated punctuation
- deterministic batch composition
- Writing insights exposure of both new rule switches
- automatic batch application of the new mechanics
- one-step undo restoration

`test/writing_rules_test.dart` expands the built-in rule/analyzer contract coverage for:

- punctuation-spacing matches
- punctuation-spacing non-matches
- trailing-whitespace matches
- trailing-whitespace non-matches
- six default analyzed rule IDs
- default-enable behavior
- registry lookup by the new stable IDs
- English US/UK support

`test/writing_widget_test.dart` keeps the established writing workflows and now uses resilient scrolling for the enlarged lazy rule list.

### Validation history

The first read-only V2.6 Core Gate exposed the overlapping whitespace ownership described above. Source formatting and analyzer were already clean, but the focused test demonstrated that an automatic batch could leave a single terminal space because `repeated-space` and a specialized rule competed for the same source range.

The production rule boundary and focused expectations were corrected. The next core run passed the focused V2.6 tests but exposed two legacy widget tests whose fixed scroll distance no longer built/reached the batch button after the rule catalogue grew from four switches to six. The legacy tests were corrected to scroll the real lazy dialog until the keyed action is visible.

The final read-only Core Gate run `31379698591` then passed:

- dependency resolution
- runner formatting
- `flutter analyze`
- focused V2.6 tests
- the complete legacy writing subsystem suite
- the complete project test suite
- `flutter build web --release`

The first release-materialization gate run `31380142709` passed the full source/tests/build candidate, including all 150 project tests and the release web build, but the final hygiene assertion intentionally blocked the commit. The helper had been deleted from the working tree, while the audit queried `git ls-files` before staging the deletion, so the index still listed the helper path.

The release gate was corrected to stage the complete candidate with `git add -A` before checking tracked V2.6 helper/workflow residue. The audit therefore reflects the actual tree that would be committed rather than the pre-stage index.

Corrected Release Gate run `31380448117` passed every step:

- checkout of the V2.6 feature branch
- stable Flutter setup
- guarded one-time release integration
- one-time helper removal
- source/test formatting
- dependency resolution
- lockfile stability
- format verification
- analyzer
- focused V2.6 tests
- complete writing subsystem tests
- complete project regression suite
- release web build
- permanent V2.6 API/docs/web/version/runtime-dependency/hygiene audit
- exact validated-tree commit

The validated helper-free release candidate was committed as `d2686870d8ec89c0fe3154fb2261228b54eb8c01` before this change-ledger commit was added.

### Permanent V2.6 file inventory

The validated V2.6 candidate changed the following permanent files relative to the V2.5 `main` tree:

- `.github/pull_request_template.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `README.md`
- `SECURITY.md`
- `SUPPORT.md`
- `docs/ACCESSIBILITY.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/LANGUAGE_PACKS.md`
- `docs/PRIVACY.md`
- `docs/RELEASING.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `docs/TROUBLESHOOTING.md`
- `docs/USER_GUIDE.md`
- `docs/WRITING_RULES.md`
- `lib/features/editor/spell_checker_page.dart`
- `lib/writing.dart`
- `lib/writing/rules/punctuation_spacing_rule.dart`
- `lib/writing/rules/repeated_space_rule.dart`
- `lib/writing/rules/trailing_whitespace_rule.dart`
- `lib/writing/writing_analyzer.dart`
- `pubspec.yaml`
- `test/v26_writing_rules_test.dart`
- `test/writing_rules_test.dart`
- `test/writing_widget_test.dart`
- `web/index.html`
- `web/manifest.json`

This `what_changed.md` ledger is itself an additional permanent V2.6 documentation file.

### Files intentionally not changed

V2.6 does not require changes to the spelling dictionaries, personal-dictionary codecs, language registry, settings-transfer codec, persistence key versions, suggestion ranker interfaces, bounded spelling report model, correction core APIs, application entry point, analyzer configuration, license, ignore files, CODEOWNERS, Dependabot configuration, permanent CI workflow, or release workflow.

Those files remain part of the compatibility surface and are intentionally left unchanged rather than churned for release-number-only edits.

### Release invariant

The V2.6 release is considered complete only when the permanent `main` tree contains the helper-free `2.6.0+11` release, both new public rules and exports, the six-rule registry, the refined repeated-space ownership, all focused/legacy regression coverage, synchronized release documentation including this ledger, synchronized web metadata, and no temporary `tools/v26*` or `.github/workflows/v26-*` release-gate artifacts.

## V2.9 zero-error hardening audit — 2026-08-14

This audit continues from the merged V2.9 diagnostic-summary baseline at commit `5b16c18c1dba9a9c1a1e1522199467c319254d10`. The work was intentionally split into small implementation, regression-test, formatting, configuration, workflow, dependency, and documentation commits for reviewability.

### Production correctness fixes

- Replaced `SpellCheckReport` debug-only constructor assertions with runtime validation so invalid report metadata is rejected in release builds as well as debug builds. Runtime checks cover negative scanned-token counts, non-positive limits, truncated reports without limits, captured issue counts above the declared limit, and scanned-token counts smaller than captured issue counts.
- Made `SpellLanguagePack.recognizedSuffixes` a defensive immutable snapshot so caller-owned list mutation cannot change pack behavior after construction.
- Normalized custom `SpellCheckerEngine.wordFrequencies` keys through the active language pack, discarded empty normalized keys, and retained the best/lower rank when multiple source keys normalize to the same word.
- Tightened sentence-capitalization boundary detection so terminal punctuation must be followed by separating whitespace before the next token; dot-connected text such as `example.com` no longer creates a false sentence boundary.
- Strengthened `WritingAnalysisResult` runtime consistency checks so captured findings must belong to analyzed rules and the result language, and exact per-rule totals may contain only analyzed rule IDs.
- Made `WritingAnalyzer` reject duplicate configured rule IDs before analysis so enablement, persistence, ordering, and diagnostics cannot become ambiguous.
- Preserved Flutter's native active IME composing span while text composition is in progress instead of replacing it with custom spelling-highlight spans.
- Made `TextStatistics` word counting Unicode-letter aware with the same supported internal apostrophe/hyphen token forms used by spelling tokenization.
- Corrected the About dialog release version from stale `2.8.0` to `2.9.0`.

### Regression coverage added

- Added release-mode constructor-invariant tests for `SpellCheckReport`.
- Added immutable recognized-suffix configuration coverage.
- Added custom frequency-key normalization and normalized-duplicate ranking coverage.
- Added dot-connected sentence-boundary coverage.
- Added `WritingAnalysisResult` analyzed-rule/language/per-rule-total ownership coverage.
- Added duplicate writing-rule-ID rejection coverage.
- Added active IME composition rendering coverage in the spell-check editing controller.
- Added Unicode text-statistics coverage.
- Added V2.9 About-dialog version coverage.

### Toolchain and dependency hygiene

- Synchronized analyzer exclusions with the Flutter 3.47 project/tooling layout used by CI.
- Applied the exact Dart 3.13 formatter output required by CI.
- Refreshed `pubspec.lock` with Flutter 3.47 so `flutter pub get` no longer dirties the tracked lockfile. The refresh includes `matcher 0.12.20`, `meta 1.19.0`, `test_api 0.7.12`, and `vector_math 2.4.2`.

### Workflow cleanup

- Removed obsolete one-time V2.2, V2.3, and V2.8 reconciliation workflows from the permanent tree. Those workflows had write permissions and their own release-tree checks stated that disposable helper workflows must not remain after reconciliation.
- Restored the permanent workflow directory to the normal `ci.yml` and tagged `release.yml` workflows after each temporary diagnostic/synchronization helper completed.

### V2.9 release/documentation synchronization

- Updated README current-release metadata to `2.9.0+14` and documented the public privacy-safe writing-analysis diagnostic summary.
- Added the missing `2.9.0` changelog entry.
- Updated API documentation for V2.9, six built-in writing-rule IDs, runtime model invariants, Unicode statistics, immutable language configuration, normalized custom frequencies, and `WritingAnalysisDiagnosticSummary`.
- Advanced release instructions from the stale V2.8 candidate/tag to `2.9.0+14` / `v2.9.0`, and added the lockfile-clean verification requirement.
- Updated architecture, language-pack, privacy, testing, troubleshooting, user-guide, writing-rule, accessibility, performance, contribution, security, support, issue-template, and pull-request-template documentation to match the V2.9 implementation and hardening contracts.
- Kept the V2.9 diagnostic-summary privacy contract exact: the model contains counts/rule/language metadata only and has no automatic clipboard, persistence, telemetry, or network side effect.

### Repository-wide audit coverage

The audit explicitly inspected the complete tracked project surface rather than only files already failing CI: top-level Dart barrels/startup, every core engine/model/codec/statistics file, all bundled dictionary/frequency data, both storage adapters, every writing model/analyzer/rule, every editor widget/controller/dialog, every test file, all GitHub templates/workflows/metadata, root governance/release/security/support files, all documentation files, and the tracked web host files. Files with no demonstrated defect or drift were intentionally left unchanged.

### Validation evidence

Before this audit-log commit, the repair branch passed the permanent CI format/analyze/full-test workflow on the code/configuration hardening head. This final release-validator run then completed all release-sensitive checks on the synchronized V2.9 candidate using Flutter stable / Dart from the CI toolchain:

```text
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
flutter build web --release
```

All commands above completed successfully before this section was committed. After removing the one-time validator and the final documentation-only synchronization helper, the permanent-tree head was independently checked by the repository's ordinary CI workflow; dependency installation, formatting, `flutter analyze`, and the full Flutter test suite all completed successfully.

### Result

The audited candidate has no known remaining formatter error, analyzer diagnostic, failing automated test, lockfile drift, or release-web build failure. This is a verified zero-failure state for the repository's automated gates and the audited invariants above; it is not a claim that any non-trivial software can be mathematically guaranteed to contain zero undiscovered future bugs.
## V2.10 — Deterministic Large-Document Benchmarking

Release version: `2.10.0+15`

About version: `2.10.0`

V2.10 implements the roadmap's repeatable large-document performance-observation milestone as developer-run tooling rather than application telemetry. It composes the existing bounded spelling and writing-analysis APIs over generated synthetic text, keeps production result models timing-free, and makes benchmark workload/output contracts deterministic enough for controlled cross-commit comparisons.

### Deterministic synthetic scenario

`tool/benchmark/analysis_benchmark_scenario.dart` adds `AnalysisBenchmarkScenario`.

- The standard corpus is generated from a source-controlled synthetic chunk and repeat count.
- Repetitions use one newline separator, making generated character count deterministic.
- Scenario name must be non-blank.
- Repeat count and spelling/writing capture limits must be positive.
- Suggestion limit must be non-negative, allowing deliberate zero-suggestion scans.
- Custom chunks must be non-empty.
- `toJsonMetadata()` exposes only scenario shape and never serializes corpus text.

The standard chunk deliberately exercises a stable spelling misspelling plus repeated spaces, repeated words, punctuation-spacing/repetition, sentence-capitalization, and trailing-whitespace writing-rule paths.

### Stable spelling workload

`tool/benchmark/analysis_benchmark_runner.dart` supplies a fixed source-controlled benchmark dictionary and frequency table rather than depending on the complete evolving bundled vocabulary. This prevents normal dictionary expansion from silently changing benchmark spelling eligibility.

The selected `SpellLanguagePack` still owns tokenization, normalization, suffix behavior, suggestion-distance policy, language identity, and language-aware writing support.

Each warmup/measured iteration creates a fresh `SpellCheckerEngine` and `WritingAnalyzer`, preventing suggestion-cache or mutable session state from contaminating later samples.

### Immutable benchmark result model

`tool/benchmark/analysis_benchmark_result.dart` adds `AnalysisBenchmarkSample` and `AnalysisBenchmarkSummary`.

Each sample records:

- zero-based iteration index;
- spelling and writing elapsed durations;
- spelling scanned-token/captured-issue/truncation metadata;
- writing captured/exact-total/truncation metadata;
- sorted analyzed writing-rule IDs;
- sorted exact per-rule writing totals.

Runtime validation rejects negative indexes/durations/counts, spelling captures above scanned tokens, impossible writing totals, writing truncation inconsistent with exact uncaptured counts, blank/duplicate rule IDs, totals for non-analyzed rules, negative rule totals, and per-rule sums that disagree with the exact overall writing total.

Rule-ID lists, per-rule maps, and sample collections are defensive immutable snapshots.

### Cross-model scenario consistency

`AnalysisBenchmarkSummary` additionally rejects samples that contradict the scenario:

- spelling captures cannot exceed the configured spelling limit;
- a truncated spelling sample must fill that capture limit;
- writing captures cannot exceed the configured writing limit;
- a truncated writing sample must fill that capture limit;
- sample indexes must be contiguous and zero-based;
- at least one measured sample is required;
- language ID must be non-blank;
- warmup count must be non-negative.

Across measured iterations, every deterministic outcome must remain identical: spelling scanned/captured/truncated values, writing captured/exact-total/truncated values, analyzed rule IDs, and exact per-rule totals. Elapsed times may vary; analysis workload/outcomes may not.

### Timing aggregation

The summary exposes spelling/writing minimum, median, and maximum durations.

Odd-size medians select the middle sorted microsecond value. Even-size medians use the integer midpoint of the two middle values. Timings are descriptive machine/toolchain observations and are never correctness thresholds.

Timing data remains outside `SpellCheckReport` and `WritingAnalysisResult`, preserving deterministic production result contracts.

### Versioned JSON and human reports

Benchmark JSON uses `formatVersion == 1` and contains language, scenario shape, warmup/measured iteration counts, min/median/max timings, deterministic spelling outcomes, writing captured/exact/truncated outcomes, analyzed rule IDs, exact per-rule totals, and individual measured samples.

The JSON report never serializes generated corpus text. Any incompatible future shape change must advance the format version.

`tool/benchmark/analysis_benchmark_reporter.dart` renders the same workload and aggregate timing metadata in human-readable form, including sorted analyzed rule IDs and exact per-rule totals, while excluding corpus text.

### Strict CLI configuration and exit behavior

`tool/benchmark/analysis_benchmark_options.dart` supports:

- `--repeats=N`
- `--warmup=N`
- `--iterations=N`
- `--spelling-limit=N`
- `--writing-limit=N`
- `--suggestions=N`
- `--language=ID`
- `--json`
- `--help`

Malformed, unknown, duplicate, missing-value, and non-integer options are rejected before execution. Current benchmark language IDs are `en-US` and `en-GB`.

`tool/benchmark/analysis_benchmark_command.dart` distinguishes configuration from execution failures:

- help returns 0;
- malformed/unsupported configuration returns usage error 64 with usage text;
- deterministic execution/invariant failure returns software error 70 without misleading usage text;
- successful human/JSON execution returns 0.

`tool/benchmark_large_document.dart` is the thin stdout/stderr/exit-code entrypoint.

### Focused benchmark tests

V2.10 adds six layered benchmark test files:

- `test/analysis_benchmark_scenario_test.dart`
- `test/analysis_benchmark_result_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/analysis_benchmark_options_test.dart`
- `test/analysis_benchmark_reporter_test.dart`
- `test/analysis_benchmark_command_test.dart`

Coverage includes deterministic corpus construction, metadata privacy, invalid bounds, result/scenario invariants, defensive immutability, odd/even medians, stable multi-sample outcomes, both built-in language packs, all six writing-rule IDs, exact per-rule sum consistency, CLI parsing/errors, human/JSON corpus exclusion, and an end-to-end JSON command run.

The existing widget suite also advances the About-version assertion to `2.10.0`.

### Permanent CI and release validation

`.github/workflows/ci.yml` now formats `lib test tool`, runs `flutter analyze`, executes the complete Flutter tests, and runs a tiny synthetic benchmark CLI smoke command with no timing threshold.

`.github/workflows/release.yml` repeats format/analyze/test/benchmark smoke before `flutter build web --release` and artifact upload.

Timing values are never normal CI pass/fail thresholds.

### Version and compatibility boundaries

- `pubspec.yaml` advances to `2.10.0+15`.
- The About dialog reports `2.10.0`.
- Benchmark classes live under `tool/` and are intentionally not exported through public package barrels.
- No runtime dependency was added.
- No public spelling/writing runtime API, persisted preference key, transfer format, language ID, writing-rule ID, correction contract, storage adapter, or editor workflow was changed by the benchmark milestone.
- `shared_preferences` remains the application-local preference runtime dependency.

### Privacy and security boundaries

The benchmark generates its own source-controlled synthetic text. It does not automatically read editor documents, clipboard content, personal vocabulary, ignored words, preferences, correction history, raw findings, or arbitrary document files.

Human/JSON reports serialize shape/count/rule/timing metadata only and exclude corpus text. The benchmark does not automatically persist or upload reports.

CLI values are validated data, not evaluated code. The benchmark adds no analytics, telemetry, advertising, account system, cloud grammar/spelling service, background upload, or application runtime network request.

Machine-dependent timings are not CPU/wall-clock/security guarantees and are not used as correctness thresholds.

### Documentation and repository metadata synchronized

V2.10 updates README, changelog, roadmap, performance/testing/development/privacy/security/releasing/architecture/API/language-pack/writing-rule/accessibility/user-guide/troubleshooting/support/contribution documentation, bug/feature issue templates, and the pull-request checklist. `docs/V2_10_BENCHMARK.md` is the dedicated benchmark contract.

Templates request synthetic-only reproduction information and distinguish deterministic outcome failures from unrelated machine timing variation.

### Complete tracked-file audit boundary

V2.10 starts from merged V2.9 hardening commit `1c33a95142cb951b5a8d3e69aedd5e81bfac6434`, whose complete repository surface had already passed the V2.9 code/config/test/document audit and exact final validation.

Immediately before the final release-validator helper was added, compare from that base to helper-free functional candidate `ccb7a0e250f7fe859c15e383aea78c72792026fd` reported 73 granular development commits, zero commits behind main, and exactly 40 permanent changed paths. Every V2.10 changed path was reviewed through direct source/test/config inspection or guarded exact documentation transformations. Every tracked path absent from the compare set is byte-identical to the fully audited V2.9 base and was intentionally not churned merely to mention V2.10.

The permanent functional diff covers both issue templates, the PR template, both permanent workflows, root release/governance/support documents, all V2.10-relevant technical/user docs plus the new dedicated benchmark guide, About/package version metadata, six benchmark test files plus the About widget test, and the benchmark implementation/CLI files under `tool/`.

This `what_changed.md` update is the additional permanent release-ledger path.

### Defects found and fixed during V2.10 development

The development audit caught and fixed real defects instead of treating predecessor green CI as proof of new-code correctness:

- canonical Dart 3.13 formatting drift in new benchmark tests/result code;
- a benchmark-result test that cleared its source list before reading `source.first`;
- an unnecessary language import in the runner;
- an invalid `SpellCheckReport.isTruncated` reference, corrected to the real `truncated` contract;
- initially weak cross-model sample/scenario invariants;
- command execution failures initially being mislabeled as option/usage failures;
- benchmark reports initially omitting analyzed writing-rule IDs and exact per-rule totals needed to reproduce the writing workload;
- stale documentation wording that called validated CLI integers “bounded” when no arbitrary maximum is imposed;
- the first release-validator YAML definition embedding an unindented Markdown heredoc, causing workflow-parse failure before any project command ran. The validator was split into a compact read-only gate plus a separate ledger-sync write step.

### Functional CI evidence

Ordinary CI run `31768678031` (CI #340) validated helper-free functional candidate `ccb7a0e250f7fe859c15e383aea78c72792026fd` and passed:

- dependency resolution;
- canonical `lib test tool` formatting;
- `flutter analyze`;
- the complete Flutter test suite;
- the threshold-free benchmark CLI smoke command.

### Final V2.10 release-validator evidence

Read-only V2.10 final release-validator run `31768853528` validated candidate `8d654ece6fb3bcb686f4e2aaf9e79224600b7b4c` and passed every configured stage:

```text
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
en-US JSON benchmark: 250 repeats, 1 warmup, 3 measured iterations
en-GB human benchmark: 50 repeats, 1 warmup, 2 measured iterations
flutter build web --release
```

The gate additionally asserted V2.10 package/About/README/changelog/roadmap identity, JSON format version 1, the sorted six-rule analyzed writing set, exact per-rule-total sum consistency, capture-limit consistency, corpus-text exclusion in JSON and human reports, and absence of every other `v210-*` temporary workflow.

At this release gate the candidate has no known formatter failure, analyzer diagnostic, failing automated test, benchmark-validation failure, lockfile drift, or release-web build failure. Timing values remain intentionally excluded from correctness thresholds.

A final ordinary CI run is required after all V2.10 helper workflows are deleted and the ledger is committed. That final helper-free CI result is the merge gate; no `v210-*` helper may enter `main`.

## V2.11 — Keyboard-First Writing Insights Accessibility & Benchmark Invariant Hardening

Release version: `2.11.0+16`

About version: `2.11.0`

V2.11 continues from merged V2.10 `main` commit `303ff7c5883e50298090546d7db76345e444c467`. The milestone implements the roadmap's broader keyboard-only and large limited-result accessibility coverage while preserving the established local-only spelling/writing architecture. During the same repository audit, V2.10 benchmark metadata was strengthened so an exact per-rule total map is genuinely complete for the complete analyzed-rule set.

The work was intentionally split into granular production, regression, formatter, benchmark, release-metadata, documentation, template, diagnostic, and validation commits rather than squashing unrelated changes together.

### Writing insights runtime hardening

`WritingInsightsDialog` now validates `maxIssues` through runtime code before state creation. Values less than or equal to zero throw `ArgumentError` in release and debug builds; the built-in default remains 200.

The dialog adds a dedicated search `FocusNode` and a keyboard shortcut scope with a focus anchor inside that subtree. While Writing insights owns focus:

- `Ctrl+F` focuses the existing **Search rules and findings** field.
- `Command+F` provides the equivalent macOS shortcut.
- Escape with any transient review search/category/automatic-fixes-only state clears the complete transient `WritingReviewQuery`, keeps the dialog open, and restores search focus.
- Escape with an already-empty transient query closes through the existing `_close()` result path.

The focus anchor exists because validation demonstrated that a shortcut wrapper without a guaranteed focused descendant could fail to receive Ctrl/Command+F after focus traversal. V2.11 therefore protects shortcut routing as a modal focus invariant rather than assuming search itself always owns focus.

Enabled writing-rule switches remain separate from review filters. Escape does not reset `_enabledRuleIds`, persisted per-language rule choices, corrections, editor text, diagnostic-summary state, or Portable settings.

### Live accessibility semantics

Writing insights now exposes keyed live semantic regions for the two compact review counts:

- `writing-rules-visible-count` describes the number of currently visible rules relative to the supported rule set.
- `writing-findings-visible-count` describes the number of visible findings relative to captured findings and, for limited results with exact V2.8 diagnostics, the exact overall total.

Compact visual count strings remain visually available while `ExcludeSemantics` prevents duplicate or ambiguous announcements. Limited results continue to distinguish visible, captured, and uncaptured data instead of presenting the retained prefix as complete.

This metadata does not make uncaptured findings reviewable or fixable. Search, filtering, and automatic corrections still operate only on retained `WritingIssue` objects, preserving the V2.7 captured-only safety boundary.

### Benchmark exact-total invariant repair

The V2.10 benchmark sample contract previously allowed an internally incomplete exact map: a sample could declare analyzed rules `A` and `B`, provide an exact total only for `A`, and still pass if the values present happened to sum to the overall exact total.

`AnalysisBenchmarkSample` now requires `writingTotalIssueCountByRule` to contain exactly one non-negative entry for every `writingAnalyzedRuleIds` value and no other rule. Missing entries are rejected before a sample can enter a summary.

`WritingAnalyzer` intentionally omits zero-count rules from its raw exact per-rule map, so the benchmark runner now materializes an explicit `0` for every analyzed rule that has no finding before constructing a sample. The benchmark therefore reports a complete deterministic outcome even for a clean corpus.

The existing requirements remain in force: rule IDs are non-blank, unique, and sorted snapshots; totals cannot be negative; rule totals must sum to the exact writing total; deterministic analysis outcomes must be identical across measured samples; elapsed times may vary without becoming correctness thresholds.

The benchmark JSON format remains version 1. No public runtime package barrel export, application telemetry, persisted report format, or runtime dependency was added.

### Focused regression coverage

`test/v211_writing_keyboard_test.dart` protects Ctrl+F search focus after keyboard focus moves away from search; focus remaining inside the modal shortcut scope; first Escape clearing an active query and keeping the dialog open; search-focus restoration; second Escape closing an empty-query dialog; combined category plus Automatic fixes only clearing; and real lazy-`ListView` behavior by asserting controls while mounted and scrolling them back into the tree for post-Escape checks.

`test/v211_writing_semantics_test.dart` protects release-mode rejection of non-positive `maxIssues`, live exact finding-count semantics for deliberately limited analysis, live visible/total rule-count semantics, search-filtered count changes, and lazy-list-safe discovery of off-screen semantic nodes.

`test/analysis_benchmark_result_test.dart` adds incomplete exact-map rejection. `test/analysis_benchmark_runner_test.dart` proves a zero-finding corpus still reports the complete six-rule analyzed set with an explicit zero for each rule. `test/widget_test.dart` advances the About-version regression to `2.11.0`.

### Release identity and documentation synchronization

The package advances from `2.10.0+15` to `2.11.0+16`; the About dialog advances from `2.10.0` to `2.11.0`.

The release/documentation pass synchronized the complete V2.11-relevant project surface rather than mechanically rewriting historical release text:

- `README.md` declares V2.11 current and documents keyboard-first Writing insights review.
- `CHANGELOG.md` contains the dated 2.11.0 release entry.
- `docs/ROADMAP.md` marks 2.11 implemented and removes completed benchmark/accessibility future bullets.
- `docs/V2_11_ACCESSIBILITY.md` is the dedicated interaction/accessibility release contract.
- `docs/V2_10_BENCHMARK.md` records the strengthened complete per-rule exact-total invariant.
- `docs/ACCESSIBILITY.md`, `docs/API.md`, `docs/ARCHITECTURE.md`, `docs/DEVELOPMENT.md`, `docs/PERFORMANCE.md`, `docs/PRIVACY.md`, `docs/RELEASING.md`, `docs/TESTING.md`, `docs/TROUBLESHOOTING.md`, `docs/USER_GUIDE.md`, and `docs/WRITING_RULES.md` describe the exact V2.11 behavior and compatibility boundaries.
- `CONTRIBUTING.md`, `SECURITY.md`, and `SUPPORT.md` cover V2.11 keyboard/focus/semantics review requirements.
- The bug-report, feature-request, and pull-request templates contain V2.11 reproduction/review guidance.

Historical V2.9 and V2.10 sections remain historical. No old release text was globally replaced merely to show the new version.

### Compatibility, persistence, privacy, and security boundaries

V2.11 changes no language ID, writing-rule ID, writing-rule matching algorithm, correction algorithm, personal-dictionary format, settings-transfer format, preference key, suggestion-ranker API, spelling result model, writing diagnostic-summary format, benchmark JSON format, or direct runtime dependency set.

Review search/category/automatic-fix state remains in-memory transient dialog state. Live semantic labels contain count/status metadata rather than editor text, source excerpts, replacement text, personal vocabulary, ignored words, or correction-history snapshots.

Ctrl/Command+F only requests focus on the existing local review field. Escape only changes transient review state or closes the local modal. No shortcut evaluates input as code, launches a URL, reads arbitrary files, uploads a document, or creates a telemetry/network path.

The pre-existing explicit **Copy diagnostic summary** action remains the documented user-initiated clipboard path and continues to copy only the metadata-only diagnostic representation.

### Defects and validation assumptions caught during V2.11 development

The development process caught and corrected real defects or unsafe assumptions instead of treating predecessor green CI as proof of the new milestone:

- `AnalysisBenchmarkSample` initially accepted incomplete exact per-rule maps.
- Tightening that invariant exposed the runner's need to materialize analyzer-omitted zero-count rules.
- New Dart code/tests initially required canonical Dart 3.13 formatting.
- The analyzer caught a relative import from a new test into `lib/`; it was converted to a package import.
- Initial keyboard tests incorrectly assumed every lazy dialog child remained mounted after scrolling.
- The first Ctrl+F implementation assumed `CallbackShortcuts` would always have a focused descendant; CI demonstrated otherwise, leading to the focus-anchor production fix.
- Multiple widget-test iterations exposed additional lazy-list assertions that read controls after scrolling had legitimately unmounted them; assertions were moved to the period in which each control is mounted and post-state checks re-scroll the real production list.
- A one-time formatter helper encountered a GitHub HTTP 500 after locally creating a commit. The remote branch did not receive that unresolved helper output; the corrected formatter reran after `flutter pub get`, used `sanskarin@outlook.in` as the authorized commit email, and pushed only canonical resolved-project formatting.
- The first final release-validator script assumed a nested benchmark sample JSON shape. The benchmark command and all 224 tests succeeded, but the validator raised `KeyError: 'writing'`. The gate, not product code, was corrected to the actual stable flat version-1 schema and rerun successfully.
- The first ledger helper embedded an unindented Markdown body directly inside a YAML heredoc and failed workflow parsing before a job was created. It made no ledger change and was removed; the ledger was then applied through a separate temporary Python helper so workflow YAML stayed minimal and valid.

Temporary formatter, documentation, ledger, and release-validator workflows/scripts were one-time branch tooling only. Every helper is required to be removed before the merge-eligible permanent tree.

### Permanent V2.11 changed-file scope

Relative to V2.10 `main`, the permanent release changes these implementation, test, release, documentation, and template files:

- `.github/ISSUE_TEMPLATE/bug_report.yml`
- `.github/ISSUE_TEMPLATE/feature_request.yml`
- `.github/pull_request_template.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `README.md`
- `SECURITY.md`
- `SUPPORT.md`
- `docs/ACCESSIBILITY.md`
- `docs/API.md`
- `docs/ARCHITECTURE.md`
- `docs/DEVELOPMENT.md`
- `docs/PERFORMANCE.md`
- `docs/PRIVACY.md`
- `docs/RELEASING.md`
- `docs/ROADMAP.md`
- `docs/TESTING.md`
- `docs/TROUBLESHOOTING.md`
- `docs/USER_GUIDE.md`
- `docs/V2_10_BENCHMARK.md`
- `docs/V2_11_ACCESSIBILITY.md`
- `docs/WRITING_RULES.md`
- `lib/features/editor/spell_checker_page.dart`
- `lib/features/editor/writing_insights_dialog.dart`
- `pubspec.yaml`
- `test/analysis_benchmark_result_test.dart`
- `test/analysis_benchmark_runner_test.dart`
- `test/v211_writing_keyboard_test.dart`
- `test/v211_writing_semantics_test.dart`
- `test/widget_test.dart`
- `tool/benchmark/analysis_benchmark_result.dart`
- `tool/benchmark/analysis_benchmark_runner.dart`

This `what_changed.md` section is the additional permanent release-ledger path, for 33 permanent V2.11 changed paths in total.

Every permanent changed path above was inspected at the diff level during the release audit. Tracked files absent from this permanent change set are byte-identical to the fully audited merged V2.10 base and were intentionally not churned simply to mention V2.11.

### Ordinary functional CI evidence

Permanent ordinary CI run `31778547418` (CI #423) validated helper-free functional/documented candidate `6e57c34c58d00a06616f098822ccaaa17df91201` and passed dependency resolution, canonical formatting for `lib test tool`, `flutter analyze`, the complete Flutter test suite, and the threshold-free benchmark CLI smoke command. The test suite ended with **224 tests passed**.

Ordinary CI run `31778813668` (CI #425) independently reconfirmed the same permanent quality gates after the final release-validator schema correction commit.

### Final V2.11 release-validator evidence

Corrected read-only V2.11 final release-validator run `31778813655` validated the release candidate after all runtime, regression, documentation, and version work and passed every configured stage:

```text
flutter pub get
git diff --exit-code -- pubspec.lock
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
en-US JSON benchmark: 250 repeats, 1 warmup, 3 measured iterations, 100/100 capture limits, 3 suggestions
en-GB human benchmark: 50 repeats, 1 warmup, 2 measured iterations, 20/20 capture limits, 2 suggestions
V2.11 package/About/README/changelog/roadmap/contract/workflow identity assertions
flutter build web --release
```

The en-US report check additionally asserted JSON format version 1, lexically sorted analyzed rule IDs, exact per-rule key-set equality with analyzed rule IDs, non-negative integer totals, per-rule sum equality with exact overall writing total, and representative-sample equality with summary-level analysis-outcome rule/totals metadata.

At this gate the candidate had no lockfile drift, formatter failure, analyzer diagnostic, test failure, benchmark-invariant failure, release-identity failure, or web release-build failure.

### Final permanent-tree merge invariant

The release validator and all other V2.11 helpers are deliberately non-permanent. After this ledger is committed, the final branch must contain only the reusable `.github/workflows/ci.yml` and `.github/workflows/release.yml` workflows. An ordinary CI run on the exact documentation-complete helper-free head must pass dependency installation, canonical formatting, analyzer, all 224 Flutter tests, and the benchmark CLI smoke command.

Only that exact final CI-green head is eligible for merge to `main`. The resulting `main` merge commit must then pass the same ordinary push-triggered CI. This establishes a verified zero-failure state for the repository's audited automated gates and V2.11 invariants; it is not a mathematical claim that non-trivial software can contain no undiscovered future defect.

