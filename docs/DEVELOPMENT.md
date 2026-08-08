# Development Guide

## Prerequisites

Install:

- Git
- Flutter stable
- Dart SDK compatible with `pubspec.yaml` (currently `>=3.8.0 <4.0.0`)
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

Runtime dependencies are intentionally small:

- Flutter SDK.
- `shared_preferences` for device-local personal dictionary and suggestion-count persistence.

No runtime network, analytics, authentication, or cloud spelling dependency is used.

## Run the web app

```bash
flutter run -d chrome
```

## Generate additional Flutter host platforms

The repository commits the web host and portable Dart/Flutter application source. Generate additional local platform runners with your installed Flutter version only when needed.

Review generated files before committing them because platform templates can vary by Flutter version and may include machine- or signing-specific configuration.

## Important directories

### `lib/core`

Reusable spelling algorithms, value objects, statistics, and dictionary import/export codec. Core changes should normally have unit tests.

### `lib/data`

Bundled base/extension dictionary data and approximate frequency ranks.

### `lib/features`

Flutter UI and interaction code, including the editor and personal-dictionary manager.

### `lib/storage`

Application-local persistence adapters. `DictionaryPreferences` currently owns `shared_preferences` integration.

### `test`

Unit, persistence, codec, and widget tests.

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
flutter test --reporter expanded
```

Build web:

```bash
flutter build web --release
```

## Adding bundled dictionary words

V1.1 dictionary data is split across:

- `lib/data/english_dictionary.dart`
- `lib/data/english_dictionary_extension.dart`

Requirements:

- Lowercase normalized spelling.
- No duplicate within the edited const set.
- Straight apostrophe for directly stored contractions.
- Add a regression test when an entry resolves a reported bug.
- Prefer broadly useful vocabulary over project-specific one-off terms.

For common words used to break ranking ties, update `lib/data/english_word_frequencies.dart` with a lower rank meaning higher preference.

## Changing suggestion ranking

Ranking changes belong in `lib/core/spell_checker_engine.dart` and/or `lib/core/edit_distance.dart`.

Current ordering is:

1. Edit distance.
2. First-character agreement.
3. Approximate frequency rank.
4. Candidate length.
5. Alphabetical order.

Add tests covering:

- Expected candidate inclusion.
- Deterministic ordering where ordering matters.
- Frequency tie breaks.
- Transposition behavior.
- Threshold behavior.
- Suffix-preserving suggestions when applicable.

## Changing contraction or possessive behavior

Regular apostrophe suffix handling lives in `SpellCheckerEngine`. Preserve direct dictionary lookup before stem-based recognition so explicitly curated irregular forms remain authoritative.

Add tests for both accepted forms and correction output.

## Changing personal-dictionary import/export

The public format is implemented by `PersonalDictionaryCodec`.

Rules:

- Keep exports versioned.
- Do not silently accept unsupported versions.
- Preserve deterministic sorted output.
- Reject malformed word entries rather than storing ambiguous values.
- Add migration logic before changing the meaning of an existing version.

## Changing persistence

`DictionaryPreferences` is application-internal and currently stores:

- Normalized personal words.
- Suggestion-count preference.

Persistence changes must include tests using `SharedPreferences.setMockInitialValues` so CI remains deterministic.

Do not persist editor text unless the privacy model and user experience are explicitly redesigned and documented first.

## Changing UI behavior

Keep core spelling logic out of widget code. UI code should call the engine and persistence adapter rather than reimplement dictionary matching/storage rules.

Add widget tests for important interaction changes. Widget tests that touch preferences must initialize mock shared preferences before pumping the app.

## Privacy review

Any proposed network dependency, analytics feature, crash reporting service, telemetry, synchronization, accounts, or editor-text persistence requires explicit privacy review and a corresponding update to `docs/PRIVACY.md` before merge.

## Updating version numbers

Update the `version` field in `pubspec.yaml`, add a changelog entry, update user-facing About version text when needed, and follow [RELEASING.md](RELEASING.md) for tagged releases.
