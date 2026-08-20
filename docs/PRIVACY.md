# Privacy

SpellChecker is designed so the bundled spelling and writing-analysis workflow operates locally without sending editor text to a remote spelling, grammar, AI, analytics, advertising, or account service.

This page documents the current `3.2.0+25` application/library privacy model. Security reporting requirements are in [SECURITY.md](../SECURITY.md).

## Summary

The bundled application does **not** require or implement:

- remote spelling/grammar analysis;
- generative rewriting/model inference;
- document upload;
- user accounts;
- cloud preference synchronization;
- cloud personal-dictionary synchronization;
- editor-analysis telemetry;
- advertising SDKs;
- remote logging of editor text/findings.

Durable application configuration uses Flutter's local `shared_preferences` abstraction.

## Data inventory

### Editor text

Purpose: current user editing and in-memory spelling/writing analysis.

Durability: not stored by SpellChecker as a preference/document.

Network: not transmitted by the bundled spelling/writing implementation.

Transfer: excluded from Portable settings, personal-dictionary export, and diagnostic summary.

### Spelling issues and writing findings

Purpose: current review, suggestion, and correction workflows.

Durability: in-memory result state only.

Network: not transmitted by SpellChecker.

Transfer: findings, source excerpts, offsets, and replacement text are not exported by Portable settings or personal-dictionary formats.

### Selected language and suggestion count

Purpose: configure the active built-in language pack and spelling suggestion limit.

Durability: stored locally when preference storage succeeds.

Portable settings: included.

### Personal vocabulary

Purpose: accept user-specific words and include them as suggestion candidates for the selected language.

Durability: stored locally per language when preference storage succeeds.

Portable settings: **excluded**.

Personal-dictionary export: included only when the user explicitly chooses copy/export in the dictionary manager.

### Writing-rule choices

Purpose: choose enabled deterministic writing rules per language.

Durability: stored locally per language as rule IDs when preference storage succeeds.

Portable settings: explicit per-language overrides are included.

No editor source/finding data is stored with rule preferences.

### Session-only state

Ignored words, correction undo history, Writing insights search/filter state, captured issues, and analysis results remain in session memory and are not part of the durable preference contract.

## Local preference storage

SpellChecker uses the `shared_preferences` Flutter plugin as an abstraction over host-local preference storage.

Current durable categories:

```text
selected language
suggestion limit
per-language personal words
per-language explicit writing-rule IDs
```

Physical backing-store details depend on the platform/plugin and are not part of SpellChecker's public API.

Browser/site/app storage can be cleared by the user, host browser, operating system, enterprise policy, or platform lifecycle. Export vocabulary/settings before clearing host data if those values matter.

## Android privacy boundary

Android is an officially committed and release-built target. The production Android manifest intentionally:

- requests **no** `android.permission.INTERNET` permission;
- sets `android:allowBackup="false"` so Android cloud backup does not copy SpellChecker shared preferences by default;
- sets `android:usesCleartextTraffic="false"`;
- requires no runtime permission for the core spelling/writing workflow.

The debug and profile Android manifests can request Internet access because Flutter development tooling needs it for debugging and hot reload. That development-only permission is not declared by the production `android/app/src/main/AndroidManifest.xml`.

Android Auto Backup normally includes shared preferences. Disabling backup prevents cloud-based backup/restore of those preferences. On Android 12 and newer, direct device-to-device migration behavior can vary by Android version and device manufacturer even when cloud backup is disabled.

See [Android support](../android/README.md) for build, signing, Play packaging, and Android device-testing guidance.

## Native platform considerations

Official Flutter runners are committed for Android, iOS, Linux, macOS, Web, and Windows. Native platform behavior can affect physical preference storage, clipboard behavior, accessibility, windowing, signing, and distribution.

The repository does not add analytics, crash-upload SDKs, account SDKs, or remote model clients for any target. Signing credentials and store credentials remain external release secrets and are not runtime data collection mechanisms.

See [Platform support](PLATFORM_SUPPORT.md).

## Storage failure behavior

SpellChecker treats an unsuccessful preference write/remove as failure rather than silently claiming a value was saved.

When storage is unavailable or fails:

- session spelling can continue where possible;
- the UI reports a persistence warning;
- operations that require durable state avoid falsely claiming durability;
- some state may remain active in memory only, depending on the workflow;
- personal-word save attempts are rolled back in memory when durable save fails.

## Personal dictionary export/import

Dictionary export is an explicit clipboard action initiated by the user.

Current language-aware export contains:

```text
format version
language ID
normalized personal words
```

It does **not** contain editor text, ignored words, findings, correction history, or writing-rule settings.

