# Contributing to SpellChecker

Thanks for helping improve SpellChecker.

## Before you start

1. Search existing issues and pull requests to avoid duplicate work.
2. For a substantial feature or behavior change, open an issue first so the approach can be discussed.
3. Keep pull requests focused on one change when possible.

## Development setup

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
flutter analyze
flutter test
flutter run
```

## Branches and commits

Use a descriptive branch name such as `feature/spelling-suggestions` or `fix/tokenization-apostrophes`.

Write concise commit messages that describe the change, for example:

```text
Add ranked spelling suggestions
Fix apostrophe tokenization
```

## Pull requests

A good pull request should:

- Explain what changed and why.
- Include tests for behavior changes when practical.
- Pass `flutter analyze` and `flutter test`.
- Avoid unrelated formatting or refactoring.
- Update documentation when user-facing behavior changes.

## Code style

Use standard Dart and Flutter formatting:

```bash
dart format lib test
flutter analyze
```

Prefer small, testable classes and keep spell-checking logic independent from presentation code.

## Bug reports

Please include:

- A short description of the problem.
- Steps to reproduce it.
- Expected and actual behavior.
- Flutter/Dart version and platform when relevant.

## Feature requests

Describe the writing problem the feature solves, the expected behavior, and any alternatives you considered.

## Community expectations

Be respectful, constructive, and welcoming. See [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).
