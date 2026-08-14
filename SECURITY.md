# Security Policy

## Supported versions

Security fixes are applied to the latest code on `main` and, when applicable, the newest tagged release.

| Version | Supported |
| --- | --- |
| Latest `main` | Yes |
| Latest release | Yes |
| Older releases | Best effort |

## Reporting a vulnerability

Do not publish exploitable security details, secrets, private documents, sensitive personal vocabulary, writing findings, or correction-history content in a normal public issue.

Preferred reporting method:

1. Use GitHub Private Vulnerability Reporting if enabled for the repository.
2. If unavailable, contact the maintainer through a private contact method listed on the maintainer's GitHub profile.

A useful report includes:

- Affected version or commit.
- Affected component.
- Reproduction steps using non-sensitive synthetic data.
- Expected and actual behavior.
- Security impact.
- Suggested mitigation, if known.

## Security principles

SpellChecker is designed to:

- Perform spelling and deterministic writing analysis locally.
- Avoid transmitting editor text by default.
- Persist only user-controlled local settings.
- Keep ignored words, findings, active analysis state, and correction history in memory only.
- Validate source offsets before automatic text mutation.
- Resolve batch correction overlaps conservatively and deterministically.
- Validate imported dictionary data instead of executing/interpreting arbitrary content.
- Avoid embedding secrets in source code.
- Minimize runtime dependencies.
- Keep persisted key/data formats versioned where compatibility matters.
- Run automated analysis/tests before release.

## Local persistence — V2.1

SpellChecker uses Flutter `shared_preferences` for local device/profile settings:

- Selected language ID.
- Personal dictionary words per language.
- Suggestion-count preference.
- Enabled writing-rule IDs per language.

Example key families:

```text
spellchecker.language_id.v1
spellchecker.personal_words.v2.<language-id>
spellchecker.suggestion_limit.v1
spellchecker.writing_rule_ids.v1.<language-id>
```

The stored writing-rule values are identifiers only; they do not contain editor text or finding excerpts.

The application does not persist:

- Editor documents.
- Checked spelling-result lists.
- Writing finding lists/messages/source excerpts.
- Active issue selection.
- Temporary ignored words.
- Suggestion caches.
- Correction undo snapshots.
- Batch correction plans.

Treat persisted personal vocabulary as user data and avoid logging/exposing it unnecessarily.

## V2.2 review-query security/privacy boundary

Review search/category/automatic-only controls operate only on already-local rule metadata and in-memory findings. They do not trigger remote search, external rule loading, or background document indexing.

Search text can contain words copied from a finding/document, so it must remain memory-only and must not be added to preference keys, logs, analytics, crash metadata, or network requests.

Filtered batch actions still pass through `WritingCorrection.applyAll`; filtering does not grant permission to bypass stale-range or overlap checks.

**Reset rules to defaults** removes only the selected language's writing-rule preference key. It must not clear unrelated language vocabulary/settings or execute/load rules based on untrusted stored IDs.

## Writing-rule preference integrity

V2.1 preserves three distinct states:

```text
missing rule key   -> use current built-in defaults
stored ID list     -> explicit enabled set
stored empty list  -> explicit disable-all
```

Security/correctness implications:

- Do not reinterpret an explicit empty list as defaults.
- Unknown stale rule IDs should be ignored safely, not executed dynamically.
- Rule IDs are data identifiers, not code-loading instructions.
- Renaming shipped IDs requires migration/compatibility review.

## Spelling correction safety

`SpellIssue` offsets are valid only for the checked text snapshot.

Correction code validates that current source text still matches before mutation.

For spelling replace-all:

- Only current checked matching ranges are eligible.
- Replacements are applied from later offsets toward earlier offsets.
- Stale ranges are skipped/refreshed rather than blindly mutating unrelated text.

A correction path that applies unchecked stale offsets can corrupt user text and should be treated as a security/correctness defect.

## Writing correction safety

Rules process current document text in memory and return exact source ranges.

Individual automatic fixes must validate:

