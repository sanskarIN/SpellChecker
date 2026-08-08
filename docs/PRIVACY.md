# Privacy

## Summary

SpellChecker 2.1 performs spelling and optional deterministic writing-rule analysis locally. It stores a deliberately small set of user-controlled settings on the local device/profile and does not persist editor documents or writing-analysis findings.

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

V2.1 application preferences are limited to:

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

SpellChecker 2.1 contains no analytics SDK, advertising SDK, telemetry SDK, account/authentication dependency, cloud spelling/grammar dependency, AI rewriting service, or remote document logging pipeline.

Runtime spelling and writing analysis does not require network access.

Development/build tooling can access package repositories, GitHub, and Flutter distribution infrastructure when dependencies/toolchains are resolved. Those build activities are separate from runtime document analysis.

## Dependency note

`shared_preferences` remains the only non-SDK runtime package dependency and is used for application-local settings.

V2.1 adds no new runtime dependency.

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
