# Architecture

## Goals

SpellChecker is designed around these goals:

1. Keep spelling logic independent from Flutter widgets.
2. Keep writing-rule analysis independent from Flutter widgets.
3. Keep automatic text mutation reusable, deterministic, and offset-safe.
4. Keep user text local by default.
5. Keep persistence explicit and limited to user-controlled preferences.
6. Keep language-specific behavior behind language-pack boundaries.
7. Keep the runtime dependency surface small.
8. Make core behavior deterministic and regression-testable.
9. Preserve keyboard and accessibility workflows alongside pointer/touch UI.
10. Leave clear extension points for richer deterministic local writing rules and language packs.

# Layers

## Application shell

Locations:

```text
lib/main.dart
lib/app.dart
```

`main.dart` initializes Flutter and starts `SpellCheckerApp`. `app.dart` defines Material 3 themes and selects the editor page.

## Presentation layer

Location:

```text
lib/features/editor/
```

### `spell_checker_page.dart`

Owns editor-level application state and orchestrates reusable core/storage services.

Responsibilities include:

- Editor text input.
- Text statistics.
- Explicit language selection.
- Spelling checks with the configured suggestion limit.
- Inline spelling-highlight synchronization.
- Active spelling-issue selection/navigation.
- Single spelling replacement and spelling replace-all.
- Personal-word persistence and session ignores.
- Writing insights launch and keyboard shortcut.
- Per-language writing-rule preference restoration/persistence.
- Individual writing safe fixes.
- Batch writing safe fixes.
- Shared bounded programmatic correction undo.
- Storage-unavailable state and user-visible warnings.

It does **not** implement edit distance, tokenization, writing-rule matching, preference serialization, or correction-range validation itself.

### `spell_check_editing_controller.dart`

Extends `TextEditingController` and owns inline visual rendering of checked spelling issues.

Responsibilities:

- Hold the current checked spelling issues.
- Hold the active spelling issue index.
- Build styled text spans.
- Draw valid wavy underlines.
- Apply stronger active-issue styling.
- Ignore invalid/stale/overlapping highlight ranges instead of throwing.
- Clear issue styling when text edits invalidate a spelling snapshot.

### `dictionary_manager_dialog.dart`

Owns user-facing personal-dictionary and suggestion-count management for the selected language.

Responsibilities:

- Add/remove/clear saved personal words.
- Import language-aware or legacy vocabulary.
- Copy a versioned export.
- Change suggestions per spelling issue.
- Surface storage errors.

### `writing_insights_dialog.dart`

Owns presentation of writing-rule configuration and findings.

Responsibilities:

- Show the current language.
- Show supported writing rules.
- Toggle enabled rule IDs.
- Show deterministic findings.
- Expose an individual **Apply safe fix** action.
- Expose V2.1 **Apply all safe fixes (N)** when automatic fixes exist.
- Return the chosen rule configuration/fix request to the page.

The dialog does not mutate editor text directly. `SpellCheckerPage` applies returned requests through `WritingCorrection`.

# Core spelling/language layer

Location:

```text
lib/core/
```

## `SpellLanguagePack`

The language pack is the boundary between language-independent application/engine behavior and language-specific behavior.

A pack owns:

- Stable language ID.
- Language and region codes.
- Display name.
- Dictionary data.
- Approximate frequency metadata.
- Unicode tokenization pattern.
- Valid personal-word pattern.
- Normalizer.
- Recognized suffix rules.
- Suggestion source metadata.
- Suggestion-distance policy.

`SpellLanguageRegistry` currently supplies:

```text
en-US  English (US)
en-GB  English (UK)
```

The US/UK packs intentionally remove the other variant's curated spellings before adding their own variant set, making differences such as `color`/`colour` deterministic.

## `SpellCheckerEngine`

Responsibilities:

- Tokenize through the selected language pack.
- Normalize through the selected pack.
- Check base, personal, and ignored vocabularies.
- Recognize configured suffix forms.
- Produce source-positioned `SpellIssue` values.
- Rank and cache spelling suggestions.
- Produce detailed `SpellSuggestion` metadata.
- Manage engine-local personal and ignored-word sets.

The engine has no Flutter widget/storage dependency.

## `SpellIssue`

Immutable occurrence-specific spelling finding containing:

- Exact source word.
- Start/end offsets.
- Ranked string suggestions.
- Optional producing language ID.

Offsets are valid only for the checked text snapshot.

## `SpellSuggestion`

Detailed suggestion metadata contains candidate text, edit distance, frequency rank, language identity/display name, and suggestion source.

