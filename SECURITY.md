# Security Policy

## Supported versions

Security fixes are applied to the latest code on `main` and, when applicable, the newest tagged release.

| Version | Supported |
| --- | --- |
| Latest `main` | Yes |
| Latest release | Yes |
| Older releases | Best effort |

## Reporting a vulnerability

Do not publish exploitable security details, secrets, private documents, sensitive personal vocabulary, or correction-history content in a normal public issue.

Preferred reporting method:

1. Use GitHub Private Vulnerability Reporting if enabled for the repository.
2. If unavailable, contact the maintainer through a private contact method listed on the maintainer's GitHub profile.

A useful report includes:

- Affected version or commit.
- Affected component.
- Reproduction steps using non-sensitive synthetic data.
- Expected and actual behavior.
- Security impact.
- Suggested mitigation, if known.

## Security principles

SpellChecker is designed to:

- Perform spelling/correction analysis locally.
- Avoid transmitting editor text by default.
- Persist only user-controlled personal words and the suggestion-count preference.
- Keep temporary ignored words in memory only.
- Keep checked issue state and V1.2 correction history in memory only.
- Validate source offsets before applying text corrections.
- Validate imported dictionary data instead of executing/interpreting arbitrary content.
- Avoid embedding secrets in source code.
- Minimize runtime dependencies.
- Keep persistent-data formats/keys explicitly versioned where compatibility matters.
- Run automated analysis/tests on proposed changes.

## Local persistence

SpellChecker uses Flutter `shared_preferences` for device/profile-local storage of:

- Personal dictionary words.
- Suggestion-count preference.

SpellChecker does not persist:

- Editor text.
- Checked spelling-result lists.
- Active issue selection.
- Temporary ignored words.
- Suggestion-cache contents.
- V1.2 correction undo snapshots.

The platform-specific `shared_preferences` implementation supplies the storage backend. Treat persisted personal vocabulary as user data and avoid logging/exposing it unnecessarily.

## V1.2 text-correction safety

`SpellIssue` offsets are valid only for the text snapshot that was checked. V1.2 correction code verifies that the current substring still matches the issue before mutation.

For replace-all:

- Only current checked ranges matching the target issue word are eligible.
- Ranges are applied from later offsets toward earlier offsets.
- Stale ranges are skipped instead of blindly mutating unrelated text.

Contributors must preserve these checks when modifying correction behavior. A correction path that applies stale/unvalidated offsets could corrupt user text.

## Correction undo data

The V1.2 spelling-correction undo stack can contain editor-text snapshots. It is intentionally:

- Memory-only.
- Bounded.
- Cleared when manual text editing begins a new correction history.
- Discarded with the application session.
- Excluded from preference storage and dictionary exports.

Any change that persists, logs, synchronizes, or uploads correction snapshots requires explicit security/privacy review.

## Inline highlighting

Inline highlights are generated from checked in-memory issue ranges. The editing controller validates ranges against current text before styling them and skips invalid/stale ranges.

Visual highlights are presentation data; they are not persisted or exported.

## Keyboard shortcuts

SpellChecker handles local shortcut events for checking/navigation. It does not record keyboard telemetry or maintain a key-event history.

Changes introducing global keyboard hooks, background key capture, or keyboard analytics require explicit security/privacy review.

## Import/export safety

Personal dictionary import accepts only validated word entries from supported versioned JSON, JSON arrays, or plain word lists.

Codec changes should:

- Reject malformed entries rather than evaluating/executing imported content.
- Keep the format data-only.
- Preserve explicit version checks.
- Avoid automatic network fetch/import without separate review.

Dictionary export writes user-approved vocabulary to the clipboard only after explicit action. It does not upload the export.

## Dependency review

Review new dependencies for:

- Runtime network behavior.
- Telemetry/analytics behavior.
- Storage scope.
- Platform permissions.
- Maintenance/security posture.
- Whether functionality can remain local.

`shared_preferences` is used only for application-local preference persistence. V1.2 adds no new runtime dependency.

## Dependency and secret hygiene

Do not commit:

- API keys.
- Passwords.
- Signing certificates.
- Service-account credentials.
- Access tokens.
- Private user documents.
- Real sensitive personal dictionary exports.
- Real editor/correction-history samples containing private content.

The repository `.gitignore` covers common secret/build patterns, but contributors remain responsible for reviewing every commit.

## Privacy-sensitive changes

These require explicit security/privacy review and updates to `docs/PRIVACY.md` before implementation/release:

- Synchronization.
- Accounts.
- Cloud spelling/grammar/AI services.
- Analytics or remote logging.
- Crash reporting.
- Remote configuration.
- Editor-text persistence.
- Persistent/general document history.
- Persistent correction undo history.
- Automatic dictionary upload.
- Keyboard/usage telemetry.
- Global/background key capture.
