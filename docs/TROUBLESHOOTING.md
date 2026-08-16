# Troubleshooting

This guide covers common SpellChecker `2.16.0+21` application, storage, import/export, analysis, keyboard, development, and release-build problems.

Before opening a public issue, prefer a small synthetic example instead of a private document. See [Support](../SUPPORT.md).

# Application startup

## Preferences are still loading

Some durable-setting actions are unavailable until local preferences finish loading.

What to do:

1. allow the startup load to finish;
2. look for a storage/loading warning;
3. retry the action after controls become enabled.

SpellChecker avoids accepting settings/dictionary actions while it cannot yet truthfully describe the durable state.

## “Could not load saved dictionary preferences” or similar storage warning

The host preference layer failed during startup.

Effects can include:

- built-in defaults/session state used instead of saved values;
- persisted personal vocabulary not restored;
- persisted language/rule preferences unavailable;
- spelling still usable in session mode.

Try:

- reload the app/browser;
- verify site/app storage is permitted;
- leave private/incognito mode if it discards/blocks storage;
- check enterprise/browser storage policies;
- do not clear existing site data if you still need saved vocabulary and have not backed it up.

If reproducible, report browser/platform/Flutter version and a synthetic workflow.

# Spelling results

## A valid word is marked unknown

Check the selected language first. Regional spelling can differ between `en-US` and `en-GB`.

Also check whether the word:

- belongs in your personal dictionary;
- uses unusual punctuation/hyphen/apostrophe characters;
- contains a decomposed/unsupported Unicode sequence;
- is simply not in the bundled dictionary.

If it is a user/domain word, use **Save word** for the selected language.

## A saved word is unknown after switching language

Expected: personal dictionaries are language-specific.

A word saved in `en-US` does not automatically exist in `en-GB`. Save/import it separately for the other language if appropriate.

## A saved word disappeared after restart

Likely causes:

- local preference write failed;
- browser/site/app data was cleared;
- private/incognito storage did not persist;
- the word was saved under another language;
- host storage policy removed local data.

Check for prior storage warnings and select the language under which the word was saved.

Use personal-dictionary export for backups.

## Ignore once did not survive restart

Expected. Ignored words are session/engine state only.

Use **Save word** for durable acceptance.

## Spelling results disappeared after typing

Expected. Manual editing invalidates the previous checked source snapshot so stale issue offsets are not reused.

Run **Check spelling** again when ready.

## Suggestions look different after changing language

Expected. Language pack dictionary/frequencies and regional vocabulary influence suggestions.

## Too many/few suggestions

Open **Manage personal dictionary** and set **Suggestions per spelling issue** from 1 to 10.

Portable settings can also transfer this value.

## Result says more than 200 issues / limited result

The bundled UI captures the first 200 spelling issues. When it observes another unknown word, it reports truncation/limited state.

This is not data loss in the editor; it is a result-capture policy. Correct/edit/recheck the text to review later issues, or use the public engine differently in a custom integration.

# Spelling correction

## A suggestion did not apply

The issue may be stale. SpellChecker applies a correction only if the current source range still contains the checked word.

If you edited text after checking, run the spelling check again.

## Replace all changed fewer occurrences than expected

Replace all operates only on current matching `SpellIssue` ranges represented by the checked result. It is intentionally not a global text replacement.

A limited 200-issue result can therefore represent only a prefix of unknown occurrences.

## Casing changed

SpellChecker preserves common lower/title/upper casing patterns per occurrence. If a specialized casing rule is needed beyond those patterns, apply/edit manually and report a synthetic example if behavior seems incorrect.

# Writing insights

## Writing insights shows no findings

Check:

- editor text is not blank;
- selected language is English (US/UK);
- relevant writing rules are enabled;
- a search/category/preset/Automatic fixes only filter is not hiding findings;
- the text actually matches a deterministic built-in rule.

Use Escape once to clear an active transient query/filter state.

## Some rules are disabled after restart

Rule choices are persisted per language. You may be looking at the explicit configuration for that pack.

Use **Reset rules to defaults** if you want to remove the explicit override and return to current built-in defaults.

