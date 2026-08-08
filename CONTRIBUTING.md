# Contributing to SpellChecker

Thank you for helping improve SpellChecker. This guide defines the contribution workflow used by the project.

## Code of Conduct

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before starting

1. Search existing issues and pull requests for related work.
2. For large features, architecture changes, persistence-format changes, public API changes, keyboard-contract changes, or language architecture changes, open an issue before implementation.
3. Keep each pull request focused on one logical change.
4. Do not include credentials, private keys, personal data, real user documents, sensitive dictionary exports, or generated build outputs.
5. Preserve privacy-first local behavior unless a separately reviewed change explicitly requires otherwise.
6. Preserve keyboard/accessibility behavior when changing the editor.

## Development requirements

- Flutter stable
- Dart SDK compatible with `pubspec.yaml` (currently `>=3.8.0 <4.0.0`)
- Git

```bash
flutter doctor
flutter --version
dart --version
```

## Setup

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter analyze
flutter test --reporter expanded
flutter run -d chrome
```

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the complete setup and architecture-specific guidance.

## Branch naming

Use short descriptive names:

```text
feature/language-pack-loader
feature/editor-shortcut-settings
fix/stale-highlight-range
docs/update-user-guide
refactor/correction-history
```

## Commit messages

Prefer imperative, descriptive commit messages. Conventional Commit prefixes are encouraged:

```text
feat: add language pack abstraction
fix: skip stale inline issue ranges
test: cover replace-all undo behavior
docs: document keyboard navigation
chore: update CI configuration
```

## Code style and required checks

```bash
dart format lib test
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

Fix analyzer/test failures in source or tests. Do not broadly suppress checks for convenience.

## Architecture rules

### Spelling logic

Keep tokenization, dictionary checks, suggestion ranking, and normalization independent from Flutter widgets.

### Text correction

Single/replace-all mutation belongs in `TextCorrection` or another reusable core abstraction, not duplicated inside widgets.

Correction code must:

- Validate checked source ranges against current text.
- Refuse stale ranges safely.
- Apply replace-all ranges from the document end toward the beginning.
- Preserve case per occurrence.
- Return deterministic mutation metadata.

### Inline highlighting

`SpellCheckEditingController` owns inline styling. Do not move dictionary/ranking logic into the controller.

Checked highlight ranges must be validated against current text and cleared when manual edits invalidate the check.

### Undo behavior

The current V1.2 correction stack is application-level, bounded, and memory-only.

- Single correction = one undo entry.
- Replace-all = one undo entry.
- Manual editing clears spelling-specific correction history.
- Do not persist editor/correction snapshots without explicit privacy review.

### Active issue state

Changes to active issue behavior must keep editor selection, inline style, Results selected state, navigation controls, and Results auto-scroll coherent.

### Persistence

Keep persistence adapters outside the core spelling/correction engine. Current persisted state is limited to personal words and suggestion-count preference.

## Keyboard and accessibility contracts

V1.2 defines:

- `F7`: next issue.
- `Shift+F7`: previous issue.
- `Ctrl+Enter`: spelling check.
- `Command+Enter`: spelling check.

When changing editor controls:

- Preserve keyboard-only access.
- Avoid focus traps.
- Keep visible alternatives for shortcuts.
- Keep issue meaning available through text/semantics, not color/underline alone.
- Give icon-only actions meaningful tooltips/labels.
- Update [docs/ACCESSIBILITY.md](docs/ACCESSIBILITY.md) and tests for behavior changes.

## Tests

Behavior changes should include tests at the correct layer:

- Core spelling changes → `spell_checker_test.dart`.
- Edit distance/ranking → focused algorithm tests.
- Corrections/replace-all/case → `text_correction_test.dart`.
- Inline highlight controller → `spell_check_editing_controller_test.dart`.
- Personal dictionary codec → import/export compatibility tests.
- Persistence → mocked preference tests.
- User/keyboard/undo/empty-state workflow → widget tests.
- Bug fixes → regression test reproducing the previous failure.

