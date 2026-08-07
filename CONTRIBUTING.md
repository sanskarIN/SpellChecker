# Contributing to SpellChecker

Thank you for helping improve SpellChecker. This guide defines the contribution workflow used by the project.

## Code of Conduct

Participation in the project is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before starting

1. Search existing issues and pull requests for related work.
2. For large features, architecture changes, or public API changes, open an issue before implementation.
3. Keep each pull request focused on one logical change.
4. Do not include credentials, private keys, personal data, or generated build outputs.

## Development requirements

- Flutter stable
- Dart SDK compatible with `pubspec.yaml`
- Git

Verify your environment:

```bash
flutter doctor
flutter --version
```

## Setup

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For a complete local setup and directory explanation, read [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Branch naming

Use short descriptive branch names:

```text
feature/persistent-dictionary
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

Run formatting before committing:

```bash
dart format lib test
```

Then run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

### Dart and Flutter guidance

- Prefer immutable values and `const` constructors where practical.
- Keep spelling logic independent of widgets.
- Keep UI state local unless cross-feature state requires a dedicated abstraction.
- Avoid adding a package when a small standard-library implementation is sufficient.
- Document public APIs and behavior changes.
- Treat user text as private data.
- Do not add telemetry or network transmission without an explicit design discussion and privacy documentation update.

## Tests

Behavior changes should include tests. At minimum:

- Core spelling changes: unit tests.
- Edit-distance/ranking changes: focused algorithm tests.
- User workflow changes: widget tests when practical.
- Bug fixes: regression test reproducing the previous failure.

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

Use the repository pull request template and complete every relevant section.

## Documentation changes

Update documentation when changing:

- Public APIs → `docs/API.md`
- Internal architecture → `docs/ARCHITECTURE.md`
- Setup/dependencies → `docs/DEVELOPMENT.md`
- User workflow → `docs/USER_GUIDE.md`
- Privacy behavior → `docs/PRIVACY.md`
- Release behavior → `docs/RELEASING.md`
- Planned scope → `docs/ROADMAP.md`

## Dictionary contributions

Dictionary changes must be reviewed carefully because false positives and false negatives directly affect user experience.

When adding words:

- Use lowercase normalized entries.
- Avoid adding obvious misspellings.
- Prefer broadly useful words over highly personal vocabulary.
- Add tests when the entry fixes a known issue.
- Keep apostrophes normalized to the straight apostrophe form in dictionary data.

## Security

For security-sensitive issues, follow [SECURITY.md](SECURITY.md) instead of opening a normal public issue with exploit details.

## License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).
