from pathlib import Path
import json
import re

ROOT = Path('.')

def read(path):
    return (ROOT / path).read_text()

def write(path, text):
    (ROOT / path).write_text(text)

def require_once(text, needle, label):
    if text.count(needle) != 1:
        raise SystemExit(f'{label}: expected one anchor, found {text.count(needle)}')

def insert_after_h1(path, section):
    text = read(path)
    marker = '## V2.16 final stabilization'
    if marker in text:
        return
    lines = text.splitlines(keepends=True)
    if not lines or not lines[0].startswith('# '):
        raise SystemExit(f'{path}: missing H1')
    insertion = '\n' + section.strip() + '\n\n'
    write(path, lines[0] + insertion + ''.join(lines[1:]))

# About source.
path = 'lib/features/editor/spell_checker_page.dart'
text = read(path)
require_once(text, "applicationVersion: '2.15.0'", path)
text = text.replace("applicationVersion: '2.15.0'", "applicationVersion: '2.16.0'", 1)
old = "A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, deterministic extensible suggestion ranking,"
new = "A privacy-first open-source writing utility finalized in V2.16 with Unicode-scalar unrestricted Damerau-Levenshtein distance, decomposed-Unicode word handling, strict local import validation, truthful preference-write failures, startup-state synchronization, and Unicode-safe correction casing, plus explicit language packs, deterministic extensible suggestion ranking,"
require_once(text, old, path)
text = text.replace(old, new, 1)
write(path, text)

# Changelog.
path = 'CHANGELOG.md'
text = read(path)
anchor = '## [2.15.0] - 2026-08-15'
require_once(text, anchor, path)
entry = '''## [2.16.0] - 2026-08-15

### Fixed
- Corrected public Damerau-Levenshtein distance to operate on Unicode scalars and to implement the unrestricted algorithm rather than the restricted optimal-string-alignment recurrence.
- Aligned suggestion-distance thresholds, candidate length filtering, and prefix comparison with Unicode-scalar semantics.
- Kept decomposed combining-mark word clusters intact in spelling tokenization and text statistics, and canonically composed common Latin accent sequences used by bundled English vocabulary.
- Rejected malformed personal-dictionary version types and duplicate Portable Settings writing-rule IDs instead of silently interpreting or deduplicating them.
- Propagated failed local preference writes/removals so persistence errors cannot be reported as successful.
- Refreshed already-checked spelling results after saved preferences restore, and guarded Writing Insights and Ignore-once session mutations until restoration completes.
- Made case-preserving spelling corrections Unicode-scalar-safe and avoided treating uncased scripts as uppercase text.
- Removed nondeterminism from the final startup regression by bringing the lazy Ignore action into view and avoiding `pumpAndSettle()` while startup is intentionally unresolved.

### Changed
- Advanced package identity to `2.16.0+21` and About identity to `2.16.0`.
- Added final repository-wide bug-audit and release-validation documentation without expanding the ten-rule writing catalogue.

### Compatibility, privacy, and dependency boundary
- Portable Settings remains format version 1; personal-dictionary legacy V1 missing-version compatibility remains supported.
- The built-in writing-rule catalogue remains ten rules and existing explicit rule preferences remain authoritative.
- Direct runtime dependencies remain Flutter and `shared_preferences`; no telemetry, account system, cloud writing service, document upload, or new application-network behavior was added.

'''
text = text.replace(anchor, entry + anchor, 1)
write(path, text)

# README current release + highlight.
path = 'README.md'
text = read(path)
highlight = '- V2.15 advisory unmatched-curly-brace diagnostics'
require_once(text, highlight, path)
text = text.replace(highlight, '- V2.16 final stabilization fixes Unicode-scalar distance/casing, decomposed-word handling, strict imports, storage-failure reporting, and startup-state races while retaining the ten-rule registry.\n' + highlight, 1)
pattern = re.compile(r'## Current release\n\n.*?(?=\n## )', re.S)
match = pattern.search(text)
if not match:
    raise SystemExit('README: current release section missing')
