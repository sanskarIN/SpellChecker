# Security Policy

This policy describes the current SpellChecker `3.2.0+25` security model, supported versions, reporting process, trust boundaries, platform protections, and contributor expectations.

For privacy/data-flow details, see [docs/PRIVACY.md](docs/PRIVACY.md). For build, signing, and distribution boundaries, see [docs/EXECUTABLE_BUILDS.md](docs/EXECUTABLE_BUILDS.md) and [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md). Historical release-specific security notes remain available through [docs/RELEASE_HISTORY.md](docs/RELEASE_HISTORY.md).

## Supported versions

Security fixes are applied to the latest code on `main` and, when practical, the newest tagged release.

| Version | Support |
| --- | --- |
| Latest `main` | supported |
| Latest release | supported |
| Older releases | best effort |

## Reporting a vulnerability

Do not publish exploitable details, secrets, private documents, sensitive personal vocabulary, or other user data in a normal public issue.

Preferred process:

1. use GitHub Private Vulnerability Reporting for this repository when available;
2. if private reporting is unavailable, contact the maintainer through a private contact method listed on the maintainer's GitHub profile;
3. provide a minimal synthetic reproduction rather than real private data.

A useful report includes:

- affected version/commit;
- affected component;
- reproduction steps;
- expected versus actual behavior;
- security impact;
- environment/platform when relevant;
- mitigation idea, if known.

Do not include credentials/tokens/keys in the report body; rotate exposed credentials through the relevant provider first.

## Security goals

SpellChecker is designed to:

- perform spelling and deterministic writing analysis locally;
- avoid requiring a remote text-analysis service;
- minimize runtime dependencies;
- keep editor text/findings/correction history out of durable preference storage;
- validate imported settings/dictionary metadata strictly;
- validate current source ownership before automatic text mutation;
- resolve writing batch overlaps conservatively and deterministically;
- keep rule/language/persistence identifiers versioned/stable where compatibility matters;
- avoid dynamic execution of imported dictionary/settings data;
- avoid downloading or executing untrusted writing rules;
- surface preference write failures instead of falsely claiming durability;
- keep production signing material outside the public repository;
- run automated formatting, analysis, tests, benchmark smoke, and target builds before release packaging.

## Current runtime attack surface

The bundled application currently has a deliberately small runtime integration surface:

```text
Flutter framework
shared_preferences local storage
Flutter clipboard API for explicit copy actions
browser/host rendering, storage, clipboard, and platform runtime behavior
```

There is no current runtime dependency for:

- HTTP/network text analysis;
- telemetry/analytics;
- advertising;
- user authentication/accounts;
- remote logging;
- cloud document sync;
- dynamic plugin/rule downloads;
- remote model inference.

A future change adding any of those materially changes the threat model and requires explicit security/privacy/design review.

## Untrusted editor text

Treat editor text as untrusted data.

Core analyzers:

- tokenize, compare, and scan strings;
- do not execute document contents;
- do not evaluate code/markup;
- do not interpret strings as commands;
- do not fetch URLs embedded in text;
- do not dynamically load code based on text.

Structural delimiter rules scan literal delimiter characters only. They are not programming-language/template/Markdown parsers and never execute surrounding text.

## Source-range mutation safety

Automatic correction is a security/correctness boundary because stale offsets could mutate unintended text.

### Spelling

`TextCorrection` requires current source ranges to still match `SpellIssue.word` before applying. Replace-all operates only on supplied represented issues and applies from source end toward the beginning.

### Writing

`WritingCorrection.apply` requires a non-null replacement plus exact current `originalText` ownership.

`applyAll`:

- sorts by deterministic source ordering;
- skips advisory findings;
- skips invalid/stale ranges;
- skips later overlapping candidates;
- applies accepted edits end-to-start.

Filtered UI batches use the same correction engine; filtering does not bypass validation/conflict rules.

## Advisory structural rules

`unmatched-parenthesis`, `unmatched-square-bracket`, and `unmatched-curly-brace` are advisory-only. They detect literal imbalance but do not guess insertion/deletion/movement rewrites.

This separates deterministic detection from mutation when the correct fix is ambiguous.

## UTF-16 / Unicode safety

Public issue source ranges are UTF-16 code-unit offsets matching Dart/Flutter string editing. Scalar-sensitive algorithms use Unicode scalar iteration where required to avoid splitting non-BMP characters.

Changes to Unicode-sensitive parsing/correction must include non-BMP/decomposed-sequence regression coverage where relevant.

Malformed imported text/metadata must not be used to bypass source ownership or index validation.

## Local persistence

Durable preference categories:

```text
selected language
suggestion limit
per-language personal vocabulary
per-language explicit writing-rule IDs
```

Not durably persisted by SpellChecker:

```text
editor text
spelling results
writing findings/messages/excerpts
ignored session words
suggestion cache
active issue selection
correction history
review search/filter/preset state
```

Personal vocabulary is user data and should not be exposed or logged unnecessarily.

