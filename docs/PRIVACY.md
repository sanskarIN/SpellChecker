# Privacy

## Summary

SpellChecker version 1.2 performs spelling analysis locally and stores only a small set of user-controlled preferences on the local device/profile.

V1.2 adds inline highlighting, active issue navigation, replace-all, keyboard shortcuts, and spelling-correction undo. None of those features add cloud processing, analytics, authentication, advertising, telemetry, or new persistent document storage.

## User text

SpellChecker does not include code that sends editor text to:

- A remote spelling API.
- An analytics service.
- An advertising service.
- An account system.
- A telemetry or remote-logging pipeline.
- A cloud correction or rewriting service.

Editor text remains in the running application memory. SpellChecker does not persist editor documents.

Hosting platforms, browsers, operating systems, development tools, or user-installed software can have behavior outside this repository; that behavior is not part of SpellChecker's application code.

## Checked issue data

A spelling check creates an in-memory `List<SpellIssue>` containing:

- The source word.
- Start/end character offsets.
- Ranked suggestions.

V1.2 also keeps an in-memory active issue index so the editor and Results panel can stay synchronized.

Checked issue data is not written to preferences, files, or a remote service by SpellChecker. Manual editing clears the previous checked issue/highlight state because offsets belong to a specific text snapshot.

## Correction undo snapshots

V1.2 keeps a bounded in-memory spelling-correction undo stack. Each entry is a `TextEditingValue` representing the editor state immediately before a spelling correction.

Because an undo snapshot can contain editor text, the following privacy requirements apply:

- Correction snapshots remain memory-only.
- They are not written to `shared_preferences`.
- They are not included in dictionary exports.
- They are not sent over a network.
- They are discarded when the application process/session ends.
- Manual text input clears the spelling-specific correction stack, beginning a new correction history.
- The editor's **Clear** action clears the current document/correction history.

A future feature that persists document/correction history would require an explicit privacy redesign and documentation update before release.

## Personal dictionary

Words saved through **Save word** or the personal-dictionary manager are persisted through Flutter `shared_preferences`.

Stored values are normalized personal vocabulary only. The application does not store the surrounding sentence/document that caused a word to be saved.

The exact backing mechanism is selected by the `shared_preferences` plugin for each platform/profile. For example, a browser build uses browser-local application storage rather than a SpellChecker cloud service.

## Suggestion-count preference

The selected 1–10 suggestion count is stored through `shared_preferences` so the setting survives normal application restarts.

## Ignored words

Ignored words are intentionally session-only. They remain in the active `SpellCheckerEngine` instance and are not written to persistent preferences.

## Inline highlights

Inline issue underlines are generated from the current checked issue list by the in-memory editing controller. SpellChecker does not save screenshots, styled text, highlight ranges, or rendered spans.

The active issue receives additional visual styling and editor selection, but those values are transient UI state.

## Keyboard shortcuts

V1.2 listens for local keyboard events such as:

- `Ctrl+Enter` / `Command+Enter` for checking.
- `F7` / `Shift+F7` for issue navigation.

SpellChecker does not record keyboard telemetry or maintain a keystroke log. The editor necessarily receives user text through Flutter's normal text-input system while the application is running.

## Import and export

Dictionary import/export is user initiated.

- Import reads text pasted by the user into the application.
- Export writes the personal-dictionary JSON document to the local clipboard.
- SpellChecker does not upload imported/exported dictionary data.

Clipboard contents can be read/managed by the host platform according to platform permissions and policies. SpellChecker writes the export only when the user selects **Copy export**.

## Stored preference keys

The application uses versioned local keys for:

- Personal words.
- Suggestion-count preference.

Versioned keys allow future migrations to be explicit rather than silently changing existing-data meaning.

V1.2 does not add a new preference key for editor text, issues, active issue state, shortcuts, or correction history.

## Analytics and telemetry

Version 1.2 contains no analytics SDK, advertising SDK, telemetry SDK, crash-reporting SDK, or remote logging dependency.

## Network access

The runtime spelling/correction engine does not require network access.

Development/build tooling can access package repositories while resolving dependencies. GitHub Actions downloads Flutter/package dependencies while validating the repository. Those build/development activities are separate from runtime spelling analysis.

## Dependency note

`shared_preferences` remains the only non-SDK runtime dependency and is used solely for local preference persistence. V1.2 adds no new runtime dependency.

## Data deletion

Users can remove saved personal vocabulary through the personal-dictionary manager:

- Remove individual words.
- Select **Clear all** to delete the saved personal-word list.

Ignored words disappear when cleared or when the application session ends.

The editor's **Clear** action removes:

- Current visible editor text.
- Current checked issue/highlight state.
- Current spelling-correction undo stack.

It does not modify saved personal dictionary preferences or the suggestion-count preference.

## Storage failures

If local preference storage cannot load or write, SpellChecker surfaces a warning and continues session spelling where possible.

A storage failure does not cause editor text to be sent to a remote fallback service; there is no remote fallback spelling/persistence service in V1.2.

## Future privacy-sensitive features

These require explicit design/privacy review and an update to this document before release:

- Cloud spelling or grammar APIs.
- Cloud AI rewriting.
- Cross-device synchronization.
- Accounts.
- Analytics.
- Crash reporting.
- Remote configuration.
- Any persistence of editor documents.
- Persistent general document history or correction undo history.
- Automatic upload of personal dictionaries.
- Keyboard/usage telemetry.

Any optional network feature must be clearly user-controlled and must not silently change the privacy-first default.

## Contributions and issue reports

Do not include private documents, secrets, personal messages, or sensitive personal dictionary exports in public bug reports/tests. Use minimal synthetic text that reproduces the problem.