Persistence/widget tests must use isolated mock preferences rather than real machine data.

For scrollable V1.2 issue actions, use `tester.ensureVisible` before tapping when the control is outside Flutter test's default viewport. Do not distort production layout to satisfy a viewport assumption.

See [docs/TESTING.md](docs/TESTING.md).

## Pull requests

A pull request should:

- Explain the problem and solution.
- Describe user-visible behavior.
- Link relevant issues.
- Include appropriate tests.
- Pass formatting, analysis, and tests.
- Update documentation/changelog when needed.
- Avoid unrelated refactoring.
- Call out persistence/privacy/migration implications.
- Call out keyboard/accessibility changes.
- State whether public API behavior changed.

Use the repository PR template.

## Documentation matrix

Update documentation when changing:

- Public APIs → `docs/API.md`
- Internal architecture → `docs/ARCHITECTURE.md`
- Setup/dependencies/storage/editor internals → `docs/DEVELOPMENT.md`
- User workflow/shortcuts → `docs/USER_GUIDE.md`
- Privacy/state retention → `docs/PRIVACY.md`
- Accessibility/keyboard behavior → `docs/ACCESSIBILITY.md`
- Test strategy → `docs/TESTING.md`
- Failure/recovery behavior → `docs/TROUBLESHOOTING.md`
- Release/smoke checks → `docs/RELEASING.md`
- Planned/completed scope → `docs/ROADMAP.md`
- Released behavior → `CHANGELOG.md`
- Repository overview/current version → `README.md`

## Writing-rule contributions

Follow [docs/WRITING_RULES.md](docs/WRITING_RULES.md). New rules need a stable ID, clear scope, explicit language eligibility, deterministic ranges, unit tests, stale-fix tests when applicable, and user/privacy documentation.

Do not market a simple heuristic as full grammar analysis. Do not add text logging/network processing through a rule implementation.

## Language-pack contributions

Follow [docs/LANGUAGE_PACKS.md](docs/LANGUAGE_PACKS.md). Language-specific tokenization/normalization belongs in a pack, not widgets. New packs require compatible/licensed data, Unicode tests, state-isolation tests, selector/persistence coverage, migration considerations, and documentation.

Do not add runtime dictionary downloads or network language detection without explicit privacy/security design review.

## Dictionary contributions

- Use lowercase normalized entries.
- Avoid obvious misspellings.
- Prefer broadly useful words over highly personal vocabulary.
- Add regression tests for reported bugs.
- Use straight apostrophes in directly stored data.
- Check both base and extension dictionary data for duplicates.

For frequency ranks:

- Lower rank means stronger preference.
- Add deterministic ranking tests when ordering matters.
- Do not present the compact rank table as a comprehensive linguistic corpus.

## Personal dictionary format contributions

`PersonalDictionaryCodec` defines a user-transfer format:

- Keep exports versioned.
- Preserve existing version-1 readability unless a documented migration changes it.
- Reject unsupported versions explicitly.
- Keep output normalized, deduplicated, and sorted.
- Reject malformed entries rather than silently storing ambiguous data.
- Update API/user/privacy/changelog docs for format changes.

## Persistence contributions

When modifying `DictionaryPreferences`:

- Add mocked persistence tests.
- Keep editor text/check results/active issue/correction history unpersisted unless an explicitly reviewed feature changes that design.
- Use versioned keys/documented migrations when data meaning changes.
- Do not display persistence success before writes complete.
- Preserve rollback/no-false-success behavior.
- Preserve session spelling when storage is unavailable.

## Security and privacy

Use [SECURITY.md](SECURITY.md) for security-sensitive reports instead of public exploit details.

Synchronization, accounts, cloud spelling/grammar, analytics, remote logging, crash reporting, editor-text persistence, persistent correction history, or keyboard telemetry require explicit privacy/security review before implementation.

## License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).
