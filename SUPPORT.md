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
- Platform/browser.
- Reproduction steps.
- Expected behavior.
- Actual behavior.
- Minimal synthetic sample text containing no private information.

For V1.2 editor problems, state whether the issue involves:

- Inline underlines/highlights.
- Active issue selection.
- `F7` / `Shift+F7` navigation.
- `Ctrl+Enter` / `Command+Enter` checking.
- Previous/next issue buttons.
- Single replacement.
- **Replace all…**.
- Snackbar **Undo** or **Undo correction**.
- Blank/clean result state.
- Local storage warning.
- Narrow/scrollable issue layout.
- Screen-reader/keyboard accessibility.

For personal-dictionary problems, state whether it involves:

- **Save word**.
- **Ignore once**.
- Import/export.
- Removing/clearing saved words.
- Restoring words after restart/reload.
- Suggestion-count persistence.

If a shortcut is affected, include the exact key combination and whether the visible equivalent control works. Browser/OS key handling can differ.

If replace-all/undo is affected, use repeated synthetic words and describe the capitalization pattern and expected replacement count.

Do not attach a real personal dictionary export or private document if it contains sensitive vocabulary/content. Create a small synthetic reproducer.

## Writing-rules reports

For Writing insights bugs, include the rule name/ID, selected language, synthetic input, expected finding/fix, and whether text changed after analysis. State whether disabling the rule works and whether Undo correction restores the previous document.

Do not post private documents or sensitive writing samples.

## Language-pack reports

For language issues, include the selected pack ID/display name and synthetic sample word. Distinguish among tokenization, normalization, dictionary coverage, variant spelling, suggestion ranking, personal-word isolation, persisted selection, and import/export language metadata.

Do not attach copyrighted dictionary datasets or private vocabulary dumps.

## Feature requests

Use the **Feature request** template. Explain the writing problem, expected behavior, and why it belongs in SpellChecker.

For storage, synchronization, accounts, cloud services, analytics, editor-text persistence, persistent undo/document history, language packs, or keyboard telemetry, include privacy/security expectations.

## Security reports

Do not use normal issues for vulnerabilities. Follow [SECURITY.md](SECURITY.md).

## Privacy-sensitive examples

Never post private documents, account information, secrets, personal messages, sensitive personal vocabulary, or correction-history content as test samples. Replace sensitive content with a minimal synthetic example.

## Personal dictionary recovery

Saved personal words are local and are not cloud-synchronized. Before clearing application/browser data, use **Copy export** if you need a portable backup.

If saved words disappear unexpectedly, follow [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Correction undo expectations

V1.2 correction undo is intentionally session-only and spelling-specific. Manual text editing clears the correction stack, and application restart does not restore it.

If you report an undo problem, distinguish between:

- Undo immediately after a spelling correction.
- Undo after replace-all.
- Undo after subsequent manual typing.
- Undo after document clear or restart.

The last two cases intentionally do not preserve the earlier spelling-correction history.