Physical preference storage is provided by the `shared_preferences` platform implementation. SpellChecker does not treat platform-specific preference file/registry locations as a public API.

## Preference integrity

Writing-rule preferences intentionally distinguish:

```text
missing key          -> current defaults
non-empty stored set -> explicit enabled IDs
empty stored set     -> explicit disable-all
```

Do not collapse empty to missing/default. Unknown/stale rule IDs are intersected with supported current rules rather than executed dynamically.

Preference writes/removals are considered successful only when the platform preference API reports success.

## Import/export security

### Personal dictionary

Dictionary import treats input as data only. It validates JSON/version/language/word entries or supported plain-list forms, normalizes with the target language pack, and never evaluates content.

Current language-aware version-2 documents require a registered supported language ID. The bundled UI refuses to silently merge a document tagged for another language into the current language.

### Portable settings

Portable settings requires:

```text
format: spellchecker-settings
version: 1
```

The codec validates object shape, registered language IDs, suggestion bounds, override shapes, rule-ID syntax, and duplicates.

Settings import does not load or execute rules from imported IDs. Effective enabled rules remain limited to source-controlled current registry rules that support the selected language.

### Fail-closed parsing

Unsupported or malformed metadata should raise a validation failure rather than silently interpreting an ambiguous format.

## Import persistence transaction

The application attempts to preserve and restore previous durable settings if Portable settings persistence fails partway through import.

A failed storage write should not be reported as durable success. If restoration cannot be guaranteed, the UI marks storage unavailable or reports the failure.

## Clipboard boundary

Dictionary/settings/diagnostic copy actions require explicit user action.

Copied personal vocabulary or settings can become visible to other software according to host clipboard policy. SpellChecker cannot control clipboard readers after data has been copied.

The metadata-only writing diagnostic excludes editor text, excerpts, replacements, and offsets by design, reducing accidental data disclosure in support workflows.

## Diagnostic output

`WritingAnalysisDiagnosticSummary` contains counts and stable rule/language metadata only.

It deliberately excludes:

- document text;
- source excerpts;
- finding messages;
- suggested replacements;
- source offsets.

Future diagnostics/logging should default to similarly privacy-minimized metadata and require explicit design before including user content.

## Denial-of-service / large inputs

The application provides bounded retained issue/finding policies, but these are not execution-time sandboxes.

Important distinctions:

- spelling UI captures the first 200 issues and avoids suggestion generation after overflow proof;
- writing UI captures the first 200 findings, but enabled rules still scan input to produce exact totals;
- structural rules are iterative and stress-tested, but large input still consumes CPU/memory;
- public callers can request different or unbounded limits.

Host applications accepting attacker-controlled very large inputs must apply their own input/resource policies as appropriate.

Do not describe current capture limits as hard protection against all computational denial-of-service conditions.

## Dynamic code/plugin boundary

Current built-in writing rules are source-controlled Dart code. SpellChecker does not dynamically download or execute third-party rule code.

Any future plugin-loading system must define before implementation:

- trusted origin/signing;
- update/revocation;
- code execution permissions;
- filesystem/network access;
- sandboxing/host process isolation;
- privacy/data access;
- dependency/supply-chain policy.

## Dependency and supply-chain policy

Runtime dependencies are intentionally minimal. Before adding a dependency, review:

- necessity;
- maintainer/source trust;
- license;
- transitive dependency footprint;
- known advisories;
- network/telemetry behavior;
- native permissions/code;
- update cadence;
- data access.

`pubspec.lock` is committed so application builds have a reviewed dependency resolution. Dependabot configuration can surface dependency updates, but maintainers still need to review compatibility and security impact.

GitHub Actions should use trusted actions, explicit reviewed versions, and the least permissions practical for each job. A dependency or action update is not considered safe solely because automation proposed it.

## Platform security boundaries

SpellChecker commits Android, iOS, Linux, macOS, Web, and Windows Flutter runners. Cross-platform CI builds release-mode outputs for all six targets, but platform permission and signing models differ.

### Android

The production Android manifest is intentionally offline-first:

- no production `android.permission.INTERNET` request;
- `android:usesCleartextTraffic="false"`;
- `android:allowBackup="false"`.

Debug/profile development manifests can request Internet access where Flutter development tooling requires it. CI tests that this development permission does not leak into the production manifest.

Production upload signing is supported through ignored `android/key.properties`. The private keystore, passwords, and Play credentials must remain external. When release credentials are absent, public CI uses non-production signing only to prove APK/AAB buildability; that output is not a store release.

### iOS

The committed production `Info.plist` keeps App Transport Security exceptions explicitly disabled for arbitrary loads, arbitrary web-content loads, and local networking exceptions.

Public CI builds the iOS app with `--no-codesign`, validates bundle identity/version metadata, and requires an embedded Apple privacy manifest before archiving. Certificates, private keys, provisioning, App Store credentials, and production signing remain outside the repository.

### macOS

The release entitlement set enables App Sandbox and does not grant release network client, network server, or JIT entitlements.

