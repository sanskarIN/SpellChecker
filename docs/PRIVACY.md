# Privacy

## Summary

SpellChecker 2.3 performs spelling and optional deterministic writing-rule analysis locally. It stores a deliberately small set of user-controlled settings on the local device/profile and does not persist editor documents or writing-analysis findings.

V2.1 newly persists only **writing-rule identifiers**, namespaced by selected language. It does not persist the text that produced a finding, the finding message, source excerpts, or batch correction plans.

## Runtime text processing

Editor text remains in application memory while the app is running.

SpellChecker does not include application code that sends editor text to:

- A remote spelling API.
- A remote grammar API.
- An AI rewriting service.
- An analytics service.
- An advertising service.
- An account system.
- A telemetry service.
- A remote logging pipeline.

Hosting platforms, browsers, operating systems, Flutter tooling, and user-installed software can have behavior outside this repository; that behavior is not part of SpellChecker's application code.

## Spelling analysis data

A spelling check creates in-memory `SpellIssue` values containing source word, offsets, language identity where available, and ranked suggestions.

The active spelling issue index and inline highlight state are also memory-only.

Manual editing invalidates old source offsets and clears stale spelling/highlight state.

SpellChecker does not write spelling issue lists, highlight spans, active issue positions, or suggestion caches to local preferences.

## Writing insights data

Writing insights receives the current editor text in memory when the user explicitly opens the workflow or uses its keyboard shortcut.

The local `WritingAnalyzer` can create in-memory findings containing:

- Rule ID/name.
- Human-readable message.
- Source range.
- Exact original source text for that finding.
- Optional deterministic replacement.
- Language ID.
- Severity.

These findings are not persisted by SpellChecker.

The application does not store:

- Writing finding lists.
- Finding source excerpts.
- Rule messages tied to a document.
- Batch correction candidate plans.
- Per-document writing-analysis history.

## Writing-rule preferences — V2.1

V2.1 stores enabled writing-rule **IDs** per language through `shared_preferences`.

Current key shape:

```text
spellchecker.writing_rule_ids.v1.<language-id>
```

Examples:

