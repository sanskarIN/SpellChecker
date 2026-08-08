# Language Packs

SpellChecker 1.3 introduces an explicit language-pack architecture. A language pack owns the data and rules needed to tokenize, normalize, validate, check, and rank words for one language/variant without changing the editor or correction layers.

## Built-in packs

Version 1.3 ships with:

| ID | Display name | Language | Region |
| --- | --- | --- | --- |
| `en-US` | English (US) | English | United States |
| `en-GB` | English (UK) | English | United Kingdom |

`en-US` remains the default for backward compatibility with SpellChecker 1.0–1.2.

## Explicit selection

Core callers choose a language explicitly:

```dart
import 'package:spellchecker/language.dart';
import 'package:spellchecker/spell_checker.dart';

final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);
```

The Flutter application exposes the same built-in registry through the editor's language selector. The selected pack is stored locally and restored on a later launch.

SpellChecker does not perform automatic language detection in V1.3. Explicit selection avoids silently changing spelling rules based on short or ambiguous text.

## `SpellLanguagePack`

A pack contains:

- `id` — stable BCP-47-style project identifier such as `en-US`.
- `languageCode` — base language code.
- `regionCode` — variant/region code.
- `displayName` — user-facing label.
- `dictionary` — normalized accepted words.
- `wordFrequencies` — optional deterministic suggestion tie-break ranks.
- `tokenPattern` — regular expression used to identify candidate word tokens.
- `validWordPattern` — whole-word validation used for personal dictionary entries.
- `normalizer` — language-specific canonicalization function.
- `recognizedSuffixes` — pack-specific regular suffix handling.
- `suggestionSource` — source label carried into detailed suggestion metadata.

The engine delegates tokenization, normalization, personal-word validation, suffix rules, and suggestion-distance thresholds to the selected pack.

## Unicode tokenization

The built-in English packs use Unicode letter properties instead of `[A-Za-z]`-only tokenization. This allows a complete token such as:

```text
café
naïve
résumé
façade
jalapeño
```

to remain one word token rather than being split at the accented letter.

Internal punctuation accepted by the built-in pattern includes:

- Straight apostrophe `'`.
- Curly apostrophe `’`.
- ASCII hyphen `-`.
- Common Unicode hyphen forms that normalize to ASCII `-`.

The English normalizer lowercases text, converts curly apostrophes to straight apostrophes, and converts supported Unicode hyphen characters to ASCII hyphen.

Unicode-aware tokenization is architecture, not a claim that the English dictionary contains every Unicode word. A correctly tokenized word can still be unknown if it is not in the selected pack or its personal dictionary.

## US and UK variant behavior

The two English packs deliberately differ for common variant-specific spellings. Examples include:

```text
US: color       UK: colour
US: behavior    UK: behaviour
US: center      UK: centre
US: organization UK: organisation
US: theater     UK: theatre
US: traveler    UK: traveller
```

Words widely accepted in both variants are intentionally not forced into an artificial difference.

Changing the selected language re-runs the current spelling check with the new pack. It does not rewrite the user's text automatically.

## Suggestion metadata

`SpellCheckerEngine.suggestionDetailsFor` returns `SpellSuggestion` values containing:

- Candidate word.
- Edit distance.
- Frequency rank.
- Language ID.
- Language display name.
- Source description.

The older `suggestionsFor` API remains available and returns only candidate strings.

Detailed metadata lets future UI/plugin layers explain where a suggestion came from without changing the deterministic string-suggestion contract used by existing callers.

## Language-tagged issues

`SpellIssue.languageId` identifies the pack that produced an issue. It is optional for source compatibility with manually constructed 1.x issues and tests.

Issues/offsets are still valid only for the exact text snapshot that was checked. Changing language invalidates the current issue set and creates new issues.

## Personal dictionary isolation

Saved personal words are namespaced by language pack.

Conceptually:

```text
en-US -> {custom US vocabulary}
en-GB -> {custom UK vocabulary}
```

A personal word saved for `en-US` is not automatically accepted in `en-GB`. This prevents user vocabulary and preference assumptions from leaking across language selections.

Temporary ignored words are also isolated because switching language creates a new engine/session state for the selected pack.

## Preference keys and migration

SpellChecker 1.3 stores personal words under version-2 language-specific keys:

```text
spellchecker.personal_words.v2.en-US
spellchecker.personal_words.v2.en-GB
```

The selected language is stored under:

```text
spellchecker.language_id.v1
```

The old SpellChecker 1.1/1.2 personal-word key:

```text
spellchecker.personal_words.v1
```

is treated as `en-US` data. On first US load, those words are normalized and migrated into the US V2 namespace. During the 1.x compatibility period, US saves can keep the legacy mirror synchronized so existing upgrades remain safe.

An unsupported stored language ID falls back to `en-US`.

## Personal dictionary document format

### Version 2

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

### Version 1 compatibility

SpellChecker continues to decode the previous format:

```json
{
  "version": 1,
  "words": ["customword"]
}
```

Because V1 has no language metadata, it is interpreted using the language selected by the importing caller/UI.

JSON arrays and plain comma/newline word lists are also treated as legacy/current-selection imports.

The legacy `PersonalDictionaryCodec.encode` method remains version-1-compatible. New language-aware callers should use `encodeForLanguage`.

## Cross-language imports

When a Version-2 export names a language different from the currently selected UI pack, SpellChecker does not silently merge it into the wrong personal dictionary. The user is asked to switch to the export's language first.

Unknown language IDs and unsupported document versions are rejected explicitly.

## Adding a new built-in language pack

A contribution adding a language should include:

1. A stable language-pack ID.
2. A clear user-facing display name.
3. Unicode-aware tokenizer appropriate for that language.
4. Whole-word personal-entry validation.
5. Normalization rules documented and tested.
6. A curated dictionary with clear licensing/provenance suitable for MIT repository distribution.
7. Suggestion-frequency metadata or an explicit rationale for omitting it.
8. Suffix/morphology rules only when they are deterministic enough for the current engine abstraction.
9. Unit tests for native-script/diacritic tokens.
10. Tests proving personal/ignored state does not leak to other packs.
11. UI selection/restoration tests.
12. Documentation and changelog updates.
13. Privacy/security review if the pack requires downloading data or any runtime network behavior.

Do not copy a dictionary whose license is incompatible with this repository.

## Pack isolation requirements

For every pair of packs A/B, tests should establish:

- A personal word added to A is not automatically accepted by B.
- An ignored word in A is not automatically ignored by B.
- Saved A vocabulary uses an A-specific preference namespace.
- Selecting B creates issues/suggestions tagged as B.
- Pack switch invalidates old issue offsets/highlights.
- Import metadata cannot silently place an A export into B.

## Non-goals in 1.3

Version 1.3 does not provide:

- Automatic language detection.
- Cloud language-pack download.
- Account-based dictionary synchronization.
- Grammar checking.
- Full morphological analyzers.
- A claim of complete dictionary coverage for either English variant.

The V1.3 goal is a stable, testable language boundary that later versions can extend without moving language-specific rules into widgets or storage code.
