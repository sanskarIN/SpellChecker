# Frequently Asked Questions

## General

### What is SpellChecker?

SpellChecker is a privacy-first Flutter spelling utility and deterministic writing assistant. It provides a bundled editor application plus reusable Dart spelling, language-pack, correction, and writing-analysis APIs.

### What version is documented here?

The evergreen documentation describes `3.3.0+26` on the current repository `main` branch unless a page explicitly identifies itself as a historical release document.

### Is SpellChecker open source?

Yes. The repository is distributed under the MIT License. See [LICENSE](../LICENSE).

### Can I support the project financially?

Yes, optionally, through [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN). Funding is not required for bug reports, feature requests, security reports, contributions, or review.

## Privacy

### Does SpellChecker upload my editor text?

The bundled application performs spelling and built-in writing analysis locally. It does not use a remote spelling/grammar service and does not add cloud writing, document upload, or telemetry for editor analysis.

### Is my text saved automatically?

SpellChecker does not provide durable editor-document persistence. Preference storage contains configuration such as selected language, suggestion count, personal words, and writing-rule choices—not editor text.

### What does the diagnostic summary contain?

The Writing insights diagnostic summary contains analysis counts and rule/language metadata. It deliberately excludes editor text, source excerpts, finding messages, replacements, and source offsets.

See [Privacy](PRIVACY.md) for the complete data-flow contract.

## Languages

### Which languages are built in?

Thirteen offline spelling packs are built in: `en-US`, `en-GB`, `hi-IN`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, `it-IT`, `bn-IN`, `mr-IN`, `ta-IN`, `te-IN`, and `ru-RU`.

### Does SpellChecker detect the language automatically?

No. Language selection is explicit.

### Can I add another language?

The library is designed around `SpellLanguagePack`, so additional packs can be implemented. A complete pack needs explicit dictionary, tokenization, normalization, valid-word, frequency/suggestion, affix, and metadata behavior plus tests. See [Language packs](LANGUAGE_PACKS.md).

### Are my personal words shared between language packs?

No. Personal vocabulary is stored separately per language pack.

## Spelling

### Why is a word marked unknown even though it is valid in another language or regional variant?

The selected language pack controls dictionary behavior. For example, a regional spelling can be accepted by one English pack and unknown in the other, while vocabulary from a different built-in language requires selecting that language's pack.

### How many suggestions can I show?

The bundled application supports 1–10 suggestions per spelling issue, with a default of 5.

### What is “Replace all” actually replacing?

It replaces only matching occurrences represented by the current checked `SpellIssue` list whose source ranges still match. It is not a global unvalidated string replacement.

### Why did my spelling results disappear after I typed something?

Spelling issues belong to the text snapshot that was checked. Manual editing changes source offsets and invalidates the previous snapshot, so SpellChecker clears stale results rather than risking an incorrect replacement.

### Why can the UI show a limited/truncated result?

The bundled UI retains at most the first 200 spelling issues. This bounds expensive suggestion generation and result rendering. The public engine can also be used unbounded or with a caller-specified capture limit.

## Writing insights

### Is Writing insights a full grammar checker?

No. It is a deterministic local rule system. It intentionally does not claim exhaustive grammar/style coverage or generative rewriting.

### How many built-in writing rules are there?

Eleven in the current registry.

### Which languages currently receive built-in writing findings?

The current built-in writing rules declare English (`en`) support, so they are eligible for `en-US` and `en-GB`. The eleven non-English starter packs provide spelling and suggestions without applying English-specific writing rules.

### What does the V3.3 colon rule do?

`missing-colon-space` detects a colon between words when the following space is missing and the edit is deterministic. It owns only the colon source range, so `Label :value` can safely compose with the existing pre-punctuation-spacing fix and become `Label: value` in one batch.

### Why do some findings have no fix button?

A `WritingIssue` is advisory when `replacement == null`. The unmatched parenthesis, square bracket, and curly brace rules are intentionally advisory because detecting an unmatched delimiter does not prove the correct edit.

### What does “Automatic fixes only” do?

It filters the review to findings that have deterministic replacements. Advisory findings are hidden while that filter is active.

### Are search and review filters saved?

No. Writing insights search, category filters, presets, and automatic-fix filtering are temporary dialog state.

### Are rule switches saved?

Yes. Enabled writing-rule IDs are persisted separately for each language when local storage succeeds.

### What is the difference between disabling every rule and Reset rules to defaults?

Disabling every rule stores an explicit empty set, meaning “keep all rules disabled for this language.” Reset removes the explicit override, meaning “use the current built-in default rule set.”

### Why does Writing insights mention captured and total findings?