Dictionary import reads user-supplied clipboard/text input locally and validates/normalizes it before merging accepted words into the selected language's personal dictionary.

A version-2 dictionary for another supported language is not silently merged into the current language; the UI asks the user to switch language first.

Because personal vocabulary can itself be sensitive, review exported JSON before sharing it with anyone.

## Portable settings export/import

Portable settings is another explicit copy/paste path.

Included:

```text
selected language
suggestion limit
explicit per-language writing-rule overrides
```

Excluded:

```text
editor text
personal vocabulary
ignored session words
spelling issues/suggestions
writing findings/messages/excerpts/replacements/offsets
correction history
transient review search/filter/preset state
```

Portable settings is designed to be non-document configuration only.

## Diagnostic summary

Writing insights can copy a `WritingAnalysisDiagnosticSummary` after an explicit user action.

The summary contains metadata such as language ID, complete/limited state, capture limits, counts, and stable rule identifiers. It deliberately excludes editor text, source excerpts, finding messages, replacements, and source offsets.

Metadata can still reveal which rule types fired and rough counts, so review copied diagnostics before posting them publicly when the context is sensitive.

## Clipboard boundary

The application uses Flutter clipboard APIs only for explicit copy actions such as:

- personal-dictionary export;
- Portable settings export;
- writing diagnostic summary.

SpellChecker does not automatically copy editor text to the clipboard.

Once data is on the system clipboard, other software or host policies may be able to read it according to operating-system/browser behavior.

## Network boundary

Core spelling/writing APIs do not perform network requests. The current runtime dependency set is Flutter plus `shared_preferences`; no HTTP client, analytics SDK, ad SDK, remote model client, or account SDK is required for analysis.

Repository documentation contains external links such as GitHub and Buy Me a Coffee. Visiting an external link is a separate user navigation action and is not part of editor analysis.

Future changes that add runtime networking must update this privacy contract, security review, tests, and user-facing disclosure in the same change.

## BMC/funding privacy boundary

The canonical optional project funding link is:

```text
https://buymeacoffee.com/sanskarIN
```

Funding is optional and separate from SpellChecker text analysis. The application does not send editor text or analysis findings to Buy Me a Coffee.

## Benchmark and test privacy

Benchmark tooling under `tool/` generates synthetic text/scenarios and records deterministic analysis metadata/timing. It is local developer tooling, not background telemetry.

Project documentation/tests should use synthetic examples. Public bug reports should prefer minimal artificial text rather than private documents or messages.

Never include credentials, secrets, private documents, account information, or sensitive personal vocabulary in public issues unless doing so is necessary and safe.

See [Support](../SUPPORT.md).

## Browser/web host considerations

Browser behavior can affect local site storage availability/retention, clipboard permissions, private/incognito storage lifetime, and enterprise storage policies.

SpellChecker can surface preference-layer failure but cannot override browser privacy/storage policies.

## Library integrator responsibility

Reusable `SpellCheckerEngine`, `WritingAnalyzer`, correction helpers, and codecs are local deterministic code. A third-party application can choose to send its own text/results elsewhere; that behavior belongs to the integrating application and is not created automatically by SpellChecker's public analysis APIs.

Integrators should clearly document any additional network, storage, or logging paths they add around the library.

## Logs and exceptions

Core validation can throw local exceptions such as `FormatException` or `ArgumentError` for invalid input/configuration. SpellChecker does not install a remote logging pipeline for those errors.

Avoid logging raw editor text, personal vocabulary, or findings in future diagnostics unless there is an explicit, privacy-reviewed, user-controlled design.

## Data deletion/reset

SpellChecker provides application controls for clearing editor text, clearing ignored session words, removing personal words for the current language, and resetting writing rules to registry defaults.

Complete host preference deletion can also be performed through browser/application data management outside SpellChecker, but that may delete all local settings/vocabulary. Back up intentionally exported data first if necessary.

## Privacy review checklist for contributors

A change requires explicit privacy review when it introduces or changes:

- network communication;
- telemetry/analytics/crash upload;
- user/account identifiers;
- file/document persistence;
- clipboard automation;
- new durable data categories;
- external dictionary/model downloads;
- third-party plugin execution;
- platform permissions;
- diagnostic/logging content;
- export/import content;
- platform backup/restore behavior.

For such changes, update this page, [Security](../SECURITY.md), [Architecture](ARCHITECTURE.md), current user docs, and relevant validation before merge.

## Related documentation

- [Android support](../android/README.md)
- [Configuration and local data](CONFIGURATION.md)
- [Architecture](ARCHITECTURE.md)
- [Security](../SECURITY.md)
- [Support](../SUPPORT.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Troubleshooting](TROUBLESHOOTING.md)
