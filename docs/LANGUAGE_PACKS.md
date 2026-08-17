# Language Packs

SpellChecker keeps language-specific spelling behavior behind `SpellLanguagePack`. This page documents the current `3.1.1+24` language model, built-in packs, Unicode behavior, extension path, and application-integration limits.

## Public import

```dart
import 'package:spellchecker/language.dart';
```

Core engine APIs are available from:

```dart
import 'package:spellchecker/spell_checker.dart';
```

## Current built-ins

| ID | Language | Region | Display name | Status |
| --- | --- | --- | --- | --- |
| `en-US` | `en` | `US` | English (US) | built in, default |
| `en-GB` | `en` | `GB` | English (UK) | built in |
| `hi-IN` | `hi` | `IN` | Hindi (India) | built in |
| `es-ES` | `es` | `ES` | Spanish (Spain) | built in |
| `fr-FR` | `fr` | `FR` | French (France) | built in |
| `de-DE` | `de` | `DE` | German (Germany) | built in |
| `pt-BR` | `pt` | `BR` | Portuguese (Brazil) | built in |
| `it-IT` | `it` | `IT` | Italian (Italy) | built in |

SpellChecker does not auto-detect language. The bundled UI requires explicit selection.

## `SpellLanguagePack`

A pack owns:

```text
id
languageCode
regionCode
displayName
dictionary
wordFrequencies
tokenPattern
validWordPattern
normalizer
recognizedPrefixes
recognizedSuffixes
suggestionSource
```

The constructor captures dictionary, frequency, prefix, and suffix collections as immutable snapshots.

### Stable ID

`id` is the full pack identifier used by issues, persistence, dictionary transfer, Portable settings, and UI selection. Built-in IDs use language-region form such as `en-US`.

Pack equality/hash code use `id`, so IDs should be stable and unique in any integration.

### Language code

`languageCode` is the broader code used by writing-rule eligibility. Current built-in writing rules declare `en`, so both `en-US` and `en-GB` are eligible.

### Dictionary

`dictionary` contains normalized accepted base words for the pack. The spelling engine also considers personal dictionary words, ignored session words, and recognized suffixes.

### Frequency ranks

`wordFrequencies` supplies approximate ranking metadata for suggestions. Lower numeric ranks are preferred by the default suggestion ranker after edit-distance/prefix criteria.

### Token pattern

The built-in Unicode token pattern recognizes sequences of Unicode letters plus combining marks, with supported internal apostrophe/hyphen forms:

- straight apostrophe `'`;
- curly apostrophe `’`;
- ASCII hyphen `-`;
- supported Unicode hyphen variants `‐` and `‑`.

A token match's offsets remain Dart UTF-16 code-unit offsets.

### Valid personal-word pattern

The built-in valid-word pattern accepts normalized Unicode letter/combining-mark sequences with supported normalized apostrophe/hyphen separators. Input is normalized before validation.

### Normalizer

Built-in Unicode normalization:

1. trims outer whitespace;
2. lowercases;
3. converts curly apostrophe `’` to `'`;
4. converts supported Unicode hyphen variants to `-`;
5. composes a defined set of common decomposed Latin base+combining-mark sequences into their precomposed forms.

This lets common decomposed inputs such as an accented Latin letter normalize consistently with bundled vocabulary.

The composition table is explicit rather than a general Unicode-normalization library. New language packs should define normalization appropriate to their dictionaries and tests.

### Recognized affixes

Current built-in English packs recognize:

```text
n't
're
've
'll
'd
'm
's
```

The spelling engine accepts recognized affixes when the normalized stem is known. English keeps its contraction suffixes. V3.1 also adds apostrophe-elision prefixes for French (for example `l'`, `d'`, `qu'`) and Italian (for example `l'`, `d'`, `all'`, `dell'`, `nell'`). Suggestions are ranked on the stem and recognized prefix/suffix text is reattached.

### Suggestion source

`suggestionSource` is a human-readable label copied into detailed `SpellSuggestion.source` metadata for base dictionary candidates.

Each built-in uses a language-specific bundled source label in detailed suggestion metadata.

## Pack methods

```dart
String normalizeWord(String word)
Iterable<RegExpMatch> tokenize(String text)
bool isValidWord(String word)
int maximumSuggestionDistance(int wordLength)
```

`maximumSuggestionDistance` currently returns:

```text
1 for length <= 4
2 for length <= 8
3 otherwise
```

The engine passes Unicode-scalar word length to this policy.

## `SpellLanguageRegistry`

```dart
SpellLanguageRegistry.englishUs
SpellLanguageRegistry.englishGb
SpellLanguageRegistry.hindiIndia
SpellLanguageRegistry.spanishSpain
SpellLanguageRegistry.frenchFrance
SpellLanguageRegistry.germanGermany
SpellLanguageRegistry.portugueseBrazil
SpellLanguageRegistry.italianItaly
SpellLanguageRegistry.builtIns
SpellLanguageRegistry.defaultPack
SpellLanguageRegistry.byId(id)
SpellLanguageRegistry.contains(id)
```

