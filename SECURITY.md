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
- Reproduction steps using non-sensitive test data.
- Expected and actual behavior.
- Security impact.
- Suggested mitigation, if known.

Do not send real credentials, private documents, or personal user content as test data.

## Security principles

SpellChecker is designed to:

- Perform spelling analysis locally.
- Avoid transmitting user text by default.
- Avoid storing session words permanently in version 1.0.
- Avoid embedding secrets in source code.
- Minimize dependencies.
- Run automated formatting, analysis, and tests on changes.

## Dependency and secret hygiene

Contributors must not commit:

- API keys.
- Passwords.
- Signing certificates.
- Service-account credentials.
- Access tokens.
- Private user documents.

The repository `.gitignore` contains common secret and build-output patterns, but contributors remain responsible for reviewing every commit before pushing it.
