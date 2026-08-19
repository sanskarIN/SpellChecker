# Feature Reference

This page describes the **current** SpellChecker `3.2.0+25` product surface. It is an evergreen reference; release-specific V2.x documents describe historical milestones and may contain older registry sizes or compatibility context.

## Product summary

SpellChecker combines a Flutter editor workflow with reusable Dart spelling and writing-analysis APIs. Analysis is deterministic and local. The bundled application is designed for explicit multilingual spelling-language selection, personal vocabulary, explainable writing rules, safe source-range corrections, and bounded review of large inputs.

## Spelling

### Local tokenization and dictionary checks

Spelling is performed by `SpellCheckerEngine` using the selected `SpellLanguagePack`. The engine supports:

- Unicode-aware tokenization and normalization;
- a bundled base dictionary;
- per-engine personal dictionary words;
- per-engine session ignored words;
- language-specific recognized prefix/suffix handling from known stems;
- occurrence-specific `SpellIssue` source ranges;
- deterministic ranked suggestions;
- detailed suggestion metadata;
- bounded issue capture through `analyze()`.

The compatibility `check()` API is unbounded and returns `List<SpellIssue>`. The `analyze()` API can cap retained issues and returns scan/truncation metadata.

### Suggestions

The default ranker uses deterministic candidate metadata including edit distance, prefix/first-character agreement, approximate frequency rank, length, and lexical fallback ordering. The public `SpellSuggestionRanker` strategy can be replaced by callers.

Suggestion distance and candidate length operate on Unicode scalar values. Public source ranges remain Dart/Flutter UTF-16 string offsets.

The bundled application allows 1–10 suggestions per issue; the default is 5.

### Correction workflow

The bundled UI supports:

- replace one checked occurrence;
- replace all represented checked occurrences of the same unknown word;
- case-preserving replacement for common lower/title/upper patterns;
- stale-source validation before mutation;
- end-to-start multi-range replacement;
- one correction-history entry for a replace-all operation;
- shared bounded undo history for spelling and writing corrections.

Manual text edits invalidate the previous spelling snapshot instead of reusing old issue offsets.

## Built-in languages

| ID | Display name | Status |
| --- | --- | --- |
| `en-US` | English (US) | built in, default |
| `en-GB` | English (UK) | built in |
| `hi-IN` | Hindi (India) | built in |
| `es-ES` | Spanish (Spain) | built in |
| `fr-FR` | French (France) | built in |
| `de-DE` | German (Germany) | built in |
| `pt-BR` | Portuguese (Brazil) | built in |
| `it-IT` | Italian (Italy) | built in |
| `bn-IN` | Bengali (India) | built in |
| `mr-IN` | Marathi (India) | built in |
| `ta-IN` | Tamil (India) | built in |
| `te-IN` | Telugu (India) | built in |
| `ru-RU` | Russian (Russia) | built in |

SpellChecker does not auto-detect language. Language selection is explicit. Personal vocabulary and writing-rule choices are stored separately for each built-in language.

The eleven non-English packs are curated offline starter lexicons rather than exhaustive linguistic dictionaries. Further languages or deeper vocabulary require reviewed `SpellLanguagePack` data, normalization/affix behavior, tests, and licensing review. See [Language packs](LANGUAGE_PACKS.md).

## Writing insights

The writing subsystem is separate from spelling. It uses `WritingRule`, `WritingAnalyzer`, `WritingIssue`, `WritingCorrection`, review presets/queries, and diagnostic-summary APIs.

### Current built-in rules

| Rule ID | User-facing purpose | Category | Automatic fix |
| --- | --- | --- | --- |
| `repeated-word` | consecutive repeated word | Clarity | yes |
| `sentence-capitalization` | lowercase sentence start | Mechanics | yes |
| `repeated-space` | multiple interior horizontal spaces | Mechanics | yes |
| `punctuation-spacing` | whitespace before punctuation | Mechanics | yes |
| `missing-punctuation-space` | missing space after selected punctuation between words | Mechanics | yes |
| `trailing-whitespace` | whitespace at line/document endings | Mechanics | yes |
| `repeated-punctuation` | repeated punctuation sequences in documented scope | Mechanics | yes |
| `unmatched-parenthesis` | unpaired literal `(` or `)` | Mechanics | no; advisory |
| `unmatched-square-bracket` | unpaired literal `[` or `]` | Mechanics | no; advisory |
| `unmatched-curly-brace` | unpaired literal `{` or `}` | Mechanics | no; advisory |

All current built-in writing rules declare English (`en`) eligibility, so they run for the two built-in English packs only. The eleven non-English V3.2 packs provide spelling and suggestions without applying English-specific writing rules. Structural delimiter checks are literal balancing rules; they are not syntax-aware parsers for source code, templates, Markdown, URLs, or quoted-domain grammars.

See [Writing rules](WRITING_RULES.md) for precise source ownership, severities, rule IDs, compatibility behavior, and plugin requirements.

### Review controls

Writing insights supports:

