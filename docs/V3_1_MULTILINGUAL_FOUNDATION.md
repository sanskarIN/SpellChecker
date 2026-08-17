# V3.1 Multilingual Foundation

SpellChecker V3.1 expands the offline spelling registry from two English variants to eight built-in packs while keeping the V3 cross-platform, privacy, persistence, and deterministic-analysis contracts intact.

## Version

- package: `3.1.0+23`
- About: `3.1.0`
- default language remains: `en-US`

## Added built-in spelling packs

- `hi-IN` — Hindi (India)
- `es-ES` — Spanish (Spain)
- `fr-FR` — French (France)
- `de-DE` — German (Germany)
- `pt-BR` — Portuguese (Brazil)
- `it-IT` — Italian (Italy)

Together with `en-US` and `en-GB`, the application exposes eight explicit offline spelling packs.

## Engine and persistence changes

- reuse Unicode letter/combining-mark tokenization for Latin and Devanagari scripts;
- generalize built-in normalization beyond English-only naming;
- add immutable `recognizedPrefixes` to `SpellLanguagePack`;
- add prefix/suffix-aware stem checking and suggestion reconstruction;
- cover common French and Italian apostrophe elision;
- keep personal dictionaries isolated by full language ID;
- keep suggestion metadata deterministic and language-specific.

## Writing-rule boundary

This release expands spelling language support. Current Writing insights rules still declare English (`en`) eligibility and therefore run only for `en-US` and `en-GB`. V3.1 intentionally does not apply English-specific mechanics/capitalization rules to the six new packs.

## Lexicon boundary

The new dictionaries are project-curated offline starter lexicons of common words with small deterministic frequency-rank maps. They validate useful common-text behavior and the multilingual architecture, but are not exhaustive national dictionaries, morphology engines, or grammar references.

## Privacy and dependencies

No runtime dependency, account, telemetry, cloud writing service, document upload, or background dictionary download is added. Language data remains bundled and local.

## Validation requirements

- canonical formatting;
- `flutter analyze`;
- complete Flutter tests;
- multilingual registry/engine/persistence/widget regressions;
- deterministic benchmark smoke;
- Android, iOS, Linux, macOS, Web, and Windows release builds.
