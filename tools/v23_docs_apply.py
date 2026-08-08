from pathlib import Path


def replace_once(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(old, new, 1))


def insert_before(path: Path, marker: str, section: str, label: str) -> None:
    text = path.read_text()
    if section.strip() in text:
        return
    count = text.count(marker)
    if count != 1:
        raise RuntimeError(f'{path}: {label}: expected exactly one marker, found {count}')
    path.write_text(text.replace(marker, section + '\n\n' + marker, 1))


def append_section(path: Path, heading: str, body: str) -> None:
    text = path.read_text()
    if heading in text:
        return
    suffix = '' if text.endswith('\n') else '\n'
    path.write_text(text + suffix + '\n' + heading + '\n\n' + body.strip() + '\n')


# README: current release identity and user-facing workflows.
readme = Path('README.md')
replace_once(
    readme,
    "`2.2.0+7`\n\nVersion 2.2 is the Writing Review & Rule Management release. It keeps V2.1 persistence, batch-safety, one-step undo, and keyboard workflows while adding reusable rule categories, transient search/category/automatic-fix review filters, filtered batch application, and a true per-language **Reset rules to defaults** action that removes the stored override instead of freezing today's defaults. Existing V2.1, V1.3, and V1.2 behavior remains compatible.",
    "`2.3.0+8`\n\nVersion 2.3 is the **Review Presets & Preference Portability** release. It keeps V2.2 categories, transient review filtering, reset-to-defaults, V2.1 correction safety, one-step undo, and keyboard workflows while adding stable reusable review presets plus a versioned non-document Portable settings format. Portable settings transfer selected language, suggestion count, and explicit per-language writing-rule overrides only; editor text, personal vocabulary, ignored words, findings, and correction history are excluded. Existing 2.x spelling/writing APIs remain compatible.",
    'current release block',
)
replace_once(
    readme,
    "- Temporary Writing insights search, category filters, and **Automatic fixes only** review.\n",
    "- Stable Writing insights review presets: **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes**.\n- Temporary Writing insights search, category filters, and **Automatic fixes only** review.\n- Versioned **Portable settings** copy/import for selected language, suggestion count, and explicit per-language writing-rule overrides.\n",
    'highlight insertion',
)
insert_before(
    readme,
    "### Reset rules to defaults — V2.2",
    """### Review presets — V2.3

Writing insights adds four stable local review presets:

- **All findings** (`all-findings`) — clears category/fix-only filtering.
- **Mechanics** (`mechanics`) — selects the Mechanics category.
- **Clarity** (`clarity`) — selects the Clarity category.
- **Automatic fixes** (`automatic-fixes`) — shows deterministic automatic findings only.

Presets project into the existing `WritingReviewQuery` state; they do not create a second filtering engine. Free-text search is intentionally retained when changing presets, so a user can combine a preset with a temporary search. Preset selection, search text, category filters, and automatic-fixes-only state are memory-only dialog state and disappear when Writing insights closes.
""",
    'review presets section',
)
insert_before(
    readme,
    "## Main workflow",
    """## Portable settings — V2.3

Open **Portable settings** from the app bar to copy or import a versioned preferences document.

The current format is:

```json
{
  \"format\": \"spellchecker-settings\",
  \"version\": 1,
  \"languageId\": \"en-US\",
  \"suggestionLimit\": 5,
  \"writingRuleOverrides\": {
    \"en-US\": [\"sentence-capitalization\"],
    \"en-GB\": []
  }
}
```

Only durable non-document preferences are transferred:

- Selected built-in language ID.
- Suggestion count (1–10).
- Complete set of **explicit** per-language writing-rule overrides.

Override semantics are preserved exactly: a missing language key means **unset/use current registry defaults**, while a present empty array means **explicitly disable all rules** for that language. Valid well-formed unknown future rule IDs are preserved for forward compatibility; malformed IDs, unsupported languages/formats/versions, malformed structures, and invalid suggestion limits are rejected.

Portable settings deliberately exclude editor text, personal dictionary words, ignored session words, spelling findings, writing findings, and correction/undo history. Export copies JSON only when the user presses **Copy settings JSON**. Import reads user-pasted JSON locally; it does not contact a server.

Import is persistence-first. SpellChecker snapshots the previous portable preference document, writes the imported language/limit/complete override map, and performs a best-effort rollback if any local write fails. `shared_preferences` does not provide multi-key transactions, so rollback is documented as best effort rather than atomic. The live editor state changes only after persistence succeeds. Target-language personal vocabulary is loaded separately and preserved; editor text remains unchanged, stale issue/correction state is cleared, and non-blank text is rechecked with the imported language.
""",
    'portable settings section',
)
replace_once(
    readme,
    "- Enabled writing-rule IDs, namespaced by language.\n",
    "- Enabled writing-rule IDs, namespaced by language.\n\nV2.3 can copy/import a user-triggered portable representation of the selected language, suggestion count, and explicit writing-rule override map. The transfer document itself is not automatically persisted as a document or sent anywhere; import writes those values back through the same local preference adapter.\n",
    'persistence note',
)
replace_once(
    readme,
    "│   │   ├── personal_dictionary_codec.dart\n",
    "│   │   ├── personal_dictionary_codec.dart\n│   │   ├── settings_transfer_codec.dart\n",
    'core structure',
)
replace_once(
    readme,
    "│   │   ├── dictionary_manager_dialog.dart\n",
    "│   │   ├── dictionary_manager_dialog.dart\n│   │   ├── settings_transfer_dialog.dart\n",
    'feature structure',
)
replace_once(
    readme,
    "│   ├── storage/\n│   │   └── dictionary_preferences.dart\n",
    "│   ├── storage/\n│   │   ├── dictionary_preferences.dart\n│   │   └── settings_transfer_service.dart\n",
    'storage structure',
)
replace_once(
    readme,
    "│       ├── writing_issue.dart\n│       └── writing_rule.dart\n",
    "│       ├── writing_issue.dart\n│       ├── writing_review_preset.dart\n│       ├── writing_review_query.dart\n│       └── writing_rule.dart\n",
    'writing structure',
)
replace_once(
    readme,
    "│   ├── writing_review_query_test.dart\n│   ├── writing_rules_test.dart\n",
    "│   ├── writing_review_preset_test.dart\n│   ├── writing_review_query_test.dart\n│   ├── settings_transfer_codec_test.dart\n│   ├── settings_transfer_dialog_test.dart\n│   ├── settings_transfer_service_test.dart\n│   ├── v23_widget_test.dart\n│   ├── writing_rules_test.dart\n",
    'test structure',
)