## `TextCorrection`

Reusable offset-safe spelling mutation layer.

Responsibilities:

- Validate checked spelling ranges against current text.
- Replace one spelling issue with case preservation.
- Replace all still-current checked occurrences of the same source word.
- Apply replace-all edits from end to beginning.
- Return resulting text/caret/replacement count.
- Refuse stale corrections without partial mutation.

Undo is deliberately outside `TextCorrection`; the page decides how a correction result is grouped into history.

## `PersonalDictionaryCodec`

Responsibilities:

- Validate/normalize personal vocabulary.
- Encode legacy version-1 transfers where requested.
- Encode language-aware version-2 transfers.
- Decode versioned JSON, JSON arrays, and plain word lists.
- Preserve explicit language identity in V2 documents.
- Reject unsupported versions, unsupported languages, and malformed word entries.

## Edit distance

`damerauLevenshteinDistance` supports insertion, deletion, substitution, and adjacent transposition.

## Text statistics

`TextStatistics` calculates character, word, and sentence counts.

# Writing-rules layer

Locations:

```text
lib/writing.dart
lib/writing/
```

## `WritingRule`

Public side-effect-free plugin contract. Each rule declares:

- Stable persistent ID.
- Display name.
- Description.
- Supported language IDs/codes.
- Deterministic `analyze(text, languagePack)` implementation.

## `WritingRuleRegistry`

Contains built-in rule instances and the default enabled rule IDs.

Current built-ins:

```text
repeated-word
sentence-capitalization
repeated-space
repeated-punctuation
```

## `WritingAnalyzer`

Responsibilities:

- Select rules that support the active language pack.
- Filter by an optional enabled-ID set.
- Combine findings.
- Sort findings deterministically.
- Report analysed rule IDs and per-rule counts.

The analyzer has no storage/UI/network dependency.

## `WritingIssue`

Immutable writing finding containing:

- Rule identity/name.
- Human-readable message.
- Exact source range and `originalText`.
- Optional deterministic replacement.
- Language ID.
- Severity.

`replacement == null` means advisory-only. An empty string is a valid automatic replacement.

## `WritingCorrection`

Reusable writing-mutation boundary.

### Individual fix

`WritingCorrection.apply` validates that the current source range still equals `issue.originalText` before replacement.

### V2.1 batch fix

`WritingCorrection.applyAll`:

1. Sorts candidates by start, end, then rule ID.
2. Skips advisory/no-replacement findings.
3. Skips invalid/stale findings.
4. Keeps the earliest deterministic candidate when automatic fixes overlap.
5. Applies accepted edits from the document end toward the beginning.
6. Returns one final `WritingBatchCorrectionResult` with applied/skipped counts and a safe caret.

This intentionally conservative policy avoids ambiguous chained transformations.

See [WRITING_RULES.md](WRITING_RULES.md).

# V2.3 review presets and preference portability

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


# Data layer

Location:

```text
lib/data/
```

Contains bundled English dictionary data, US/UK variants, curated extension vocabulary, and approximate frequency ranks.

The application loads bundled data from Dart source and performs no runtime network fetch for spelling dictionaries.

# Persistence layer

Location:

```text
lib/storage/dictionary_preferences.dart
lib/storage/settings_transfer_service.dart
```

`DictionaryPreferences` wraps Flutter `shared_preferences` for application-owned local settings.

V2.1 persists:

- Selected language ID.
- Personal dictionary words per language.
- Suggestion-count preference.
- Enabled writing-rule IDs per language.

It deliberately does not persist:

- Editor documents.
- Checked spelling issue lists.
- Writing findings.
- Finding source excerpts.
- Ignored words.
- Active issue index.
- Suggestion cache.
- Correction undo snapshots.
- Batch correction plans.

## Versioned keys

Examples:

```text
spellchecker.personal_words.v2.en-US
spellchecker.personal_words.v2.en-GB
spellchecker.language_id.v1
spellchecker.suggestion_limit.v1
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

The old `spellchecker.personal_words.v1` key remains a compatibility/migration source for the default US vocabulary namespace.

## Writing-rule preference semantics

The storage API preserves three states:

```text
missing key       -> null -> use current registry defaults
stored IDs        -> enable those supported IDs
stored empty list -> explicitly disable all rules for that language
```

This distinction is required for backward-compatible V2.0 upgrades and deliberate “disable all” user choices.

# Public library surfaces

Reusable barrels:

```dart
import 'package:spellchecker/spell_checker.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';
```

UI widgets/controllers and `DictionaryPreferences` remain internal integration types.

# Startup flow

```text
Application startup
   │
   ▼
