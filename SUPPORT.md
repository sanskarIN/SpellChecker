# Support


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

# Privacy-sensitive examples

Never post:

- Private documents.
- Account information.
- Secrets/credentials.
- Personal messages.
- Sensitive personal vocabulary.
- Real correction-history snapshots.
- Private writing findings/source excerpts.

Replace sensitive data with a minimal synthetic reproducer.

# Local data recovery

Personal vocabulary is local and not cloud-synchronized. Before clearing browser/application data, use **Copy export** if you need a portable personal-dictionary backup.

Writing-rule preferences, selected language, and suggestion count are local settings that can be copied/imported through **Portable settings** in V2.3. Personal vocabulary remains a separate language-aware dictionary export. Clearing host application/profile storage can remove all of these local values.

If saved data disappears unexpectedly, follow [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) before filing an issue.

## V2.3 portable settings reports

For review-preset issues, include the preset name/ID, selected language, synthetic review text, and whether a search/category/automatic-fix filter was also active. For portable-settings issues, include a minimized synthetic JSON document with any private vocabulary/text removed, whether the failure happened during validation or persistence, the selected platform, and whether existing language/rule/suggestion preferences were restored. Do not post real documents, personal dictionaries, credentials, or sensitive clipboard content.

## V2.4 custom ranker reports

For custom-ranker issues, include the ranker policy in pseudocode, a small synthetic dictionary/input, active language ID, expected/actual ordered candidate words, and whether the behavior reproduces with `DefaultSpellSuggestionRanker`. Do not include private document text or sensitive personal dictionaries.

# V2.5 large-document reports

For a `200+` or bounded-analysis bug, use synthetic text and include:

- Whether the report/UI showed `200+`.
- The configured/API `maxIssues` when using the library directly.
- Captured issue count.
- `truncated`, `complete`, and `scannedTokenCount` for API reports when relevant.
- Whether Replace all was incorrectly visible/hidden.
- Selected language and suggestion count.

Do not attach a private large document. A repeated synthetic token sequence is sufficient for limit-state bugs.

## V2.6 spacing-rule reports

For punctuation-spacing/trailing-whitespace bugs, provide a minimal synthetic sample and say whether it involves interior repeated spaces, whitespace immediately before punctuation, LF/CRLF line endings, or document-end whitespace. Include the selected English pack and whether rule choices were unset/default or explicitly saved. Do not attach a private document when a short synthetic string can reproduce the issue.

## V2.7 limited Writing insights reports

When reporting a V2.7 Writing insights problem, include whether the dialog displayed a limited-result notice, the selected language, active review preset/filter state, and whether the issue reproduced after editing/reopening Writing insights. Do not include private document text unless it is necessary and safe to share; a small synthetic reproduction is preferred.

A `200+`-style state means the built-in dialog captured its first 200 findings in review order and observed at least one more. Filters and batch actions then operate on the captured prefix only.

## V2.8 exact diagnostics reports

For a Writing insights count/diagnostics bug, use a minimal synthetic sample and include:

- selected language ID;
- enabled writing-rule IDs;
- configured `maxIssues` when using the public analyzer API;
- retained/captured finding count;
- exact overall total when present;
- exact per-rule totals when present;
- complete/truncated state;
- active review preset/search/category/fix-only filters;
- whether editor text, language, or rule settings changed after the analysis.

For analyzer-produced results, exact per-rule totals should sum to the exact overall total, and an exact truncated result should report at least one uncaptured finding.

Do not attach a private large document simply to prove a count mismatch. Repeated synthetic text or a small custom synthetic rule is preferred.

The `captured/total` badge describes one current local analysis snapshot. Reopen Writing insights after editing or switching languages before comparing totals.

## V2.9 diagnostic-summary support reports

For writing-analysis count/ordering problems, maintainers can ask for the deterministic `WritingAnalysisDiagnosticSummary.toPlainText()` output plus the SpellChecker version and a synthetic reproduction. The summary is designed to contain counts and stable rule/language metadata without editor text or finding excerpts. If exact totals show `unavailable`, record whether the result was directly constructed for compatibility rather than returned by `WritingAnalyzer.analyze()`. Do not ask users to post private documents, personal dictionaries, raw correction history, or sensitive finding excerpts in public issues.

## V2.10 benchmark support

For V2.10 benchmark questions, include the exact benchmark command, selected built-in language, Flutter/Dart versions, scenario repetition/limit values, and the metadata-only report output when safe. Use the built-in synthetic corpus; do not attach private documents to reproduce performance observations. Timing differences are meaningful only when the compared environment/toolchain and command are controlled. Malformed options, unsupported language IDs, changing analysis outcomes across measured iterations, or benchmark command crashes are correctness/support issues; a slower number on unrelated hardware by itself is not.

## V2.11 keyboard/accessibility support

For V2.11 Writing insights keyboard or semantics problems, report the exact synthetic text, platform/Flutter version, which control had focus, whether Ctrl/Command+F moved to review search, whether the first Escape cleared an active transient query, and whether the second Escape closed. For count announcements, include captured/total metadata and active synthetic filters rather than private document excerpts.

If a widget regression involves an apparently missing off-screen control, remember that Writing insights is intentionally lazy; reproduce by scrolling the real dialog rather than assuming every item is mounted simultaneously.