`defaultPack` is `en-US`.

`byId` is fallback-oriented: null, empty, or unsupported IDs return the default pack. For strict validation, call `contains(id)` before `byId`.

## US/UK dictionary behavior

The packs share the common English dictionary/frequency foundation but apply explicit regional additions/exclusions.

Representative difference:

```text
en-US: color
en-GB: colour
```

The codebase includes additional explicit US/UK regional variants. Do not assume every spelling variant can be generated mechanically; the dictionaries are the authority.

## Multilingual coverage boundary

V3.1 adds six curated offline starter lexicons across Latin and Devanagari scripts. They cover representative common vocabulary and deterministic typo suggestions but are not exhaustive national dictionaries, grammar engines, or morphology analyzers. Current Writing insights rules remain English-only (`en`), so the six new packs provide spelling without applying English-specific writing rules.

## Use a built-in pack with the engine

```dart
final engine = SpellCheckerEngine(
  languagePack: SpellLanguageRegistry.englishGb,
);

final issues = engine.check('The colour is nice.');
```

## Custom pack example

A caller can construct a custom pack and pass it directly to reusable APIs:

```dart
final customPack = SpellLanguagePack(
  id: 'example-EX',
  languageCode: 'example',
  regionCode: 'EX',
  displayName: 'Example',
  dictionary: <String>{'hello', 'world'},
  wordFrequencies: <String, int>{'hello': 1, 'world': 2},
  tokenPattern: RegExp(r'[A-Za-z]+'),
  validWordPattern: RegExp(r'^[a-z]+$'),
  normalizer: (word) => word.trim().toLowerCase(),
  recognizedSuffixes: const <String>[],
  suggestionSource: 'example dictionary',
);

final engine = SpellCheckerEngine(languagePack: customPack);
```

## Custom packs and the writing analyzer

Writing rules decide support independently through `supportedLanguageIds`.

A custom pack with `languageCode: 'en'` is eligible for rules that declare `en`, even if its full pack ID is not a built-in registry ID:

```dart
final result = WritingAnalyzer().analyze(
  text,
  languagePack: customEnglishPack,
);
```

Only use that broad eligibility when the rule's behavior is actually valid for the custom pack.

## Important registry/application limitation

Constructing a custom `SpellLanguagePack` does **not** automatically register it with `SpellLanguageRegistry`.

Current registry-based application features understand only built-in IDs. In particular:

- the bundled language dropdown uses `SpellLanguageRegistry.builtIns`;
- persisted selected language validation uses the registry;
- version-2 personal dictionary metadata validation uses registered IDs;
- Portable settings language validation uses registered IDs.

Therefore a third-party/custom pack can be used directly with reusable engine/analyzer APIs, but making it a first-class bundled application language requires source changes to the registry/data/UI/persistence/tests/docs—not only constructing an object at runtime.

## Adding an official built-in language

A production-quality new built-in pack should define/review:

1. stable language-region ID and metadata;
2. dictionary source/content/licensing and provenance;
3. frequency/ranking metadata;
4. tokenization regex with Unicode behavior;
5. valid personal-word policy;
6. normalization/canonicalization;
7. recognized suffix/affix policy, if any;
8. suggestion-distance expectations;
9. regional variant/exclusion behavior;
10. personal-dictionary import/export behavior;
11. persisted language selection;
12. writing-rule eligibility;
13. Portable settings validation;
14. benchmark scenario compatibility;
15. user/API/privacy documentation.

## Tests for a new pack

At minimum, add tests for:

- registry ID/default behavior;
- representative accepted/rejected regional words;
- token source ranges;
- normalization;
- decomposed/non-BMP Unicode where applicable;
- personal-word validation;
- recognized affix behavior;
- suggestions/ranking metadata;
- dictionary codec round trip and wrong-language handling;
- per-language persistence isolation;
- application language switching;
- writing-rule support filtering;
- Portable settings round trip;
- benchmark language option if supported there.

## Dictionary source and licensing

Bundled dictionary/frequency data lives under `lib/data/`. Before adding external language data, confirm its license is compatible with the repository and document attribution/redistribution requirements. Do not copy a dictionary from an incompatible or unclear source.

## Performance considerations

Large dictionaries increase candidate iteration cost for suggestions. `SpellCheckerEngine` filters by scalar length difference and maximum edit distance before ranking, but a new language pack should still be benchmarked with representative synthetic workloads.

Do not weaken correctness/source-range guarantees solely for benchmark numbers.

## Privacy

A language pack is local data/configuration. Built-in packs do not cause network requests. A future language implementation that downloads dictionaries or contacts a service would create a new privacy/security architecture and must not be presented as equivalent to current built-ins without explicit review/documentation.

## Related documentation

- [Public API](API.md)
- [Examples](EXAMPLES.md)
- [Writing rules](WRITING_RULES.md)
- [Configuration](CONFIGURATION.md)
- [Development](DEVELOPMENT.md)
- [Testing](TESTING.md)
