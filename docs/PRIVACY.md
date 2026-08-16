# Privacy

SpellChecker is designed so the bundled spelling and writing-analysis workflow can operate locally without sending editor text to a remote spelling, grammar, AI, analytics, or account service.

This page documents the current `2.16.0+21` application/library privacy model. Security reporting requirements are in [SECURITY.md](../SECURITY.md).

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

### Spelling issues/suggestions

Purpose: current checked result presentation and correction.

Durability: in-memory result state only.

Network: not transmitted by SpellChecker.

Transfer: not exported by application settings/dictionary formats.

### Writing findings

Purpose: current Writing insights review and correction.

Durability: in-memory dialog/analysis result state only.

Network: not transmitted by SpellChecker.

Transfer: findings/excerpts/messages/replacements/offsets are excluded from the metadata-only diagnostic summary and Portable settings.

### Selected language

Purpose: choose the active built-in language pack.

Durability: stored locally when preference storage succeeds.

Portable settings: included.

### Suggestion count

Purpose: configure number of spelling suggestions shown/generated per captured issue in the application.

Durability: stored locally when preference storage succeeds.

Portable settings: included.

### Personal vocabulary

Purpose: accept user-specific words and include them as suggestion candidates for a selected language.

Durability: stored locally per language when preference storage succeeds.

Portable settings: **excluded**.

Personal-dictionary export: included only when the user explicitly chooses copy/export in the dictionary manager.

### Writing-rule choices

Purpose: choose enabled deterministic writing rules per language.

Durability: stored locally per language as rule IDs when preference storage succeeds.

Portable settings: explicit per-language overrides are included.

No editor source/finding data is stored with rule preferences.

### Ignored session words

Purpose: temporarily suppress spelling findings for a word.

Durability: engine/session memory only.

Portable settings: excluded.

Personal-dictionary export: excluded.

### Correction undo history

Purpose: restore a previous editing value after an application correction.

Durability: bounded in-memory session stack only.

Portable settings: excluded.

### Writing insights search/filter/preset state

Purpose: temporary local review scope.

Durability: open-dialog memory only.

Portable settings: excluded.

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

## Internal preference keys

Internal keys are documented for debugging/migration in [Configuration](CONFIGURATION.md). They are not a public integration API and should not be treated as a stable external database schema.

## Storage failure behavior

SpellChecker treats an unsuccessful preference write/remove as failure rather than silently claiming a value was saved.

When storage is unavailable/fails:

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

The summary includes metadata such as:

- language ID;
- complete/limited state;
- capture limit;
- captured/exact/uncaptured finding counts;
- stable rule IDs/display names;
- per-rule captured/exact counts.

It deliberately excludes:

- editor text;
- source excerpts;
- finding messages;
- replacements;
- source offsets.

This makes it safer for support discussions, but metadata can still reveal which rule types fired and rough counts. Review any copied diagnostic before posting it publicly if that context is sensitive.

## Clipboard boundary

The application uses Flutter clipboard APIs only for explicit copy actions such as:

- personal-dictionary export;
- Portable settings export;
- writing diagnostic summary.

SpellChecker does not automatically copy editor text to the clipboard.

Once data is on the system clipboard, other software/host policies may be able to read it according to operating-system/browser behavior. Clear the clipboard after copying sensitive personal vocabulary if appropriate for your environment.

## Network boundary

Core spelling/writing APIs do not perform network requests. The current runtime dependency set is Flutter plus `shared_preferences`; no HTTP client, analytics SDK, ad SDK, remote model client, or account SDK is required for analysis.

Repository documentation contains external links (GitHub, Buy Me a Coffee, etc.). Visiting an external link is a separate user/navigation action and is not part of editor analysis.

Future changes that add runtime networking must update this privacy contract, security review, tests, and user-facing disclosure in the same change.

## BMC/funding privacy boundary

The canonical optional project funding link is:

```text
https://buymeacoffee.com/sanskarIN
```

It exists in repository/support surfaces. Funding is optional and separate from SpellChecker text analysis. The application does not send editor text or analysis findings to Buy Me a Coffee.

## Benchmark privacy

The benchmark tooling under `tool/` generates synthetic text/scenarios and records deterministic analysis metadata/timing. It is a local developer tool, not background telemetry.

Do not replace the synthetic benchmark corpus with private documents in public benchmark reports.

## Tests and examples

Project documentation/tests should use synthetic examples. Bug reports should prefer minimal artificial text rather than real private documents.

Never include in public issues unless necessary and safe:

- private documents/messages;
- credentials/secrets;
- account information;
- sensitive personal vocabulary;
- real correction-history snapshots;
- private finding/source excerpts.

See [Support](../SUPPORT.md).

## Browser/web host considerations

The committed/release-built target is Flutter web. Browser behavior can affect:

- local site storage availability/retention;
- clipboard permissions;
- private/incognito storage lifetime;
- enterprise storage policies.

SpellChecker can surface preference-layer failure but cannot override browser privacy/storage policies.

## Native target considerations

Native runners are not currently committed/release-built. If official native support is added, privacy review must cover that platform's preference backing store, clipboard behavior, permissions, file access, crash reporting, update systems, and any signing/distribution integrations.

See [Platform support](PLATFORM_SUPPORT.md).

## Library integrator responsibility

Reusable `SpellCheckerEngine`, `WritingAnalyzer`, correction helpers, and codecs are local deterministic code. A third-party application can of course choose to send its own text/results elsewhere; that behavior belongs to the integrating application and is not created automatically by SpellChecker's public analysis APIs.

Integrators should clearly document any additional network/storage/logging paths they add around the library.

## Logs and exceptions

Core validation can throw local exceptions such as `FormatException`/`ArgumentError` for invalid input/configuration. SpellChecker does not install a remote logging pipeline for those errors.

Avoid logging raw editor text/personal vocabulary/findings in any future diagnostic integration unless there is an explicit, privacy-reviewed user-controlled design.

## Data deletion/reset

SpellChecker provides application controls for:

- clearing editor text;
- clearing ignored session words;
- removing/clearing personal words for the current language;
- resetting writing rules to registry defaults by removing an explicit override.

Complete host preference deletion can also be performed through browser/application data management outside SpellChecker, but that may delete all local settings/vocabulary. Back up first if necessary.

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
- export/import content.

For such changes, update this page, [Security](../SECURITY.md), [Architecture](ARCHITECTURE.md), current user docs, and relevant tests before merge.

## Related documentation

- [Configuration and local data](CONFIGURATION.md)
- [Architecture](ARCHITECTURE.md)
- [Security](../SECURITY.md)
- [Support](../SUPPORT.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Troubleshooting](TROUBLESHOOTING.md)
