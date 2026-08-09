## What changed

Describe the change and why it is needed.

## User-visible behavior

Describe any behavior a SpellChecker user will notice. Write `None` if there is no user-visible change.

For editor changes, mention affected language state, highlighting, spelling/writing findings, shortcuts, individual/bulk correction, undo, persistence, empty/error states, or dictionary behavior.

## Testing

- [ ] `dart format --output=none --set-exit-if-changed lib test` passes locally when practical.
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

## V2.6 writing catalogue

Complete when relevant.

- [ ] New/changed rule IDs are stable and documented.
- [ ] Automatic scope is narrow, deterministic, and language-explicit.
- [ ] Exact source ranges/original text and replacements are tested.
- [ ] Interaction/overlap ownership with existing automatic rules is tested.
- [ ] Unset/default versus explicit stored rule-set behavior is preserved.
- [ ] Batch correction still uses the shared stale/overlap/undo contract.
- [ ] No rule-specific widget mutation path, remote processing, telemetry, or dynamic code loading was introduced.
