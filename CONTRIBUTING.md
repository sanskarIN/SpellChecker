# Contributing to SpellChecker

Thank you for helping improve SpellChecker. This guide defines the contribution workflow used by the project.

## Code of Conduct

Participation in the project is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before starting

1. Search existing issues and pull requests for related work.
2. For large features, architecture changes, persistence-format changes, or public API changes, open an issue before implementation.
3. Keep each pull request focused on one logical change.
4. Do not include credentials, private keys, personal data, real user documents, or generated build outputs.
5. Preserve the privacy-first local behavior unless a separately reviewed change explicitly requires otherwise.

## Development requirements

- Flutter stable
- Dart SDK compatible with `pubspec.yaml` (currently `>=3.8.0 <4.0.0`)
- Git

Verify your environment:

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

For a complete local setup and directory explanation, read [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Branch naming

Use short descriptive branch names:

```text
feature/editor-highlighting
feature/language-pack-loader
fix/apostrophe-tokenization
docs/update-user-guide
refactor/suggestion-ranking
```

## Commit messages

Prefer imperative, descriptive commit messages. Conventional Commit prefixes are encouraged:

```text
feat: add persistent personal dictionary
fix: preserve cursor after replacement
test: cover transposed spelling suggestions
docs: document release workflow
chore: update CI configuration
```

## Code style

Format before committing:

```bash
dart format lib test
```

Then run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

### Dart and Flutter guidance

- Prefer immutable values and `const` constructors where practical.
- Keep spelling logic independent of widgets.
- Keep persistence adapters outside the core spelling engine.
- Keep UI state local unless cross-feature state requires a dedicated abstraction.
- Avoid adding a package when a small standard-library implementation is sufficient.
- Document public APIs and behavior changes.
- Treat editor text and personal vocabulary as private user data.
- Do not add telemetry or network transmission without an explicit design discussion and privacy-documentation update.
- Fix analyzer findings in source/tests rather than broadly suppressing lints for convenience.

## Tests

Behavior changes should include tests. At minimum:

- Core spelling changes: unit tests.
- Edit-distance/ranking changes: focused algorithm tests.
- Personal-dictionary codec changes: import/export compatibility tests.
- Persistence changes: mocked preference tests.
- User workflow changes: widget tests when practical.
- Bug fixes: regression test reproducing the previous failure.

Persistence/widget tests must use isolated test preferences such as `SharedPreferences.setMockInitialValues` rather than real machine data.

See [docs/TESTING.md](docs/TESTING.md).

## Pull requests

A pull request should:

- Explain the problem and solution.
- Describe user-visible changes.
- Link relevant issues.
- Include tests for behavior changes.
- Pass formatting, analysis, and test checks.
- Update docs and changelog when appropriate.
- Avoid unrelated refactoring.
- Call out storage/privacy/migration implications when relevant.

Use the repository pull request template and complete every relevant section.

## Documentation changes

Update documentation when changing:

- Public APIs → `docs/API.md`
- Internal architecture → `docs/ARCHITECTURE.md`
- Setup/dependencies/storage → `docs/DEVELOPMENT.md`
- User workflow → `docs/USER_GUIDE.md`
- Privacy behavior → `docs/PRIVACY.md`
- Accessibility behavior → `docs/ACCESSIBILITY.md`
- Test strategy → `docs/TESTING.md`
- Troubleshooting behavior → `docs/TROUBLESHOOTING.md`
- Release behavior → `docs/RELEASING.md`
- Planned/completed scope → `docs/ROADMAP.md`
- Released behavior → `CHANGELOG.md`

## Dictionary contributions

Dictionary changes must be reviewed carefully because false positives and false negatives directly affect user experience.

When adding bundled words:

- Use lowercase normalized entries.
- Avoid obvious misspellings.
- Prefer broadly useful words over highly personal vocabulary.
- Add tests when an entry fixes a known issue.
- Keep apostrophes normalized to the straight apostrophe form in dictionary data.
- Check both base and extension data to avoid accidental duplicate maintenance.

When changing approximate frequency ranks:

- Lower rank means stronger preference.
- Add a deterministic ranking test when ordering is important.
- Do not claim the compact rank table is a comprehensive linguistic frequency corpus.

## Personal dictionary format contributions

`PersonalDictionaryCodec` defines a user-transfer format, so changes require extra care.

- Keep exports versioned.
- Preserve readability of existing version-1 data unless a documented migration strategy says otherwise.
- Never silently reinterpret an unsupported version.
- Keep output deterministic (normalized, deduplicated, sorted).
- Reject malformed entries rather than silently storing ambiguous data.
- Update `docs/API.md`, `docs/USER_GUIDE.md`, `docs/PRIVACY.md`, and `CHANGELOG.md` for format changes.

## Persistence contributions

`DictionaryPreferences` currently stores personal words and the suggestion-count preference via `shared_preferences`.

When modifying persistence:

- Add mocked persistence tests.
- Keep editor text unpersisted unless a separately reviewed feature explicitly changes that design.
- Use versioned keys or documented migrations when data meaning changes.
- Avoid writing success UI before the storage operation succeeds.
- Preserve rollback/no-false-success behavior for user-visible saves.

## Security and privacy

For security-sensitive issues, follow [SECURITY.md](SECURITY.md) instead of opening a normal public issue with exploit details.

Any proposed synchronization, account system, cloud spelling/grammar API, analytics, remote logging, crash reporting, or editor-text persistence requires explicit privacy and security review before implementation.

## License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).
