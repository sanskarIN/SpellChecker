## What changed

Describe the change and why it is needed.

## User-visible behavior

Describe any behavior a SpellChecker user will notice. Write `None` if there is no user-visible change.

For editor changes, mention affected highlighting, active issue state, shortcuts, replacement, replace-all, undo, empty/error states, or dictionary behavior.

## Testing

- [ ] `dart format --output=none --set-exit-if-changed lib test` passes locally when practical.
- [ ] `flutter analyze` passes.
- [ ] `flutter test --reporter expanded` passes.
- [ ] I added/updated tests at the appropriate core/controller/widget layer.
- [ ] I manually checked the affected workflow when appropriate.
- [ ] Scrollable widget tests use realistic scrolling/`ensureVisible` instead of relying on a fixed test viewport when needed.

## Keyboard and accessibility

- [ ] Keyboard-only behavior remains usable, or I documented intentional shortcut/focus changes.
- [ ] Essential issue state/action is not communicated only by color, underline, hover, or badges.
- [ ] Icon-only controls have meaningful tooltips/labels.
- [ ] I updated accessibility semantics/tests/docs when relevant.

## Writing rules

- [ ] Rule logic is side-effect free and outside Flutter widgets.
- [ ] Supported languages are explicit.
- [ ] Automatic fixes validate exact current source text.
- [ ] Rule changes include focused unit/widget tests.
- [ ] No document logging, hidden persistence, telemetry, or network grammar processing is introduced.

## Language architecture

- [ ] Language-specific rules remain behind `SpellLanguagePack` instead of widgets.
- [ ] Personal/ignored state does not leak across packs.
- [ ] Unicode/tokenization/normalization changes have focused tests.
- [ ] Dictionary data licensing/provenance is suitable for this repository.
- [ ] Import/export/persistence migration behavior is documented when changed.

## Correction safety

Complete this section for correction/editor mutations.

- [ ] Checked source ranges are validated before mutation.
- [ ] Replace-all does not blindly replace unchecked/stale text.
- [ ] Undo grouping/clearing behavior is tested and documented when changed.
- [ ] Manual edits do not leave stale inline highlights/results active.

## Persistence and privacy

- [ ] I described any new persisted data or migration.
- [ ] Editor text/check results/correction history remain unpersisted unless this PR explicitly reviews and documents a change.
- [ ] No unexpected network, analytics, authentication, telemetry, or keyboard logging behavior is introduced.
- [ ] Privacy/security documentation is updated when data handling changes.

## Documentation

- [ ] README/docs are updated when needed.
- [ ] `CHANGELOG.md` is updated for release-relevant changes.
- [ ] `docs/API.md` is updated for public API changes.
- [ ] `docs/ARCHITECTURE.md` is updated for state/data-flow changes.
- [ ] `docs/USER_GUIDE.md` / `docs/TROUBLESHOOTING.md` are updated for user-visible behavior.
- [ ] `docs/TESTING.md` / `docs/ACCESSIBILITY.md` are updated when test/accessibility contracts change.

## Safety and repository hygiene

- [ ] No credentials, tokens, signing keys, private user documents, sensitive dictionary exports, or private correction-history samples are included.
- [ ] Sample text/screenshots use synthetic data and contain no sensitive information.
- [ ] The change is focused and does not include unrelated generated files.

## Related issues

Closes #