- Replacement exists.
- Source offsets are valid/current.
- Current substring equals `WritingIssue.originalText` exactly.

V2.1 batch correction additionally:

1. Sorts candidates deterministically by start/end/rule ID.
2. Skips advisory/no-replacement findings.
3. Skips invalid/stale findings.
4. Accepts the earliest deterministic non-overlapping fix and skips later overlaps.
5. Applies accepted edits from document end toward beginning.
6. Returns one final text plus applied/skipped counts.

Do not bypass `WritingCorrection` by directly applying finding replacements in widgets.

## Correction undo data

The bounded shared correction stack can contain complete editor-text snapshots.

It is intentionally:

- Memory-only.
- Bounded.
- Cleared by a new manual editing sequence.
- Discarded with the application session.
- Excluded from preferences and exports.

One snapshot can represent a spelling or writing automatic operation, including a V2.1 writing batch.

Persisting, logging, synchronizing, or uploading correction snapshots requires explicit security/privacy redesign.

## Writing-rule code trust

Current built-in rules are source-controlled Dart code compiled with the application.

`WritingRule` is an extension interface, but V2.1 does **not** dynamically download or execute untrusted third-party rule code.

Any future dynamic/plugin registry needs a separate threat model covering:

- Code origin/trust.
- Signing/integrity.
- Update channel.
- Permission scope.
- Sandbox/process boundaries where applicable.
- Document access.
- Network access.
- Revocation.
- Privacy disclosure.

Do not treat a stored rule ID as permission to load arbitrary code.

## Language-pack safety

Built-in packs are compiled local data. The current application does not download executable/content packs at runtime.

Language-tagged dictionary imports validate document version and supported language identity before merging.

Pack switches construct isolated session state so ignored words and personal vocabulary do not silently leak across languages. V2.1 also isolates writing-rule preferences by language.

Any remote pack/download mechanism requires separate signature/integrity, licensing, privacy, and update-channel review.

## Import/export safety

Personal dictionary imports accept only validated word data from supported versioned JSON, JSON arrays, or plain word lists.

Codec changes should:

- Reject malformed entries rather than evaluate/execute imported content.
- Keep transfer formats data-only.
- Preserve explicit version/language checks.
- Avoid automatic remote fetch/import without separate review.

Export writes user-approved vocabulary to the clipboard after explicit user action. It does not upload the export.

## Keyboard handling

SpellChecker handles local key events for editor workflows, including spelling check, Writing insights, and spelling issue navigation.

It does not record keyboard telemetry or maintain a key-event history.

Global keyboard hooks, background key capture, or keyboard analytics require explicit security/privacy review.

## Dependency review

Review new dependencies for:

- Runtime network behavior.
- Telemetry/analytics behavior.
- Storage scope.
- Platform permissions.
- Maintenance/security posture.
- Supply-chain/update behavior.
- Whether the functionality can remain local.

`shared_preferences` remains the only non-SDK runtime dependency and is used for application-local preferences. V2.3 adds no new runtime package.

## Dependency and secret hygiene

Do not commit:

- API keys.
- Passwords.
- Signing certificates.
- Service-account credentials.
- Access tokens.
- Private user documents.
- Sensitive real personal dictionary exports.
- Real editor/correction-history samples containing private content.
- Private writing findings/source excerpts.

The repository `.gitignore` covers common secret/build patterns, but contributors remain responsible for reviewing every commit.

## Privacy-sensitive changes

These require explicit security/privacy review before implementation/release:

- Synchronization/accounts.
- Cloud spelling/grammar/AI services.
- Analytics/remote logging.
- Crash reporting that may capture editor text.
- Remote configuration affecting analysis behavior.
- Editor-document persistence.
- Persistent general/correction history.
- Automatic dictionary/rule upload/download.
- Keyboard/usage telemetry.
- Global/background key capture.
- Dynamic external rule/plugin execution.

Update [docs/PRIVACY.md](docs/PRIVACY.md) and relevant user/security documentation before shipping such behavior.