# Changelog.
changelog = Path('CHANGELOG.md')
insert_before(
    changelog,
    '## [2.2.0] - 2026-08-08',
    """## [2.3.0] - 2026-08-08

### Added

- Public `WritingReviewPreset` with stable **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes** IDs.
- Writing insights preset chips that project into the existing reusable review-query state while retaining temporary free-text search.
- Public `SpellCheckerSettingsDocument` and version-1 `SpellCheckerSettingsCodec` for deterministic non-document preference transfer.
- **Portable settings** dialog with explicit local clipboard export and validated pasted-JSON import.
- Internal `SettingsTransferService` that exports durable preference state, replaces the complete portable preference set on import, and performs best-effort rollback after a failed write.
- Focused preset, settings codec, persistence rollback, dialog, and end-to-end editor workflow regression tests.

### Changed

- Package version advances to `2.3.0+8`; About version advances to `2.3.0`.
- Portable import can change selected language, suggestion count, and explicit per-language writing-rule overrides while preserving editor text and target-language personal vocabulary.
- Successful portable import clears stale issue/correction state and rechecks non-blank text with the imported language.
- V2.3 release recovery removes temporary integration helpers/workflows from the permanent tree.

### Compatibility, security, and privacy

- Portable override documents preserve the distinction between a missing language key (unset/use registry defaults) and a present empty list (explicit disable-all).
- Valid well-formed unknown future rule IDs are preserved; malformed rule IDs, unsupported languages, unsupported formats/versions, malformed structures, and suggestion limits outside 1–10 are rejected.
- Portable settings exclude editor text, personal vocabulary, ignored session words, spelling/writing findings, and correction history.
- Import validation and preference writes are local. `shared_preferences` has no multi-key transaction, so rollback after a write failure is best effort and is not described as atomic.
- Review preset/search/category/automatic-fix state remains transient and unpersisted.
- No new runtime dependency, cloud grammar/spelling service, analytics, telemetry, account system, or remote document transfer is introduced.
""",
    '2.3 changelog',
)