CI validates the entitlement/plist syntax, builds the `.app`, checks its bundle identity/version metadata, and requires an embedded Apple privacy manifest. Public distribution still requires an intentional external signing/notarization process.

### Web

Web builds necessarily execute inside a browser origin and fetch their own static application assets from the host serving the application. That transport behavior is different from sending editor content to a remote analysis service.

SpellChecker does not include a network spelling/grammar API, telemetry endpoint, account service, or document upload service. Browser storage, clipboard, extensions, enterprise policy, service infrastructure, and hosting headers remain part of the web host/browser trust boundary.

### Windows and Linux

The current Windows and Linux applications use the shared Flutter/local-preference behavior and do not add a SpellChecker network-analysis service. These operating systems do not use the Android/iOS permission-manifest model for ordinary desktop networking, so release review must rely on code/dependency review, runtime behavior, packaging validation, and any future installer/sandbox policy selected for the distribution channel.

Windows code signing and Linux package/repository signing, if adopted, require external private credentials and explicit distribution policy.

## CI and release security

Current source, cross-platform, and release workflows use GitHub-hosted runners. Public repository validation does not require application secrets.

The primary quality gate performs:

```text
flutter pub get
canonical Dart formatting check
flutter analyze
complete Flutter test suite
deterministic benchmark smoke
```

Cross-platform CI then validates release-mode outputs for:

```text
Web
Android APK + Android App Bundle
Linux desktop bundle
Windows desktop bundle
macOS application bundle
iOS application bundle without codesigning
```

Target workflows use read-only repository contents permission unless a future publishing operation explicitly requires more. Android and Apple jobs contain additional platform-specific privacy/metadata validation before artifact upload.

The tagged/manual release workflow mirrors the six-target build contract and uploads validation/staging artifacts. It does not currently publish to application stores, notarization services, a package repository, a hosted website, or a permanent GitHub Release record.

GitHub Actions artifacts are build evidence/staging output, not by themselves a cryptographic end-user provenance guarantee. If permanent release publication is added, define checksums/provenance, write permissions, environment protections, rollback, and secret handling explicitly.

## Secrets and signing material

No application secret is required for local spelling or writing analysis.

Never commit:

- API keys;
- passwords;
- OAuth tokens;
- Android signing keys/keystores or passwords;
- Apple signing certificates/private keys;
- provisioning credentials containing sensitive material;
- Windows/macOS code-signing private keys;
- notarization credentials;
- package/store service-account credentials.

Use repository/environment secret stores for future CI publishing integrations and expose only the minimum scope needed.

Unsigned, debug-signed, or no-codesign CI output must not be presented as a production-signed store artifact.

## Application identity and update safety

Stable application identifiers affect upgrade continuity, preference continuity, signing, and store identity.

The current reverse-domain identity is `in.sanskar.spellchecker` where the platform uses that model, while the user-facing product name is `SpellChecker`.

Changing application/package/bundle identifiers is a migration and requires explicit review. Do not change identifiers as a cosmetic rename or runner-template refresh.

## Release artifact review

A successful compiler invocation is necessary but not sufficient for a trustworthy public release. Release review should verify, as applicable:

- exact source commit and package version;
- complete quality-gate success;
- target release build success;
- expected bundle contents and runtime dependencies;
- application identity and version metadata;
- privacy/permission/entitlement boundaries;
- signing identity for the intended distribution channel;
- artifact checksum/provenance when published permanently;
- clean-environment install/startup behavior;
- no secrets embedded in source, logs, or artifacts.

See [docs/EXECUTABLE_BUILDS.md](docs/EXECUTABLE_BUILDS.md) for the complete packaging boundary.

## External links and BMC

Repository/support documentation includes external links such as GitHub and [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN).

These are project navigation/funding surfaces, not editor-analysis services. SpellChecker does not send editor text or findings to Buy Me a Coffee.

Funding never changes vulnerability handling or support access.

## Security-sensitive contributor checklist

Before merging a security-relevant change, verify:

- threat boundary clearly identified;
- no hidden new network/data flow;
- strict input validation;
- source-range/index validation;
- no dynamic execution of imported data;
- no secret/private data committed or logged;
- least privilege for workflow permissions;
- platform manifests/entitlements still match the documented privacy boundary;
- persistence error behavior is truthful;
- Unicode and large-input behavior is tested where relevant;
- signing material remains external;
- privacy/security/platform/release documentation is updated;
- regression coverage reproduces the weakness safely.

## Coordinated disclosure

Maintainers should avoid publishing exploit details before a fix or mitigation is available when early disclosure could harm users.

A security fix should include regression coverage and appropriate changelog/release notes without unnecessarily publishing sensitive exploit detail.

## Related documentation

- [Privacy](docs/PRIVACY.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Configuration](docs/CONFIGURATION.md)
- [Testing](docs/TESTING.md)
- [Platform support](docs/PLATFORM_SUPPORT.md)
- [Executable builds and packaging](docs/EXECUTABLE_BUILDS.md)
- [Releasing](docs/RELEASING.md)
- [Support](SUPPORT.md)
