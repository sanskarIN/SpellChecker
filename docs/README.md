# SpellChecker Documentation

<p align="center">
  <a href="https://buymeacoffee.com/sanskarIN">
    <img alt="Buy Me a Coffee — Support SpellChecker" src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Support%20SpellChecker-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=000000">
  </a>
</p>

This directory is the documentation home for SpellChecker `3.2.0+25`. SpellChecker is a privacy-first Flutter spelling utility and deterministic writing assistant. The current repository commits official Flutter runners for Android, iOS, Linux, macOS, Windows, and Web, ships thirteen built-in offline spelling language packs, exposes three public Dart API barrels, and contains ten built-in local writing rules.

## Choose your path

### I want to use the application

Start with:

1. [Getting started](GETTING_STARTED.md) — install prerequisites, run the app on committed targets, and perform the first spelling and writing checks.
2. [User guide](USER_GUIDE.md) — complete editor, spelling, Writing insights, dictionary, settings, keyboard, undo, and large-document workflows.
3. [Feature reference](FEATURES.md) — current capabilities, limits, and intentionally unsupported behavior.
4. [Configuration and local data](CONFIGURATION.md) — languages, suggestion limits, personal dictionaries, ignored words, writing-rule preferences, Portable settings, and persistence behavior.
5. [Keyboard shortcuts](KEYBOARD_SHORTCUTS.md) — compact keyboard reference.
6. [FAQ](FAQ.md) — common usage, privacy, platform, language, import/export, and troubleshooting questions.
7. [Glossary](GLOSSARY.md) — project terms such as bounded analysis, captured findings, UTF-16 offsets, Unicode scalars, rule overrides, and advisory fixes.
8. [Troubleshooting](TROUBLESHOOTING.md) — recovery guidance for startup, storage, imports, analysis, and build problems.
9. [Accessibility](ACCESSIBILITY.md) — keyboard, focus, semantics, contrast, responsive layout, and assistive-technology contract.
10. [Privacy](PRIVACY.md) — data-flow and local-storage boundaries.

### I want to use SpellChecker as Dart/Flutter code

Start with:

1. [Library examples](EXAMPLES.md) — copyable examples for spelling, bounded analysis, language packs, dictionaries, writing analysis, diagnostics, corrections, and custom rules.
2. [Public API](API.md) — detailed contract for exported classes and functions.
3. [Language packs](LANGUAGE_PACKS.md) — built-ins and extension model.
4. [Writing rules](WRITING_RULES.md) — rule catalogue, IDs, categories, severities, automatic/advisory behavior, and plugin contract.
5. [Architecture](ARCHITECTURE.md) — package boundaries and application data flow.
6. [Performance](PERFORMANCE.md) — bounded-analysis behavior and deterministic benchmark tooling.
7. [Glossary](GLOSSARY.md) — shared terminology for API, Unicode, analysis, persistence, and review concepts.

Public import barrels:

```dart
import 'package:spellchecker/spell_checker.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';
```

Application widgets and persistence adapters are implementation details unless they are exported from one of those barrels.

### I want to contribute or maintain the project

Use:

1. [Development guide](DEVELOPMENT.md) — prerequisites, repository layout, development commands, and implementation expectations.
2. [Testing guide](TESTING.md) — test structure, focused suites, CI gates, Android support-contract validation, Unicode/UTF-16 coverage, and benchmark smoke.
3. [Documentation maintenance](DOCUMENTATION_MAINTENANCE.md) — documentation source-of-truth rules, link policy, versioning, and review checklist.
4. [Release guide](RELEASING.md) — tagged multi-platform release workflow and release validation.
5. [Executable builds and packaging](EXECUTABLE_BUILDS.md) — complete build, packaging, signing-boundary, platform-generation, verification, troubleshooting, and tracked-file inventory for release artifacts.
6. [Platform support](PLATFORM_SUPPORT.md) — what is committed, built, validated, and still external distribution/signing work.
7. [Android support guide](../android/README.md) — Android development, privacy, predictive back, APK/AAB packaging, production signing, Google Play preparation, device testing, and troubleshooting.
8. [Roadmap](ROADMAP.md) — completed release scope and optional future directions.
9. [Release history index](RELEASE_HISTORY.md) — navigation for V2.x design/audit/validation records.
10. [Contributing](../CONTRIBUTING.md), [security policy](../SECURITY.md), [support policy](../SUPPORT.md), [governance](../GOVERNANCE.md), and [code of conduct](../CODE_OF_CONDUCT.md).