current = '''## Current release

`2.16.0+21`

Version 2.16 is the **Final Stabilization and Bug Audit** release. It fixes every reproducible defect found during the final repository-wide audit: Unicode-scalar and unrestricted Damerau-Levenshtein correctness, scalar-consistent suggestion eligibility, decomposed combining-mark tokenization/normalization/statistics, strict import metadata, truthful local persistence failure reporting, startup preference/result/session synchronization, Unicode-safe case-preserving correction, and deterministic startup widget regressions. The built-in writing-rule catalogue remains ten rules. Portable Settings remains format version 1, direct runtime dependencies remain Flutter and `shared_preferences`, and no telemetry, account, cloud-writing, document-upload, or new application-network behavior is introduced.

See [V2.16 final bug audit](docs/V2_16_BUG_AUDIT.md) and [V2.16 final validation](docs/V2_16_FINAL_VALIDATION.md).
'''
text = text[:match.start()] + current + text[match.end():]
write(path, text)

# PR template and maintained public docs.
sections = {
'.github/pull_request_template.md': '''## V2.16 final stabilization review note
For final-stabilization changes, verify Unicode-scalar source/algorithm semantics, strict external-data validation, truthful persistence failures, startup-state synchronization, deterministic widget hit testing, unchanged ten-rule compatibility, privacy/dependency boundaries, and regression coverage before merge.''',
'CONTRIBUTING.md': '''## V2.16 final stabilization
The final stabilization baseline requires regression-first fixes. Unicode-sensitive code must define whether offsets are UTF-16 or Unicode scalars, imported formats must fail closed on malformed metadata, persistence operations must surface platform failures, and widget tests must not depend on off-screen hit tests or settling intentionally pending futures.''',
'SECURITY.md': '''## V2.16 final stabilization
V2.16 strengthens fail-closed local import parsing and persistence error reporting. It adds no network service, telemetry, account system, document upload, or new runtime dependency. Security reports should continue to distinguish malformed local data handling from remote attack surfaces the application does not expose.''',
'SUPPORT.md': '''## V2.16 final stabilization
When reporting a V2.16 problem, include the exact app version, platform, selected language, whether local preferences finished loading, a minimal non-sensitive input, and whether the problem involves decomposed Unicode, imported settings/dictionaries, persistence, or startup actions. Do not include private documents unless the minimal text itself is safe to share.''',
'docs/ACCESSIBILITY.md': '''## V2.16 final stabilization
Startup actions now keep their state truthful while saved preferences are restoring. The final widget regressions explicitly bring lazy controls into view before activation and avoid waiting for intentionally unresolved startup work, preserving deterministic keyboard/screen-reader review semantics.''',
'docs/API.md': '''## V2.16 final stabilization
`damerauLevenshteinDistance` now means unrestricted Damerau-Levenshtein distance over Unicode scalar values. Suggestion eligibility uses the same scalar-length model. Public spelling issue/source ranges remain UTF-16 offsets because they index Dart strings and Flutter text editing. Portable Settings remains version 1 and the writing-rule public catalogue remains ten built-ins.''',
'docs/ARCHITECTURE.md': '''## V2.16 final stabilization
The final audit keeps three boundaries explicit: algorithmic similarity operates on Unicode scalars; editor source ranges remain UTF-16 offsets; local persistence/import layers fail closed when a platform write or external format is invalid. Startup restores the selected language, vocabulary, rule choices, and suggestion count before durable/session mutations are allowed.''',
'docs/DEVELOPMENT.md': '''## V2.16 final stabilization
Before proposing a bug fix, reproduce it with the narrowest regression first. Run `flutter pub get`, canonical `dart format`, `flutter analyze`, the complete Flutter suite, and benchmark smoke. Unicode work must include non-BMP or decomposed-sequence coverage when relevant; asynchronous widget tests must not use `pumpAndSettle()` while deliberately leaving a future unresolved.''',
'docs/LANGUAGE_PACKS.md': '''## V2.16 final stabilization
Built-in English tokenization now treats each Unicode letter plus following combining marks as one word cluster. The English normalizer deterministically composes the common Latin accent sequences represented by bundled loanwords. Suggestion distance and length thresholds operate on Unicode scalars; editor offsets remain UTF-16.''',
'docs/PERFORMANCE.md': '''## V2.16 final stabilization
Unrestricted Damerau-Levenshtein now uses a last-seen-row/column matrix over Unicode scalars. This is correctness-first and remains bounded in practice by the existing suggestion-distance and candidate-length filters. The deterministic benchmark smoke remains a release gate; no timing threshold was added.''',
'docs/PRIVACY.md': '''## V2.16 final stabilization
All V2.16 fixes remain local. Decomposed-Unicode normalization, edit distance, import validation, preference restoration, diagnostics, and corrections execute on-device/in-process. No editor text, personal vocabulary, settings document, or diagnostic excerpt is transmitted to a spelling or grammar service.''',
'docs/RELEASING.md': '''## V2.16 final stabilization
The final release candidate is `2.16.0+21` / About `2.16.0`. Acceptance requires canonical formatting, static analysis, the complete Flutter suite, deterministic benchmark smoke, `flutter build web --release`, exact version/bug-audit/privacy/dependency assertions, absence of disposable V2.16 helpers, and green merged-main CI. The repository still does not invent a first tag/release convention unless maintainers explicitly choose one.''',
'docs/ROADMAP.md': '''## V2.16 final stabilization
V2.16 closes the planned project implementation sequence with a repository-wide bug/error audit rather than another catalogue expansion. The milestone fixes all reproducible defects found in that audit and leaves future ideas—additional language packs, rule/plugin work, or publication automation—as optional follow-up directions rather than unfinished V2.16 requirements.''',
'docs/TESTING.md': '''## V2.16 final stabilization
Permanent regressions cover unrestricted/scalar edit distance, scalar suggestion eligibility, decomposed Unicode tokenization/statistics, strict dictionary/settings parsing, failed preference writes, startup result/session synchronization, Unicode-safe case correction, and deterministic lazy widget activation. The complete suite—not focused tests alone—is a release gate.''',
'docs/TROUBLESHOOTING.md': '''## V2.16 final stabilization
If saved preferences fail, V2.16 now reports storage unavailability instead of assuming success. If Unicode spelling differs, compare precomposed and decomposed input and record the selected language. During startup, Writing Insights and Ignore-once may report that preferences are still loading; retry after restoration finishes rather than treating temporary defaults as durable state.''',
'docs/USER_GUIDE.md': '''## V2.16 final stabilization
Version 2.16 improves correctness without changing the core workflow. Unicode spelling handles decomposed accents more consistently, suggestions use Unicode-scalar distance, imported dictionaries/settings reject malformed metadata, storage failures are surfaced, and already-checked results refresh after saved preferences load. The ten Writing insights rules remain unchanged.''',
'docs/WRITING_RULES.md': '''## V2.16 final stabilization
The built-in/default writing catalogue remains exactly ten rules. V2.16 is a stabilization release, not a catalogue migration: existing explicit rule sets remain authoritative, unset/reset preferences continue to resolve to the current ten-rule registry, and Portable Settings remains format version 1.''',
}
for p, section in sections.items():
    if p == '.github/pull_request_template.md':
        text = read(p)
        if '## V2.16 final stabilization review note' not in text:
            if not text.startswith('# '):
                raise SystemExit(f'{p}: expected H1')
            first, rest = text.split('\n', 1)
            write(p, first + '\n\n' + section + '\n\n' + rest)
    else:
        insert_after_h1(p, section)

