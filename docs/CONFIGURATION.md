# Configuration and Local Data

This document is the current reference for SpellChecker preferences, local persistence, personal dictionaries, ignored words, writing-rule choices, and transfer formats.

## Configuration overview

The bundled application has four durable preference areas:

1. selected language;
2. suggestion count;
3. per-language personal vocabulary;
4. per-language explicit writing-rule IDs.

It also has temporary/session state that is intentionally not durable, including editor text, ignored words, current findings, active spelling issue, Writing insights search/filter state, and correction undo history.

The application stores durable preferences through `shared_preferences`.

## Selected language

Current built-in language IDs are:

```text
en-US
en-GB
hi-IN
es-ES
fr-FR
de-DE
pt-BR
it-IT
bn-IN
mr-IN
ta-IN
te-IN
ru-RU
```

`en-US` is the default pack. When the application restores a saved language ID, an unsupported or missing value falls back to the default pack.

Changing language creates a fresh language-specific spelling engine, restores that language's personal dictionary and writing-rule choices, clears stale correction/session state, and rechecks non-blank editor text.

## Suggestion count

The application supports 1 through 10 spelling suggestions per issue.

```text
minimum: 1
default: 5
maximum: 10
```

Out-of-range values read through the preference adapter are normalized to the nearest bound. Portable settings validation is stricter and rejects a suggestion count outside 1–10.

## Personal dictionary

Personal vocabulary is stored separately for each language pack.

Application behavior:

- words are normalized by the selected `SpellLanguagePack`;
- invalid/empty words are rejected;
- duplicates collapse after normalization;
- saved values are sorted before persistence;
- the selected language's personal words become valid spelling words and suggestion candidates;
- a word saved in one language pack does not automatically appear in any other pack's personal dictionary.

The dictionary manager can add, remove, clear, copy an export, and import words. Import **merges** valid imported words with the current personal dictionary; it does not replace the whole set.

### Current language-aware personal-dictionary format

Current exports use version 2:

```json
{
  "version": 2,
  "language": "en-US",
  "words": [
    "openai",
    "spellchecker"
  ]
}
```

Properties:

- `version` must be integer `2` for the current language-aware format;
- `language` must name a registered language pack;
- `words` must be an array;
- each non-blank entry must normalize to a valid word for that document's language;
- duplicate normalized words collapse;
- a version-2 document for a different language is not imported into the currently selected language by the bundled UI; switch to the document's language first.

### Legacy personal-dictionary compatibility

The codec also reads legacy forms:

- version-1 JSON objects containing `words`;
- JSON arrays;
- plain word lists separated by line breaks or commas.

A version-1 document does not contain a language ID, so the caller/current UI language provides the language context.

The legacy `PersonalDictionaryCodec.encode(...)` method still emits version 1 for the default pack to preserve compatibility. New language-aware UI exports use `encodeForLanguage(...)` and version 2.

## Ignored session words

**Ignore once** adds the normalized word to the active engine's ignored-word set.

Ignored words are:

- session/engine state;
- cleared manually by the app-bar action or implicitly when a fresh language engine is created;
- not written to `shared_preferences`;
- not included in personal-dictionary export;
- not included in Portable settings.

Use the personal dictionary instead when a word should remain accepted across sessions.

## Writing-rule preferences

Writing-rule choices are durable and language-specific. The preference model deliberately has three distinct states.

The ten current built-in writing rules support English and therefore run for `en-US` and `en-GB`. For the eleven non-English built-in spelling packs, the current built-in supported-rule set is empty. An explicit stored/imported rule ID can remain part of preference data for compatibility, but it does not become effective unless that rule exists and supports the selected language.

### Unset

No stored key exists for a language. The editor uses `WritingRuleRegistry.defaultEnabledRuleIds`, filtered to supported rules.

This state automatically follows future registry-default changes.

### Explicit non-empty set

A stored set names enabled rule IDs. Only those IDs that still exist and support the selected language become effective.

This state does not silently opt into newly added built-in rules.

### Explicit empty set

An existing stored key containing an empty list means the user deliberately disabled every writing rule for that language.

It is **not** equivalent to unset.

### Reset rules to defaults

The Writing insights **Reset rules to defaults** action removes the selected language's stored writing-rule key. After reset, current registry defaults become effective. This is different from explicitly turning every switch off.

## Temporary Writing insights configuration

The following review controls are temporary and are not persisted:

- review search text;
- Mechanics/Clarity category filters;
- selected review preset;
- Automatic fixes only state.

Closing the dialog discards that transient review query. Rule enable/disable switches, by contrast, are durable per language.