# Roadmap.
roadmap = Path('docs/ROADMAP.md')
insert_before(
    roadmap,
    '## Future 2.x direction',
    """## 2.3 — Review presets and preference portability

Status: implemented.

- [x] Public stable review-preset metadata and IDs.
- [x] All findings, Mechanics, Clarity, and Automatic fixes presets.
- [x] Presets reuse `WritingReviewQuery` and retain transient free-text search.
- [x] Versioned deterministic non-document settings codec.
- [x] Portable selected language and 1–10 suggestion-count preference.
- [x] Portable complete explicit per-language writing-rule override map.
- [x] Preservation of unset/default versus explicit-empty/disable-all semantics.
- [x] Forward-compatible preservation of well-formed unknown rule IDs.
- [x] Dedicated Portable settings copy/import dialog.
- [x] Persistence-first import with best-effort rollback on write failure.
- [x] Personal-vocabulary and editor-text exclusion/preservation guarantees.
- [x] Focused codec/persistence/dialog/widget regression coverage.
- [x] Complete V2.3 documentation, privacy, release, and repository metadata.
""",
    '2.3 roadmap',
)
replace_once(
    roadmap,
    '- User-visible rule categories and search/filtering.\n- Import/export of non-sensitive application preferences.\n',
    '- Additional review presets/categories driven by demonstrated workflows.\n- Additional portable non-document preferences with explicit compatibility/version review.\n',
    'future completed items',
)

# API.
api = Path('docs/API.md')
replace_once(
    api,
    'SpellChecker 2.1 exposes reusable spelling, language, correction, and local writing-rule APIs through three public barrels.',
    'SpellChecker 2.3 exposes reusable spelling, language, correction, local writing-review, and portable-settings APIs through three public barrels.',
    'api intro version',
)
insert_before(
    api,
    '# Application persistence boundary',
    """# V2.3 review preset and portable-settings APIs

## `WritingReviewPreset`

`package:spellchecker/writing.dart` exports immutable reusable review presets. Current stable IDs are:

```text
all-findings
automatic-fixes
clarity
mechanics
```

`WritingReviewPreset.values` exposes the built-ins; `WritingReviewPreset.byId(id)` falls back to `allFindings` for an unknown/null ID. `preset.toQuery(search: ...)` returns the corresponding `WritingReviewQuery`. Search is caller-supplied/transient and is not stored in the preset.

Preset IDs are compatibility-sensitive metadata. Do not silently reuse an existing ID for different semantics.

## `SpellCheckerSettingsDocument`

`package:spellchecker/spell_checker.dart` exports the versioned portable preference document:

```dart
final document = SpellCheckerSettingsDocument(
  languageId: 'en-US',
  suggestionLimit: 5,
  writingRuleOverrides: <String, Iterable<String>>{
    'en-US': <String>{'sentence-capitalization'},
    'en-GB': const <String>[],
  },
);
```

`writingRuleOverrides` contains **explicit overrides only**. `hasWritingRuleOverride(languageId) == false` means unset/use current registry defaults. A present empty set means explicit disable-all.

## `SpellCheckerSettingsCodec`

Current constants:

```text
format = spellchecker-settings
version = 1
minSuggestionLimit = 1
maxSuggestionLimit = 10
```

`encode(document)` validates language IDs, suggestion limits, and rule IDs and emits deterministic indented JSON with sorted language keys/rule IDs.

`decode(source)` rejects malformed JSON, unsupported format/version, unsupported language IDs, invalid override structures, malformed rule IDs, and suggestion limits outside 1–10. Well-formed unknown future rule IDs are preserved instead of being discarded by the codec.

The codec is intentionally storage/network agnostic and never carries editor text, personal vocabulary, ignored words, findings, or correction history.

## Internal `SettingsTransferService`

The Flutter application uses an internal storage service to project `SpellCheckerSettingsDocument` onto `DictionaryPreferences`. It is not part of the public barrel guarantee. The service snapshots prior portable preferences and performs best-effort rollback if a multi-key import write fails; `shared_preferences` does not provide transactional writes.
""",
    'v2.3 api section',
)