## Current product contract

| Area | Current contract |
| --- | --- |
| Package version | `3.2.0+25` |
| Dart SDK | `>=3.8.0 <4.0.0` |
| Runtime dependencies | Flutter SDK and `shared_preferences` |
| Built-in language packs | `en-US`, `en-GB`, `hi-IN`, `es-ES`, `fr-FR`, `de-DE`, `pt-BR`, `it-IT`, `bn-IN`, `mr-IN`, `ta-IN`, `te-IN`, `ru-RU` |
| Default language | `en-US` |
| Built-in writing rules | 10 |
| Suggestion limit | 1–10; default 5 |
| Spelling UI capture | first 200 issues, with explicit truncated state |
| Writing UI capture | first 200 findings, with exact analyzer totals and captured-only review/fix semantics |
| Editor text persistence | none |
| Personal dictionary persistence | local, per language |
| Writing-rule persistence | local, per language |
| Portable settings format | `spellchecker-settings`, version 1 |
| Personal dictionary format | version 2 for language-aware export; legacy version 1 remains readable |
| Network spelling/grammar | none |
| Telemetry/account/cloud sync | none |
| Committed host runners | Android, iOS, Linux, macOS, Windows, Web |
| Automated release artifacts | Android APK + Android App Bundle, iOS no-codesign app, Linux bundle, macOS app, Web bundle, Windows bundle |
| iOS transport policy | arbitrary, web-content, and local networking exceptions disabled in the production Info.plist |
| macOS release policy | App Sandbox enabled with no network client/server entitlement and no release JIT entitlement |

Apple release validation is intentionally artifact-based as well as source-based. Both normal cross-platform CI and tagged release CI lint Apple plist/entitlement sources, run the Apple repository support contract, build release-mode iOS/macOS apps, verify the compiled bundle identifier and version metadata, and require at least one embedded `PrivacyInfo.xcprivacy` manifest from the Apple dependency graph. This keeps the privacy-manifest guarantee tied to what would actually be packaged rather than only to a source-tree assumption.

## Evergreen docs versus historical docs

The files linked under the user, library, contributor, and maintainer paths above are **evergreen**: they describe the current `main` behavior and should be updated when the code contract changes.

Files named for a specific release, such as `V2_15_*` or `V2_16_*`, are **historical records**. They document what a particular release introduced, audited, or validated. Historical files should not be rewritten merely because a later release changed the product. If a historical statement conflicts with an evergreen current-state page, use the evergreen page for current behavior and the historical page only for release context.

The post-release audit is recorded in [POST_V216_AUDIT_2026_08_16.md](POST_V216_AUDIT_2026_08_16.md).

## Documentation quality expectations

Every current-state document should distinguish between:

- behavior guaranteed by public APIs;
- behavior implemented by the bundled application UI;
- internal persistence details that may change;
- historical compatibility behavior;
- optional future work that is not currently shipped.

Examples must use synthetic/non-sensitive text. Privacy documentation must never imply that editor text, personal vocabulary, ignored session words, correction history, or finding excerpts are uploaded by the application.

Executable/build documentation additionally must distinguish between a portable Flutter source target, a committed runner, a validated build, and a published release artifact. The tracked-file inventory in [Executable builds and packaging](EXECUTABLE_BUILDS.md) is machine-checked so new committed files cannot be silently omitted from build/release documentation.

## Support and funding

SpellChecker is free and open source. Bug reports, feature requests, security reports, and contribution review are not conditioned on funding. Optional financial support is available through [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN).

For help, read [SUPPORT.md](../SUPPORT.md) and [Troubleshooting](TROUBLESHOOTING.md) before opening a public issue. Never attach private documents when a synthetic reproducer is sufficient.