The dialog retains the first 200 findings for review. Analyzer-produced results can still report exact total/per-rule counts. When truncated, exact totals are informational; uncaptured findings cannot be reviewed or fixed from that result.

## Personal dictionary

### What does Save word do?

It normalizes the word using the selected language pack and saves it in that language's local personal dictionary. Future sessions for that language accept it when storage succeeds.

### What does Ignore once do?

It adds the word to the current engine/session ignored set. It is not persisted and is cleared when session/engine state is reset.

### Can I export my personal words?

Yes. The dictionary manager copies a language-aware version-2 JSON export.

### What import formats are accepted?

The personal-dictionary codec reads current version-2 objects, supported legacy version-1 objects, JSON arrays, and compatible plain line/comma word lists.

### Can I import an en-US version-2 dictionary while en-GB is selected?

The bundled UI refuses that cross-language import and asks you to switch to the document's language first. This prevents silently mixing language-specific vocabulary.

## Portable settings

### Does Portable settings include personal words?

No. Personal vocabulary uses a separate export/import workflow.

### What does Portable settings include?

Selected language, suggestion limit, and explicit per-language writing-rule overrides.

### Does it include editor text or findings?

No.

### Why are missing and empty writing-rule overrides different?

A missing language override means “use current registry defaults.” An empty array means “explicitly disable all rules for that language.”

See [Configuration](CONFIGURATION.md) for the exact JSON contract.

## Storage

### Where are preferences stored?

The application uses Flutter's `shared_preferences` abstraction. The physical backing store is platform/plugin-specific and is not part of the public SpellChecker API.

### What happens if local storage fails?

The application reports the failure and avoids claiming unsaved changes were durable. Some spelling functionality can continue in session mode.

### Will clearing browser/site/app data remove my dictionary/settings?

It can. Export personal vocabulary and copy Portable settings before clearing host storage if you need a backup.

## Platforms

### Which Flutter runners are committed and release-built?

The repository commits Android, iOS, Linux, macOS, Web, and Windows runners. Cross-platform validation and release workflows build all six targets on appropriate GitHub-hosted operating systems. Production signing, notarization, store credentials, and channel-specific installers remain external distribution work where required.

### Does a successful CI build mean every platform artifact is store-ready?

No. Build validation proves that the committed source and runner compile together. Signed mobile/desktop distribution still needs the target's signing, provisioning, notarization, packaging, and store/channel policy.

See [Platform support](PLATFORM_SUPPORT.md) and [Executable builds and packaging](EXECUTABLE_BUILDS.md).

## Keyboard and accessibility

### What are the main shortcuts?

- `Ctrl+Enter` / `Command+Enter`: check spelling.
- `Ctrl+Shift+Enter` / `Command+Shift+Enter`: open Writing insights.
- `F7`: next spelling issue.
- `Shift+F7`: previous spelling issue.
- `Ctrl+F` / `Command+F` inside Writing insights: focus search.
- Escape inside Writing insights: clear active transient filters first, otherwise close.

See [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md).

### Why does a shortcut sometimes not fire in a browser?

The browser, operating system, extensions, hardware function-key mode, or assistive technology can intercept shortcuts before Flutter receives them. Use the visible control when the host reserves a combination.

## Development

### What are the required quality gates?

The core CI gate is:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
```

CI also runs a deterministic benchmark command smoke test. Cross-platform and release workflows additionally build Android, iOS, Linux, macOS, Web, and Windows release-mode targets on appropriate hosts.

### Why do source ranges use UTF-16 offsets?

Dart string slicing and Flutter text editing use UTF-16 code-unit offsets. SpellChecker's issue ranges therefore match those APIs. Edit-distance and some Unicode casing/length logic operate on Unicode scalar values; do not confuse those indexes with issue offsets.

### Why are there many V2.x and V3.x documents?

They are historical design/audit/validation records. For current behavior, start from [docs/README.md](README.md) and evergreen topic pages. Use [Release history](RELEASE_HISTORY.md) to navigate historical records.

### Which APIs are public?

Use the three public barrels:

```dart
package:spellchecker/spell_checker.dart
package:spellchecker/language.dart
package:spellchecker/writing.dart
```

Widgets/storage adapters are internal unless exported by those barrels.

## Troubleshooting and support

### Where should I start when something is wrong?

Read [Troubleshooting](TROUBLESHOOTING.md), then [Support](../SUPPORT.md).

For public bug reports, prefer minimal synthetic text. Do not paste private documents, credentials, account information, personal messages, or sensitive personal vocabulary when a synthetic reproducer is enough.

Security vulnerabilities should follow [SECURITY.md](../SECURITY.md), not a public issue.
