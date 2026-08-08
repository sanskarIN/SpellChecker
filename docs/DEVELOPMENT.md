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

Runtime dependencies remain intentionally small:

- Flutter SDK.
- `shared_preferences` for device-local personal dictionary and suggestion-count persistence.

V1.2 adds no new runtime dependency. Inline highlighting, shortcuts, replace-all, and correction undo are implemented with Flutter/Dart APIs and project code.

## Run the web app

```bash
flutter run -d chrome
```

## Generate additional Flutter host platforms

The repository commits the web host and portable Dart/Flutter source. Generate additional local platform runners with your installed Flutter version only when needed.

Review generated files before committing them because platform templates can vary by Flutter version and may include machine- or signing-specific configuration.

## Important directories

### `lib/core`

Reusable spelling/correction algorithms, value objects, statistics, and dictionary import/export codec.

Important V1.2 file:

- `text_correction.dart` — validates checked source ranges and performs deterministic single/replace-all mutation without Flutter widget dependencies.

Core changes should normally have focused unit tests.

### `lib/data`

Bundled base/extension dictionary data and approximate frequency ranks.

### `lib/features/editor`

Flutter editor interaction code:

- `spell_checker_page.dart` — page state, check/active-issue navigation, correction undo, results workflow, storage-warning state, keyboard shortcuts.
- `spell_check_editing_controller.dart` — inline checked-issue text styling.
- `dictionary_manager_dialog.dart` — persistent personal dictionary/preferences UI.

### `lib/storage`

Application-local persistence adapters. `DictionaryPreferences` owns `shared_preferences` integration.

### `test`

Unit, persistence, codec, controller, and widget tests.

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

Run a focused V1.2 test:

```bash
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
flutter test test/widget_test.dart
```

## Changing correction behavior

Correction mutation belongs in `lib/core/text_correction.dart`, not directly in widgets.

Keep these invariants:

1. Never trust a `SpellIssue` offset after text may have changed.
2. Verify the current substring still equals `issue.word` before mutation.
3. Apply replace-all ranges from highest start offset to lowest.
4. Preserve capitalization independently per occurrence.
5. Return the number of actual replacements.
6. Return a caret offset that is inside the resulting string.
7. Do not partially mutate when a single targeted issue is stale.

Add or update `test/text_correction_test.dart` for deterministic changes.

## Changing correction undo

The application-level correction undo stack lives in `SpellCheckerPage`; it is intentionally not part of `TextCorrection`.

Current design:

- Stores pre-correction `TextEditingValue` snapshots.
- Maximum depth: 20 entries.
- Single replacement = one undo entry.
- Replace-all = one undo entry.
- Manual user text edits clear the correction stack.
- Stack is memory-only and never persisted.

If changing this model, add widget tests and update privacy/user/architecture documentation. Do not silently turn spelling-specific undo into document persistence.

## Changing inline highlighting

`SpellCheckEditingController` extends `TextEditingController` and overrides `buildTextSpan`.

Rules:

- A checked range must still match the current text before styling.
- Invalid/stale/overlapping ranges must be skipped safely.
- Non-active issues receive wavy underlining.
- The active issue may receive additional foreground/background emphasis.
- Visual styling cannot be the only indication that an issue exists; the Results panel/semantics must remain available.
- Manual text changes should clear checked issue styling until the next spelling check.

Add/update `test/spell_check_editing_controller_test.dart` for controller behavior.

## Changing active issue navigation

Active issue state is shared across:

- Results header.
- Results issue card selected state.
- Inline active highlight.
- Editor selection.
- Results auto-scroll.

Navigation currently wraps at both ends.

Keyboard contracts:

- `F7`: next issue.
- `Shift+F7`: previous issue.
- `Ctrl+Enter`: run spelling check.
- `Command+Enter`: run spelling check.

Avoid introducing focus traps. When adding shortcuts, consider platform conflicts and preserve standard text-editing shortcuts.

## Widget test viewport behavior

V1.2 issue cards contain more actions and can extend below Flutter test's default viewport. Tests that tap an issue action should make the intended control visible first when necessary:

```dart
final control = find.text('Save word');
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

This tests the real scrollable interaction instead of relying on a particular test-surface height.

## Adding bundled dictionary words

Dictionary data is split across:

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

Current ordering:

1. Edit distance.
2. First-character agreement.
3. Approximate frequency rank.
4. Candidate length.
5. Alphabetical order.

Add tests covering candidate inclusion, deterministic ordering where relevant, frequency ties, transposition, thresholds, and suffix-preserving suggestions.

## Changing contraction or possessive behavior

Regular apostrophe suffix handling lives in `SpellCheckerEngine`. Preserve direct dictionary lookup before stem-based recognition so curated irregular forms remain authoritative.

Add tests for accepted forms and correction output.

## Changing personal-dictionary import/export

The public format is implemented by `PersonalDictionaryCodec`.

Rules:

- Keep exports versioned.
- Do not silently accept unsupported versions.
- Preserve deterministic sorted output.
- Reject malformed word entries rather than storing ambiguous values.
- Add migration logic before changing the meaning of an existing version.

## Changing persistence

`DictionaryPreferences` currently stores:

- Normalized personal words.
- Suggestion-count preference.

Persistence changes must include tests using `SharedPreferences.setMockInitialValues` so CI remains deterministic.

Do not persist editor text, checked issues, active issue selection, or correction undo snapshots unless the privacy model/user experience is explicitly redesigned and documented first.

## Changing UI behavior

Keep core spelling and text-correction logic out of widgets. UI code should call core APIs and persistence adapters.

For user-visible editor changes:

- Add widget tests when deterministic.
- Check narrow and wide layouts.
- Check keyboard-only use.
- Check active issue/results synchronization.
- Check stale range behavior.
- Check semantics and text scaling.
- Preserve session spelling when persistence is unavailable.

Widget tests that touch preferences must initialize mock shared preferences before pumping the app.

## Privacy review

Any proposed network dependency, analytics feature, crash reporting, telemetry, synchronization, accounts, editor-text persistence, or persistent correction history requires explicit privacy review and an update to `docs/PRIVACY.md` before merge.

## Updating version numbers

Update:

- `version` in `pubspec.yaml`.
- `CHANGELOG.md`.
- README current release.
- About-dialog version text.
- Roadmap status when a milestone completes.
- Relevant API/user/development/testing/accessibility/privacy documentation.

Follow [RELEASING.md](RELEASING.md) for tagged releases.