# Architecture.
arch = Path('docs/ARCHITECTURE.md')
insert_before(
    arch,
    '# Data layer',
    """# V2.3 review presets and preference portability

## Review preset flow

`WritingReviewPreset` lives in `lib/writing/` beside `WritingReviewQuery`. Presets are immutable named projections onto category/automatic-fix filtering; the dialog remains responsible only for transient selection state. Free-text search is not stored in a preset and is intentionally retained when the user switches presets.

```text
WritingReviewPreset
   │
   └── toQuery(search)
          │
          ▼
   WritingReviewQuery
      ├── filterRules
      └── filterIssues
```

No preset bypasses `WritingCorrection`; filtered batch fixes still use the V2.1 correction primitive.

## Portable settings layers

```text
SpellCheckerSettingsCodec       public pure JSON/validation layer
SettingsTransferService         internal durable-preference projection/rollback
SettingsTransferDialog          import/export presentation only
SpellCheckerPage                live-session mutation after persistence succeeds
```

The portable document contains selected language, suggestion limit, and the complete explicit per-language writing-rule override map. Personal vocabulary is deliberately outside this format.

## Import flow

```text
Paste JSON
   │
   ▼
SpellCheckerSettingsCodec.decode
   │ validate only
   ▼
SettingsTransferService.importDocument
   ├── validate programmatic document
   ├── snapshot previous portable preferences
   ├── write language + suggestion limit + complete override map
   └── write failure -> best-effort restore snapshot, rethrow
            │ success
            ▼
SpellCheckerPage
   ├── preserve already-loaded editor text
   ├── load/reuse target-language personal vocabulary
   ├── create fresh language engine
   ├── resolve imported/default effective writing rules
   ├── clear stale issue/correction state
   └── re-check non-blank editor text
```

Because `shared_preferences` has no multi-key transaction, rollback is a best-effort safety mechanism rather than an atomic persistence guarantee. The page changes live state only after the service succeeds.
""",
    'architecture v2.3 section',
)
replace_once(
    arch,
    'Location:\n\n```text\nlib/storage/dictionary_preferences.dart\n```',
    'Location:\n\n```text\nlib/storage/dictionary_preferences.dart\nlib/storage/settings_transfer_service.dart\n```',
    'storage locations',
)

# Writing rules spec.
writing = Path('docs/WRITING_RULES.md')
insert_before(
    writing,
    '## Tests',
    """## V2.3 review presets

`WritingReviewPreset` is public review-organization metadata layered on `WritingReviewQuery`. Stable built-ins are:

```text
all-findings      -> no category/fix-only filter
mechanics         -> Mechanics category
clarity           -> Clarity category
automatic-fixes   -> automaticFixesOnly = true
```

Preset IDs are stable public metadata and require compatibility/release review before renaming or semantic reuse. A preset does not persist search text or rule choices. `toQuery(search: ...)` accepts the current transient search so preset changes can retain the user's local search context.

Writing insights can still create custom combinations by using the category chips and automatic-fix switch directly. That custom transient state does not require or synthesize a new preset ID.

Preset changes select review scope only. Individual/batch correction authority remains `WritingCorrection.apply`/`applyAll`, including stale-range validation, overlap handling, end-to-start application, applied/skipped counts, and one-step undo.
""",
    'writing presets spec',
)
replace_once(
    writing,
    'test/writing_review_query_test.dart\ntest/writing_rules_test.dart',
    'test/writing_review_preset_test.dart\ntest/writing_review_query_test.dart\ntest/writing_rules_test.dart',
    'writing tests list',
)

