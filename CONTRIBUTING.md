# Contributing to SpellChecker

Thank you for helping improve SpellChecker. This guide describes the current contribution workflow and compatibility/safety expectations for `2.16.0+21`.

For project behavior, start with the [complete documentation hub](docs/README.md). Historical release-specific contributor notes are preserved through [Release history](docs/RELEASE_HISTORY.md), not mixed into this current guide.

## Code of Conduct

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before starting

Search existing issues and pull requests for related work.

Open an issue/design discussion before large changes involving:

- public API compatibility;
- architecture/layer boundaries;
- persisted preference/key semantics;
- transfer-format versions;
- built-in language packs/dictionary data;
- writing-rule IDs/default registry;
- correction conflict/source-range behavior;
- keyboard/accessibility contracts;
- platform runners/releases;
- runtime networking/dependencies;
- privacy/security-sensitive behavior.

Keep a pull request focused on one logical goal even when that goal requires implementation, tests, and documentation across several files.

Never commit credentials, tokens, signing keys, provisioning profiles, private documents, sensitive personal dictionary exports, or unrelated generated build output.

## Development requirements

- Git;
- Flutter stable;
- Dart compatible with `>=3.8.0 <4.0.0`;
- Chrome or another suitable Flutter development target.

Verify:

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
flutter run -d chrome
```

See [Development](docs/DEVELOPMENT.md) and [Platform support](docs/PLATFORM_SUPPORT.md).

## Branch naming

Use a short descriptive name, for example:

```text
feature/new-writing-rule
feature/language-pack-example
fix/unicode-source-range
fix/settings-import-rollback
docs/api-reference
refactor/suggestion-ranking
```

## Commit messages

Prefer focused imperative messages. Conventional Commit prefixes are encouraged:

```text
feat: add deterministic writing rule
fix: preserve non-BMP source range
perf: reduce suggestion candidate work
test: cover settings rollback
docs: update language pack guide
chore: adjust CI configuration
```

Do not manufacture meaningless commits solely to increase commit count; each commit should remain reviewable and logically explainable.

## Required local quality gate

After `flutter pub get`:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

Apply formatting with:

```bash
dart format lib test tool
```

Run benchmark smoke for analysis/benchmark-sensitive work:

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

For release/web-build changes also run:

```bash
flutter build web --release
```

Do not suppress analyzer/test failures broadly for convenience. Fix the implementation/test/design mismatch.

## Public API boundaries

Supported reusable imports are:

```dart
import 'package:spellchecker/spell_checker.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';
```

Changes to exported names, signatures, nullability/defaults, validation, ordering, source-range semantics, or documented behavior require:

- compatibility review;
- regression tests;
- [API](docs/API.md) update;
- [Examples](docs/EXAMPLES.md) update when usage changes;
- changelog/release note when user/developer visible.

Application widgets and `DictionaryPreferences` are internal integration types unless intentionally exported.

## Unicode and source offsets

SpellChecker source ranges use Dart/Flutter UTF-16 code-unit offsets. Unicode-sensitive algorithms such as edit distance and selected casing/length operations use Unicode scalar values.

When changing Unicode-sensitive code:

- explicitly identify whether a value is UTF-16 offset or scalar count;
- include non-BMP regression coverage when single-code-unit mistakes are possible;
- include decomposed combining-mark coverage when normalization/boundaries are relevant;
- verify exact substring source ownership.

Do not call a source offset a rune/grapheme index.

## Spelling changes

Preserve:

- deterministic token/source order;
- language-pack normalization;
- personal/ignored word behavior;
- suggestion cache correctness;
- deterministic ranker + lexical fallback;
- scalar edit-distance/candidate-length consistency;
- safe represented-range correction;
- bounded spelling truncation proof semantics.

A bounded report is truncated only after an additional unknown word exists beyond the retained limit.

## Suggestion ranker changes

`SpellSuggestionRanker` should be deterministic and side-effect-free. The engine applies a final lexical tie-break for equal custom scores.

Test custom dictionaries, personal candidates, equal-score ties, Unicode candidates, frequency metadata, and suffix behavior as relevant.

## Writing-rule contributions

The current built-in/default registry contains exactly ten stable rules. See [Writing rules](docs/WRITING_RULES.md).

A new/changed built-in rule must define:

- stable unique ID;
- display name/description;
- category and severity;
- explicit language eligibility;
- exact UTF-16 source ownership;
- deterministic positive/negative scope;
- automatic replacement only when the edit is genuinely deterministic;
- interaction with every existing automatic rule;
- bounded/exact-total behavior;
- preference/default compatibility;
- Portable-settings compatibility;
- review filter/search/diagnostic behavior;
- widget/undo behavior;
- Unicode/stress coverage where relevant.

When detection is deterministic but correction is ambiguous, return an advisory finding (`replacement: null`) instead of guessing.

## Writing analyzer/correction changes

Preserve:

- duplicate rule-ID rejection;
- language/enabled filtering;
- deterministic global ordering;
- globally earliest bounded prefix;
- exact analyzer totals;
- captured-only correction authority;
- stale-source validation;
- deterministic start/end/rule-ID batch conflict selection;
- end-to-start mutation;
- applied/skipped accounting.

Do not create a separate weaker correction algorithm for filtered UI batches.

## Language-pack contributions

Before adding an official built-in language, review:

- dictionary/frequency source licensing;
- stable ID/code/region/display metadata;
- tokenization and personal-word validation;
- normalization/canonicalization;
- regional variants;
- suffix behavior;
- suggestion ranking/distance expectations;
- personal-dictionary transfer;
- preference isolation;
- writing-rule eligibility;
- Portable-settings validation;
- benchmark/UI integration;
- tests and documentation.

A custom `SpellLanguagePack` passed directly to reusable APIs is not automatically registered with the bundled UI/registry.

See [Language packs](docs/LANGUAGE_PACKS.md).

## Persistence and transfer changes

Current durable state includes:

```text
selected language
suggestion limit
per-language personal vocabulary
per-language explicit writing-rule IDs
```

Writing-rule preferences distinguish:

```text
missing key          -> defaults
non-empty stored set -> explicit enabled set
empty stored set     -> explicit disable-all
```

Do not collapse explicit empty into defaults.

Current transfer contracts:

```text
personal dictionary: language-aware version 2, legacy readers retained
Portable settings: spellchecker-settings version 1
```

Format/key migrations require strict validation, backward-compatibility tests, rollback/error behavior, and docs.

A failed `shared_preferences` write/remove must not be presented as successfully durable.

See [Configuration](docs/CONFIGURATION.md).

## Flutter UI contributions

Preserve:

- checked-result invalidation after manual text editing;
- loading/storage truthfulness;
- language switch state restoration/reset behavior;
- first-200 spelling/writing UI policies;
- captured-only limited actions;
- shared bounded correction undo;
- visible alternatives for keyboard shortcuts;
- wide/narrow layout usability;
- semantics/live-state feedback for important results/errors.

See [User guide](docs/USER_GUIDE.md), [Accessibility](docs/ACCESSIBILITY.md), and [Keyboard shortcuts](docs/KEYBOARD_SHORTCUTS.md).

## Widget tests

Do not use `pumpAndSettle()` when a test intentionally leaves a Future unresolved. Use controlled `pump()`/completion instead.

For lazy/off-screen dialog content, scroll/ensure visibility rather than assuming every item is mounted.

## Performance contributions

Use the deterministic benchmark for controlled comparisons. Do not add arbitrary universal millisecond CI thresholds across varying hosted hardware.

Performance improvements must preserve Unicode, source ownership, deterministic results, exact totals, and correction safety.

See [Performance](docs/PERFORMANCE.md).

## Privacy/security contributions

The current application is local-first and does not require a network analysis service, telemetry, accounts, or cloud document sync.

Any change introducing runtime networking, telemetry, logging upload, user identity, file/document persistence, new permissions, external model/dictionary downloads, dynamic plugin execution, or new sensitive durable data requires explicit review and documentation in the same PR.

Update [Privacy](docs/PRIVACY.md) and [Security](SECURITY.md) before merge when these boundaries change.

For a vulnerability, do not open a public issue; follow [SECURITY.md](SECURITY.md).

## Documentation contributions

Follow [Documentation maintenance](docs/DOCUMENTATION_MAINTENANCE.md).

Current behavior belongs in evergreen docs. Release-specific design/audit evidence belongs in historical files indexed by [Release history](docs/RELEASE_HISTORY.md).

When code changes current behavior, update the matching docs in the same PR rather than filing a follow-up documentation task.

## Tests

Use focused tests while iterating, but run the complete suite before merge. See [Testing](docs/TESTING.md) for component checklists and commands.

New regressions should normally include the narrowest test that fails before the fix and passes after it.

## Pull request description

A useful PR explains:

- problem/goal;
- solution/scope;
- compatibility/migration impact;
- privacy/security/platform/accessibility impact;
- tests run;
- docs updated;
- known limitations/non-goals.

Do not claim “zero bugs” or “all platforms supported” when the repository evidence does not establish that.

## Review checklist

Before requesting/merging review, confirm:

- format check passes;
- analyzer passes;
- complete test suite passes;
- benchmark smoke passes when applicable;
- web release build passes for release/build changes;
- public API compatibility reviewed;
- UTF-16/scalar semantics reviewed;
- persistence/transfer compatibility reviewed;
- writing-rule/language default compatibility reviewed;
- privacy/security/accessibility/platform impact reviewed;
- current docs updated;
- historical docs remain historically accurate;
- no secrets/private data/generated build artifacts added.

## Support and funding

Normal questions/bugs use [SUPPORT.md](SUPPORT.md). Security issues use [SECURITY.md](SECURITY.md).

Optional project funding is available at [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN), but funding does not affect whether issues, security reports, contributions, or feature proposals can be submitted/reviewed.
