# Development Guide

This is the current development guide for SpellChecker. Historical release engineering notes are indexed in [Release history](RELEASE_HISTORY.md).

For complete executable/release-artifact instructions—including platform build commands, packaging, signing boundaries, verification, and the machine-checked tracked-file inventory—see [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Prerequisites

Install:

- Git;
- Flutter stable;
- Dart compatible with `>=3.8.0 <4.0.0` (normally supplied by Flutter);
- at least one usable Flutter target for local application work;
- the platform toolchain for every additional committed target you plan to run or build.

Verify:

```bash
flutter doctor
flutter --version
dart --version
```

For platform/executable work, prefer `flutter doctor -v` and verify the specific target toolchain before building or changing runner files.

## Clone and resolve dependencies

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
```

Runtime dependencies are intentionally small:

- Flutter SDK;
- `shared_preferences`.

Do not add a runtime dependency when a small deterministic implementation is sufficient. Any dependency that introduces networking, telemetry, account identity, native permissions, or sensitive-data handling requires explicit architecture/privacy/security review.

## Run a committed target

Choose any committed target available on the current development machine. For example:

```bash
flutter devices
flutter run -d chrome
```

The repository commits official Flutter runners for Android, iOS, Linux, macOS, Web, and Windows. Target-specific run commands and toolchain requirements are documented in [Getting started](GETTING_STARTED.md), [Platform support](PLATFORM_SUPPORT.md), and [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Repository layout

```text
.github/                  GitHub Actions, funding, collaboration templates
lib/app.dart              Material application/theme root
lib/main.dart             application entry point
lib/spell_checker.dart    public core spelling barrel
lib/language.dart         public language barrel
lib/writing.dart          public writing barrel
lib/core/                 spelling/language/correction/codec/statistics primitives
lib/data/                 bundled dictionary/frequency data
lib/features/editor/      Flutter editor and dialogs
lib/storage/              application-local preference integration
lib/writing/              writing analyzer, rules, corrections, review helpers
test/                     regression/unit/widget/persistence/Unicode/stress tests
tool/                     deterministic benchmark tooling
android/                  committed Android Flutter runner
ios/                      committed iOS Flutter runner
linux/                    committed Linux Flutter runner
macos/                    committed macOS Flutter runner
web/                      committed Flutter web host
windows/                  committed Windows Flutter runner
docs/                     current documentation and historical release records
```

Every tracked path is classified in the marked inventory inside [Executable builds and packaging](EXECUTABLE_BUILDS.md). `test/documentation_repository_test.dart` compares that inventory to `git ls-files`, so adding, deleting, or renaming a committed file requires updating the inventory in the same change.

## Architectural boundaries

### `lib/core`

Keep reusable non-widget spelling/language primitives here. Core code should not depend on Flutter widgets or preference storage.

Current responsibilities include:

- language packs/registry;
- spelling engine and reports;
- issues/suggestions/ranking;
- unrestricted Unicode-scalar Damerau-Levenshtein distance;
- safe text correction;
- personal-dictionary and Portable-settings codecs;
- text statistics.

### `lib/writing`

Keep reusable deterministic writing analysis here. This layer owns:

- `WritingRule` plugin contract;
- `WritingAnalyzer` and result diagnostics;
- ten built-in rules;
- writing correction;
- review query/presets/categories;
- metadata-only diagnostic summaries.

Do not put Flutter widgets or `shared_preferences` logic in this layer.

### `lib/features/editor`

Application workflow belongs here: editor state, checked-result lifecycle, keyboard shortcuts, dialogs, result presentation, persistence calls, and bounded correction undo.

### `lib/storage`

This layer adapts application preferences to `shared_preferences`. Keep the reusable public spelling/writing APIs independent from this adapter.

## Public API policy

A Dart type/function is part of the supported public surface when exported from one of:

```text
package:spellchecker/spell_checker.dart
package:spellchecker/language.dart
package:spellchecker/writing.dart
```

Before changing an exported signature or semantic contract:

1. review source compatibility;
2. review persisted/serialized compatibility where relevant;
3. add/update tests;
4. update [API](API.md) and [Examples](EXAMPLES.md);
5. update CHANGELOG/release records when user/developer visible.

Internal application classes should not be documented as public APIs unless they are intentionally exported.

## Unicode model

SpellChecker deliberately uses two coordinate concepts.

### Source ranges: UTF-16

`SpellIssue.start/end` and `WritingIssue.start/end` are Dart string/Flutter editing offsets measured in UTF-16 code units.

For a current writing finding:

```dart
text.substring(issue.start, issue.end) == issue.originalText
```

For a current spelling issue:

```dart
text.substring(issue.start, issue.end) == issue.word
```

### Scalar operations

Edit distance, suggestion length filtering, and selected casing logic use Unicode scalar values (`String.runes`) to avoid splitting non-BMP characters.

When changing Unicode-sensitive behavior, include non-BMP and/or decomposed combining-mark coverage as relevant.

## Spelling engine invariants

Changes to `SpellCheckerEngine` should preserve:

- selected language-pack ownership;
- deterministic token/source ordering;
- personal/ignored word normalization;
- suggestion cache invalidation when personal vocabulary changes;
- deterministic ranker plus lexical fallback;
- scalar-consistent candidate length/distance;
- bounded `analyze()` semantics;
- no suggestion generation for the overflow issue used only to prove truncation;
- compatibility of unbounded `check()`.

A bounded spelling report reaches `truncated == true` only after another unknown word exists beyond the retained limit.

## Suggestion ranker changes

`SpellSuggestionRanker` receives already-eligible candidates. Rankers must be deterministic and should be side-effect-free. The engine applies a final lexical word tie-break when the strategy returns zero.

When changing the default ranker, add deterministic ordering tests including ties, custom dictionaries, personal candidates, frequency metadata, and Unicode cases.

## Text correction invariants

`TextCorrection` must never blindly mutate stale ranges.

Before applying a spelling edit, verify source ownership. Replace-all must operate only on supplied matching current `SpellIssue` objects and apply edits from end to start.

Common casing preservation must remain Unicode-scalar-safe.

## Writing-rule development

See [Writing rules](WRITING_RULES.md) for the complete plugin/change checklist.

Every new built-in rule needs:

- stable unique ID;
- user-readable metadata;
- explicit language support;
- exact UTF-16 source ownership;
- category/severity decision;
- explicit advisory versus automatic-replacement decision;
- interaction tests with other automatic rules;
- registry/default compatibility tests;
- persistence/Portable-settings compatibility review;
- bounded totals/review/filter/diagnostic tests where relevant;
- widget workflow and undo coverage;
- Unicode/stress coverage where relevant.

Do not add a guessed automatic fix for a deterministically detectable but ambiguously correct condition.

## Writing analyzer invariants

`WritingAnalyzer` rejects duplicate configured rule IDs.

Unbounded findings are deterministically ordered by source position, severity ordering, then rule ID. Bounded analysis must retain the same globally earliest prefix even when later rules yield earlier positions.

Analyzer-produced results count exact overall/per-rule totals even when retained findings are bounded. Exact totals do not create correction authority for uncaptured findings.

## Writing correction invariants

Individual correction requires a non-null replacement and exact current source ownership.

Batch correction:

1. sorts by start/end/rule ID;
2. skips advisory/stale/invalid findings;
3. accepts the earliest deterministic non-overlapping candidates;
4. skips later overlaps;
5. mutates accepted edits from end to start;
6. reports applied/skipped counts.

Filtered UI batch actions must reuse this same algorithm rather than implementing a second conflict policy.

## Preference compatibility

Per-language writing-rule persistence has three states:

- missing key -> registry defaults;
- explicit non-empty set -> exactly stored supported IDs;
- explicit empty set -> all rules disabled.

Do not collapse an explicit empty set to defaults.

**Reset rules to defaults** removes the override rather than saving today's default IDs.

Personal vocabulary is also language-specific. `en-US` legacy personal-word migration/synchronization must remain covered when preference storage behavior changes.

Preference write APIs must treat an unsuccessful `shared_preferences` write/remove result as failure and must not falsely report durability.

See [Configuration](CONFIGURATION.md).

## Transfer-format compatibility

### Personal dictionaries

Current language-aware format: version 2. Legacy version 1, JSON arrays, and compatible plain lists remain readable.

Strictly reject malformed metadata/invalid entries rather than silently importing ambiguous data.

### Portable settings

Current format:

```text
format: spellchecker-settings
version: 1
```

Portable settings excludes personal vocabulary and document/session data. Missing override key and explicit empty override are different semantics.

Changing a versioned format requires compatibility/migration tests and updates to API/configuration/user docs.

## Application state invariants

Editor/application changes should preserve:

- preference restoration before dependent controls/actions claim durability;
- checked spelling results refresh after restored preferences when appropriate;
- text edits invalidate stale spelling snapshots;
- language switching clears stale engine/session/correction state and restores language-specific durable settings;
- storage errors remain visible/truthful;
- correction undo stores pre-correction `TextEditingValue` snapshots and stays bounded;
- Writing insights operates on its current dialog analysis snapshot;
- captured-only limited-result actions do not imply whole-document authority.

## Keyboard/accessibility changes

Primary shortcuts are documented in [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md). Any shortcut change should update tooltips, user/accessibility documentation, and widget tests in the same PR.

Do not remove visible pointer/touch alternatives merely because a shortcut exists.

Semantics/live-region changes should be tested using Flutter semantics/widget tooling where possible.

## Platform runner and executable changes

The repository currently commits Android, iOS, Linux, macOS, Web, and Windows runners. When changing one of those runners or adding another officially supported target:

1. follow the target prerequisites and packaging guidance in [Executable builds and packaging](EXECUTABLE_BUILDS.md);
2. review generated/native changes rather than accepting tool output blindly;
3. preserve stable application identifiers/metadata unless a migration is intentional;
4. keep signing credentials out of Git;
5. keep target build CI and artifact handling aligned with support claims;
6. validate target-specific storage, clipboard, accessibility, keyboard, and startup behavior;
7. update the tracked-file inventory for every committed path addition/deletion/rename;
8. update [Platform support](PLATFORM_SUPPORT.md), [Releasing](RELEASING.md), privacy/security docs, README, and other affected current-state docs.

A locally modified/generated runner is not proof of distribution-ready signed support by itself.

## Documentation changes

Use [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md). Current-state behavior belongs in evergreen docs; version-specific design/audit evidence belongs in historical files linked from [Release history](RELEASE_HISTORY.md).

Any tracked-file addition/deletion/rename must also update the machine-checked inventory in [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Development quality gates

After resolving dependencies, the canonical repository gate is:

```bash
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

To apply formatting locally:

```bash
dart format lib test tool
```

Run benchmark smoke for changes affecting analysis/benchmark behavior:

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

Build any committed release target whose toolchain is available on the current machine. Common release commands are:

```bash
flutter build web --release
flutter build apk --release
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

For iOS compilation without distribution signing:

```bash
flutter build ios --release --no-codesign
```

The complete build/package verification procedure, host requirements, signing boundaries, and output paths are in [Executable builds and packaging](EXECUTABLE_BUILDS.md).

The primary CI workflow runs dependency resolution, formatting, analyzer, complete tests, and benchmark smoke. The focused documentation/metadata workflow runs the repository documentation audit on relevant changes. Cross-platform CI repeats source quality gates and builds all six committed targets, while the release workflow mirrors those six target builds and uploads release-validation artifacts.

## Focused testing

Use focused suites while developing, then run the full suite before merge. Examples:

```bash
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
flutter test test/language_pack_test.dart
flutter test test/writing_rules_test.dart
flutter test test/writing_correction_test.dart
flutter test test/writing_preferences_test.dart
flutter test test/widget_test.dart
```

Exact focused files evolve with the project; [Testing](TESTING.md) is the current index.

For documentation/build-inventory work, `test/documentation_repository_test.dart` is a useful focused check, but the full suite remains required before release.

## Benchmark development

The benchmark under `tool/` uses generated synthetic text and deterministic scenario metadata. It is a developer measurement tool, not telemetry and not a user-data profiler.

Do not turn benchmark timings into universal pass/fail thresholds across unrelated hardware/toolchains. Correctness smoke should assert executable/report invariants, not a fixed speed.

## Dependency and privacy review

Before adding any new dependency or external integration, answer:

- Does this add a network request?
- Could editor text/personal vocabulary/findings leave the device?
- Does it add analytics/telemetry/ads/account identity?
- Does it request platform permissions?
- Does it store new sensitive data?
- Is it necessary versus a small local implementation?
- What security/privacy/docs/tests are required?

Do not merge a new sensitive-data path without updating [Privacy](PRIVACY.md) and [Security](../SECURITY.md).

## Pull requests

Keep commits reviewable and focused. A complete PR should include implementation, regression coverage, and documentation updates for changed behavior.

Before merge, confirm:

- format/analyze/full tests pass;
- benchmark smoke passes when required;
- public API/persistence/source-range compatibility is reviewed;
- privacy/security implications are documented;
- current docs match code;
- the executable-build tracked-file inventory matches `git ls-files`;
- platform/build changes update actual target CI/artifact documentation;
- historical records were not rewritten merely to match a later release.

## Related documentation

- [Architecture](ARCHITECTURE.md)
- [Testing](TESTING.md)
- [API](API.md)
- [Writing rules](WRITING_RULES.md)
- [Language packs](LANGUAGE_PACKS.md)
- [Configuration](CONFIGURATION.md)
- [Executable builds and packaging](EXECUTABLE_BUILDS.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Releasing](RELEASING.md)