```text
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

Stored values are rule identifiers such as:

```text
repeated-space
sentence-capitalization
```

They do not contain editor text or finding excerpts.

### Unset versus explicit empty

The application distinguishes:

```text
missing key       -> user has never configured this language -> registry defaults
stored ID list    -> explicit enabled rules
stored empty list -> explicit disable-all
```

This preference meaning is local application state only.

### Persistence failure

If a rule switch cannot be saved, the current in-memory choice remains active for that session and the application reports that local persistence is unavailable.

SpellChecker does not send the preference or editor text to a remote fallback.

## Review filters — V2.2

Writing insights search text, selected rule categories, the automatic-fixes-only switch, visible counts, and the filtered visible finding set are dialog-local memory state.

SpellChecker does not persist or upload:

- Review search queries.
- Selected review categories.
- Automatic-fixes-only state.
- Visible/hidden finding lists.
- Filtered batch plans.

Closing the dialog discards the review filters.

## Reset-to-defaults privacy behavior

Resetting writing rules clears the selected language's local `spellchecker.writing_rule_ids.v1.<language-id>` override. It does not create a document log or send a reset event to a remote service.

If local storage removal fails, built-in defaults stay active for the current session while the existing persisted override can remain on the device/profile and may reappear after restart.

## Review presets and Portable settings — V2.3

Review preset selection is transient dialog state. Preset IDs are public application metadata, but SpellChecker does not persist which preset/search/category/fix-only combination a user was viewing.

Portable settings are explicitly user-triggered. The copied/imported version-1 document contains only:

- Selected built-in language ID.
- Suggestion-count preference.
- Explicit per-language writing-rule override lists.

It excludes editor text, personal dictionary words, ignored session words, spelling issue lists, writing findings/source excerpts, and correction/undo snapshots.

**Copy settings JSON** writes the generated JSON to the local clipboard only after user action. Import reads JSON pasted by the user. SpellChecker does not upload or remotely synchronize this document.

Before an import, the application snapshots the previous portable preference state. If any local preference write fails, it attempts to restore that snapshot and reports failure; Flutter `shared_preferences` has no multi-key transaction, so this restoration is best effort rather than an atomic guarantee. The live editor switches to imported settings only after the persistence service succeeds.

The target language's personal vocabulary is loaded independently and reused after a successful import. Portable settings neither transfer nor clear that vocabulary. Editor text also remains unchanged; stale analysis/undo state is cleared and non-blank text is rechecked locally.


## Language selection and vocabulary

The selected built-in language ID is stored locally.

Personal vocabulary is namespaced by language. Switching language creates new in-memory language-specific engine/session state so temporary ignored words and suggestion caches do not leak between packs.

Legacy V1 personal words are read only from SpellChecker's existing local key and interpreted/migrated into the default `en-US` namespace. No external data is fetched for migration.

SpellChecker does not perform automatic language detection or language/keyboard telemetry.

## Personal dictionary

Words saved through **Save word** or the personal dictionary manager are stored locally through Flutter `shared_preferences`.

Stored personal values contain normalized vocabulary only, not the surrounding sentence/document that caused a save.

The platform-specific `shared_preferences` implementation chooses the backing local mechanism. A browser build uses browser/profile-local application storage rather than a SpellChecker cloud service.

## Suggestion count

The selected 1–10 suggestion count is stored locally so it survives normal application restarts.

## Ignored words

Ignored words are intentionally session-only in the active spelling engine and are not written to preferences.

Changing language constructs a fresh engine/session, so ignored words do not silently cross language packs.

## Correction undo snapshots

SpellChecker keeps a bounded in-memory correction history. A `TextEditingValue` snapshot can contain the full editor document immediately before an automatic correction.

V2.1 uses the same history for:

- Single spelling replacement.
- Spelling replace-all.
- Individual writing safe fix.
- Writing batch safe fix.

Privacy requirements:

- Snapshots remain memory-only.
- They are not stored in `shared_preferences`.
- They are not included in personal dictionary exports.
- They are not sent over a network by SpellChecker.
- They disappear when the application session ends.
- Manual user editing clears the programmatic correction stack.
- Clearing the editor clears the current correction stack.

A future persistent document/correction history feature requires a separate privacy design and documentation update before release.

## Batch writing correction

`WritingCorrection.applyAll` receives current in-memory text plus current in-memory findings.

It validates/skips stale/advisory/overlapping findings and returns a final text value. SpellChecker does not persist the batch candidate set or skipped-finding details as a document history.

The pre-batch editor snapshot enters the same memory-only correction stack so the whole batch can be undone once.

## Inline highlights

Inline spelling underlines and active styling are generated from current in-memory issue state. SpellChecker does not save screenshots, rendered spans, or highlight ranges.

## Keyboard shortcuts

Current local shortcuts include:

```text
Ctrl/Command+Enter        spelling check
Ctrl/Command+Shift+Enter  Writing insights
F7                        next spelling issue
Shift+F7                  previous spelling issue
```

SpellChecker does not maintain a keystroke log or keyboard telemetry.

The editor necessarily receives ordinary text-input events through Flutter while the application is running.

## Import/export

Personal dictionary transfer is explicitly user-triggered.

- Import reads text pasted/provided by the user into the application.
- Export writes a language-aware personal dictionary document to the local clipboard.
- SpellChecker does not upload imported/exported dictionary data.

Clipboard contents are subject to host platform/browser policies. SpellChecker writes the export only when the user chooses **Copy export**.

Current version-2 exports include language identity plus normalized personal vocabulary, not editor content.

## Persisted settings inventory

V2.3 application preferences remain limited to:

- Selected language ID.
- Personal words per language.
- Suggestion-count preference.
- Enabled writing-rule IDs per language.

Example versioned keys:

```text
spellchecker.language_id.v1
spellchecker.personal_words.v2.en-US
spellchecker.personal_words.v2.en-GB
spellchecker.suggestion_limit.v1
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

The legacy personal-word key remains only for backward-compatible US migration/mirroring behavior.

## Explicitly non-persisted state

SpellChecker does not persist:

- Editor documents.
- Spelling issue lists.
- Writing finding lists.
- Finding messages/source excerpts.
- Active issue index.
- Ignored words.
- Inline rendered highlight spans.
- Suggestion caches.
- Correction undo snapshots.
- Batch correction plans.

## Analytics/telemetry/network

SpellChecker 2.3 contains no analytics SDK, advertising SDK, telemetry SDK, account/authentication dependency, cloud spelling/grammar dependency, AI rewriting service, or remote document logging pipeline.

Runtime spelling and writing analysis does not require network access.

Development/build tooling can access package repositories, GitHub, and Flutter distribution infrastructure when dependencies/toolchains are resolved. Those build activities are separate from runtime document analysis.

## Dependency note

`shared_preferences` remains the only non-SDK runtime package dependency and is used for application-local settings.

V2.3 adds no new runtime dependency.

## Data deletion