## Portable settings security boundary — V2.3

Portable settings are untrusted user-supplied JSON. Import validates format/version, supported language IDs, suggestion limits, override structure, and rule-ID syntax before persistence. The format does not execute code or dynamically load rules. Export is copied to the local clipboard only after explicit user action. Imported data is not sent to a remote service. `shared_preferences` writes are not transactional; rollback is best effort and must not be represented as an atomic security boundary.

## Suggestion-ranker extension boundary — V2.4

`SpellSuggestionRanker` is an injected in-process interface, not a trusted/dynamic plugin-loading system. SpellChecker does not discover, download, execute, or sandbox third-party ranker packages at runtime. Candidate eligibility and edit-distance limits remain in `SpellCheckerEngine` before custom ranking. Applications that compile in third-party ranker code are responsible for reviewing that code like any other dependency.

## V2.5 bounded-analysis safety boundary

A spelling issue cap is a resource/UX boundary, not permission to weaken correction safety. Captured issues retain exact checked source ranges and all existing stale-source validation.

When a report is truncated, the built-in editor hides Replace all because the checked issue list is incomplete. Do not re-enable bulk mutation by searching raw text from the widget or by treating uncaptured matches as checked ranges.

`maxIssues` must be positive when supplied. The bound does not execute imported data, alter ranker trust, add network processing, or persist document-derived report metadata.

## V2.6 deterministic rule safety

The two new spacing rules are source-controlled Dart implementations compiled with the application. They do not interpret or execute document content, load external rules, or bypass `WritingCorrection` source validation. Specialized ownership of punctuation-adjacent/trailing whitespace prevents conflicting built-in automatic replacements for the same exact source range. V2.6 adds no dependency, permission, remote service, telemetry, or dynamic-code boundary.

## V2.7 bounded writing-analysis security

V2.7 does not introduce remote rule loading, executable plugins, dynamic code evaluation, worker downloads, or network-backed analysis. `maxIssues` constrains retained `WritingIssue` objects but is not a denial-of-service boundary for arbitrary custom rules because every enabled/supported rule is still executed to preserve global result ordering.

Callers that accept untrusted very large documents or untrusted third-party rule implementations must enforce their own input-size, execution-time, isolation, or plugin-trust policies. The built-in local rules remain source-controlled and deterministic.

Automatic mutations continue to use exact-source stale checks and conservative overlap handling; a bounded result does not bypass those protections.

## V2.8 writing diagnostics security boundary

Exact V2.8 finding totals are correctness/observability metadata, not an execution sandbox or denial-of-service control.

The analyzer still consumes findings from every enabled/supported rule across the supplied text so it can preserve global ordering and calculate exact totals. Therefore neither `maxIssues` nor `totalIssueCount` should be represented as bounding:

- arbitrary custom-rule CPU time;
- wall-clock execution time;
- memory allocated internally by a custom rule;
- document length;
- untrusted plugin execution.

Applications embedding SpellChecker with untrusted documents or third-party rule code remain responsible for their own input-size, isolation, timeout, and plugin-trust controls.

Exact totals and per-rule totals are memory-only and are not automatically logged, persisted, uploaded, or exported. A future diagnostic/crash-report feature must treat them as document-derived metadata and must not silently transmit them with user text or source excerpts.

The repository's Buy Me a Coffee link does not change security-reporting priority, disclosure handling, maintainer trust boundaries, or project governance.

## V2.9 diagnostic-summary security boundary

The V2.9 `WritingAnalysisDiagnosticSummary` API is intentionally metadata-only. It does not read or serialize editor text, finding excerpts/messages, replacements, source offsets, personal vocabulary, correction history, timestamps, device identifiers, or network metadata. It adds no automatic clipboard write, persistence, telemetry, or remote logging behavior. The current Writing insights **Copy diagnostic summary** control is an explicit user action and copies only the safe formatted summary; any future file/network transport requires separate security/privacy review and must not silently substitute raw `WritingIssue` data for the safe summary.
