## V2.14 structural-rule release checks

When a change touches the current unmatched-square-bracket milestone, confirm that `unmatched-square-bracket` keeps one-character UTF-16 ownership, remains advisory-only, preserves explicit older rule overrides, participates in bounded/private diagnostics and benchmark identity, and does not add parser claims or automatic mutations without dedicated evidence.

- [ ] The nine-rule registry/export identity is covered when the catalogue changes.
- [ ] Advisory findings remain excluded by **Automatic fixes only** and skipped by batch correction.
- [ ] Explicit V2.13 eight-rule preferences and Portable settings remain exact unless the user resets or explicitly opts in.
- [ ] Release metadata, `what_changed.md`, web metadata, behavior docs, and final validation evidence are synchronized for `2.14.0+19`.

## What changed

## V2.12 writing-boundary reminder

For writing-rule changes, confirm stable IDs, language eligibility, Unicode/UTF-16 source ranges, adjacent/overlapping automatic-fix ownership, default-vs-explicit preference behavior, benchmark workload metadata, and focused plus full-suite regressions. V2.12's `missing-punctuation-space` rule is the reference case for decomposed combining-mark boundaries and punctuation-only ownership.
Describe the change and why it is needed.

## User-visible behavior

Describe any behavior a SpellChecker user will notice. Write `None` if there is no user-visible change.

For editor changes, mention affected language state, highlighting, spelling/writing findings, shortcuts, individual/bulk correction, undo, persistence, empty/error states, or dictionary behavior.

## Testing

- [ ] `dart format --output=none --set-exit-if-changed lib test tool` passes locally when practical.
- [ ] `flutter analyze` passes.
- [ ] `flutter test --reporter expanded` passes.
- [ ] `flutter build web --release` passes for release-sensitive changes.
- [ ] I added/updated tests at the appropriate core/persistence/controller/widget layer.
- [ ] I manually checked the affected workflow when appropriate.
- [ ] Scrollable/lazy widget tests exercise realistic scrolling/`ensureVisible` rather than relying on a fixed viewport.

## Public API and compatibility

- [ ] Public barrel/API changes are documented in `docs/API.md`.
- [ ] Existing public behavior remains compatible or the intended breaking/migration behavior is documented.
- [ ] Stable language IDs, writing-rule IDs, preference keys, and transfer-format versions are not silently reinterpreted.

## Keyboard and accessibility

- [ ] Keyboard-only behavior remains usable, or intentional shortcut/focus changes are documented/tested.
- [ ] Visible controls remain available for shortcut workflows.
- [ ] Essential issue/finding state is not communicated only by color, underline, hover, or badges.
- [ ] Icon-only controls have meaningful tooltips/labels.
- [ ] Accessibility semantics/tests/docs are updated when relevant.

Current shortcut contracts include `Ctrl/Command+Enter`, `Ctrl/Command+Shift+Enter`, `F7`, and `Shift+F7`.

## Writing-rule safety (when applicable)

- [ ] New/changed writing-rule IDs are stable and preference compatibility is documented.
- [ ] Source ranges have exact ownership tests, including Unicode/UTF-16 cases where relevant.
- [ ] Automatic replacement is provided only when the edit is deterministic; ambiguous findings remain advisory.
- [ ] Registry/default changes include persistence, Portable-settings, UI, diagnostics, benchmark, and documentation review.

## Writing rules

- [ ] Rule logic is deterministic, side-effect free, and outside Flutter widgets.
- [ ] Rule IDs are stable and unique.
- [ ] Supported languages are explicit.
- [ ] Automatic findings contain exact source ranges/original text.
- [ ] New/changed automatic fixes have stale-range tests.
- [ ] Rule changes include focused unit/widget tests.
- [ ] No document logging, hidden persistence, telemetry, or network grammar processing is introduced.

## Writing rule preferences

Complete when changing rule settings/persistence.

- [ ] Preferences remain namespaced by language.
- [ ] Missing/unset still means registry defaults.
- [ ] Explicit stored empty list still means disable all.
- [ ] Unknown/stale rule IDs are handled safely.
- [ ] Migration is documented/tested if stable IDs or key meaning changes.

## Writing review management

- [ ] Writing-rule categories preserve intended public/source compatibility.
- [ ] Search/category/automatic-fix filtering is implemented in reusable query code rather than duplicated in widgets.
- [ ] Review filter state remains transient unless persistence is explicitly reviewed/documented.
- [ ] Filtered batches still use the shared writing-correction safety/undo contract.
- [ ] Reset-to-defaults clears the language override rather than storing today's defaults.
- [ ] Query/filter/reset behavior has unit/widget regression tests.

## Batch correction safety

Complete for automatic bulk-writing changes.

- [ ] Candidate ordering/conflict resolution is deterministic.
- [ ] Advisory findings are not mutated.
- [ ] Stale/invalid ranges are skipped/refused safely.
- [ ] Overlap behavior is documented and tested.
- [ ] Accepted edits preserve source-offset safety.
- [ ] Applied/skipped counts are tested.
- [ ] One user-visible batch has intentional/tested undo grouping.

