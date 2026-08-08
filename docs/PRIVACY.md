# Privacy

## Summary

SpellChecker version 1.1 performs spelling analysis locally and stores only a small set of user-controlled preferences on the local device/profile.

## User text

SpellChecker does not include code that sends editor text to:

- A remote spelling API.
- An analytics service.
- An advertising service.
- An account system.
- A telemetry or remote-logging pipeline.

Editor text remains in the running application memory. SpellChecker does not persist editor documents.

Hosting platforms, browsers, operating systems, development tools, or user-installed software may have behavior outside this repository; that behavior is not part of SpellChecker's application code.

## Personal dictionary

Words saved through **Save word** or the personal-dictionary manager are persisted through Flutter `shared_preferences`.

Stored values are normalized personal vocabulary only. The application does not store the surrounding sentence or document that caused a word to be saved.

The exact backing mechanism is chosen by the `shared_preferences` plugin for each platform/profile. For example, a browser build uses browser-local application storage rather than a SpellChecker cloud service.

## Suggestion-count preference

The selected 1–10 suggestion count is also stored through `shared_preferences` so the setting survives normal application restarts.

## Ignored words

Ignored words are intentionally session-only. They remain in the active `SpellCheckerEngine` instance and are not written to persistent preferences.

## Import and export

Dictionary import/export is user initiated.

- Import reads text pasted by the user into the application.
- Export writes the personal-dictionary JSON document to the local clipboard.
- SpellChecker does not upload imported or exported dictionary data.

Clipboard contents can be read or managed by the host platform according to platform permissions and policies; SpellChecker itself only writes the export when the user selects **Copy export**.

## Stored preference keys

The current application uses versioned local keys for:

- Personal words.
- Suggestion-count preference.

Versioned keys allow future migrations to be explicit rather than silently changing the meaning of existing data.

## Analytics and telemetry

Version 1.1 contains no analytics SDK, advertising SDK, telemetry SDK, crash-reporting SDK, or remote logging dependency.

## Network access

The runtime spelling engine does not require network access.

Development and build tooling can access package repositories when resolving dependencies. GitHub Actions also downloads Flutter and package dependencies while validating the repository. Those development/build activities are separate from runtime spelling analysis.

## Dependency note

V1.1 adds `shared_preferences` solely for local preference persistence. It is not used for networking, analytics, authentication, or synchronization.

## Data deletion

Users can remove saved personal vocabulary through the personal-dictionary manager:

- Remove individual words.
- Select **Clear all** to delete the saved personal-word list.

Ignored words disappear when cleared or when the application session ends.

The editor's **Clear** action removes current editor text from the visible controller state but does not modify saved dictionary preferences.

## Future privacy-sensitive features

The following require explicit design review and an update to this document before release:

- Cloud spelling or grammar APIs.
- Cross-device synchronization.
- Accounts.
- Analytics.
- Crash reporting.
- Remote configuration.
- Any persistence of editor text.

Any optional network feature should be clearly user-controlled and must not silently change the project's privacy-first default.

## Contributions and issue reports

Do not include private documents, secrets, or personal messages in public bug reports. Use synthetic sample text that reproduces the problem.
