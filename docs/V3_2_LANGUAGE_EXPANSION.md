# V3.2 Language Expansion

SpellChecker V3.2 expands the offline spelling registry from eight to thirteen built-in language packs while hardening Unicode tokenization for scripts that use join controls.

## Release identity

- Package: `3.2.0+25`
- About version: `3.2.0`
- Default language: `en-US`
- Built-in language packs: 13
- Built-in writing rules: 10, still English-only
- Runtime dependencies: Flutter SDK and `shared_preferences`
- Release-build targets: Android, iOS, Linux, macOS, Web, Windows

## New built-in packs

| ID | Language | Region | Display name |
| --- | --- | --- | --- |
| `bn-IN` | `bn` | `IN` | Bengali (India) |
| `mr-IN` | `mr` | `IN` | Marathi (India) |
| `ta-IN` | `ta` | `IN` | Tamil (India) |
| `te-IN` | `te` | `IN` | Telugu (India) |
| `ru-RU` | `ru` | `RU` | Russian (Russia) |

The existing `en-US`, `en-GB`, `hi-IN`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, and `it-IT` packs remain supported and keep their stable IDs.

## Unicode join-control hardening

The built-in Unicode tokenizer and personal-word validator now preserve U+200C ZERO WIDTH NON-JOINER and U+200D ZERO WIDTH JOINER when they occur inside Unicode letter/combining-mark word sequences. This prevents legitimate joined Indic-script words from being split into separate spelling tokens.

Source ranges remain Dart/Flutter UTF-16 offsets. Edit distance and suggestion-length policy continue to use Unicode scalar values.

## Spelling behavior

Each new pack includes a project-curated offline starter lexicon and deterministic frequency-ranking metadata. V3.2 tests cover:

- stable registry IDs;
- representative native-language text;
- typo suggestions for every new pack;
- language-specific suggestion metadata;
- preference persistence for every registered language;
- per-language personal-dictionary isolation;
- Portable Settings round trips for every registered language;
- language-selector discovery, switching, and restoration;
- Unicode join-control tokenization.

These dictionaries are starter vocabularies, not exhaustive national dictionaries, morphology engines, or grammar references.

## Writing Insights boundary

The current ten Writing Insights rules continue to declare English (`en`) eligibility only. Bengali, Marathi, Tamil, Telugu, Russian, and the other non-English packs receive spelling, suggestions, personal dictionaries, persistence, and transfer support without incorrectly applying English-specific writing rules.

## Languages intentionally deferred

V3.2 does not label segmentation-heavy or normalization-sensitive languages as supported before the architecture is ready:

- Japanese, Korean, and Chinese require a reviewed token-segmentation strategy rather than simple whitespace assumptions.
- Arabic requires an explicit policy for normalization, optional diacritics, and morphology before a built-in pack is claimed.

## Acceptance criteria

V3.2 is complete only when:

1. all thirteen built-in IDs resolve and persist correctly;
2. every new pack accepts representative native-language text and produces deterministic suggestions;
3. join-control words remain single Unicode tokens;
4. Portable Settings and personal dictionaries remain language-isolated;
5. current documentation and About/package identities agree on `3.2.0+25` / `3.2.0`;
6. formatting, analyzer, full tests, and benchmark smoke are green;
7. Android, iOS, Linux, macOS, Web, and Windows release builds succeed and publish artifacts;
8. the same gates pass again after merge to `main`.