## Language architecture

- [ ] Language-specific spelling/token/normalization rules remain behind `SpellLanguagePack`.
- [ ] Personal, ignored, and writing-rule preference state does not leak across packs.
- [ ] Unicode/tokenization/normalization changes have focused tests.
- [ ] Dictionary data licensing/provenance is suitable for this repository.
- [ ] Import/export/persistence migration behavior is documented when changed.
- [ ] Writing-rule eligibility is reviewed for new/changed packs.

## Spelling correction safety

Complete for spelling correction/editor mutations.

- [ ] Checked source ranges are validated before mutation.
- [ ] Replace-all does not blindly replace unchecked/stale text.
- [ ] Case behavior is preserved/tested where applicable.
- [ ] Undo grouping/clearing behavior is tested/documented when changed.
- [ ] Manual edits do not leave stale inline highlights/results active.

## Persistence and privacy

- [ ] I described any new persisted data/key/migration.
- [ ] Editor text, spelling/writing findings, and correction history remain unpersisted unless this PR explicitly reviews/documents a change.
- [ ] Persistence failures do not produce false durability claims.
- [ ] No unexpected network, analytics, authentication, telemetry, remote logging, or keyboard logging behavior is introduced.
- [ ] Privacy/security docs are updated when data handling changes.

## Documentation

- [ ] README/current release is updated when needed.
- [ ] `CHANGELOG.md` is updated for release-relevant changes.
- [ ] `docs/API.md` is updated for public API changes.
- [ ] `docs/ARCHITECTURE.md` is updated for state/data-flow changes.
- [ ] `docs/LANGUAGE_PACKS.md` is updated for language/state changes.
- [ ] `docs/WRITING_RULES.md` is updated for rule/correction/preferences changes.
- [ ] `docs/USER_GUIDE.md` / `docs/TROUBLESHOOTING.md` are updated for user-visible behavior.
- [ ] `docs/TESTING.md` / `docs/ACCESSIBILITY.md` are updated when test/accessibility contracts change.
- [ ] `docs/PRIVACY.md`, `SECURITY.md`, and `SUPPORT.md` are updated when relevant.

## Safety and repository hygiene

- [ ] No credentials, tokens, signing keys, private user documents, sensitive dictionary exports, private writing findings, or private correction-history samples are included.
- [ ] Sample text/screenshots use synthetic data.
- [ ] No temporary integration/reconciliation workflow or helper script remains in the intended release tree.
- [ ] The change is focused and contains no unrelated generated files.

## Related issues

Closes #

## V2.3 review presets and portable settings

Complete when relevant.

- [ ] Review preset IDs/semantics remain stable or migration/release notes are included.
- [ ] Free-text review search remains transient unless persistence is explicitly reviewed.
- [ ] Portable settings preserve missing/unset versus present-empty override semantics.
- [ ] Portable settings exclude editor text, personal vocabulary, ignored words, findings, and correction history.
- [ ] Import validation and best-effort rollback behavior have focused tests.
- [ ] `shared_preferences` behavior is not described as transactional.
- [ ] No temporary `tools/v23_*` or `.github/workflows/v23-*` integration/recovery artifact remains in the release tree.

## V2.5 bounded-analysis / performance

Complete when relevant.

- [ ] Historical unbounded `check()` behavior remains compatible.
- [ ] Explicit issue limits are positive and truncation is proven rather than inferred from equality with the cap.
- [ ] Overflow issues do not receive unnecessary suggestion generation.
- [ ] Limited UI results are visibly/semantically identified.
- [ ] Bulk correction is not exposed for an incomplete checked occurrence set.
- [ ] Performance tests use synthetic data and deterministic invariants rather than unstable wall-clock thresholds.
- [ ] `docs/PERFORMANCE.md` is updated when the performance contract changes.

## V2.6 deterministic writing-rule checklist

Complete when relevant.

- [ ] New/changed built-in rule IDs are stable and documented.
- [ ] Exact source ranges and automatic replacements have focused tests.
- [ ] English pack eligibility is explicit/tested when applicable.
- [ ] Rule ownership does not create avoidable conflicting exact-range replacements.
- [ ] Unset/default versus explicit persisted rule-list semantics remain compatible.
- [ ] Writing insights lazy-list accessibility/viewport behavior is exercised realistically.
- [ ] Batch composition and one-step undo remain safe.
- [ ] No new persistence/network/telemetry/runtime dependency is introduced unintentionally.
- [ ] No temporary `tools/v26_*` or `.github/workflows/v26-*` release artifact remains in the final tree.

## V2.7 bounded writing-analysis checklist

- [ ] Optional `maxIssues` behavior preserves unbounded compatibility and positive-limit validation.
- [ ] Bounded findings preserve the globally sorted unbounded prefix and exact-at-limit completeness.
- [ ] Limited Writing insights wording describes captured findings/filters/batch actions truthfully.
- [ ] Focused bounded-analysis and limited-dialog tests are included or remain green.
- [ ] No persistence format, runtime dependency, network, privacy, or security boundary changed unintentionally.
- [ ] `what_changed.md` and release documentation are synchronized with the implementation.
- [ ] No V2.7 helper or disposable workflow is included in the permanent release diff.