# Privacy.
privacy = Path('docs/PRIVACY.md')
replace_once(
    privacy,
    'SpellChecker 2.1 performs spelling and optional deterministic writing-rule analysis locally.',
    'SpellChecker 2.3 performs spelling and optional deterministic writing-rule analysis locally.',
    'privacy intro version',
)
insert_before(
    privacy,
    '## Language selection and vocabulary',
    """## Review presets and Portable settings — V2.3

Review preset selection is transient dialog state. Preset IDs are public application metadata, but SpellChecker does not persist which preset/search/category/fix-only combination a user was viewing.

Portable settings are explicitly user-triggered. The copied/imported version-1 document contains only:

- Selected built-in language ID.
- Suggestion-count preference.
- Explicit per-language writing-rule override lists.

It excludes editor text, personal dictionary words, ignored session words, spelling issue lists, writing findings/source excerpts, and correction/undo snapshots.

**Copy settings JSON** writes the generated JSON to the local clipboard only after user action. Import reads JSON pasted by the user. SpellChecker does not upload or remotely synchronize this document.

Before an import, the application snapshots the previous portable preference state. If any local preference write fails, it attempts to restore that snapshot and reports failure; Flutter `shared_preferences` has no multi-key transaction, so this restoration is best effort rather than an atomic guarantee. The live editor switches to imported settings only after the persistence service succeeds.

The target language's personal vocabulary is loaded independently and reused after a successful import. Portable settings neither transfer nor clear that vocabulary. Editor text also remains unchanged; stale analysis/undo state is cleared and non-blank text is rechecked locally.
""",
    'privacy v2.3 section',
)
replace_once(
    privacy,
    '## Persisted settings inventory\n\nV2.1 application preferences are limited to:',
    '## Persisted settings inventory\n\nV2.3 application preferences remain limited to:',
    'privacy persisted inventory version',
)
replace_once(
    privacy,
    'SpellChecker 2.1 contains no analytics SDK, advertising SDK, telemetry SDK, account/authentication dependency, cloud spelling/grammar dependency, AI rewriting service, or remote document logging pipeline.',
    'SpellChecker 2.3 contains no analytics SDK, advertising SDK, telemetry SDK, account/authentication dependency, cloud spelling/grammar dependency, AI rewriting service, or remote document logging pipeline.',
    'privacy analytics version',
)
replace_once(
    privacy,
    'V2.1 adds no new runtime dependency.',
    'V2.3 adds no new runtime dependency.',
    'privacy dependency version',
)

# User guide.
user = Path('docs/USER_GUIDE.md')
replace_once(
    user,
    '- **Writing insights** app-bar action.\n',
    '- **Writing insights** app-bar action.\n- **Portable settings** app-bar action.\n',
    'user guide app bar',
)
insert_before(
    user,
    '## Built-in writing rules',
    """## Review presets — V2.3

Above the V2.2 category controls, Writing insights provides **All findings**, **Mechanics**, **Clarity**, and **Automatic fixes** presets. A preset changes category/automatic-fix review scope but keeps the current free-text search. You can then adjust category chips/toggle manually for a custom temporary combination.

Preset/search/category/automatic-fix state is never saved. Closing the dialog resets that review state; per-language rule switches remain the durable preference.

# Portable settings — V2.3

Select **Portable settings** in the app bar.

### Copy

The dialog shows the current durable selected language, suggestion count, explicit override-language count, and a deterministic JSON document. Choose **Copy settings JSON** to place that JSON on the local clipboard.

### Import

Paste a `spellchecker-settings` version-1 JSON document and choose **Import settings**. A successful import replaces:

- Selected language.
- Suggestion count.
- Complete set of explicit per-language writing-rule overrides.

A missing language in `writingRuleOverrides` means that language returns to built-in defaults. A present empty list means all writing rules are explicitly disabled for that language.

Portable settings do **not** contain personal words or editor text. Existing target-language personal vocabulary remains available after import, and current editor text remains unchanged. The editor clears stale checked/finding/undo state and rechecks non-blank text under the imported language.

If local storage fails mid-import, SpellChecker reports that the import failed and attempts to restore the previous durable portable settings. Because local preference storage is not transactional, restoration is best effort.
""",
    'user guide v2.3 sections',
)

