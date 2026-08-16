# Support

<p align="center">
  <a href="https://buymeacoffee.com/sanskarIN">
    <img alt="Buy Me a Coffee — Support SpellChecker" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20SpellChecker-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=000000">
  </a>
</p>

> SpellChecker is free and open source. Financial support is optional; if you want to help continued development, use the highlighted **Buy Me a Coffee** link above.

## V2.16 final stabilization
When reporting a V2.16 problem, include the exact app version, platform, selected language, whether local preferences finished loading, a minimal non-sensitive input, and whether the problem involves decomposed Unicode, imported settings/dictionaries, persistence, or startup actions. Do not include private documents unless the minimal text itself is safe to share.


## V2.15 support note
`unmatched-curly-brace` is advisory-only. If a `{` or `}` warning appears, SpellChecker intentionally does not guess whether to insert, delete, move, or rewrite text. The rule can be disabled per language in Writing insights.


## V2.14 unmatched-square-bracket reports

For an unexpected V2.14 structural finding, include the app version `2.14.0`, language pack, stable rule ID `unmatched-square-bracket`, whether the rule preference is default or explicit, and a minimal non-sensitive delimiter pattern when possible. Privacy-safe Writing analysis diagnostics can provide rule/count metadata without copying the editor document.

## V2.13 support note

For unmatched-parenthesis reports, include whether the text intentionally contains literal unmatched delimiters (for example in code or markup) and whether the rule was enabled explicitly or through defaults. The **Copy diagnostic summary** action can share the stable rule ID and counts without copying document excerpts. Do not include private document text unless you choose to share it separately.

## V2.12 support note

For `Hello,world`-style cases, confirm the selected language is English (US) or English (UK) and that **Missing punctuation space** is enabled in Writing insights. Users with an older explicit rule selection may need **Reset rules to defaults** to opt into the new seventh default rule. Period and colon boundaries are intentionally outside V2.12's automatic scope.
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
- Selected language.
- Minimal synthetic reproduction steps.
- Expected behavior.
- Actual behavior.
- Whether the equivalent visible control works when a keyboard shortcut is involved.

Never attach private documents or sensitive vocabulary when a short synthetic sample can reproduce the problem.

# Spelling/editor reports

For spelling/editor bugs, say whether the issue involves:

- Inline underlines/highlights.
- Active issue selection.
- `F7` / `Shift+F7` navigation.
- `Ctrl+Enter` / `Command+Enter` spelling check.
- Previous/next issue controls.
- Single spelling replacement.
- **Replace all…**.
- **Undo** / **Undo correction**.
- Blank/clean states.
- Storage warning.
- Narrow/scrollable layout.
- Screen-reader/keyboard accessibility.

For replace-all/undo bugs, use repeated synthetic words and include the expected replacement count/casing.

# Writing insights reports

For Writing insights bugs include:

- Selected language ID/display name.
- Rule display name and stable ID when known.
- Synthetic input text.
- Which rule switches are enabled.
- Expected finding/fix.
- Actual finding/fix.
- Whether text changed after the analysis was produced.
- Whether **Undo correction** restores the previous document.

## V2.1 persisted rule preference bugs

State whether the issue is:

- A switch not persisting after close/reopen.
- A switch not restoring after application restart.
- US/UK rule preference leakage.
- Explicit disable-all unexpectedly becoming defaults.
- A newly added rule unexpectedly changing an explicit stored set.
- Storage-warning/failure behavior.

If safe to do so, report only the stored **rule IDs**, never editor content. Example:

```text
en-US enabled IDs: repeated-word, sentence-capitalization
```

Do not post local preference dumps that contain sensitive personal vocabulary.

## V2.1 batch fix bugs

For **Apply all safe fixes** issues, include:

- Synthetic input.
- Finding rule IDs/ranges if known.
- Expected final synthetic text.
- Actual final synthetic text.
- Applied/skipped counts shown by the UI.
- Whether any findings overlapped.
- Whether text changed after analysis.
- Whether one Undo restores the exact pre-batch text.

The expected V2.1 overlap policy is deterministic: earliest safe source range wins; later overlapping fixes are skipped.

# V2.2 review-management reports

For search/filter problems include synthetic text plus:

- Search query (synthetic/non-sensitive).
- Selected category chips.
- Automatic-fixes-only state.
- Visible/total finding counts.
- Whether **Clear review filters** restores the expected finding.
- Whether the problem affects rule switches, findings, or both.

For **Apply visible safe fixes** bugs include expected/actual synthetic final text, visible automatic finding count, applied/skipped feedback, and whether one Undo restores the exact pre-batch text.

For **Reset rules to defaults** bugs state the selected language, prior enabled rule IDs, whether the stored per-language rule key was removed, whether defaults became active immediately, and whether an old override reappeared after restart. Do not post private editor text or a full preference dump.

# Language-pack reports

Include the selected pack ID/display name and synthetic sample.

Distinguish among:

- Tokenization.
- Normalization.
- Dictionary coverage.
- US/UK variant behavior.
- Suggestion ranking.
- Personal-word isolation.
- Writing-rule preference isolation.
- Persisted language selection.
- Import/export language metadata.

Do not attach copyrighted dictionary datasets or private vocabulary dumps.

# Personal dictionary reports

State whether the issue involves:

- **Save word**.
- **Ignore once**.
- Import/export.
- Removing/clearing saved words.
- Language-specific vocabulary restoration.
- Suggestion-count persistence.
- Version-1 migration.
- Version-2 cross-language import validation.

Create a small synthetic dictionary export instead of attaching a real sensitive export.

# Keyboard reports

Current shortcuts:

```text
Ctrl+Enter             spelling check
Command+Enter          spelling check
Ctrl+Shift+Enter       Writing insights
Command+Shift+Enter    Writing insights
F7                     next spelling issue
Shift+F7               previous spelling issue
```

Include:

- Exact key combination.
- Platform/browser.
- Whether the visible equivalent action works.
- Whether focus was in the editor/dialog/another control.

Browser/OS key interception can differ by platform.

# Correction undo expectations

Correction undo is shared by automatic spelling and writing operations, bounded, and session-only.

One history entry represents:

- One spelling replacement.
- One spelling replace-all.
- One writing safe fix.
- One writing batch safe-fix operation.

Manual typing clears the correction stack. Application restart does not restore it.

If reporting an undo bug, distinguish between immediate undo, undo after a bulk operation, undo after manual typing, and behavior after document clear/restart.

# Feature requests

Use the **Feature request** template. Explain:

- The writing/spelling problem being solved.
- Expected behavior.
- Which language(s) it affects.
- Whether it changes public APIs, persisted data, keyboard workflows, correction safety, or privacy/security boundaries.

For storage, synchronization, accounts, cloud services, AI rewriting, analytics, editor persistence, persistent history, remote language/rule downloads, or dynamic plugins, include privacy/security expectations.

# Security reports

Do not use normal public issues for vulnerabilities. Follow [SECURITY.md](SECURITY.md).


# Support the project

SpellChecker is free and open source. If the project is useful to you and you would like to support continued development, you can [buy Sanskar a coffee](https://buymeacoffee.com/sanskarIN).

Financial support is optional. It does not provide privileged access to security reports, issue triage, roadmap decisions, releases, or contribution review.