# Web metadata.
path = 'web/manifest.json'
data = json.loads(read(path))
data['description'] = 'SpellChecker V2.16 final stabilization: privacy-first local spelling and writing analysis with Unicode-scalar unrestricted Damerau-Levenshtein suggestions, decomposed-Unicode word handling, strict local imports, truthful preference persistence errors, synchronized startup state, ten deterministic writing rules, portable non-document preferences, and undo-friendly corrections.'
write(path, json.dumps(data, indent=2, ensure_ascii=False) + '\n')

path = 'web/index.html'
text = read(path)
text = re.sub(r'<meta name="description" content="[^"]*">', '<meta name="description" content="SpellChecker V2.16 - privacy-first local spelling and writing analysis with Unicode-scalar unrestricted Damerau-Levenshtein suggestions, decomposed-Unicode word handling, strict local imports, truthful persistence errors, synchronized startup state, ten deterministic writing rules, and undo-friendly corrections.">', text, count=1)
write(path, text)

# Final bug-audit refinements.
path = 'docs/V2_16_BUG_AUDIT.md'
text = read(path)
text = text.replace('This record is regression-led: release identity remains at V2.15 until the corrected functional candidate passes permanent CI.', 'Release identity: package `2.16.0+21`; About `2.16.0`. The audit was regression-led: release identity was not advanced until the corrected functional candidate passed permanent CI.')
text = text.replace('The regression now explicitly brings **Ignore once** into view, settles layout, verifies one target, and only then taps it.', 'The regression now explicitly brings **Ignore once** into view, pumps one bounded frame, verifies one target, and only then taps it; it deliberately avoids `pumpAndSettle()` while preference restoration remains unresolved.')
text = text.replace('## Release blockers still required\n\nThe candidate must pass canonical formatting, `flutter analyze`, the complete Flutter test suite, benchmark smoke, continued repository-wide defect review, synchronized release/documentation metadata including `what_changed.md`, removal of the temporary working scope and all disposable helpers, an independent release-mode web build/audit, normal history-preserving merge, and final default-branch CI.', '''## Functional validation evidence

Permanent CI run `31879869993` passed canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the final helper-free functional stabilization head `33f3ee4577f69d260ddea9cc88fa3895e567a7a4`.

Earlier red full-suite runs were investigated rather than rerun until green. Diagnostic annotations isolated the startup Ignore regression first to an off-screen missed hit test and then to an inappropriate `pumpAndSettle()` while preference restoration was intentionally pending. Both test-harness defects were corrected before the accepted functional gate above.

## Remaining release gates

The synchronized `2.16.0+21` candidate must still pass package-aware canonical formatting, permanent CI, an independent release-mode web build/audit, helper-residue checks, a normal history-preserving merge, merged-main CI, and final documentation-only merge evidence before V2.16 is complete.''')
write(path, text)

