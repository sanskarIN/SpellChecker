# Getting Started

This guide takes a new user or contributor from a clean checkout to a running SpellChecker instance and a verified development environment.

## What SpellChecker is

SpellChecker is a Flutter application and reusable Dart codebase for local spelling and deterministic writing analysis. The bundled application does not send editor text to a remote spelling or grammar service. It supports English (US) and English (UK), per-language personal dictionaries, local writing-rule preferences, bounded large-document review, portable non-document settings, and ten deterministic built-in writing rules.

Current package version: `2.16.0+21`.

## Prerequisites

Install:

- Git.
- Flutter stable.
- A Dart SDK compatible with `>=3.8.0 <4.0.0` (Flutter supplies Dart).
- A browser supported by Flutter when running the committed web host.
- Platform-specific Flutter tooling only if you choose to generate/run an additional native target locally.

Verify your toolchain:

```bash
flutter doctor
flutter --version
dart --version
```

## Clone and install dependencies

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
```

The runtime dependency set is intentionally small:

- Flutter SDK.
- `shared_preferences` for local preference storage.

No runtime package is used for telemetry, cloud grammar, remote document analysis, accounts, or synchronization.

## Run the application

The repository commits a Flutter web host, so the most direct development target is Chrome:

```bash
flutter run -d chrome
```

If Flutter reports that Chrome is unavailable, use `flutter devices` to see available local targets. Additional native runners are not committed in the repository; see [Platform support](PLATFORM_SUPPORT.md).

## Perform your first spelling check

1. Open SpellChecker.
2. Keep **English (US)** selected or choose **English (UK)** from the language selector.
3. Enter synthetic text such as `Helo world`.
4. Select **Check spelling** or press `Ctrl+Enter` / `Command+Enter`.
5. Review the inline underline and the Results panel.
6. Choose a suggestion to replace one occurrence, or use **Replace all…** when multiple checked occurrences of the same unknown word exist.
7. Use `F7` and `Shift+F7` to move among spelling issues.

SpellChecker treats checked issues as a snapshot of the source text. Editing the text invalidates stale spelling results rather than applying corrections to old offsets.

## Perform your first writing review

Open **Writing insights** from the app bar or press `Ctrl+Shift+Enter` / `Command+Shift+Enter`.

Try text such as:

```text
hello  world!! This is is a sample .
```

Depending on the text, Writing insights can report repeated words, capitalization, repeated spaces, punctuation spacing, missing punctuation spacing, trailing whitespace, repeated punctuation, and advisory unmatched delimiters.

The current built-in rule catalogue contains ten rules. Rules that have a deterministic replacement can expose **Apply safe fix** and participate in batch correction. Structural unmatched-parenthesis, square-bracket, and curly-brace findings are advisory and do not automatically rewrite the text.

Inside Writing insights:

- `Ctrl+F` / `Command+F` focuses review search.
- Search, category filters, presets, and **Automatic fixes only** are temporary.
- The first Escape clears an active transient query/filter state.
- Escape closes the dialog when the transient query is already empty.
- Rule enable/disable choices are durable per language.
- **Reset rules to defaults** clears the selected language's explicit rule override.

## Personal dictionary and ignored words

Use **Save word** on an issue to add the normalized word to the selected language's persistent personal dictionary.

Use **Ignore once** to suppress a word only for the current application session. Ignored words are not persisted and are not included in Portable settings or personal-dictionary exports.

Open **Manage personal dictionary** from the app bar to review saved words and set the suggestion count. The current suggestion limit is 1–10, with a default of 5.

Personal vocabulary is isolated by language. Saving a word in `en-US` does not automatically save it in `en-GB`.

## Portable settings

The **Portable settings** dialog exports/copies preferences only. It includes:

- selected language;
- suggestion limit;
- explicit per-language writing-rule overrides.

It deliberately excludes:

- editor text;
- personal vocabulary;
- ignored session words;
- spelling findings;
- writing findings;
- correction history;
- transient Writing insights search/filter/preset state.

See [Configuration and local data](CONFIGURATION.md) for the exact format and semantics.

## Personal dictionary transfer

The dictionary manager supports language-aware personal-dictionary import/export. Current language-aware documents use format version 2 and carry the language identifier. Legacy version 1 and compatible plain/array forms remain readable for backward compatibility.

Do not confuse personal-dictionary transfer with Portable settings: they intentionally carry different data.

## Run the project quality gates

After dependency resolution, run the same core checks used by CI:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

Run the deterministic benchmark smoke command when changing analysis behavior or benchmark tooling:

```bash
dart run tool/benchmark_large_document.dart \
  --repeats=4 \
  --warmup=0 \
  --iterations=1 \
  --spelling-limit=2 \
  --writing-limit=5 \
  --suggestions=0 \
  --language=en-US \
  --json
```

For broader benchmark guidance, see [Performance](PERFORMANCE.md).

## Build the web release target

```bash
flutter build web --release
```

The generated output is written to `build/web`. The repository's release workflow performs formatting, analysis, the complete Flutter test suite, benchmark smoke, and a release web build before uploading the web artifact.

## Use the library APIs

Core spelling APIs:

```dart
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine();
final issues = engine.check('Helo world');
for (final issue in issues) {
  print('${issue.word}: ${issue.suggestions}');
}
```

Writing APIs:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

final result = WritingAnalyzer().analyze(
  'hello  world',
  languagePack: SpellLanguageRegistry.englishUs,
);

for (final issue in result.issues) {
  print('${issue.ruleId}: ${issue.message}');
}
```

See [Library examples](EXAMPLES.md) and [Public API](API.md) for complete examples and contracts.

## Where to go next

- Application behavior: [User guide](USER_GUIDE.md).
- Current capabilities and limitations: [Feature reference](FEATURES.md).
- Settings/import/export: [Configuration](CONFIGURATION.md).
- Public APIs: [API](API.md).
- Writing rule catalogue: [Writing rules](WRITING_RULES.md).
- Architecture: [Architecture](ARCHITECTURE.md).
- Development and tests: [Development](DEVELOPMENT.md) and [Testing](TESTING.md).
- Problems: [Troubleshooting](TROUBLESHOOTING.md) and [Support](../SUPPORT.md).
