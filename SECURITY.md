# Security Policy

## Supported versions

Security fixes are applied to the latest code on `main` and, when applicable, the newest tagged release.

| Version | Supported |
| --- | --- |
| Latest `main` | Yes |
| Latest release | Yes |
| Older releases | Best effort |

## Reporting a vulnerability

Do not publish exploitable security details, secrets, or private user data in a normal public issue.

Preferred reporting method:

1. Use GitHub Private Vulnerability Reporting if it is enabled for the repository.
2. If private reporting is unavailable, contact the maintainer through a private contact method listed on the maintainer's GitHub profile.

A useful report includes:

- Affected version or commit.
- Affected component.
- Reproduction steps using non-sensitive synthetic test data.
- Expected and actual behavior.
- Security impact.
- Suggested mitigation, if known.

Do not send real credentials, private documents, personal messages, or private dictionary exports as test data.

## Security principles

SpellChecker is designed to:

- Perform spelling analysis locally.
- Avoid transmitting editor text by default.
- Persist only user-controlled personal words and the suggestion-count preference in V1.1.
- Keep temporary ignored words in memory only.
- Avoid embedding secrets in source code.
- Minimize runtime dependencies.
- Keep persistent-data formats and keys explicitly versioned where compatibility matters.
- Run automated analysis and tests on proposed changes.

## Local persistence in V1.1

V1.1 uses Flutter `shared_preferences` for device/profile-local storage of:

- Personal dictionary words.
- Suggestion-count preference.

SpellChecker does not persist editor text, spelling-result lists, temporary ignored words, or suggestion-cache contents.

The storage backend is provided by the platform-specific `shared_preferences` implementation. Contributors should treat persisted personal vocabulary as user data and avoid logging or exposing it unnecessarily.

## Import/export safety

Personal dictionary import accepts only validated word entries from supported versioned JSON, JSON arrays, or plain word lists.

Contributors changing the codec should:

- Reject malformed entries instead of evaluating or executing imported content.
- Keep the format data-only.
- Preserve explicit version checks.
- Avoid adding automatic network fetch/import behavior without separate security/privacy review.

Dictionary export writes user-approved vocabulary to the clipboard only after an explicit user action. It does not upload the export.

## Dependency review

New dependencies should be reviewed for:

- Runtime network behavior.
- Telemetry/analytics behavior.
- Storage scope.
- Platform permissions.
- Maintenance/security posture.
- Whether the functionality can reasonably remain local.

The V1.1 `shared_preferences` dependency is used only for application-local preference persistence.

## Dependency and secret hygiene

Contributors must not commit:

- API keys.
- Passwords.
- Signing certificates.
- Service-account credentials.
- Access tokens.
- Private user documents.
- Real personal dictionary exports containing sensitive vocabulary.

The repository `.gitignore` contains common secret and build-output patterns, but contributors remain responsible for reviewing every commit before pushing it.

## Privacy-sensitive changes

Synchronization, accounts, cloud spelling/grammar services, analytics, crash reporting, remote configuration, or editor-text persistence require explicit security/privacy review before implementation and corresponding updates to `docs/PRIVACY.md`.