Users can remove personal vocabulary through the personal dictionary manager.

Writing-rule preferences can be changed by toggling rule switches. Turning all switches off stores an explicit empty set for that language; re-enabling switches updates the stored set.

Ignored words disappear when cleared or when the application session ends.

The editor's **Clear** action removes current editor text, current analysis/highlight state, and correction history. It does not delete persistent settings such as language, vocabulary, suggestion count, or writing-rule IDs.

Removing browser/app/profile data according to the host platform's controls can remove all locally stored SpellChecker preferences.

## Storage failure

When local preference storage is unavailable:

- SpellChecker reports a visible/semantic warning.
- Session spelling remains available.
- Writing analysis remains available.
- Current in-memory writing-rule switch choices can remain active.
- Durable preference changes may fail.
- No remote fallback service is contacted.

## Security-sensitive future features

These require explicit privacy/security design review and documentation updates before release:

- Cloud spelling/grammar APIs.
- AI rewriting/model inference.
- Cross-device synchronization.
- Accounts.
- Analytics/telemetry.
- Crash reporting that may capture editor state.
- Remote configuration affecting analysis behavior.
- Editor document persistence.
- Persistent general document/correction history.
- Automatic dictionary/rule download.
- Keyboard/usage telemetry.
- Dynamic external rule/plugin loading.

Any optional network feature must be clearly user-controlled and must not silently replace the local-first default.

## Contributions and issue reports

Do not include private documents, secrets, credentials, personal messages, or sensitive personal dictionary exports in public tests/issues.

Use minimal synthetic text that reproduces the problem.

## Suggestion rankers — V2.4

The V2.4 ranker API is local in-process Dart code supplied when constructing `SpellCheckerEngine`. SpellChecker does not persist ranker choice/state, dynamically download rankers, send candidate metadata to a service, or add a network dependency. The built-in application continues using `DefaultSpellSuggestionRanker`. Portable settings and personal-dictionary transfer formats are unchanged.

## V2.5 bounded-analysis privacy behavior

`SpellCheckReport` is memory-only. It can contain spelling issue words, source offsets, and suggestions and therefore follows the same private document-state rules as prior `SpellIssue` lists.

The 200-issue editor cap does not upload skipped text, log overflow words, persist report metadata, or send performance telemetry. The overflow word used to prove truncation is inspected locally and is not materialized into a persisted/report issue.

V2.5 introduces no document persistence, analytics, remote logging, account system, cloud spelling/grammar service, background upload, or new runtime package.

## V2.6 writing-rule privacy boundary

Punctuation-spacing and trailing-whitespace analysis runs locally against the in-memory editor text through the existing `WritingAnalyzer`. Findings/source snippets remain memory-only. V2.6 persists no new value: only the existing per-language rule-ID preferences can reference the two new stable IDs after a user changes/reset rule choices. No document text, whitespace finding, correction plan, analytics event, telemetry, or network request is added.

## V2.7 bounded writing-analysis privacy

The optional writing `maxIssues` bound and the built-in 200-finding Writing insights policy do not add storage or transmission. The analyzer reads the supplied text in memory, retains at most the configured finding count when bounded, and returns in-memory metadata describing whether additional findings existed.

Captured findings, uncaptured finding counts, analysis limits, review search/filter state, and correction history are not newly persisted. The application still has no cloud spelling/grammar service, telemetry, analytics, account requirement, advertising, background document upload, or automatic remote rewriting.

A limited result should be treated as potentially containing sensitive source excerpts just like any other `WritingIssue`; application code must not log or export it by default.

## V2.8 exact diagnostics privacy boundary

V2.8 adds exact overall and per-rule finding counts to analyzer-produced writing results. These values are derived from the same in-memory editor text that Writing insights already analyzes locally.

The new diagnostics are **not**:

- written to `shared_preferences`;
- included in Portable settings exports;
- included in personal-dictionary exports;
- uploaded to a service;
- sent to analytics or telemetry;
- written to a remote log;
- retained as background history after the analysis/dialog is discarded.

Exact counts can still reveal limited characteristics about a document, such as how many findings a rule produced. For that reason they should be treated as document-derived data when adding future logging, debugging, crash reporting, clipboard export, synchronization, or diagnostic-report features.

Any future persistence or export of exact finding totals requires explicit privacy review and user-facing documentation. V2.8 itself keeps them local and memory-only.

The Buy Me a Coffee funding link added to repository documentation is a normal external link. SpellChecker does not contact that site from the application runtime, and no editor text or application state is sent to it by SpellChecker.
