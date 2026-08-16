# Documentation Maintenance

This page defines how SpellChecker documentation should evolve with the codebase. The goal is to keep documentation complete without allowing current behavior, historical release notes, public API guarantees, internal implementation details, and executable/release claims to blur together.

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
docs/GLOSSARY.md
docs/EXAMPLES.md
docs/API.md
docs/LANGUAGE_PACKS.md
docs/WRITING_RULES.md
docs/ARCHITECTURE.md
docs/PLATFORM_SUPPORT.md
docs/EXECUTABLE_BUILDS.md
docs/PERFORMANCE.md
docs/PRIVACY.md
docs/ACCESSIBILITY.md
docs/DEVELOPMENT.md
docs/TESTING.md
docs/TROUBLESHOOTING.md
docs/RELEASING.md
docs/ROADMAP.md
docs/RELEASE_HISTORY.md
docs/DOCUMENTATION_MAINTENANCE.md
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

`test/documentation_repository_test.dart` also treats repository-file coverage as executable documentation evidence: the marked tracked-file inventory in [Executable builds and packaging](EXECUTABLE_BUILDS.md) must match `git ls-files` exactly.

## Source-of-truth priority

For current behavior, review in this order:

1. public code/API contracts and current application behavior;
2. current tests and CI/release workflows;
3. evergreen topic documentation;
4. root README summary;
5. historical release notes.

Historical records are authoritative about what that historical release intended/validated, not about later current behavior.

For executable/release support, also distinguish these separate facts:

1. portable Flutter/Dart source exists;
2. a target runner is committed;
3. the target build is validated;
4. a release artifact is produced and retained/distributed.

Do not collapse those four levels into one “cross-platform” claim.

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

### Platform support or executable-build change

Update:

- `docs/PLATFORM_SUPPORT.md` support matrix;
- `docs/EXECUTABLE_BUILDS.md` target prerequisites, runner generation, commands, output/package expectations, signing boundary, verification, and tracked-file inventory;
- `docs/GETTING_STARTED.md` run/build steps when the supported user path changes;
- `docs/DEVELOPMENT.md` prerequisites and platform-development process;
- `docs/RELEASING.md` artifacts/signing/release process;
- `docs/PRIVACY.md` and `SECURITY.md` for platform-specific storage/network/security implications;
- root README and repository description when support claims change;
- CI/release workflows so the advertised target is actually built/validated.

Do not advertise a target as officially supported merely because Flutter can generate a runner. Add reviewed runner files, build validation, artifact policy, and release/support documentation first.

Every newly committed platform runner file must appear in the machine-checked tracked-file inventory in `docs/EXECUTABLE_BUILDS.md`.

### Tracked file addition, deletion, or rename

Regardless of file type:

1. update the marked tracked-file inventory in `docs/EXECUTABLE_BUILDS.md`;
2. classify the path in the appropriate inventory section;
3. document any build, validation, release, security, privacy, or support effect;
4. update inbound/outbound documentation links as needed;
5. run `test/documentation_repository_test.dart` and then the complete test suite.

This requirement is intentionally broad so “complete executable documentation” cannot silently fall behind the repository tree.

### CI/release workflow change

Update:

- `docs/TESTING.md`;
- `docs/RELEASING.md`;
- `docs/EXECUTABLE_BUILDS.md`;
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

### Keep build commands scoped to actual support

Build documentation must say whether a command is:

- part of the current official repository/release path; or
- a future/local target procedure that first requires reviewed runner generation and toolchain setup.

A documented native build command must not be interpreted as proof that the native runner is currently committed or release-supported.

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
- executable build/package docs;
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

- every new evergreen file is linked from `docs/README.md` when appropriate;
- current package version is correct;
- language count/IDs match `SpellLanguageRegistry`;
- writing-rule count/IDs match `WritingRuleRegistry.builtIns`;
- public API imports match exported barrels;
- suggestion bounds match application/storage/codec validation;
- UI capture limits match code;
- platform/release claims match workflow files and committed runners;
- `docs/EXECUTABLE_BUILDS.md` accurately distinguishes current web support from non-committed native runners;
- the executable-build tracked-file inventory matches `git ls-files` exactly;
- privacy claims match actual storage/network paths;
- code examples match current signatures;
- relative links resolve;
- no current-state page accidentally repeats stale historical registry counts;
- `dart format`/analysis/tests still pass when documentation changes include test/script updates.

## Documentation CI

The repository has executable documentation assertions in `test/documentation_repository_test.dart`. Among other current-state checks, it now verifies that the marked inventory in `docs/EXECUTABLE_BUILDS.md` accounts for every Git-tracked repository file and contains no stale paths.

A future dedicated Markdown link/lint job may additionally check:

- broken relative Markdown links;
- duplicate/missing documentation index entries;
- stale current version strings;
- current built-in language/rule IDs in selected evergreen reference files;
- malformed Markdown.

Any such tooling should remain deterministic, fast, and dependency-conscious.

## Review responsibility

A code reviewer should treat a stale public/current-state document as part of the change's correctness surface. “Code is correct but docs are wrong” is not complete work when the change affects documented behavior.

For repository structure or executable/release changes, a reviewer should also treat an incomplete tracked-file inventory as a correctness failure, because it breaks the documented guarantee that executable-build documentation accounts for the complete committed project tree.