## I turned every rule off, then expected Reset behavior

Turning all switches off stores an explicit empty set: “all rules disabled.”

**Reset rules to defaults** removes the explicit override: “follow registry defaults.”

They are deliberately different.

## Automatic fixes only hides unmatched delimiters

Expected. `unmatched-parenthesis`, `unmatched-square-bracket`, and `unmatched-curly-brace` are advisory and have no automatic replacement.

## A safe writing fix did not apply

The finding may be advisory or stale.

Automatic correction requires:

- non-null replacement;
- valid source range;
- current substring exactly equal to the analyzed `originalText`.

Reopen Writing insights after editing to obtain a fresh analysis.

## Batch applied fewer fixes than the count I noticed

Batch correction skips:

- advisory findings;
- stale/invalid findings;
- later findings overlapping an already accepted earlier candidate.

If filters are active, only visible automatic findings are submitted to the batch.

The result reports applied/skipped counts.

## Writing insights shows 200 captured but a larger total

Expected for a large result. The dialog retains the globally earliest 200 findings while analyzer-produced diagnostics can count exact totals.

Filters/fixes work only on captured findings. Total metadata does not grant mutation authority for uncaptured ranges.

## Search shortcut opened browser search instead

Some browsers/host environments can intercept `Ctrl+F` / `Command+F` before Flutter. Use the visible **Search rules and findings** field.

Inside a normally delivered Writing insights shortcut scope, Ctrl/Command+F is registered to focus the dialog search.

## Escape did not close Writing insights

If a transient review query is active, the first Escape intentionally clears search/categories/Automatic fixes only and leaves the dialog open. Press Escape again when the query is empty to close.

# Personal dictionary import/export

## Import says the dictionary is for another language

Current version-2 exports include language metadata. The bundled UI refuses to merge an `en-US` dictionary into `en-GB` or vice versa.

Switch to the document's language and import again.

## Import rejects a word

Each non-blank entry must normalize to a valid word for the target language pack. Entries containing invalid characters/structure cause a format error instead of being silently discarded.

Try a minimal import containing only the problematic entry.

## Import added no new words

The imported normalized words may already exist. Import merges into the current dictionary and reports when no new words were found.

## I expected import to replace my dictionary

Dictionary import **merges**. Use the dictionary manager's clear/remove controls if you want to change existing saved words first.

## Clipboard copy failed or nothing appears

Browser/OS clipboard policies can block clipboard writes. Check permissions/secure-context/browser policy and retry from the explicit copy control.

# Portable settings

## Portable settings does not include my personal dictionary

Expected. Personal vocabulary has a separate language-aware transfer format.

Portable settings carries only:

- selected language;
- suggestion limit;
- explicit per-language writing-rule overrides.

## Imported settings reset a language to defaults

A language missing from `writingRuleOverrides` has no explicit override after import and therefore uses registry defaults.

A language present with `[]` explicitly disables all rules.

## Settings JSON is rejected

Check:

- valid JSON object;
- `format` exactly `spellchecker-settings`;
- `version` exactly `1`;
- `languageId` is `en-US` or `en-GB`;
- `suggestionLimit` integer 1–10;
- `writingRuleOverrides` object;
- override language keys are supported;
- override values are string arrays;
- rule IDs use valid syntax and are not duplicated within one override.

See [Configuration](CONFIGURATION.md) for an example.

## Import failed while saving

The application attempts to restore previous durable settings if the import persistence transaction fails. It reports whether prior settings were restored when possible and marks storage unavailable.

Do not assume a failed import was partially durable without checking the UI/state after the error.

# Undo

## Undo correction is unavailable

The correction stack is in-memory and bounded. It can be empty because:

- no SpellChecker correction has been applied;
- manual editing/state reset began a new correction-history path;
- language/session reset cleared correction history;
- app restarted.

It is not document version history.

## One undo reversed many changes

Expected after a spelling Replace all or writing batch. Each accepted batch is recorded as one pre-correction editing snapshot.

# Statistics

## Character count differs from visible characters

