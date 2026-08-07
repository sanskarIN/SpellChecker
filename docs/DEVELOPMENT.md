# Development Guide

## Prerequisites

Install:

- Git
- Flutter stable
- Platform tooling required by your chosen Flutter target

Verify:

```bash
flutter doctor
flutter --version
dart --version
```

## Clone

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
```

## Dependencies

```bash
flutter pub get
```

SpellChecker intentionally has a small dependency graph. Runtime dependencies currently consist only of Flutter SDK libraries.

## Run the web app

```bash
flutter run -d chrome
```

## Generate additional Flutter host platforms

The repository commits the web host and the portable Dart/Flutter application source. To generate additional local platform runners with your installed Flutter version, use Flutter's project tooling from the repository root, selecting only the platforms you need.

Review generated files before committing them because platform templates vary by Flutter version and may include machine- or signing-specific configuration.

## Important directories

### `lib/core`

Pure/reusable spelling logic. Changes should normally have unit tests.

### `lib/data`

Bundled dictionary data.

### `lib/features`

Flutter UI and interaction code.

### `test`

Unit and widget tests.

### `docs`

Project documentation.

### `.github`

CI/release workflows and collaboration templates.

## Development commands

Format:

```bash
dart format lib test
```

Check formatting without modifying files:

```bash
dart format --output=none --set-exit-if-changed lib test
```

Analyze:

```bash
flutter analyze
```

Test:

```bash
flutter test
```

Build web:

```bash
flutter build web --release
```

## Adding a dictionary word

Edit `lib/data/english_dictionary.dart`.

Requirements:

- Lowercase normalized spelling.
- No duplicate entry.
- Straight apostrophe for contractions.
- Add a regression test if the entry resolves a reported bug.

## Changing suggestion ranking

Ranking changes belong in `lib/core/spell_checker_engine.dart` and/or `lib/core/edit_distance.dart`.

Add tests covering:

- Expected candidate inclusion.
- Ordering where ordering matters.
- Transposition behavior.
- Threshold behavior.

## Changing UI behavior

Keep core spelling logic out of widget code. UI code should call the engine rather than reimplementing dictionary matching.

Add widget tests for important interaction changes.

## Privacy review

Any proposed network dependency, persistent storage, analytics feature, crash reporting service, or telemetry requires an explicit privacy review and corresponding update to `docs/PRIVACY.md` before merge.

## Updating version numbers

Update the `version` field in `pubspec.yaml` and add a changelog entry. Follow [RELEASING.md](RELEASING.md) for tagged releases.