## V2.8 exact writing-analysis diagnostics checklist

Complete when relevant.

- [ ] Analyzer-produced overall/per-rule exact totals are internally consistent and immutable.
- [ ] Direct V2.7-style result construction remains source-compatible when diagnostics are omitted.
- [ ] Exact totals include uncaptured findings without retaining every uncaptured `WritingIssue` object.
- [ ] The bounded retained list still equals the global deterministic prefix of unbounded analysis.
- [ ] Exact-at-limit completeness and true-overflow semantics are covered by focused tests.
- [ ] Disabled/unsupported rules are excluded from exact totals.
- [ ] Writing insights exact captured/total, first-N-of-total, per-rule totals, and uncaptured wording are tested.
- [ ] Limited filters and corrections remain captured-only, stale-safe, overlap-safe, and one-step undoable.
- [ ] Lazy/scrollable dialog tests navigate real off-screen controls rather than making production content eager.
- [ ] Exact totals remain local/memory-only and are not silently persisted, logged, exported, uploaded, or used as timing telemetry.
- [ ] `docs/PERFORMANCE.md` does not describe finding counts/`maxIssues` as a CPU-time or document-size security bound.
- [ ] `.github/FUNDING.yml` and documented support links remain optional and do not alter governance, support, security, or runtime behavior.
- [ ] `what_changed.md`, changelog, roadmap, README/web, and all affected technical/user/policy/release docs are synchronized.
- [ ] `pubspec.yaml` / About versions and tag instructions match the intended V2.8 release.
- [ ] No `tools/v28*` or disposable `.github/workflows/v28-*` file is included in the permanent release diff.

## V2.9 diagnostic-summary / hardening checklist

Complete when relevant.

- [ ] Diagnostic summaries remain deterministic and metadata-only; raw editor text/findings are not serialized.
- [ ] Compatibility results without V2.8 exact totals remain representable without guessed counts.
- [ ] `SpellCheckReport` / `WritingAnalysisResult` runtime consistency invariants remain enforced in release builds.
- [ ] Writing analyzer rule IDs remain unique and finding/total ownership matches analyzed rule IDs/language.
- [ ] Language-pack configuration remains immutable after construction and custom frequency keys follow pack normalization.
- [ ] IME composing feedback and Unicode token/statistics behavior have focused regressions when touched.
- [ ] `pubspec.yaml`/About/README/changelog/releasing/tag instructions match the intended V2.9 release.
- [ ] `flutter pub get` leaves `pubspec.lock` clean on the supported release toolchain.
- [ ] Exact-tree format, analyze, full tests, and `flutter build web --release` pass before release.
- [ ] No V2.2/V2.3/V2.8/V2.9 disposable reconciliation workflow/helper remains in the permanent release tree.

## V2.10 deterministic benchmark checklist

Complete when benchmark/tooling/performance-observability behavior is touched.

- [ ] Benchmark inputs remain generated synthetic data; no private/user-document ingestion path was added.
- [ ] Fixed benchmark dictionary/frequency metadata remains stable or the intentional workload change is versioned/documented.
- [ ] Warmup and measured iteration validation remains explicit.
- [ ] Each measured sample uses fresh spelling/writing analysis state.
- [ ] Measured samples must agree on deterministic analysis outcomes even when elapsed timings differ.
- [ ] Human/JSON reports exclude corpus text and raw document findings.
- [ ] Incompatible JSON report changes advance `formatVersion` and are documented.
- [ ] Timing values remain descriptive and machine-dependent; normal CI does not use performance thresholds.
- [ ] `tool/` is included in formatting/static-analysis coverage and the benchmark CLI smoke test remains green.
- [ ] Both built-in language IDs remain covered when language-aware benchmark behavior changes.
- [ ] No runtime dependency, persistence format, application telemetry, network request, or public runtime API was introduced unintentionally.
- [ ] `docs/V2_10_BENCHMARK.md`, performance/testing/privacy/security/releasing docs, changelog/roadmap/README, and `what_changed.md` are synchronized.
- [ ] No temporary V2.10 synchronization/validation workflow remains in the permanent release tree.

## V2.11 keyboard/accessibility checklist

- [ ] Writing insights shortcut changes keep visible/touch-accessible equivalents.
- [ ] Ctrl/Command+F and two-stage Escape behavior are preserved or intentionally documented/tested.
- [ ] Transient review filters remain separate from persisted per-language rule preferences.
- [ ] Lazy dialog tests scroll real content instead of forcing off-screen widgets to stay mounted.
- [ ] Rule/finding semantics communicate visible/captured/total meaning without relying on compact visual counts alone.
- [ ] Benchmark exact per-rule totals cover every analyzed rule, including zero-count rules, when benchmark code changes.
- [ ] No `v211-*` one-time workflow/helper remains in the permanent tree.
