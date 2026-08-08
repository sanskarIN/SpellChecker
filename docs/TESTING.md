# Testing

## Test strategy

SpellChecker uses layered deterministic tests so core algorithms, local persistence, rendering state, and full editor workflows can be validated independently.

The suite is organized around these boundaries:

- Core spelling/language/correction behavior runs without Flutter widgets.
- Writing-rule analysis and correction runs without Flutter widgets.
- Persistence tests use isolated mock `SharedPreferences` values.
- Inline spelling-controller tests isolate rendering state from the page.
- Widget tests verify keyboard, persistence, language selection, dialog scrolling, correction grouping, and user-visible workflows.
- Release validation additionally builds the Flutter web target.

## Run all tests

```bash
flutter test --reporter expanded
```

Short reporter:

```bash
flutter test
```

## Focused groups

Spelling/editor:

```bash
flutter test test/spell_checker_test.dart
flutter test test/text_correction_test.dart
flutter test test/spell_check_editing_controller_test.dart
flutter test test/widget_test.dart
```

Language:

```bash
flutter test test/language_pack_test.dart
flutter test test/language_dictionary_codec_test.dart
flutter test test/language_preferences_test.dart
flutter test test/language_widget_test.dart
```

Writing V2.1:

```bash
flutter test test/writing_rules_test.dart
flutter test test/writing_correction_test.dart
flutter test test/writing_preferences_test.dart
flutter test test/writing_widget_test.dart
```

## Writing-rule coverage

`test/writing_rules_test.dart` protects:

- Repeated adjacent-word matching.
- Non-adjacent duplicate non-matching behavior.
- Sentence capitalization behavior.
- Repeated horizontal-space behavior.
- Repeated punctuation behavior.
- Replacement metadata.
- Language eligibility for the built-in English packs.
- Analyzer enabled-ID filtering.
- Analyzer deterministic ordering.
- Per-rule finding counts.

Rule tests should use synthetic source text and assert the public rule contract rather than widget layout details.

## Writing correction coverage

`test/writing_correction_test.dart` protects both individual and V2.1 batch mutation.

### Individual correction

- Current automatic fix is applied.
- Stale source range is refused.
- Advisory issue without a replacement is not mutated.

### Batch correction — V2.1

- Multiple current non-overlapping fixes produce one final text.
- Applied count is accurate.
- Skipped count is accurate.
- Stale findings are skipped.
- Advisory findings are skipped.
- Overlapping fixes use deterministic earliest-candidate resolution.
- All-unsafe input leaves text unchanged.
- Returned caret remains valid.

Batch tests should include replacements that alter string length so end-to-start mutation remains protected.

## Writing preference coverage — V2.1

`test/writing_preferences_test.dart` protects the persisted rule-ID contract:

- Missing key returns `null`.
- Rule IDs are trimmed, deduplicated, sorted, and empty IDs removed.
- Explicit empty stored set remains empty rather than becoming defaults.
- `en-US` and `en-GB` preferences are isolated.
- Clearing one language returns it to unset/default state without deleting another language's values.
- Raw key shape remains versioned and language-specific.

Mock preferences before every test:

```dart
SharedPreferences.setMockInitialValues(<String, Object>{});
```

Never use a developer machine's real settings in tests.

## Writing widget coverage — V2.1

`test/writing_widget_test.dart` protects full editor behavior.

### Individual safe fix + undo

1. Enter synthetic text with writing findings.
2. Open Writing insights.
3. Scroll the lazy findings list.
4. Apply one safe fix.
5. Verify editor text changed.
6. Use **Undo correction**.
7. Verify the original editor text is restored.

### Apply all safe fixes + one-step undo

1. Enter text containing several automatic writing findings.
2. Open Writing insights.
3. Scroll to **Apply all safe fixes**.
4. Apply the batch.
5. Verify all non-overlapping current automatic fixes were reflected in the single final text.
6. Use **Undo correction** once.
7. Verify the exact pre-batch text is restored.

This protects correction-history grouping as well as mutation correctness.

### Persisted rule switches

1. Disable a writing rule in the dialog.
2. Close the dialog.
3. Verify the per-language rule-ID preference list no longer contains that ID.
4. Reopen the dialog.
5. Verify the rule remains disabled.

### Startup restoration

Seed a language-specific rule-ID key before pumping the app. Verify only those stored/supported rule switches are enabled.

### Keyboard shortcut

Send Ctrl+Shift+Enter and verify Writing insights opens. Platform-specific Command/Meta behavior can be covered separately where Flutter test event behavior is stable.

## Lazy Writing insights list

Writing insights intentionally uses a `ListView` so large finding sets remain scrollable/lazy.

A finding below the initial rule-switch area might not exist in the widget tree until scrolling occurs.

Tests should scroll the actual list:

```dart
final insightsList = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byType(ListView),
);
await tester.drag(insightsList, const Offset(0, -520));
await tester.pumpAndSettle();
```

Do not replace the lazy production list with an eagerly built test-only layout.

## Language architecture coverage

`test/language_pack_test.dart`, `test/language_dictionary_codec_test.dart`, `test/language_preferences_test.dart`, and `test/language_widget_test.dart` protect:

- Built-in registry IDs/default pack.
- Unicode tokenization and punctuation normalization.
- US/UK variant acceptance differences.
- Language-tagged issues/suggestions.
- Engine personal/ignored state isolation.
- Version-2 language-aware personal dictionary documents.
- Version-1 compatibility.
- Selected-language persistence/fallback.
- Per-language personal-word namespaces.
- Legacy V1 personal-word migration.
- Editor language switching/re-check behavior.
- Saved-word isolation across language switches.

V2.1 extends the language-state contract with per-language writing-rule preferences; those assertions live in `test/writing_preferences_test.dart` and writing widget tests.

## Core spelling engine coverage

`test/spell_checker_test.dart` covers:

- Case-insensitive dictionary matching.
- Unknown-word detection/source offsets.
- Suggestion generation/ranking.
- Frequency tie breaking.
- Suggestion limits.
- Regular contraction/possessive recognition.
- Suffix-preserving suggestions.
- Personal dictionary mutations.
- Session ignored words.
- Session reset behavior.
- Expanded bundled vocabulary.

Ranking tests should assert exact order only when ordering is itself the behavior being protected.

## Spelling correction coverage

`test/text_correction_test.dart` protects:

- Current single replacement.
- Case preservation.
- Stale offset refusal.
- Replace-all across checked repeated occurrences.
- End-to-start mutation.
- Unrelated issue preservation.
- Replacement counts/result change state.

Correct core behavior at this layer before weakening widget expectations.

## Inline spelling-controller coverage

`test/spell_check_editing_controller_test.dart` protects:

- Checked issue styling.
- Active issue styling/index.
- Clearing issues/highlights.
- Safe span construction from current text.

Add stale/invalid/overlap cases when controller behavior changes.

## Personal dictionary codec coverage

Codec tests protect:

- Deterministic normalized exports.
- Versioned object import/export.
- Version-2 language metadata.
- JSON-array/plain-list compatibility.
- Unicode/apostrophe normalization.
- Malformed entry rejection.
- Unsupported format/language rejection.

Existing transfer versions are compatibility contracts, not convenient snapshots that may be rewritten silently.

## General persistence coverage

`test/dictionary_preferences_test.dart` and language-specific tests cover:

- Personal-word save/restore.
- Suggestion-count persistence/clamping.
- Personal-word clear behavior.
- Language selection persistence.
- Language-specific namespaces/migration.

V2.1 writing preference tests cover the additional rule-ID keys.

## Statistics/edit distance

`test/edit_distance_test.dart` protects equal/insert/delete/transposition behavior.

`test/text_statistics_test.dart` protects word/character/sentence counts and blank input.

## Main widget coverage

`test/widget_test.dart` protects V1.2+ spelling/editor workflows:

- Basic spelling check/result.
- Blank-input state.
- F7 navigation.
- Spelling replace-all and undo.
- Persistent Save word.
- Language-qualified dictionary manager restore.

## Widget viewport rules

Flutter test uses a bounded default surface. Real controls can be valid but outside the current hit-test region.

When a user would scroll, tests must scroll too:

```dart
final control = find.text('Replace all…').first;
await tester.ensureVisible(control);
await tester.pumpAndSettle();
await tester.tap(control);
```

Do not change production layout only to make an offscreen test tap work.

## Keyboard tests

Use `sendKeyEvent` for simple single-key shortcuts. Modifier combinations can use key-down/key-up events when necessary.

After keyboard input, call `pumpAndSettle` before asserting visible state.

Protect the user-visible action rather than internal focus state unless focus itself is the contract.

## Semantics testing

Important semantics contracts include:

- Editor label/inline issue explanation.
- Spelling issue selected state/range/count.
- Result-count and warning live regions.
- Writing finding rule/message label.
- Writing empty state.
- Batch action text/count.
- Icon control tooltips.

Add targeted semantics assertions when they are stable under the supported Flutter version.

## CI checks

Normal CI runs:

```bash
flutter pub get
flutter analyze
flutter test --reporter expanded
```

Before release, also run:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter build web --release
```

## Analyzer policy

Fix analyzer errors/lints in source/tests. Do not suppress a rule merely to make CI green unless the project has deliberately reviewed and documented why that lint is inappropriate.

## Regression policy

Every deterministic bug fix should include a regression test that fails before the fix and passes after it.

Prefer contract assertions over incidental implementation details. Examples:

- Candidate must exist vs. candidate must occupy a particular rank.
- Batch must be one undo entry vs. exact internal stack representation.
- Finding must be reachable by scrolling vs. fixed pixel position.
- Stored empty rule list must remain explicit-empty vs. a particular `SharedPreferences` platform backend detail.

## Persistence failure behavior

User-visible durable changes must not claim success before storage completes.

Examples:

- Personal-word save rolls engine state back if persistence fails.
- Writing-rule switches remain active in the current session if persistence fails, while the application marks storage unavailable and reports the failure.

Session spelling/writing analysis remains usable without durable local storage.

## Correction-history privacy

Correction snapshots can contain full editor text. They must remain memory-only. Tests must use synthetic documents and must not persist snapshots into fixtures/preferences/log files.

## Test data privacy

Use synthetic test data. Never commit private documents, credentials, account identifiers, personal communications, or sensitive personal-dictionary exports.
