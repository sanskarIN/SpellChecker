# Documentation Maintenance

This page defines how SpellChecker documentation should evolve with the codebase. The goal is to keep documentation complete without allowing current behavior, historical release notes, public API guarantees, and internal implementation details to blur together.

## Documentation layers

SpellChecker uses four documentation layers.

### 1. Repository front door

`README.md` is the project landing page. It should answer:

- what SpellChecker is;
- why it exists;
- key current capabilities;
- current release/version;
- quickest run path;
- where to find complete documentation;
- contribution/security/support/funding links.

The root README should not be the only place where a detailed contract exists. Long-lived detail belongs under `docs/`.

### 2. Evergreen current-state documentation

These pages describe current `main` behavior and must be updated when the relevant code contract changes:

```text
docs/README.md
docs/GETTING_STARTED.md
docs/FEATURES.md
docs/USER_GUIDE.md
docs/CONFIGURATION.md
docs/KEYBOARD_SHORTCUTS.md
docs/FAQ.md
docs/EXAMPLES.md
docs/API.md
docs/LANGUAGE_PACKS.md
docs/WRITING_RULES.md
docs/ARCHITECTURE.md
docs/PLATFORM_SUPPORT.md
docs/PERFORMANCE.md
docs/PRIVACY.md
docs/ACCESSIBILITY.md
docs/DEVELOPMENT.md
docs/TESTING.md
docs/TROUBLESHOOTING.md
docs/RELEASING.md
docs/ROADMAP.md
```

Top-level evergreen project-policy files include:

```text
CONTRIBUTING.md
SECURITY.md
SUPPORT.md
GOVERNANCE.md
CODE_OF_CONDUCT.md
CHANGELOG.md
LICENSE
```

### 3. Historical design/audit/validation records

Files named for a specific release or dated audit are immutable historical context unless a factual typo/link break makes the record unusable.

Examples:

```text
docs/V2_10_BENCHMARK.md
docs/V2_11_ACCESSIBILITY.md
docs/V2_12_*.md
docs/V2_13_*.md
docs/V2_14_*.md
docs/V2_15_*.md
docs/V2_16_*.md
docs/POST_V216_AUDIT_2026_08_16.md
```

Do not rewrite an old “nine-rule registry” statement in a V2.14 record merely because current `main` has ten rules. That historical count is part of the record.

Use [Release history](RELEASE_HISTORY.md) to help readers distinguish historical from current-state documents.

### 4. Code comments/tests as executable evidence

Code is the implementation source of truth. Tests are executable evidence of intended behavior. Documentation should reflect both, but docs should not simply copy implementation details that are not stable contracts.

When documentation and code disagree, fix the mismatch in the same change that establishes the intended behavior.

## Source-of-truth priority

For current behavior, review in this order:

1. public code/API contracts and current application behavior;
2. current tests and CI/release workflows;
3. evergreen topic documentation;
4. root README summary;
5. historical release notes.

Historical records are authoritative about what that historical release intended/validated, not about later current behavior.

## Required documentation updates by change type

### Public API change

Update:

- `docs/API.md`;
- `docs/EXAMPLES.md` when a usage example is useful;
- the relevant topic page (`LANGUAGE_PACKS.md`, `WRITING_RULES.md`, etc.);
- `CHANGELOG.md`;
- tests demonstrating the contract.

If the change is source/binary/data compatible only under specific conditions, document those conditions explicitly.

### New writing rule

Update:

- `docs/WRITING_RULES.md` catalogue and rule ID list;
- `docs/FEATURES.md` current rule table;
- `docs/USER_GUIDE.md` when the rule changes user workflow;
- `docs/API.md` if the rule is publicly exported;
- `docs/CONFIGURATION.md` if default/persistence compatibility is affected;
- benchmark/stress docs when analysis load changes materially;
- `CHANGELOG.md`;
- release-history record when the addition has meaningful migration/source-ownership design.

Add tests for registry defaults, language support, source ownership, correction behavior, preference compatibility, Portable settings compatibility, review filtering, diagnostics, widget behavior, and stress/Unicode cases as appropriate.

### New language pack

Update:

- `docs/LANGUAGE_PACKS.md`;
- `docs/FEATURES.md` language table;
- `docs/USER_GUIDE.md`;
- `docs/GETTING_STARTED.md` if the first-run behavior changes;
- `docs/CONFIGURATION.md` for import/persistence semantics;
- `docs/API.md`;
- `docs/PLATFORM_SUPPORT.md` only if target behavior changes;
- tests and benchmark scenarios where relevant.

### Preference/storage change

Update:

- `docs/CONFIGURATION.md`;
- `docs/PRIVACY.md`;
- `docs/TROUBLESHOOTING.md`;
- `docs/API.md` for public codecs;
- migration/compatibility tests;
- `CHANGELOG.md`.

Never document an internal preference key as a stable public API unless the project intentionally promotes it to one.

### Keyboard/accessibility change

Update:

- `docs/KEYBOARD_SHORTCUTS.md`;
- `docs/ACCESSIBILITY.md`;
- `docs/USER_GUIDE.md`;
- tooltips/semantics labels where appropriate;
- keyboard/semantics/widget tests;
- `CHANGELOG.md` for user-visible changes.

### Platform support change

Update:

- `docs/PLATFORM_SUPPORT.md` support matrix;
- `docs/GETTING_STARTED.md` run/build steps;
- `docs/DEVELOPMENT.md` prerequisites;
- `docs/RELEASING.md` artifacts/signing process;
- `docs/PRIVACY.md` and `SECURITY.md` for platform-specific storage/network/security implications;
- root README and repository description when support claims change.

Do not advertise a target as officially supported merely because Flutter can generate a runner. Add build validation and release/support policy first.

### CI/release workflow change

Update:

- `docs/TESTING.md`;
- `docs/RELEASING.md`;
- `docs/GETTING_STARTED.md` if developer commands change;
- `docs/PLATFORM_SUPPORT.md` when build target coverage changes.

### Privacy/security behavior change

Update privacy/security documentation in the **same pull request**. Do not defer documentation when a new network path, storage category, exported diagnostic, external service, permission, credential, or sensitive-data path is introduced.

## Documentation style

### Prefer current facts over marketing language

Use precise statements such as:

> The release workflow builds a Flutter web artifact.

Do not use a broader claim such as “released on every platform” unless the repository actually builds/tests/releases those targets.

### Label guarantees versus implementation details

Public contract example:

> `SpellIssue.start/end` are UTF-16 source offsets for the checked Dart string snapshot.

Implementation-detail example:

> `DictionaryPreferences` currently uses the key prefix `spellchecker.personal_words.v2.`.

The latter can be documented for debugging, but must be labeled as internal.

### Use synthetic examples

Documentation and bug-reproduction examples must avoid private documents, credentials, account data, personal messages, or sensitive vocabulary. Prefer short artificial strings such as:

```text
Helo world
hello  world!!
word word
```

### Keep code snippets compilable in spirit

Examples should:

- use public imports when demonstrating public APIs;
- match current method signatures;
- avoid referencing unexported classes as if they were public;
- explain when persistence/UI behavior is application-specific rather than library behavior.

### Be explicit about UTF-16 versus Unicode scalars

SpellChecker intentionally uses different coordinate models for different tasks:

- source ranges: UTF-16 offsets, matching Dart `String`/Flutter editing APIs;
- unrestricted edit distance and relevant length/casing decisions: Unicode scalar values.

Never call an issue offset a “rune index.”

### Use normative words carefully

- **must**: required for correctness/compatibility/security.
- **should**: strong project expectation with possible justified exceptions.
- **may**: optional behavior.

## Links

Prefer repository-relative Markdown links for repository files:

```markdown
[User guide](USER_GUIDE.md)
[Contributing](../CONTRIBUTING.md)
```

Use absolute URLs for external services such as GitHub repository pages or Buy Me a Coffee.

When renaming a document, update every inbound link in the same change.

## Headings and navigation

Each evergreen page should:

- begin with one H1;
- explain scope near the top;
- link related pages at the end or in context;
- avoid placing current facts only inside a release-specific subsection;
- be discoverable from `docs/README.md`.

Large current-state pages may retain historical release notes, but current behavior should be easy to find without reading those notes first.

## Version references

Use the package version from `pubspec.yaml` when stating the current release. When changing it, audit:

- root README;
- About dialog/user-visible version strings;
- docs index/current release references;
- changelog/release docs;
- tests that assert version text.

Historical release documents keep their historical version references.

## Funding references

The canonical optional funding URL is:

```text
https://buymeacoffee.com/sanskarIN
```

The repository already protects key BMC surfaces with a regression test. Documentation may include funding links where useful, but funding must never be presented as a requirement for support, issue triage, security response, roadmap decisions, or contribution review.

## Documentation validation checklist

Before merging documentation-heavy work, verify:

- every new file is linked from `docs/README.md` when appropriate;
- current package version is correct;
- language count/IDs match `SpellLanguageRegistry`;
- writing-rule count/IDs match `WritingRuleRegistry.builtIns`;
- public API imports match exported barrels;
- suggestion bounds match application/storage/codec validation;
- UI capture limits match code;
- platform/release claims match workflow files and committed runners;
- privacy claims match actual storage/network paths;
- code examples match current signatures;
- relative links resolve;
- no current-state page accidentally repeats stale historical registry counts;
- `dart format`/analysis/tests still pass when documentation changes include test/script updates.

## Recommended docs CI

The repository currently validates Dart/Flutter code but does not have a dedicated Markdown link/lint job. A future documentation CI enhancement may add checks for:

- broken relative Markdown links;
- duplicate/missing documentation index entries;
- stale current version strings;
- current built-in language/rule IDs in selected evergreen reference files;
- malformed Markdown.

Any such tooling should remain deterministic, fast, and dependency-conscious.

## Review responsibility

A code reviewer should treat a stale public/current-state document as part of the change's correctness surface. “Code is correct but docs are wrong” is not complete work when the change affects documented behavior.