## Portable settings

Portable settings are intentionally separate from personal dictionaries.

### Exact included data

A Portable settings document contains:

- selected `languageId`;
- `suggestionLimit`;
- `writingRuleOverrides`, containing **explicit** per-language rule overrides only.

### Exact excluded data

Portable settings never contain:

- editor text;
- personal vocabulary;
- ignored session words;
- spelling issues;
- writing issues;
- source excerpts;
- correction history;
- review search/preset/filter state.

### Format

Current format identifier: `spellchecker-settings`.

Current version: `1`.

Example:

```json
{
  "format": "spellchecker-settings",
  "version": 1,
  "languageId": "en-US",
  "suggestionLimit": 5,
  "writingRuleOverrides": {
    "en-GB": [
      "repeated-word",
      "sentence-capitalization"
    ],
    "en-US": []
  }
}
```

Semantics of `writingRuleOverrides`:

- missing language property: no explicit override; use registry defaults;
- present language with one or more IDs: explicit enabled set;
- present language with `[]`: explicit disable-all state.

The codec sorts language IDs and rule IDs when encoding, producing deterministic JSON.

### Portable settings validation

Import rejects documents when:

- the JSON is invalid;
- the top level is not an object;
- `format` is not `spellchecker-settings`;
- `version` is not `1`;
- `languageId` is not a supported registered language;
- `suggestionLimit` is not an integer from 1–10;
- `writingRuleOverrides` is not an object;
- an override key names an unsupported language;
- an override value is not an array of strings;
- a rule ID has invalid syntax;
- a rule ID appears more than once in the same language override.

The codec validates rule-ID syntax but does not require every syntactically valid imported ID to exist in the current registry. The editor's effective-rule calculation intersects stored IDs with current supported rules, which preserves compatibility with stale/removed IDs without running unknown rules.

## Portable settings import transaction

The application reads the target language's personal dictionary **before** writing imported portable preferences because personal vocabulary is not part of the Portable settings format.

The storage service attempts to preserve/restore previous durable settings if an import fails. The UI reports that previous durable settings were restored when possible and marks storage unavailable when persistence fails.

After successful import, the editor:

- switches to the imported selected language;
- rebuilds the language-specific spelling engine using that language's already-saved personal dictionary;
- applies the imported suggestion count;
- resolves that language's writing rules using the imported explicit override or defaults;
- clears stale spelling/session/correction state;
- rechecks non-blank text.

## Internal preference keys

These keys are implementation details, documented for debugging/migration work rather than as a public API guarantee:

```text
spellchecker.personal_words.v1
spellchecker.personal_words.v2.<language-id>
spellchecker.writing_rule_ids.v1.<language-id>
spellchecker.language_id.v1
spellchecker.suggestion_limit.v1
```

The V1 personal-word key is retained for default-language migration/synchronization compatibility. New language-specific personal vocabulary uses the V2 prefix.

Do not build external integrations by directly editing these keys. Prefer the public codecs or the application UI.

## Storage failures

Preference writes are treated as successful only when `shared_preferences` reports a successful write/remove operation. A false result raises a local storage error rather than being silently treated as durable.

The application can continue in session mode after some storage failures, but it displays warnings and avoids claiming that unsaved dictionary/settings changes were persisted.

Before clearing browser/application data, export personal vocabulary and copy Portable settings if those values matter to you.

## What survives what?

| Data | Text edit | Close Writing insights | Language switch | App restart | Portable settings | Dictionary export |
| --- | --- | --- | --- | --- | --- | --- |
| Editor text | yes until cleared/current app | yes | yes | no durable guarantee | no | no |
| Spelling findings | invalidated by edit | n/a | cleared/rechecked | no | no | no |
| Writing findings | stale after edit/dialog snapshot | discarded | discarded | no | no | no |
| Selected language | yes | yes | changes | yes if storage works | yes | no |
| Suggestion count | yes | yes | global preference | yes if storage works | yes | no |
| Personal words | yes | yes | isolated by language | yes if storage works | no | yes |
| Ignored words | engine/session state | yes | cleared by new engine | no | no | no |
| Writing-rule choices | yes | yes | isolated by language | yes if storage works | explicit overrides only | no |
| Review filters/preset | n/a | no | no | no | no | no |
| Correction undo history | changes with corrections | yes | cleared on some state resets | no | no | no |

## Related documentation

- [User guide](USER_GUIDE.md)
- [Writing rules](WRITING_RULES.md)
- [Privacy](PRIVACY.md)
- [Troubleshooting](TROUBLESHOOTING.md)
- [Public API](API.md)