`TextStatistics.characters` uses Dart string length, which counts UTF-16 code units. Some non-BMP characters use two code units; combining sequences can contain multiple code units/scalars for one user-perceived grapheme.

## Sentence count includes an unfinished final sentence

Expected. Current statistics count completed terminal-punctuation boundaries plus a remaining non-empty trailing fragment.

# Keyboard/accessibility

## F7 does not move issues

Check:

- a current spelling result has issues;
- focus/browser receives F7 rather than mapping it to hardware/media/system behavior;
- browser/extension is not intercepting it.

Use visible previous/next controls as an alternative.

## Shortcut conflicts with browser/assistive technology

Host software can reserve shortcuts. Use visible controls and include environment/assistive-technology details in a report.

See [Accessibility](ACCESSIBILITY.md) and [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

# Web/platform

## `flutter run -d chrome` cannot find Chrome

Run:

```bash
flutter doctor
flutter devices
```

Install/configure a Flutter-supported browser or use an available target for local development.

## Where are Android/iOS/Windows/macOS/Linux project folders?

They are not currently committed. The repository commits `web/` plus portable Flutter/Dart source.

Do not assume a native release artifact exists because the application is written in Flutter. See [Platform support](PLATFORM_SUPPORT.md).

# Development setup

## `flutter pub get` fails

Check:

- network access to package sources;
- Flutter/Dart version compatibility;
- `pubspec.yaml` syntax;
- local package cache/environment proxy configuration.

Use Flutter stable unless intentionally testing another toolchain.

## Formatting CI fails

Run:

```bash
dart format lib test tool
```

Then verify:

```bash
dart format --output=none --set-exit-if-changed lib test tool
```

Commit canonical formatting changes separately when useful for review clarity.

## `flutter analyze` fails

Run locally and address every reported analyzer issue before assuming CI/environment failure:

```bash
flutter analyze
```

## A widget test hangs on `pumpAndSettle()`

If the test deliberately leaves a Future unresolved/loading state active, `pumpAndSettle()` may never reach settled state. Use explicit `pump()` steps and complete the controlled Future when intended.

## A dialog control cannot be found in a widget test

Writing insights/list content can be lazy/off-screen. Scroll or `ensureVisible` before asserting/tapping the control.

# Benchmark

## Benchmark rejects an option

Use:

```bash
dart run tool/benchmark_large_document.dart --help
```

Options are strict. Duplicates, unknown flags, missing values, invalid integers, non-positive required counts/limits, negative suggestions, or unsupported language IDs fail.

## Benchmark is slower than another machine

Raw timings across unrelated hardware/toolchains are not directly comparable. Record exact command, commit, Flutter/Dart versions, OS/hardware, and load.

Use benchmark smoke for correctness/executability, not universal speed thresholds.

See [Performance](PERFORMANCE.md).

# Release workflow

## Release artifact missing

The release workflow uploads the web artifact only after format, analyzer, full tests, benchmark smoke, and `flutter build web --release` all succeed.

Inspect the failed step in GitHub Actions.

## I expected a GitHub Release/app-store artifact

The current workflow uploads an Actions web artifact retained for 14 days. It does not automatically create a GitHub Release or native/app-store artifacts.

See [Releasing](RELEASING.md).

# Before filing an issue

Include:

- exact SpellChecker version/commit;
- platform/browser and Flutter/Dart version if relevant;
- selected language;
- exact feature/workflow;
- expected versus observed behavior;
- minimal synthetic text/data;
- whether storage loading/saving showed a warning;
- whether Writing insights/spelling result was limited;
- relevant safe metadata diagnostic when requested.

Do **not** post private documents, credentials, sensitive personal vocabulary, or real private messages when a synthetic reproducer is enough.

For security vulnerabilities, follow [SECURITY.md](../SECURITY.md) instead of filing a public issue.

## Related documentation

- [FAQ](FAQ.md)
- [User guide](USER_GUIDE.md)
- [Configuration](CONFIGURATION.md)
- [Support](../SUPPORT.md)
- [Development](DEVELOPMENT.md)
- [Testing](TESTING.md)