DictionaryPreferences
   ├── selected language ID
   ├── selected-language personal words
   ├── suggestion-count preference
   └── selected-language writing-rule IDs (nullable)
           │
           ▼
SpellCheckerPage
   ├── resolve SpellLanguagePack
   ├── build SpellCheckerEngine(pack)
   ├── restore personal words
   ├── resolve effective writing-rule IDs
   └── enter ready state
```

Effective writing rules are the stored/default IDs intersected with rules currently registered and supported by the active pack.

If preference restoration fails, the page marks storage unavailable and still permits local session spelling/writing workflows.

# Language switch flow

```text
Language selector
   │
   ├── resolve target pack
   ├── load target-pack personal words
   ├── load target-pack writing-rule IDs
   ├── persist selected language ID
   ├── build fresh SpellCheckerEngine(target pack)
   ├── resolve effective target-pack writing rules
   ├── clear stale correction/highlight/session state
   └── re-check non-blank editor text
```

Personal vocabulary and writing-rule preferences do not silently leak between language namespaces.

# Spelling-check flow

```text
Editor text
   │
   ├────► TextStatistics.fromText
   │
   └────► SpellCheckerEngine.check
              │
              ├── pack tokenization/normalization
              ├── dictionary lookup
              ├── suffix recognition
              └── suggestion ranking
                    │
                    ▼
                List<SpellIssue>
                  │        │
                  │        └────► Results panel
                  └─────────────► SpellCheckEditingController inline spans
```

# Spelling issue navigation

Inputs:

- `F7`: next spelling issue.
- `Shift+F7`: previous spelling issue.
- App-bar previous/next controls.
- Results previous/next controls.
- Selecting an issue card.

Activating an issue updates page state, highlight styling, editor selection/focus, and Results scrolling.

Navigation wraps at both ends.

# Keyboard shortcuts

`CallbackShortcuts` maps:

```text
Ctrl+Enter             spelling check
Command+Enter          spelling check
Ctrl+Shift+Enter       Writing insights
Command+Shift+Enter    Writing insights
F7                     next spelling issue
Shift+F7               previous spelling issue
```

The app-bar actions remain available for pointer/touch and assistive-technology workflows.

# Single spelling correction flow

```text
Suggestion selected
   │
   ▼
TextCorrection.replaceOne
   │
   ├── validate range
   ├── preserve casing
   └── return result
          │
          ├── unchanged -> refresh stale spelling check
          └── changed
                ├── push one pre-correction TextEditingValue
                ├── apply result
                └── re-check near returned caret
```

# Spelling replace-all flow

```text
Replace all with suggestion
   │
   ▼
TextCorrection.replaceAll
   │
   ├── filter matching checked occurrences
   ├── validate current ranges
   ├── apply from end toward start
   └── produce one final text
            │
            ▼
       one undo entry
```

# V2.2 writing review organization

`WritingReviewQuery` is part of reusable `lib/writing/`, not the Flutter dialog. This keeps search/category/fix-only matching deterministic and unit-testable.

The Writing insights dialog owns only transient review controls:

```text
search controller
selected rule categories
automatic-fixes-only toggle
```

Those values derive a query and visible rule/finding sets on each rebuild. They are discarded when the dialog closes and are never written to `DictionaryPreferences`.

Finding category labels are resolved from the dialog's actual analyzer-supported rules rather than the global built-in registry, preserving custom analyzer metadata.

## Filtered batch flow

```text
Writing insights filters
   │
   ▼
WritingReviewQuery.filterIssues
   │
   ├── visible findings
   └── visible automatic findings
            │
            ▼
Apply visible safe fixes
            │
            ▼
WritingCorrection.applyAll
            │
            └── same V2.1 stale/overlap/end-to-start/undo contract
```

Filtering selects the user's batch scope; it does not weaken correction validation.

## Reset-to-defaults flow

```text
Reset rules to defaults
   │
   ▼
WritingInsightsDialogResult(resetRulePreferences: true)
   │
   ▼
SpellCheckerPage
   ├── resolve _effectiveWritingRuleIds(null, active pack)
   ├── activate defaults in memory
   ├── clear language-specific stored rule-ID key
   └── report persistence failure without discarding session defaults
```

A successful reset leaves the preference **unset**, not explicitly equal to the current default set.

# Writing insights flow

```text
App-bar action or Ctrl/Command+Shift+Enter
   │
   ▼