# Detailed what_changed ledger.
path = 'what_changed.md'
text = read(path)
if '## V2.16 — Final Stabilization and Bug Audit' not in text:
    anchor = '# What Changed\n'
    require_once(text, anchor, path)
    ledger = '''
## V2.16 — Final Stabilization and Bug Audit

Release identity: package `2.16.0+21`; About `2.16.0`.

V2.16 is the final planned implementation milestone. It keeps the ten-rule Writing insights catalogue unchanged and focuses on repository-wide correctness, durability, Unicode, startup-state, import-validation, and test-determinism defects. The release fixes every reproducible defect found during this final audit; it does not claim that no future defect can ever exist.

### Unicode scalar and edit-distance correctness
- `damerauLevenshteinDistance` now operates on Unicode scalar values instead of UTF-16 code units.
- The implementation now uses unrestricted Damerau-Levenshtein distance rather than the restricted optimal-string-alignment recurrence; `CA` → `ABC` is locked at distance 2.
- Astral insertion, deletion, substitution, transposition, and interacting-edit regressions protect scalar behavior.
- Suggestion maximum-distance selection, candidate length filtering, and prefix comparison now use the same scalar model.

### Decomposed Unicode word handling
- English tokenization treats a Unicode letter plus following combining marks as one word cluster.
- Common decomposed Latin accent sequences represented by bundled English loanwords are deterministically composed without a new dependency.
- Precomposed/decomposed forms such as café, façade, jalapeño, naïve, and résumé resolve consistently.
- Text statistics uses the same combining-mark word boundary while preserving the historical UTF-16 character-count contract.

### Strict local data validation
- A present non-integer personal-dictionary `version` is rejected instead of being silently treated as legacy V1; a genuinely omitted version remains backward-compatible.
- Portable Settings rejects duplicate writing-rule IDs instead of silently collapsing them into a set.
- Portable Settings remains format version 1 and remains document/vocabulary-free.

### Truthful local persistence
- Every language, personal-word, writing-rule, suggestion-limit, removal, and legacy-migration preference write checks the `SharedPreferences` boolean result.
- A platform-reported failed write/remove now throws, allowing existing UI/service error paths to report storage unavailability rather than claiming success.

### Startup-state synchronization
- If spelling was checked before preferences finished restoring, successful restoration now reruns that check under the saved language, personal dictionary, rule choices, and suggestion limit.
- Writing Insights refuses to mutate rule state while restoration is pending and reports the shared loading status.
- Ignore-once likewise refuses to mutate the temporary startup engine, preventing ignored session words from disappearing when the restored engine replaces it.

### Unicode-safe correction casing
- `TextCorrection.matchCase` no longer indexes surrogate halves.
- Upper/title-case preservation operates on complete scalars and requires actual cased characters, preventing astral lowercase or uncased scripts from being misclassified as uppercase.

### Final test nondeterminism removed
- Full-suite diagnostics found that the new startup Ignore regression sometimes tapped an off-screen lazy control; it now uses `ensureVisible` before activation.
- A second diagnostic found `pumpAndSettle()` could time out because the test intentionally left preference restoration pending; the regression now pumps one bounded frame instead.
- The accepted helper-free functional CI therefore validates the deterministic version of the regression, not a lucky rerun.

### Audited stable contracts intentionally unchanged
- The built-in Writing insights catalogue remains ten rules; explicit historical rule overrides remain authoritative.
- Writing-analysis zero-count maps remain sparse while diagnostic summaries reconstruct analyzed zero rows.
- Personal-dictionary missing-version legacy V1 compatibility remains supported.
- Editor source ranges remain UTF-16 offsets even though similarity algorithms use Unicode scalars.
- Direct runtime dependencies remain Flutter and `shared_preferences`.

### Permanent regression coverage
- `test/edit_distance_test.dart`
- `test/spell_checker_test.dart`
- `test/language_pack_test.dart`
- `test/text_statistics_test.dart`
- `test/personal_dictionary_codec_test.dart`
- `test/settings_transfer_codec_test.dart`
- `test/dictionary_preferences_test.dart`
- `test/text_correction_test.dart`
- `test/v216_startup_preference_sync_widget_test.dart`
- `test/widget_test.dart` release-identity coverage.

### Privacy, runtime, and release boundary
- No telemetry, account system, cloud grammar/spelling service, document upload, hidden clipboard behavior, new application-network request, preference-key family, Portable Settings version, or runtime dependency was added.
- Package identity advances to `2.16.0+21`; About identity advances to `2.16.0` only after the functional bug-fix candidate passed permanent CI.
- Permanent functional CI run `31879869993` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on helper-free head `33f3ee4577f69d260ddea9cc88fa3895e567a7a4`.
- Final release-mode build, synchronized-candidate CI, implementation merge/main CI, and documentation-only post-merge evidence are recorded in `docs/V2_16_FINAL_VALIDATION.md` as they become concrete.

'''
    text = text.replace(anchor, anchor + ledger, 1)
