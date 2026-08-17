# Roadmap

SpellChecker `3.1.1+24` is the current V3 multilingual cross-platform foundation. V2.16 remains the completed stabilization line that preceded native platform expansion. This roadmap distinguishes **shipped current behavior** from **optional future directions**. It is not a promise that every future idea will be implemented, nor a schedule.

## Current status

The current project already ships:

- local deterministic spelling analysis;
- eight built-in offline spelling packs: English (US/UK), Hindi, Spanish, French, German, Brazilian Portuguese, and Italian;
- Unicode-aware tokenization/normalization and scalar edit distance;
- ranked spelling suggestions with injectable ranker strategy;
- per-language personal dictionaries;
- session ignored words;
- occurrence-safe single/replace-all spelling correction;
- first-200 spelling UI capture with explicit truncation semantics;
- deterministic local Writing insights subsystem;
- ten built-in writing rules;
- per-language writing-rule persistence with unset/explicit/empty semantics;
- Writing insights presets/search/categories/fix-only filtering;
- first-200 writing capture with exact analyzer totals;
- metadata-only diagnostic summary;
- stale-safe individual and deterministic batch writing correction;
- shared bounded correction undo;
- Portable settings format version 1;
- language-aware personal-dictionary format version 2 plus legacy readers;
- privacy/local-storage/accessibility/testing/release documentation;
- deterministic synthetic benchmark tooling;
- GitHub Actions CI;
- validated release-mode build artifacts for Android, iOS, Linux, macOS, Web, and Windows.

No unchecked V2.16 release requirement remains in the current roadmap.

## Post-V2.16 hardening already completed

The August 16, 2026 post-release audit additionally fixed:

- trailing unfinished sentence undercounting;
- terminal punctuation followed by common closing quote/bracket statistics;
- non-BMP sentence-capitalization first-scalar handling;
- sentence starts inside opening quotes/brackets after a completed sentence.

It also strengthened Buy Me a Coffee visibility and repository regression protection.

See [Post-V2.16 audit](POST_V216_AUDIT_2026_08_16.md).

# Optional future directions

The items below are opportunities, not committed release dates.

## Further language depth and expansion

V3.1 ships six new non-English starter packs. Future work can deepen those lexicons or add more languages, but should include compatible dictionary licensing/provenance, script-specific normalization and affix review, suggestion-quality/performance benchmarks, persistence/selector regressions, and an explicit writing-rule eligibility decision.

A deeper or new official language should meet the completeness checklist in [Language packs](LANGUAGE_PACKS.md).

## Additional deterministic writing rules

Potential rules should remain explainable and source-range-safe. Candidate categories could expand beyond the current Mechanics/Clarity set only with explicit public API/review design.

Every new rule needs an advisory-versus-automatic decision, compatibility review for defaults/preferences/Portable settings, interaction tests, and docs.

The project should avoid expanding the catalogue merely to increase rule count; each rule should have a precise deterministic scope.

## Third-party rule examples / plugin integration guidance

The public `WritingRule` contract already supports caller-supplied rule implementations through custom `WritingAnalyzer` configurations.

Optional work could include:

- standalone example packages/snippets;
- stronger plugin author guidance;
- rule metadata conventions;
- compatibility/testing templates.

Dynamic downloading/execution of untrusted third-party rule code is **not** current scope and would require a separate security/trust architecture.

## Additional suggestion ranking examples

`SpellSuggestionRanker` is injectable. Optional developer-facing work could provide more documented strategies or benchmark examples while preserving deterministic tie behavior.

No cloud ranking/model is required for this extension path.

## Cross-platform foundation completed

The V3 cross-platform foundation now commits official Flutter runners for Android, iOS, Linux, macOS, Windows, and Web. Cross-platform CI validates release-mode builds on target-appropriate GitHub-hosted operating systems, and the release workflow mirrors those build targets.

Remaining platform work is distribution engineering rather than runner creation:

- Android production keystore/signing and Play-style packaging policy;
- Apple signing/provisioning for iOS;
- macOS signing/notarization;
- Windows signing/installer packaging if selected;
- Linux package format/distribution policy;
- platform-specific icons/store metadata polish;
- broader manual accessibility/device matrices.

Private signing material must remain outside the repository.

## Web deployment/public hosting automation

The current release workflow uploads a web artifact but does not deploy it.