- per-language rule enable/disable switches;
- All findings, Mechanics, Clarity, and Automatic fixes presets;
- search over rule/finding metadata;
- category filters;
- **Automatic fixes only** filtering;
- individual safe fixes;
- all-safe-fixes batching;
- visible-safe-fixes batching when filters are active;
- stale-source validation;
- deterministic overlap handling;
- one-step undo for an accepted batch;
- metadata-only diagnostic summary copying.

Search, presets, category filters, and automatic-fix filtering are temporary dialog state. Rule enablement is durable per language.

## Large-document behavior

### Spelling UI

The bundled application retains at most the first 200 spelling issues. A truncated result is reported explicitly; reaching 200 alone is not enough to claim truncation unless an additional unknown word is observed.

The public spelling engine can be unbounded or caller-bounded.

### Writing UI

The built-in Writing insights dialog captures at most the first 200 findings in deterministic review order. `WritingAnalyzer` still counts exact overall and per-rule totals for analyzer-produced results. When truncated, filters and automatic corrections apply only to captured findings; exact totals are informational and do not authorize mutation of uncaptured ranges.

These limits bound retained UI/result objects and suggestion work. They are not hard CPU-time, memory, or maximum-document-size guarantees.

## Text statistics

The editor reports:

- word count;
- character count;
- sentence count.

Statistics are lightweight local calculations. Sentence counting recognizes terminal punctuation with common closing quote/bracket characters and counts a remaining non-empty trailing sentence fragment.

## Personal dictionary

Personal words are:

- normalized by the active language pack;
- validated against that pack's word rules;
- persisted locally per language by the application;
- included as suggestion candidates by the active engine;
- transferable through the separate language-aware personal-dictionary format.

Personal vocabulary is not included in Portable settings.

## Session ignored words

Ignored words are engine/session state. They suppress matching spelling findings until cleared or the session/language engine is replaced. They are deliberately not persisted and are not exported.

## Configuration and transfer

The application persists:

- selected language;
- suggestion limit;
- per-language personal dictionary words;
- explicit per-language writing-rule IDs.

Portable settings version 1 transfers only selected language, suggestion limit, and explicit writing-rule overrides. Personal dictionaries use a separate dictionary transfer format.

See [Configuration and local data](CONFIGURATION.md).

## Privacy and network behavior

The application does not require a network spelling or grammar service. It does not add telemetry, user accounts, cloud writing, document upload, or cloud synchronization.

Local preference storage uses `shared_preferences`. Editor text, analysis findings, ignored words, and correction history are not durable application preferences.

The repository and documentation naturally contain GitHub/CI/funding links, but those project links are not part of text analysis.

See [Privacy](PRIVACY.md) and [Security](../SECURITY.md).

## Accessibility and keyboard workflow

The application uses Material 3, system light/dark theme selection, responsive wide/narrow layouts, focus traversal, semantics labels, and live-region announcements for important states.

Primary shortcuts:

| Action | Shortcut |
| --- | --- |
| Check spelling | `Ctrl+Enter` / `Command+Enter` |
| Open Writing insights | `Ctrl+Shift+Enter` / `Command+Shift+Enter` |
| Next spelling issue | `F7` |
| Previous spelling issue | `Shift+F7` |
| Focus Writing insights search | `Ctrl+F` / `Command+F` |
| Clear transient review query or close Writing insights | `Escape` |

See [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md) and [Accessibility](ACCESSIBILITY.md).

## Public library surface

SpellChecker exposes three public barrels:

```dart
package:spellchecker/spell_checker.dart
package:spellchecker/language.dart
package:spellchecker/writing.dart
```

The public surface includes edit distance, dictionary/settings codecs, spelling reports/issues/suggestions/ranking, language packs, text corrections/statistics, writing rules/analyzer/issues/corrections/review helpers, and diagnostic summaries.

Application widgets and `DictionaryPreferences` are not exported by those public barrels.

## Development and release tooling

The repository includes:

- Flutter/Dart static analysis configuration;
- unit, codec, persistence, controller, integration, accessibility, Unicode, stress, and widget tests;
- deterministic large-document benchmark tooling under `tool/`;
- primary GitHub Actions CI for formatting, analysis, complete tests, and benchmark smoke;
- focused documentation/metadata CI for current-document, registry, version, link, and repository-inventory contracts;
- cross-platform CI that builds Android, iOS, Linux, macOS, Web, and Windows in release mode;
- a tagged/manual release workflow that mirrors those six target builds and uploads release-validation artifacts.

## Explicit non-features and boundaries

Current SpellChecker does **not** provide:

- automatic language detection;
- built-in languages other than English (US) and English (UK);
- a cloud grammar model or generative rewrite service;
- user accounts or cloud synchronization;
- remote telemetry from editor analysis;
- persistent document/editor-text storage;
- a document file manager or rich-text/office-file parser;
- syntax-aware programming-language parsing for structural delimiter rules;
- a promise to find every grammar/style problem;
- a promise that every finding has an automatic fix;
- committed Android/iOS/Windows/macOS/Linux runner directories;
- automated native desktop/mobile release artifacts.

The absence of those features is intentional current scope, not an implication that Flutter source cannot be adapted to additional targets. See [Platform support](PLATFORM_SUPPORT.md) and [Roadmap](ROADMAP.md).