WritingInsightsDialog
   │
   ├── WritingAnalyzer(current text, pack, enabled IDs)
   ├── rule switches
   ├── findings
   ├── individual safe-fix request
   └── batch safe-fix request
            │
            ▼
SpellCheckerPage
   ├── persist returned rule IDs per language
   ├── keep session choice if persistence fails
   └── apply requested fix through WritingCorrection
```

The dialog is not a mutation authority; the page always re-validates against the current editor text.

# Individual writing correction flow

```text
Apply safe fix
   │
   ▼
WritingCorrection.apply
   │
   ├── replacement exists?
   ├── source range valid?
   └── current substring == originalText?
            │
            ├── no -> refuse and request fresh analysis
            └── yes
                  ├── push one pre-correction TextEditingValue
                  ├── apply result
                  └── refresh spelling state
```

# V2.1 batch writing correction flow

```text
Apply all safe fixes (N)
   │
   ▼
WritingCorrection.applyAll
   │
   ├── deterministic candidate sort
   ├── skip advisory/stale/invalid findings
   ├── skip later overlaps
   ├── apply accepted edits from end toward start
   └── return one final batch result
            │
            ├── no accepted fixes -> leave text unchanged
            └── accepted fixes
                  ├── push exactly one pre-batch TextEditingValue
                  ├── apply final text once
                  ├── report applied/skipped counts
                  └── refresh spelling state
```

# Shared correction undo model

The editor keeps a bounded in-memory list of pre-correction `TextEditingValue` snapshots. The current maximum depth is 20.

One snapshot is pushed for:

- One spelling replacement.
- One spelling replace-all operation.
- One writing safe fix.
- One writing batch safe-fix operation.

Snackbar **Undo** and **Undo correction** restore the latest snapshot.

Manual typing clears this correction-specific history so stale programmatic snapshots are not mixed with a new manual editing sequence.

The history is not persisted.

# Inline spelling-highlight safety

`SpellCheckEditingController.buildTextSpan` validates every spelling issue against current text before styling it. Invalid/stale ranges are skipped. Manual edits immediately clear checked highlight state.

# Suggestion ranking

For an unknown normalized target the engine:

1. Chooses maximum edit distance from the pack policy.
2. Skips candidates with impossible length differences.
3. Computes Damerau-Levenshtein distance.
4. Prefers lower distance.
5. Prefers first-character agreement.
6. Prefers lower approximate frequency rank.
7. Prefers shorter candidates.
8. Uses alphabetical order as the final deterministic tie-breaker.
9. Caches the complete candidate list.

The suggestion cache is cleared when personal vocabulary changes.

# Personal versus ignored words

- **Personal words** are persisted per language.
- **Ignored words** are session-only engine state.

Changing language builds a fresh engine, preventing ignored-word state from silently carrying into another pack.

# Import/export boundary

`PersonalDictionaryCodec` belongs to reusable core code. Clipboard interaction belongs to presentation code.

Version-2 exports include language identity. Imports merge validated normalized vocabulary into the selected language's saved set only after compatibility checks.

# Accessibility state model

Accessibility semantics are derived from the same application state used visually; there is no second disconnected accessibility-only model.

Examples:

- Editor semantics describe inline spelling highlighting.
- Result counts and important empty/warning states use live-region semantics.
- Issue tiles identify position/range and selected state.
- Writing findings identify rule/message and safe-fix action.
- Batch action has visible text including automatic-fix count.
- Keyboard shortcuts supplement, rather than replace, normal controls.
- Color/underline/badge state is supplementary rather than the only signal.

# Privacy boundary

Runtime spelling and writing analysis is local. V2.1 adds persistence only for writing-rule **IDs**, not editor content or findings.

No cloud grammar/spelling API, AI rewriting dependency, analytics, advertising, telemetry, account system, or remote document logger is required by the architecture.

# Current extension points

Future work can extend:

- Language-pack registry and data.
- Deterministic writing-rule catalogue.
- Language-specific writing rules.
- Suggestion ranking strategies.
- Preference management UI.
- Large-document performance optimizations.
- Packaging/signing automation.

Any future dynamic plugin-loading or network feature requires an explicit security/privacy design rather than bypassing the current local-first boundaries.

# Non-goals in V2.1

V2.1 does not attempt to provide:

- Full grammar parsing.
- AI-generated rewriting.
- Automatic language detection.
- Cloud dictionary/rule synchronization.
- Account-backed preferences.
- Background document monitoring.
- Persistent document history.
- Untrusted dynamic plugin execution.
- Production-scale linguistic coverage comparable to a specialized language platform.
