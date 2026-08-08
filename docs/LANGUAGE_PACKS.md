# Language Packs

SpellChecker uses an explicit language-pack architecture. A language pack owns the language-specific data and rules needed to tokenize, normalize, validate, check, and rank words without moving those concerns into editor widgets.

V2.1 extends language isolation beyond spelling vocabulary: enabled writing-rule preferences are also stored per language.

## Built-in packs

| ID | Display name | Language | Region |
| --- | --- | --- | --- |
| `en-US` | English (US) | English | United States |
| `en-GB` | English (UK) | English | United Kingdom |

`en-US` remains the default for backward compatibility with the original 1.x spelling behavior.

## Explicit selection

Core callers choose a language explicitly:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);
```

The Flutter application exposes the same built-in registry through the editor language selector. The selected pack is stored locally and restored later.

SpellChecker does not perform automatic language detection. Explicit selection avoids silently changing spelling/writing assumptions on short or ambiguous text.

## `SpellLanguagePack`

A pack contains:

- `id` — stable project language identifier such as `en-US`.
- `languageCode` — base language code.
- `regionCode` — region/variant code.
- `displayName` — user-facing label.
- `dictionary` — normalized accepted words.
- `wordFrequencies` — deterministic suggestion tie-break metadata.
- `tokenPattern` — candidate token regular expression.
- `validWordPattern` — whole-word personal-vocabulary validation.
- `normalizer` — language-specific canonicalization.
- `recognizedSuffixes` — deterministic suffix handling.
- `suggestionSource` — metadata source label.
- Suggestion edit-distance policy.

The engine delegates tokenization, normalization, personal-word validation, suffix handling, and suggestion threshold behavior to the selected pack.

## Unicode tokenization

The built-in English packs use Unicode letter properties instead of ASCII-only `[A-Za-z]` matching, so tokens such as:

```text
café
naïve
résumé
façade
jalapeño
```

remain complete words.

Supported internal punctuation includes straight/curly apostrophes and the supported ASCII/Unicode hyphen forms normalized by the pack.

The English normalizer lowercases text, converts curly apostrophes to straight apostrophes, and converts supported Unicode hyphens to ASCII `-`.

Unicode-aware tokenization is not a claim that every Unicode word is present in the bundled dictionary.

## US and UK variant behavior

The packs deliberately differ for curated variant spellings, for example:

```text
US: color          UK: colour
US: behavior       UK: behaviour
US: center         UK: centre
US: organization   UK: organisation
US: theater        UK: theatre
US: traveler       UK: traveller
```

Each variant pack removes the opposite curated variant list before adding its own so these differences remain deterministic even when the shared dictionary grows.

Changing selected language re-checks non-blank text. It never rewrites the user's document automatically.

## Suggestion metadata

`SpellCheckerEngine.suggestionDetailsFor` returns `SpellSuggestion` values containing:

- Candidate word.
- Edit distance.
- Frequency rank.
- Language ID.
- Language display name.
- Suggestion source.

The backward-compatible `suggestionsFor` method returns candidate strings only.

## Language-tagged spelling issues

`SpellIssue.languageId` identifies the pack that produced an issue when available.

Issue offsets still belong only to the exact checked text snapshot. Changing language invalidates old spelling issues/highlights and produces new language-tagged results.

# Per-language application state

V2.1 treats language as a namespace boundary for multiple state categories.

## Personal dictionary

Conceptually:

```text
en-US -> {US personal vocabulary}
en-GB -> {UK personal vocabulary}
```

A saved word in one pack is not automatically accepted in another.

## Ignored words

Ignored words are engine/session state. Switching language constructs a fresh spelling engine, preventing temporary ignores from leaking across packs.

## Writing-rule preferences — V2.1

Enabled writing-rule IDs are also language-specific:

```text
en-US -> {enabled writing rule IDs for US}
en-GB -> {enabled writing rule IDs for UK}
```

A rule disabled in US mode remains independent from UK mode.

The editor resolves effective rule IDs by intersecting stored/default IDs with rules that currently exist and support the selected pack.

## Language switch restoration

A normal language switch restores:

1. Target pack identity.
2. Target pack personal words.
3. Target pack writing-rule IDs.
4. A fresh spelling engine/session state.
5. Fresh spelling issues for non-blank current editor text.

The document text itself is not changed or persisted as part of the switch.

# Preference keys and migration

Current language-related local keys include:

```text
spellchecker.language_id.v1
spellchecker.personal_words.v2.en-US
spellchecker.personal_words.v2.en-GB
spellchecker.writing_rule_ids.v1.en-US
spellchecker.writing_rule_ids.v1.en-GB
```

The old personal-word key:

```text
spellchecker.personal_words.v1
```

is treated as default `en-US` vocabulary during migration/compatibility handling.

An unsupported stored selected-language ID falls back to the default pack.

## Writing-rule preference states

For each language V2.1 preserves:

```text
missing writing-rule key -> current registry default IDs
stored non-empty list     -> explicit enabled IDs
stored empty list         -> explicit disable-all
```

The explicit empty state must not be converted into the missing/default state.

Unknown stored rule IDs are ignored by effective-rule resolution rather than causing a language switch failure.

# Personal dictionary transfer format

## Version 2

Language-aware exports use:

```json
{
  "version": 2,
  "language": "en-GB",
  "words": [
    "customword",
    "open-source"
  ]
}
```

The language ID is part of the portable data contract.

## Version 1 compatibility

Legacy format remains decodable:

```json
{
  "version": 1,
  "words": ["customword"]
}
```

Version 1 has no language metadata and is interpreted in the importing caller's currently selected language.

JSON arrays and plain comma/newline lists behave as current-language legacy imports.

`PersonalDictionaryCodec.encode` remains the legacy version-1 encoder; new application exports should use language-aware encoding.

## Cross-language imports

If a version-2 document names a different language from the selected UI pack, SpellChecker does not silently merge it into the wrong namespace. The user must switch to the tagged language first.

Unsupported language IDs and document versions are rejected explicitly.

## Resetting language-specific writing rules — V2.2

**Reset rules to defaults** removes the active language's `spellchecker.writing_rule_ids.v1.<language-id>` key and resolves current registry defaults for that pack. It does not write a copy of today's default IDs.

That distinction preserves language isolation and forward-compatible defaults:

```text
en-US override cleared -> en-US follows registry defaults
en-GB override remains -> en-GB keeps its explicit choices
```

Review search/category/automatic-only filters are not language preferences and are never stored in either namespace.

# Writing-rule eligibility

`WritingRule.supports(pack)` is the authority for language eligibility.

A rule can target a full pack ID or a base language code. Current built-in writing rules target English generally and therefore support both built-in English packs.

When adding a new language pack, writing rules must not be assumed compatible merely because the editor can select that language. Each rule's support declaration must be reviewed.

# Adding a built-in language pack

A language-pack contribution should include:

1. Stable pack ID.
2. Clear display name.
3. Language/region identity.
4. Unicode-aware tokenizer.
5. Whole-word personal-entry validation.
6. Documented/tested normalization.
7. Dictionary data with compatible licensing/provenance.
8. Frequency/suggestion policy or rationale for omission.
9. Deterministic suffix/morphology rules only when appropriate.
10. Native-script/diacritic tests.
11. Personal/ignored isolation tests.
12. Selected-language persistence tests.
13. Writing-rule eligibility review.
14. Per-language writing-rule preference isolation tests when rules support the pack.
15. UI selector/restoration tests.
16. Documentation/changelog updates.
17. Privacy/security review for any runtime network/download requirement.

Do not add a dictionary whose license is incompatible with this repository.

# Pack isolation requirements

For every pair of packs A/B, tests should establish:

- A personal word added/saved to A is not automatically accepted by B.
- An ignored word in A is not automatically ignored by B.
- Saved A vocabulary uses an A-specific namespace.
- Writing-rule preference A does not silently change preference B.
- Selecting B produces B-tagged issues/suggestions.
- Pack switching invalidates old issue/highlight state.
- Version-2 transfer metadata cannot silently place an A export into B.

# Privacy boundary

Language selection, language-specific personal vocabulary, and language-specific writing-rule IDs are local settings.

SpellChecker does not send the selected language, personal vocabulary, rule IDs, or editor text to a SpellChecker server.

Changing language does not enable automatic language detection or keyboard telemetry.

# Non-goals

The current language architecture does not provide:

- Automatic language detection.
- Cloud language-pack download.
- Account-based dictionary/rule synchronization.
- Full grammar parsing for every selected language.
- Full morphological analyzers.
- Complete dictionary coverage.
- Automatic compatibility of writing rules with future language packs.

The goal is a stable, explicit, testable language boundary that can be extended without moving language-specific behavior into widgets or weakening local state isolation.

## V2.3 portable language preferences

Portable settings carry an explicit selected built-in language ID plus explicit writing-rule overrides keyed by supported language ID. The settings codec rejects unsupported language IDs rather than guessing or auto-detecting a substitute. Personal vocabulary is deliberately excluded from portable settings and remains in its existing per-language local namespace. After a successful import, the editor loads the target language's existing personal words into a fresh engine and rechecks non-blank text. A missing override key means that language follows current registry defaults; an empty override list means explicit disable-all.