# Testing guide.
testing = Path('docs/TESTING.md')
insert_before(
    testing,
    '## Writing-rule coverage',
    """## V2.3 focused coverage

The V2.3 release adds five focused suites:

```bash
flutter test test/writing_review_preset_test.dart --reporter expanded
flutter test test/settings_transfer_codec_test.dart --reporter expanded
flutter test test/settings_transfer_service_test.dart --reporter expanded
flutter test test/settings_transfer_dialog_test.dart --reporter expanded
flutter test test/v23_widget_test.dart --reporter expanded
```

They protect stable preset IDs/query projection/search retention, deterministic settings JSON, unset-versus-empty override semantics, malformed/unsupported input rejection, forward-compatible well-formed rule IDs, complete override replacement, best-effort rollback, personal-vocabulary exclusion/preservation, clipboard/import dialog behavior, editor-text preservation, and the successful live language/rule/limit refresh path.

Portable settings dialogs use lazy `ListView` content. Widget tests must scroll the real dialog list before interacting with off-screen import/status controls rather than changing production layout to make tests easier.

The V2.3 recovery gate run `31260605417` passed these focused suites, the complete **125-test** regression suite, `flutter analyze`, formatting checks, and `flutter build web --release` on the exact clean code checkpoint before documentation changes.
""",
    'testing v2.3 section',
)

# Remaining affected docs receive explicit V2.3 sections.
append_section(
    Path('docs/LANGUAGE_PACKS.md'),
    '## V2.3 portable language preferences',
    """Portable settings carry an explicit selected built-in language ID plus explicit writing-rule overrides keyed by supported language ID. The settings codec rejects unsupported language IDs rather than guessing or auto-detecting a substitute. Personal vocabulary is deliberately excluded from portable settings and remains in its existing per-language local namespace. After a successful import, the editor loads the target language's existing personal words into a fresh engine and rechecks non-blank text. A missing override key means that language follows current registry defaults; an empty override list means explicit disable-all.""",
)
append_section(
    Path('docs/DEVELOPMENT.md'),
    '## V2.3 development contracts',
    """When changing review presets, keep IDs stable, keep preset behavior as a projection into `WritingReviewQuery`, and add focused preset/query/widget tests. When changing `SpellCheckerSettingsCodec`, treat `format`, `version`, language IDs, suggestion bounds, rule-ID validation, deterministic ordering, and unset-versus-explicit-empty semantics as compatibility-sensitive. Portable settings must remain non-document unless a future release explicitly redesigns the privacy boundary. Storage changes must test failure and best-effort rollback behavior; do not claim `shared_preferences` writes are transactional.""",
)
append_section(
    Path('docs/ACCESSIBILITY.md'),
    '## V2.3 review presets and portable settings',
    """Review presets use standard Material `ChoiceChip` controls with visible text labels; category filters and the automatic-fixes switch remain independently available. Portable settings uses labeled copy/import controls, a labeled multiline import field, selectable export text, and semantic live-region status/error messages. The visible Portable settings app-bar action has a tooltip, so the workflow is not shortcut-only. Tests scroll lazy dialogs to real controls instead of depending on a fixed viewport.""",
)
append_section(
    Path('docs/TROUBLESHOOTING.md'),
    '## Portable settings import problems — V2.3',
    """If a portable settings document is rejected, verify `format` is `spellchecker-settings`, `version` is `1`, `languageId` and every override key are supported built-in language IDs, `suggestionLimit` is 1–10, override values are arrays, and rule IDs use the documented lowercase stable-ID form. If storage fails during import, SpellChecker keeps the live editor on its previous state and attempts to restore the previous durable portable preferences; because local preference storage is not transactional, recovery is best effort. Personal vocabulary is not part of the portable document, so missing personal words should be investigated through the language-specific personal dictionary instead of the settings JSON.""",
)
append_section(
    Path('docs/RELEASING.md'),
    '## V2.3 release checks',
    """For a V2.3-compatible release, verify the package/About version pair, stable review-preset IDs, `spellchecker-settings` format/version compatibility, unset-versus-empty rule override semantics, deterministic settings encoding, privacy exclusions, rollback tests, focused V2.3 suites, complete regression suite, and `flutter build web --release`. Confirm the intended release tree contains no one-time `tools/v23_*` helper or `.github/workflows/v23-*` recovery/integration workflow before tagging.""",
)