write(path, text)

# Initial final validation record.
validation = '''# V2.16 Final Validation

Release candidate: `2.16.0+21` / About `2.16.0`.

V2.16 is SpellChecker's final planned implementation milestone and repository-wide stabilization audit. The acceptance standard is not an impossible claim that no future bug can exist; it is that every reproducible defect found during this audit is fixed with a permanent regression and that the exact final tree passes all repository and release-mode gates.

## Functional bug-audit boundary

The permanent audit is recorded in `docs/V2_16_BUG_AUDIT.md`. It covers Unicode-scalar/unrestricted Damerau-Levenshtein correctness, scalar suggestion eligibility, decomposed Unicode word clusters and common Latin composition, text statistics, strict dictionary/settings imports, failed preference writes, startup check/rule/session synchronization, Unicode-safe case correction, and deterministic startup widget behavior.

The ten-rule Writing insights catalogue, explicit historical rule preferences, Portable Settings format version 1, editor UTF-16 source-range contract, and direct runtime dependency boundary remain unchanged.

## Accepted functional CI

Permanent CI run `31879869993` validated helper-free functional head `33f3ee4577f69d260ddea9cc88fa3895e567a7a4` before release synchronization.

Results:
- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

Earlier red full-suite runs were actively diagnosed. The final startup Ignore regression was hardened after annotations identified an off-screen missed hit test and an inappropriate `pumpAndSettle()` while preference restoration was intentionally unresolved. The accepted functional run above includes those deterministic corrections.

## Release synchronization requirements

The synchronized release tree must contain package `2.16.0+21`, About `2.16.0`, updated `what_changed.md`, changelog/README/web metadata, maintained public docs, and no `docs/V2_16_FINAL_STABILIZATION_SCOPE.md`. Disposable synchronizers/formatters/diagnostics must be absent before final permanent CI.

## Remaining acceptance gates

The exact synchronized candidate must pass package-aware canonical formatting, permanent CI, an independent `flutter build web --release` gate with release/dependency/helper assertions, another exact-head permanent CI after evidence recording, normal merge preserving granular history, merged-main CI, and a documentation-only post-merge evidence PR with its own CI and normal merge. Final `main` must be green.
'''
write('docs/V2_16_FINAL_VALIDATION.md', validation)
