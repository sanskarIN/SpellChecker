# Contributing to SpellChecker

Thank you for helping improve SpellChecker. This guide defines the contribution workflow and compatibility/safety boundaries for the current 2.x project.

## Code of Conduct

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Before starting

1. Search existing issues and pull requests for related work.
2. Open an issue before large architecture changes, public API changes, persisted-data/key changes, language-pack changes, writing-rule ID changes, keyboard-contract changes, or security/privacy-sensitive work.
3. Keep each pull request focused on one logical change.
4. Do not include credentials, private keys, personal data, real user documents, sensitive dictionary exports, or generated build outputs.
5. Preserve local-first runtime behavior unless a separately reviewed feature explicitly changes it.
6. Preserve keyboard/accessibility behavior when changing editor interactions.
7. Treat persisted rule IDs, language IDs, and transfer-format versions as compatibility contracts rather than internal implementation details.

## Development requirements

- Flutter stable.
- Dart SDK compatible with `pubspec.yaml` (currently `>=3.8.0 <4.0.0`).
- Git.

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
flutter analyze
flutter test --reporter expanded
flutter run -d chrome
```

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md).

## Branch naming

Use short descriptive names:

```text
feature/writing-rule-category
feature/language-pack-loader
fix/batch-overlap-caret
fix/rule-preference-migration
docs/update-user-guide
refactor/suggestion-ranking
```

## Commit messages

Prefer imperative, descriptive commit messages. Conventional Commit prefixes are encouraged:

```text
feat: persist writing rule choices per language
fix: skip stale overlapping writing fixes
test: cover batch correction undo grouping
docs: document writing shortcut
chore: update CI configuration
```

## Required local checks

```bash
dart format lib test
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --reporter expanded
```

Before release-sensitive work also run:

```bash
flutter build web --release
```

Fix analyzer/test failures in source or tests. Do not broadly suppress checks for convenience.

# Public API boundaries

Current reusable API barrels are:

```dart
import 'package:spellchecker/spell_checker.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';
```

Changes to exported names or documented semantics need API documentation, compatibility review, regression tests, and release notes.

Application widgets and `DictionaryPreferences` remain internal integration types even though their user-visible behavior is documented.

# Architecture rules

## Spelling logic

Keep tokenization, normalization, dictionary checks, suffix handling, and suggestion ranking out of Flutter widgets.

Language-specific behavior belongs behind `SpellLanguagePack`.

## Spelling correction

Spelling single/replace-all mutation belongs in `TextCorrection` or another reusable core abstraction.

Correction code must:

- Validate checked source ranges against current text.
- Refuse stale ranges safely.
- Apply replace-all from document end toward beginning.
- Preserve case per occurrence.
- Return deterministic mutation metadata.

## Writing rules

Writing-rule matching belongs in `WritingRule` implementations under `lib/writing/`, not in the dialog/page.

A rule must provide:

- Stable persistent ID.
- Clear display name/description.
- Explicit language eligibility.
- Side-effect-free deterministic analysis.
- Exact source ranges and `originalText`.
- Automatic replacement only when deterministic for the documented scope.

V2.1 persists rule IDs. Renaming a shipped ID therefore requires preference migration/compatibility handling and tests.

See [docs/WRITING_RULES.md](docs/WRITING_RULES.md).

## Writing correction

Never apply `WritingIssue.replacement` directly in widget code.

Use:

```dart
WritingCorrection.apply(...)
WritingCorrection.applyAll(...)
```

V2.1 batch invariants:

1. Deterministic candidate order: start, end, rule ID.
2. Advisory/no-replacement findings are skipped.
3. Invalid/stale findings are skipped.
4. The earliest accepted candidate wins an overlap; later overlaps are skipped.
5. Accepted edits are applied from end toward start.
6. Applied/skipped counts are reported.
7. One user-visible batch becomes one correction-history entry.

A new rule that can overlap another automatic rule needs interaction/batch tests.

## Inline highlighting

`SpellCheckEditingController` owns inline spelling styling only.

Checked highlight ranges must be validated against current text and cleared when manual edits invalidate the spelling snapshot.

Do not move dictionary/ranking/writing-rule logic into the controller.

## Shared correction undo

The page-level correction stack is bounded, memory-only, and shared across programmatic spelling/writing corrections.

One entry currently represents:

- One spelling replacement.
- One spelling replace-all.
- One individual writing safe fix.
- One writing batch safe-fix operation.

Manual typing clears the correction stack.

Do not persist editor/correction snapshots without explicit privacy/product redesign. Snapshots can contain full editor text.

## Active spelling issue state

Changes must keep these views coherent:

- Editor selection.
- Inline active styling.
- Results selected state.
- Previous/next controls.
- Results auto-scroll.

## Persistence

Keep persistence outside reusable spelling/writing analysis/correction layers.

V2.1 locally persists:

- Selected language ID.
- Personal words per language.
- Suggestion count.
- Writing-rule IDs per language.

It does not persist editor text, issue/finding lists, ignored words, or correction history.

# V2.2 review management compatibility

`WritingRule.category` is public API with a source-compatible Mechanics default. New category behavior should not force existing V2 external rules to implement a new abstract member unless a deliberate breaking release documents that change.

`WritingReviewQuery` is the reusable filtering authority. Search/category/fix-only matching should not be duplicated inside widgets.

Review filters are temporary and must not be persisted without explicit privacy/product review.

Filtered batch fixes must reuse `WritingCorrection.applyAll` and preserve V2.1 stale/advisory/overlap/end-to-start/one-step-undo behavior.

**Reset rules to defaults** must clear the current language's stored override rather than save the registry's current default set. Add tests proving the key becomes missing/unset and defaults are resolved on the next dialog/session.

# Writing-rule preference compatibility

Current key shape:

```text
spellchecker.writing_rule_ids.v1.<language-id>
```

Preserve these three distinct states:

```text
missing key       -> no explicit preference -> registry defaults
stored non-empty  -> explicit enabled IDs
stored empty list -> explicit disable-all
```

Do not convert an explicit empty list to defaults.

Stored IDs should be trimmed, empty IDs removed, deduplicated, and sorted before persistence.

When restoring effective IDs, intersect stored/default IDs with rules that both exist and support the active language. Unknown stale IDs should be ignored safely.

## Language isolation

Personal vocabulary and writing-rule preferences are independently namespaced by language.

Tests for a new language/state feature should prove pack A state does not leak to pack B.

# Keyboard and accessibility contracts

Current shortcuts:

```text
Ctrl+Enter             spelling check
Command+Enter          spelling check
Ctrl+Shift+Enter       Writing insights
Command+Shift+Enter    Writing insights
F7                     next spelling issue
Shift+F7               previous spelling issue
```

When changing controls/shortcuts:

- Preserve keyboard-only access.
- Avoid focus traps.
- Keep visible alternatives for shortcuts.
- Preserve ordinary text-editing shortcuts.
- Keep issue/finding meaning available through text/semantics, not color alone.
- Give icon-only actions meaningful tooltips/labels.
- Update accessibility/user docs and widget tests.

See [docs/ACCESSIBILITY.md](docs/ACCESSIBILITY.md).

# Tests

Behavior changes should include tests at the correct layer.

## Spelling

- Engine/dictionary/suggestions → `test/spell_checker_test.dart`.
- Edit distance → `test/edit_distance_test.dart`.
- Spelling corrections → `test/text_correction_test.dart`.
- Inline controller → `test/spell_check_editing_controller_test.dart`.
- Main editor workflow → `test/widget_test.dart`.

## Language

- Pack/token/variant behavior → `test/language_pack_test.dart`.
- Language-aware dictionary transfer → `test/language_dictionary_codec_test.dart`.
- Language preference/migration → `test/language_preferences_test.dart`.
- Language selector/isolation UI → `test/language_widget_test.dart`.

## Writing

- Rule/analyzer behavior → `test/writing_rules_test.dart`.
- Individual/batch safe correction → `test/writing_correction_test.dart`.
- Per-language rule preferences → `test/writing_preferences_test.dart`.
- Writing insights/persistence/keyboard/undo → `test/writing_widget_test.dart`.

## Persistence

Use isolated mock values:

```dart
SharedPreferences.setMockInitialValues(<String, Object>{});
```

Never read/write a contributor machine's real settings in tests.

## Scrollable/lazy UI tests

Use `tester.ensureVisible` when a real user would scroll to a control.

Writing insights uses a lazy `ListView`; findings below rule switches may not be built until the list is scrolled.

Do not distort production layout to satisfy a fixed test-viewport assumption.

## Regression tests

Every deterministic bug fix should include a test reproducing the previous failure.

Protect the user/public contract rather than incidental internals.

# Pull requests

A PR should:

- Explain the problem and solution.
- Describe user-visible behavior.
- Link relevant issues.
- Include appropriate tests.
- Pass formatting, analysis, and tests.
- Build the release target for release-sensitive changes.
- Update docs/changelog when needed.
- Avoid unrelated refactoring.
- Call out persistence/privacy/migration implications.
- Call out public API changes.
- Call out keyboard/accessibility changes.
- Call out correction grouping/safety changes.

Use the repository PR template.

# Documentation matrix

Update documentation when changing:

- Public APIs → `docs/API.md`.
- Internal architecture → `docs/ARCHITECTURE.md`.
- Language pack/state behavior → `docs/LANGUAGE_PACKS.md`.
- Writing-rule/correction behavior → `docs/WRITING_RULES.md`.
- Setup/dependencies/internals → `docs/DEVELOPMENT.md`.
- User workflow/shortcuts → `docs/USER_GUIDE.md`.
- Privacy/state retention → `docs/PRIVACY.md`.
- Security boundaries → `SECURITY.md`.
- Accessibility/keyboard behavior → `docs/ACCESSIBILITY.md`.
- Test strategy → `docs/TESTING.md`.
- Failure/recovery behavior → `docs/TROUBLESHOOTING.md`.
- Release/smoke checks → `docs/RELEASING.md`.
- Planned/completed scope → `docs/ROADMAP.md`.
- Released behavior → `CHANGELOG.md`.
- Repository overview/current version → `README.md`.
- User support/reporting context → `SUPPORT.md` / issue templates.

# Language-pack contributions

Follow [docs/LANGUAGE_PACKS.md](docs/LANGUAGE_PACKS.md).

New packs require compatible/licensed data, Unicode tests, state-isolation tests, selector/persistence coverage, migration considerations, writing-rule eligibility review, and documentation.

Do not add runtime dictionary downloads or network language detection without explicit privacy/security design review.

# Dictionary contributions

- Use pack-normalized entries.
- Avoid obvious misspellings.
- Prefer broadly useful vocabulary over personal one-off terms.
- Add regression tests for reported bugs.
- Check shared/variant dictionary data for accidental conflicts.

For frequency ranks:

- Lower rank means stronger preference.
- Add deterministic ranking tests when ordering matters.
- Do not present compact ranks as a complete linguistic corpus.

# Personal dictionary format contributions

`PersonalDictionaryCodec` defines a portable user-data format.

- Keep transfer formats versioned.
- Preserve existing documented version readability unless a migration explicitly changes it.
- Never silently reinterpret unsupported versions or languages.
- Keep output normalized/deduplicated/sorted.
- Reject malformed entries.
- Update API/user/privacy/changelog docs for format changes.

# Persistence contributions

When modifying `DictionaryPreferences`:

- Add mocked persistence tests.
- Use versioned keys/documented migrations when data meaning changes.
- Preserve explicit-empty vs unset semantics for rule IDs.
- Do not display durable-success UI before writes complete.
- Preserve no-false-success/rollback behavior where current flows require it.
- Preserve session spelling/writing functionality when storage is unavailable.
- Keep editor text/findings/correction history unpersisted unless a separately reviewed feature changes that boundary.

# Security and privacy

Use [SECURITY.md](SECURITY.md) for security-sensitive reports instead of public exploit details.

These require explicit privacy/security design review before implementation:

- Synchronization/accounts.
- Cloud spelling/grammar/AI rewriting.
- Analytics/telemetry/remote logging.
- Crash reporting that may capture editor text.
- Editor-document persistence.
- Persistent correction history.
- Keyboard/usage telemetry.
- Runtime remote dictionary/rule downloads.
- Dynamic external rule/plugin execution.

# License

By contributing, you agree that your contribution may be distributed under the repository's [MIT License](LICENSE).

## V2.3 review preset and portability changes

Changes to `WritingReviewPreset` IDs or semantics require compatibility notes and focused query/widget tests. Changes to portable settings must document format/version compatibility, supported languages, suggestion bounds, explicit override semantics, excluded data, failure/rollback behavior, and privacy impact. Never add editor text, personal dictionary contents, findings, correction snapshots, credentials, or private user samples to portable-settings fixtures; use synthetic values only.

## V2.4 suggestion-ranking changes

Preserve the default ranking order unless a release explicitly documents an intentional behavior change. Custom ranker support must not bypass engine eligibility filters, must retain deterministic lexical tie fallback, and must include focused tests for context/candidate metadata and cache-stability assumptions. Do not add dynamic plugin loading as part of a ranker change without a separate security design review.

## V2.5 performance and bounded-analysis changes

Changes to issue limits, scan termination, candidate generation, caching, ranking, or large-result rendering should include deterministic regression coverage and an update to `docs/PERFORMANCE.md`.

Do not use private documents as benchmark fixtures. Do not describe `maxIssues` as a hard document-size bound. Do not expose Replace all on a truncated issue report unless a future design supplies a separate complete-range safety contract.
