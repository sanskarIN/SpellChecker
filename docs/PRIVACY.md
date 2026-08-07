# Privacy

## Summary

SpellChecker version 1.0 is designed to process spelling checks locally.

## User text

The application does not include code that sends editor text to a remote spelling API, analytics service, advertising service, or account system.

Text remains in the running application's local memory unless the hosting platform itself performs unrelated platform-level behavior outside the SpellChecker codebase.

## Personal dictionary

Words added through **Add word** are stored in memory in the active `SpellCheckerEngine` instance.

They are not persisted by SpellChecker version 1.0.

## Ignored words

Ignored words are also stored in memory only for the active engine instance.

## Analytics and telemetry

Version 1.0 contains no analytics SDK, advertising SDK, telemetry SDK, crash-reporting SDK, or remote logging dependency.

## Network access

The spelling engine itself does not require network access.

Development and build tooling may access package repositories when resolving dependencies, which is separate from runtime spelling analysis.

## Future privacy-sensitive features

The following require documentation and design review before implementation:

- Cloud spelling or grammar APIs.
- Synchronization.
- Accounts.
- Persistent dictionaries.
- Analytics.
- Crash reporting.
- Remote configuration.

Any such change must update this document before release.

## Contributions and issue reports

Do not include private documents or personal messages in public bug reports. Use synthetic sample text that reproduces the problem.
