# Support

SpellChecker is an open-source project maintained through GitHub.

## Usage questions

Before opening an issue:

1. Read the [README](README.md).
2. Read the [User Guide](docs/USER_GUIDE.md).
3. Check [Troubleshooting](docs/TROUBLESHOOTING.md).
4. Search existing issues for the same problem.

## Bug reports

Use the repository **Bug report** issue template. Include:

- SpellChecker version or commit.
- Flutter/Dart version when developing locally.
- Platform/browser and, for persistence problems, whether private/incognito mode is involved.
- Reproduction steps.
- Expected behavior.
- Actual behavior.
- Minimal synthetic sample text that contains no private information.

For personal-dictionary problems, also state whether the problem involves:

- **Save word**.
- **Ignore once**.
- Import.
- Copy export.
- Removing/clearing saved words.
- Restoring words after restart/reload.
- Suggestion-count persistence.

Do not attach a real personal dictionary export if its vocabulary is sensitive. Create a small synthetic export that reproduces the problem.

## Feature requests

Use the **Feature request** template. Explain the writing problem being solved, the expected behavior, and why it belongs in SpellChecker.

For features involving storage, synchronization, accounts, cloud services, analytics, or editor-text persistence, describe the privacy/security expectations as part of the request.

## Security reports

Do not use normal issues for vulnerabilities. Follow [SECURITY.md](SECURITY.md).

## Privacy-sensitive examples

Never post private documents, account information, secrets, personal messages, or sensitive personal vocabulary as spelling test samples. Replace sensitive content with a minimal synthetic example.

## Personal dictionary recovery

SpellChecker V1.1 stores saved personal words locally and does not provide cloud synchronization. Before clearing application/browser data, use **Copy export** if you need a portable backup of personal vocabulary.

If saved words disappear unexpectedly, follow the persistence checks in [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) before opening an issue.
