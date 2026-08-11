# Development Guide

## Prerequisites

Install:

- Git.
- Flutter stable.
- Dart SDK compatible with `pubspec.yaml` (currently `>=3.8.0 <4.0.0`).
- Platform tooling required by your chosen Flutter target.

Verify:

```bash
flutter doctor
flutter --version
dart --version
```

## Clone and resolve dependencies

```bash
git clone https://github.com/sanskarIN/SpellChecker.git
cd SpellChecker
flutter pub get
```

Runtime dependencies remain intentionally small:

- Flutter SDK.
- `shared_preferences` for device/profile-local settings.

`shared_preferences` currently stores selected language, per-language personal words, suggestion count, and per-language writing-rule IDs. It is not used for networking, analytics, document persistence, or synchronization.

## Run

```bash
flutter run -d chrome
```

The repository commits the web host and portable Flutter/Dart source. Generate additional local platform runners only when needed and review generated platform/signing files before committing them.

# Important directories

## `lib/core`

Reusable spelling/language/correction primitives:

- `spell_language_pack.dart` — language packs/registry.
- `spell_checker_engine.dart` — language-aware spelling engine.
- `spell_issue.dart` / `spell_suggestion.dart` — result models.
- `text_correction.dart` — validated spelling single/replace-all mutation.
- `personal_dictionary_codec.dart` — versioned language-aware personal vocabulary transfer.
- `edit_distance.dart` — Damerau-Levenshtein implementation.
- `text_statistics.dart` — lightweight writing statistics.

Core changes should have focused unit tests.

## `lib/writing`

Reusable local writing-rule subsystem:

- `writing_rule.dart` — public rule/plugin contract and registry.
- `writing_analyzer.dart` — language eligibility/filtering/result ordering.
- `writing_issue.dart` — immutable finding model.
- `writing_correction.dart` — stale-safe individual and V2.1 batch mutation.
- `rules/` — built-in deterministic rules.

Do not put Flutter widget or preference code in this layer.

## `lib/data`

Bundled spelling vocabulary/variant/frequency data.

## `lib/features/editor`

Flutter application workflow:

- `spell_checker_page.dart` — selected language, restored preferences, spelling/writing workflows, keyboard shortcuts, shared correction undo.
- `spell_check_editing_controller.dart` — inline spelling styling.
- `dictionary_manager_dialog.dart` — language-specific personal vocabulary/suggestion settings.
- `writing_insights_dialog.dart` — rule switches/findings/individual and batch fix requests.

## `lib/storage`

`DictionaryPreferences` is the local `shared_preferences` adapter. It is application-internal and intentionally separate from public spelling/writing APIs.

## `test`

Unit, codec, persistence, controller, language, writing, and widget regression tests.

## `docs`

Project/user/API/architecture/privacy/security/release documentation.

## `.github`

CI/release workflows and collaboration templates.

# Development commands

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

Run all tests:

```bash
flutter test --reporter expanded
```

Build the release web app:

```bash
flutter build web --release
```

Focused V2.1 writing workflow tests:

```bash
flutter test test/writing_rules_test.dart
flutter test test/writing_correction_test.dart
flutter test test/writing_preferences_test.dart
flutter test test/writing_widget_test.dart
```

Focused language tests:

```bash
flutter test test/language_pack_test.dart
flutter test test/language_dictionary_codec_test.dart
flutter test test/language_preferences_test.dart
flutter test test/language_widget_test.dart
```

Focused spelling/editor tests:

```bash
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
flutter test test/widget_test.dart
```

# Changing language packs

Language-specific tokenization/normalization/dictionary logic belongs behind `SpellLanguagePack`, not in widgets.

A new pack needs:

- Stable ID/language/region identity.
- User-readable display name.
- Unicode-aware token/validation behavior.
- Normalizer.
- Licensed/appropriate dictionary data.
- Frequency/suggestion metadata policy.
- Suffix behavior when applicable.
- Personal-word isolation tests.
- Language-selection persistence tests.
- Writing-rule eligibility review.
- User/API/privacy documentation.

Do not add runtime dictionary download/network behavior as an implementation detail without separate security/privacy review.

See [LANGUAGE_PACKS.md](LANGUAGE_PACKS.md).

# Changing spelling correction behavior

Spelling mutation belongs in `lib/core/text_correction.dart`.

Keep these invariants:

1. Never trust a `SpellIssue` range after text may have changed.
2. Verify the current source substring before mutation.
3. Apply spelling replace-all from highest source start to lowest.
4. Preserve casing independently per occurrence.
5. Report actual replacement count.
6. Return a valid caret.
7. Do not partially mutate a stale targeted single issue.

Add/update `test/text_correction_test.dart`.

# Changing V2.2 writing review metadata/query

`WritingRuleCategory` and `WritingReviewQuery` are public APIs under `lib/writing/`.