# Top-level contributor/security/support policy surface.
append_section(
    Path('CONTRIBUTING.md'),
    '## V2.3 review preset and portability changes',
    """Changes to `WritingReviewPreset` IDs or semantics require compatibility notes and focused query/widget tests. Changes to portable settings must document format/version compatibility, supported languages, suggestion bounds, explicit override semantics, excluded data, failure/rollback behavior, and privacy impact. Never add editor text, personal dictionary contents, findings, correction snapshots, credentials, or private user samples to portable-settings fixtures; use synthetic values only.""",
)
append_section(
    Path('SECURITY.md'),
    '## Portable settings security boundary — V2.3',
    """Portable settings are untrusted user-supplied JSON. Import validates format/version, supported language IDs, suggestion limits, override structure, and rule-ID syntax before persistence. The format does not execute code or dynamically load rules. Export is copied to the local clipboard only after explicit user action. Imported data is not sent to a remote service. `shared_preferences` writes are not transactional; rollback is best effort and must not be represented as an atomic security boundary.""",
)
append_section(
    Path('SUPPORT.md'),
    '## V2.3 portable settings reports',
    """For review-preset issues, include the preset name/ID, selected language, synthetic review text, and whether a search/category/automatic-fix filter was also active. For portable-settings issues, include a minimized synthetic JSON document with any private vocabulary/text removed, whether the failure happened during validation or persistence, the selected platform, and whether existing language/rule/suggestion preferences were restored. Do not post real documents, personal dictionaries, credentials, or sensitive clipboard content.""",
)

# Web/PWA descriptions.
index = Path('web/index.html')
text = index.read_text()
text = text.replace(
    'privacy-first local spelling and writing assistant with explicit language packs, categorized Writing insights review, persistent rule choices, batch-safe corrections, and keyboard workflows',
    'privacy-first local spelling and writing assistant with explicit language packs, Writing insights review presets, portable non-document preferences, persistent rule choices, batch-safe corrections, and keyboard workflows',
)
index.write_text(text)
manifest = Path('web/manifest.json')
text = manifest.read_text()
text = text.replace(
    'Privacy-first local spelling and writing assistant with explicit language packs, categorized Writing insights review, persistent rule choices, batch-safe corrections, and keyboard workflows.',
    'Privacy-first local spelling and writing assistant with explicit language packs, Writing insights review presets, portable non-document preferences, persistent rule choices, batch-safe corrections, and keyboard workflows.',
)
manifest.write_text(text)

# GitHub templates get V2.3 diagnostic/checklist coverage.
append_section(
    Path('.github/pull_request_template.md'),
    '## V2.3 review presets and portable settings',
    """Complete when relevant.\n\n- [ ] Review preset IDs/semantics remain stable or migration/release notes are included.\n- [ ] Free-text review search remains transient unless persistence is explicitly reviewed.\n- [ ] Portable settings preserve missing/unset versus present-empty override semantics.\n- [ ] Portable settings exclude editor text, personal vocabulary, ignored words, findings, and correction history.\n- [ ] Import validation and best-effort rollback behavior have focused tests.\n- [ ] `shared_preferences` behavior is not described as transactional.\n- [ ] No temporary `tools/v23_*` or `.github/workflows/v23-*` integration/recovery artifact remains in the release tree.""",
)
append_section(
    Path('.github/ISSUE_TEMPLATE/bug_report.yml'),
    '# V2.3 diagnostic note',
    """# For portable-settings/review-preset bugs, include only minimized synthetic JSON/text. Never include private editor documents, personal dictionaries, credentials, or sensitive clipboard data.""",
)
append_section(
    Path('.github/ISSUE_TEMPLATE/feature_request.yml'),
    '# V2.3 design note',
    """# Requests that expand portable settings should identify the exact preference, persistence semantics, compatibility/version impact, privacy boundary, and why it belongs in a non-document transfer format.""",
)

print('V2.3 documentation and repository-surface transform applied successfully.')