Optional work could add an intentional deployment destination such as GitHub Pages or another host, with:

- build provenance;
- environment/secret handling;
- rollback policy;
- custom-domain/security headers if relevant;
- deployment documentation.

## GitHub Release automation

The current workflow does not automatically create a GitHub Release record or permanent release asset.

Optional work could add:

- release-note generation policy;
- tag/version validation;
- GitHub Release creation;
- web artifact attachment;
- provenance/signing/checksum strategy.

## Documentation CI

The repository now has a documentation hub and repository test protecting key documentation contracts. Optional further automation could validate:

- relative Markdown links;
- Markdown style/lint;
- current package version references;
- language/rule registry references;
- duplicate/missing docs-index links.

Any added documentation tooling should remain deterministic and lightweight.

## Localization of application UI/documentation

Language packs currently control spelling data, not UI localization. Optional future work could localize labels/messages/documentation separately from spelling language packs.

This would require a Flutter localization architecture rather than overloading `SpellLanguagePack` with UI strings.

## More advanced writing analysis

Future deterministic improvements could include new local rules with carefully bounded grammar/mechanics scopes.

The project should preserve non-goals unless intentionally redesigned:

- no claim of exhaustive grammar understanding;
- no implicit generative rewriting;
- no silent semantic changes;
- no unsafe guessed mutation for ambiguous findings.

## Performance work

Potential work:

- controlled profiling of suggestion candidate loops;
- cache/memory profiling;
- writing-rule scan optimization;
- larger synthetic benchmark scenario variants;
- stable environment benchmark reporting.

Performance optimization must preserve Unicode/source-range/correction correctness.

## Data structure/dictionary improvements

Possible improvements include more efficient local lookup/candidate indexing, provided they preserve deterministic ranking results and current public behavior or explicitly document an API change.

Dictionary data changes also require language/variant/regression review.

## Accessibility expansion

Current UI has keyboard, semantics, responsive, and theme coverage. Optional expansion could include broader manual screen-reader/browser matrices, text-scale audits, automated accessibility tooling, and deeper native-platform accessibility review.

## Import/export usability

Potential improvements could include explicit file-based import/export in addition to clipboard workflows, but that would introduce file picker/storage/permission/privacy/platform considerations and must be designed deliberately.

## Document persistence

SpellChecker currently does not persist editor documents. Adding file/document saving would be a major product/privacy/security/platform feature rather than a small settings change.

Any future design would need explicit storage location, file format, overwrite/version/recovery behavior, permissions, and privacy documentation.

## What is intentionally not on the current committed roadmap

There is no committed plan requiring:

- cloud spelling/grammar;
- generative AI rewriting;
- user accounts;
- telemetry/advertising;
- background document upload/monitoring;
- untrusted dynamic plugin execution;
- automatic language detection;
- native release support without runners/CI/signing.

Any of those could only become project scope through an explicit future design/review, not by implication.

# Prioritization criteria

When choosing optional work, prefer changes that improve:

1. correctness and bug prevention;
2. privacy/security truthfulness;
3. accessibility/usability;
4. language/writing coverage with clear deterministic scope;
5. testability/maintainability;
6. performance under controlled evidence;
7. documentation/release clarity.

Avoid feature growth that weakens source ownership, deterministic behavior, backward compatibility, or local privacy without a compelling explicit redesign.

# How proposals become roadmap work

A significant proposal should identify:

- user/developer problem;
- exact scope/non-goals;
- public API impact;
- persistence/format impact;
- privacy/security impact;
- platform impact;
- accessibility impact;
- performance implications;
- migration compatibility;
- test plan;
- documentation updates.

Feature requests can be opened through the repository's GitHub issue templates. Funding is optional and does not determine whether proposals can be submitted/reviewed.

# Historical roadmap context

Release-specific design/validation files are indexed in [Release history](RELEASE_HISTORY.md). They preserve the sequence by which the current rule catalogue, bounded analysis, diagnostics, accessibility, benchmark, Unicode hardening, and stabilization behavior were added.

Use this page for future/current planning and historical records for what was planned/validated at a specific release point.

## Related documentation

- [Feature reference](FEATURES.md)
- [Release history](RELEASE_HISTORY.md)
- [Platform support](PLATFORM_SUPPORT.md)
- [Writing rules](WRITING_RULES.md)
- [Language packs](LANGUAGE_PACKS.md)
- [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md)
