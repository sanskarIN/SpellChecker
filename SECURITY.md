# Security Policy

This policy describes the current SpellChecker `2.16.0+21` security model, supported versions, reporting process, trust boundaries, and contributor expectations.

For privacy/data-flow details, see [docs/PRIVACY.md](docs/PRIVACY.md). Historical release-specific security notes remain available through [docs/RELEASE_HISTORY.md](docs/RELEASE_HISTORY.md).

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
- resolve writing batch overlaps conservatively/deterministically;
- keep rule/language/persistence identifiers versioned/stable where compatibility matters;
- avoid dynamic execution of imported dictionary/settings data;
- avoid downloading/executing untrusted writing rules;
- surface preference write failures instead of falsely claiming durability;
- run automated formatting/analyzer/tests/benchmark smoke before merge/release.

## Current runtime attack surface

The bundled application currently has a deliberately small runtime integration surface:

```text
Flutter framework
shared_preferences local storage
Flutter clipboard API for explicit copy actions
browser/host rendering/storage/clipboard behavior
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

- tokenize/compare/scan strings;
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

Personal vocabulary is user data and should not be exposed/logged unnecessarily.

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

Settings import does not load/execute rules from imported IDs. Effective enabled rules remain limited to source-controlled current registry rules that support the selected language.

### Fail-closed parsing

Unsupported/malformed metadata should raise a validation failure rather than silently interpreting an ambiguous format.

## Import persistence transaction

The application attempts to preserve/restore previous durable settings if Portable settings persistence fails partway through import.

A failed storage write should not be reported as durable success. If restoration cannot be guaranteed, the UI marks storage unavailable/reports the failure.

## Clipboard boundary

Dictionary/settings/diagnostic copy actions require explicit user action.

Copied personal vocabulary or settings can become visible to other software according to host clipboard policy. SpellChecker cannot control clipboard readers after data has been copied.

The metadata-only writing diagnostic excludes editor text/excerpts/replacements/offsets by design, reducing accidental data disclosure in support workflows.

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

- spelling UI captures first 200 issues and avoids suggestion generation after overflow proof;
- writing UI captures first 200 findings, but enabled rules still scan input to produce exact totals;
- structural rules are iterative/stress-tested but large input still consumes CPU/memory;
- public callers can request different/unbounded limits.

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

## Dependency/supply-chain policy

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

Dependabot configuration can surface dependency updates, but maintainers still need to review compatibility/security impact.

GitHub Actions should use explicit trusted actions/versions and least permissions practical for the job.

## CI/release security

Current CI/release workflows use GitHub-hosted runners and read repository contents.

The release workflow validates source then builds Flutter web and uploads an Actions artifact. It does not currently use code-signing/app-store secrets or publish native artifacts.

If release automation gains deployment/write permissions/secrets, apply least privilege, environment protections where appropriate, and document rollback/provenance/secret handling.

## Secrets

No application secret should be required for local spelling/writing analysis.

Never commit:

- API keys;
- passwords;
- OAuth tokens;
- signing keys/keystores;
- private certificates;
- provisioning profiles containing secrets;
- service-account credentials.

Use repository/environment secret stores for future CI integrations and expose only the minimum scope needed.

## Platform security

Only the web host is committed/release-built today. Official native support would require target-specific review for:

- preference storage;
- clipboard;
- filesystem permissions;
- network permissions;
- signing/update mechanism;
- deep links/URL handlers;
- crash reporting;
- package identifiers/distribution.

See [docs/PLATFORM_SUPPORT.md](docs/PLATFORM_SUPPORT.md).

## External links and BMC

Repository/support documentation includes external links such as GitHub and [Buy Me a Coffee](https://buymeacoffee.com/sanskarIN).

These are project navigation/funding surfaces, not editor-analysis services. SpellChecker does not send editor text/findings to BMC.

Funding never changes vulnerability handling or support access.

## Security-sensitive contributor checklist

Before merging a security-relevant change, verify:

- threat boundary clearly identified;
- no hidden new network/data flow;
- strict input validation;
- source-range/index validation;
- no dynamic execution of imported data;
- no secret/private data committed/logged;
- least privilege for workflow/permissions;
- persistence error behavior truthful;
- Unicode/large-input behavior tested;
- privacy/security/docs updated;
- regression test reproduces the weakness safely.

## Coordinated disclosure

Maintainers should avoid publishing exploit details before a fix/mitigation is available when early disclosure could harm users.

A security fix should include regression coverage and appropriate changelog/release notes without unnecessarily publishing sensitive exploit detail.

## Related documentation

- [Privacy](docs/PRIVACY.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Configuration](docs/CONFIGURATION.md)
- [Testing](docs/TESTING.md)
- [Releasing](docs/RELEASING.md)
- [Support](SUPPORT.md)