Category changes must preserve source compatibility where practical. The concrete `WritingRule.category` Mechanics default exists so pre-V2.2 external rules do not become uncompilable just because categories were added.

Review-query changes belong in `writing_review_query.dart`, not `WritingInsightsDialog`. Add/update `test/writing_review_query_test.dart` for search, category, automatic-fix, unknown-rule, and source-compatibility behavior.

Review filters are transient UI state. Do not add them to `DictionaryPreferences` without an explicit product/privacy decision.

Filtered batch actions must pass only the intended visible automatic issues to `WritingCorrection.applyAll`; do not create a separate filtering-specific correction implementation.

`Reset rules to defaults` must clear the stored language-specific rule override. Do not implement reset by saving `WritingRuleRegistry.defaultEnabledRuleIds`, because that would freeze today's defaults into an explicit preference.

# Changing writing rules

Implement `WritingRule`; do not add rule matching logic to widgets.

Requirements:

- Stable unique persistent rule ID.
- Deterministic side-effect-free analysis.
- Explicit supported language IDs/codes.
- Exact source ranges/original text.
- Automatic replacement only when safe for the rule's documented scope.
- Positive and negative unit tests.
- Interaction/overlap tests when the rule can collide with another automatic rule.

Run:

```bash
flutter test test/writing_rules_test.dart
flutter test test/writing_correction_test.dart
flutter test test/writing_widget_test.dart
```

Rule IDs are persisted in V2.1. Renaming a shipped rule ID is therefore a data-migration change, not a cosmetic refactor.

See [WRITING_RULES.md](WRITING_RULES.md).

# Changing individual writing correction

`WritingCorrection.apply` is the source-range validation boundary for one automatic writing fix.

Do not apply a `WritingIssue.replacement` directly in widget code.

The correction must verify:

- Replacement exists.
- Offsets are valid/current.
- Current substring equals `issue.originalText` exactly.

A stale issue returns unchanged text.

# Changing V2.1 batch writing correction

`WritingCorrection.applyAll` is the authoritative batch contract.

Current invariants:

1. Candidate ordering is source start, source end, then rule ID.
2. Findings without replacements are skipped.
3. Invalid/stale findings are skipped.
4. Later overlapping findings are skipped after an earlier candidate is accepted.
5. Accepted edits are applied from end toward start.
6. The result reports applied/skipped counts.
7. Returned caret is clamped inside final text.
8. The editor treats one successful batch as one undo entry.

Do not move overlap resolution into `WritingInsightsDialog`; the reusable correction primitive must remain authoritative.

Required regression coverage belongs in `test/writing_correction_test.dart` and `test/writing_widget_test.dart`.

# Changing writing-rule preferences

V2.1 stores rule IDs per language through `DictionaryPreferences`.

Current key shape:

```text
spellchecker.writing_rule_ids.v1.<language-id>
```

Preserve the three-state meaning:

```text
missing key       -> null -> registry defaults
stored non-empty  -> explicit enabled IDs
stored empty list -> explicit disable-all
```

Do not use `?? defaults` in a way that also replaces an empty set.

When restoring effective rule IDs, intersect stored/default IDs with rules that both exist and support the active language. Unknown stale IDs must not crash analysis.

Persistence tests use mocked `SharedPreferences`; do not read/write a developer machine's real preferences.

# Changing correction undo

The application-level correction stack lives in `SpellCheckerPage`, not in `TextCorrection` or `WritingCorrection`.

Current design:

- Stores pre-correction `TextEditingValue` snapshots.
- Maximum 20 entries.
- Single spelling replacement = one entry.
- Spelling replace-all = one entry.
- Individual writing fix = one entry.
- Writing batch fix = one entry.
- Manual user typing clears the stack.
- Stack is memory-only.

When adding a new automatic correction workflow, decide and test its grouping explicitly. Do not silently create multiple history entries for one user-visible bulk action.

# Changing inline spelling highlighting

`SpellCheckEditingController` validates issue ranges against current text before styling.

Rules:

- Skip invalid/stale/overlapping spans safely.
- Keep visual underline/background supplemental to text/semantics.
- Clear checked issue styling after manual text changes.
- Add controller tests for deterministic behavior.

# Changing keyboard workflows

Current shortcuts:

```text
Ctrl+Enter             spelling check
Command+Enter          spelling check
Ctrl+Shift+Enter       Writing insights
Command+Shift+Enter    Writing insights
F7                     next spelling issue
Shift+F7               previous spelling issue
```

When changing shortcuts:

- Consider platform conflicts.
- Preserve ordinary text-editing shortcuts.
- Keep the equivalent visible control available.
- Add widget regression coverage.
- Update accessibility/user docs and tooltips.

# Widget test viewport behavior

The editor/results/dialogs are scrollable. Tests must exercise the same visibility behavior as users instead of relying on the default 800×600 test surface.

For a control below the current viewport:

```dart
final control = find.text('Save word');
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

Writing insights intentionally uses a lazy `ListView`; findings below rule switches may need a `drag` before they exist in the widget tree.

# Changing personal dictionary transfer

`PersonalDictionaryCodec` owns the public transfer format.

Rules:

- Keep formats versioned.
- Never silently reinterpret unsupported versions/languages.
- Preserve deterministic normalized/sorted output.
- Reject malformed entries.
- Add compatibility/migration tests before changing an existing format's meaning.

# Changing persistence generally

Current persistent settings:

- Selected language ID.
- Personal words per language.
- Suggestion-count preference.
- Writing-rule IDs per language.

Persistence changes require:

- Mocked preference tests.
- Key/version migration review.
- Privacy documentation updates.
- User-visible failure behavior review.

Do not persist editor text, spelling/writing finding lists, active issue positions, ignored words, or correction snapshots unless the privacy/product model is explicitly redesigned and reviewed first.

# Changing UI behavior

Keep reusable spelling/writing mutation and analysis out of widgets.

For editor changes, test:

- Narrow/wide layouts.
- Standard 800×600 test surface.
- Keyboard-only use.
- Text scaling/scrolling.
- Stale source-range behavior.
- Semantics/live-region behavior.
- Storage unavailable paths.
- Language switching.
- Undo grouping.

# Privacy/security review

Explicit review is required before adding:

- Network spelling/grammar calls.
- AI rewriting.
- Analytics/telemetry.
- Crash-reporting services that may capture text.
- Account/synchronization systems.
- Remote configuration affecting writing analysis.
- Editor-document persistence.
- Persistent correction history.
- Dynamic external rule/plugin loading.

Update `docs/PRIVACY.md` and `SECURITY.md` before merging such changes.

# Version/release changes

For a user-visible release update:

- `pubspec.yaml` version/build.
- About version text.
- `CHANGELOG.md`.
- README current release.
- Roadmap milestone state.
- API/architecture/user/development/testing/accessibility/troubleshooting/privacy/security/release/support/contribution docs as applicable.
- GitHub issue/PR templates when new diagnostic context matters.

Follow [RELEASING.md](RELEASING.md).

## V2.3 development contracts

When changing review presets, keep IDs stable, keep preset behavior as a projection into `WritingReviewQuery`, and add focused preset/query/widget tests. When changing `SpellCheckerSettingsCodec`, treat `format`, `version`, language IDs, suggestion bounds, rule-ID validation, deterministic ordering, and unset-versus-explicit-empty semantics as compatibility-sensitive. Portable settings must remain non-document unless a future release explicitly redesigns the privacy boundary. Storage changes must test failure and best-effort rollback behavior; do not claim `shared_preferences` writes are transactional.

## V2.4 suggestion-ranker contracts

Custom `SpellSuggestionRanker` implementations must be deterministic and side-effect free for a `SpellCheckerEngine` lifetime. Do not move candidate eligibility, maximum edit distance, token exclusions, suffix handling, or language normalization into a ranker. Return zero for genuinely equal custom scores and let the engine-owned lexical fallback provide stable ordering. Add focused tests whenever candidate metadata, ranking context, default ordering, cache assumptions, or tie semantics change.

## V2.5 bounded-analysis development contract

When changing spelling-analysis performance behavior:

- Keep `check()` source-compatible and unbounded unless a future breaking release explicitly changes the contract.
- Reject non-positive explicit issue caps.
- Preserve source-order captured issues.
- Do not mark a result truncated merely because `issues.length == maxIssues`.
- Do not generate suggestions for the first proven overflow issue.
- Keep report issue lists immutable.
- Preserve V2.4 ranking/candidate eligibility semantics for captured issues.
- Do not expose Replace all from an incomplete checked issue set.
- Use synthetic text in performance/regression tests.
- Prefer deterministic work-count/state assertions over wall-clock thresholds on shared CI hardware.
- Update `docs/PERFORMANCE.md` when changing the meaning of a bound or the editor cap.

## V2.6 writing-rule development checks

When changing whitespace-oriented rules, test ownership boundaries as well as positive matches. A new automatic rule must not accidentally create a second incompatible replacement for an exact range already owned by another built-in. Use synthetic LF, CRLF, punctuation-adjacent, interior-space, and document-end cases. Keep issue ranges exact and keep widget tests on the real lazy Writing insights `ListView`; scroll controls into view rather than making production lists eager for tests.

## V2.7 bounded-analysis development checks

When modifying writing analysis, test both unbounded and bounded paths. A custom rule test must not assume findings are yielded in source order; bounded results must still match the prefix of the fully sorted unbounded result.

New result metadata must preserve these invariants: limits are positive, exact-at-limit results can remain complete, truncation requires a proven overflow finding, and captured lists remain immutable.

UI work must not describe a truncated captured set as the complete document finding set. Filters and batch actions must clearly state captured-only behavior while stale-range and one-step undo protections remain active.
