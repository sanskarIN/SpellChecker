# Security Policy

## Supported versions

SpellChecker is currently in early development. Security fixes are applied to the latest code on the default branch and the newest supported release.

## Reporting a vulnerability

Please do not publish exploitable security details in a public issue.

If GitHub private vulnerability reporting is enabled for this repository, use it to report security problems. Otherwise, contact the maintainer privately through an available GitHub contact channel and provide only the information needed to reproduce and understand the issue.

A useful report includes:

- The affected component and version or commit.
- Steps needed to reproduce the problem.
- The security impact.
- Any suggested mitigation, if known.

Please avoid including real secrets, credentials, or private user data in reports or test cases.

## Security principles

SpellChecker should:

- Avoid committing credentials and signing keys.
- Minimize collection or transmission of user text.
- Keep spell-checking functionality local by default unless a future feature clearly documents otherwise.
- Review dependencies before adding them.
- Keep automated analysis and tests enabled for proposed changes.
