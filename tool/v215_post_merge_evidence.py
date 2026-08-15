from pathlib import Path

VALIDATION = Path('docs/V2_15_FINAL_VALIDATION.md')
LEDGER = Path('what_changed.md')

validation = VALIDATION.read_text()
old_validation = '''## Final evidence-head CI requirement

This owner-authored evidence update changes the pull-request head after the successful release gate but changes no Dart source, test logic, dependency, package/About identity, persistence format, web build input, or runtime behavior.

The exact new head must receive one final green permanent CI run. Formatting, static analysis, the complete Flutter suite, and benchmark smoke must all pass before merge.

## Merge policy

PR #81 must remain mergeable and its permanent diff must remain helper-free. The implementation merge must use a normal merge commit rather than squash/rebase so the deliberately granular production, regression, debugging, release, documentation, validation, and cleanup history is preserved.

Only the exact final green candidate may merge to `main`. The implementation merge must then receive its own permanent default-branch CI run. A documentation-only post-merge follow-up must record the actual PR head/commit count, implementation merge SHA, release-gate evidence, and merged-main CI in this document and `what_changed.md`; that follow-up must itself pass CI, merge normally, and leave a final green `main` before V2.15 is considered complete.
'''
new_validation = '''## Final implementation PR and merge evidence

Final permanent PR CI run `31876743735` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on exact final PR #81 head `7a5f851f719f740267c092b5705be8c6b4bba2f6`.

At the implementation merge boundary, PR #81 contained 81 branch commits, 46 permanent changed files, 1,387 additions, and 22 deletions. The permanent diff contained only production source, public API/registry integration, tests, package/About identity, release documentation, web metadata, and the V2.15 engineering ledger; disposable V2.15 formatter, diagnostic, patch, release-sync, release-gate, and working-scope helpers were absent.

PR #81 was merged with a normal merge commit rather than squash or rebase, preserving the complete 81-commit granular branch history. The implementation merge commit is `31450fc9223f3f958c18c887c0a7047cb01a9ac8`.

The final PR tree and implementation merge tree are identical: both are `4554f793c446ae22bcddd6d76776f313bc30950d`. This confirms the default branch received the exact candidate already validated by final PR CI and the independent release-mode gate, with no merge-conflict rewrite.

## Merged-main CI evidence

Permanent default-branch CI run `31876830663` validated implementation merge `31450fc9223f3f958c18c887c0a7047cb01a9ac8` successfully.

Results:

- dependency resolution: passed;
- canonical formatting: passed;
- `flutter analyze`: passed;
- complete Flutter test suite: passed;
- deterministic benchmark smoke: passed.

The implementation merge therefore preserved the fully validated V2.15 runtime/test/build tree on `main`.

## Post-merge evidence follow-up

This documentation-only follow-up records facts that were unknowable until PR #81 had actually merged: the exact 81-commit/46-file implementation boundary, merge SHA/tree identity, and merged-main CI run.

Its permanent diff is restricted to this validation record and `what_changed.md`. It changes no Dart source, test logic, dependency, package/About identity, persistence format, web build input, preference behavior, Portable-settings format, or runtime behavior.

The post-merge evidence pull request must itself pass the repository's permanent formatting/analyze/full-test/benchmark CI and merge normally. The resulting final `main` merge must then receive one last green permanent CI run before V2.15 is considered complete.
'''
if validation.count(old_validation) != 1:
    raise SystemExit('final validation: expected one pre-merge requirement block')
VALIDATION.write_text(validation.replace(old_validation, new_validation, 1))

ledger = LEDGER.read_text()
if ledger.count('## V2.15 — Unmatched Curly Brace Diagnostics') != 1:
    raise SystemExit('ledger: expected exactly one V2.15 heading')
if ledger.count('## V2.14 — Unmatched Square Bracket Diagnostics') != 1:
    raise SystemExit('ledger: expected exactly one V2.14 heading')
if '### Final V2.15 validation and merged-main evidence' in ledger:
    raise SystemExit('ledger: final V2.15 evidence already present')

final_evidence = '''### Final V2.15 validation and merged-main evidence
- Permanent synchronized-candidate CI run `31876478606` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on owner head `759834f3d6680f10e8f03a85410a1fb7ca8d8b53`.
- Independent release-gate run `31876609678` repeated those checks, passed `flutter build web --release` and `git diff --check`, verified package/About identity, public export/registration/stable ID, exactly ten built-in rule constructors, focused regressions, explicit V2.14 preference and Portable-settings compatibility, `what_changed.md`/README/changelog/docs/manifest identity, unchanged direct runtime dependencies, generated web outputs, and zero unexpected V2.15 helper residue. The gate removed itself in cleanup commit `3f00e356685762874cda279e4a24f9deeee3c2d8`.
- The release-gate evidence update received final green permanent PR CI run `31876743735` on exact final PR #81 head `7a5f851f719f740267c092b5705be8c6b4bba2f6`.
- PR #81 contained 81 branch commits and 46 permanent changed files, with 1,387 additions and 22 deletions at the implementation merge boundary.
- PR #81 merged normally as `31450fc9223f3f958c18c887c0a7047cb01a9ac8`, preserving the complete 81-commit granular history rather than squashing it.
- The final PR tree and implementation merge tree are both `4554f793c446ae22bcddd6d76776f313bc30950d`, proving the already-green candidate was merged without tree changes.
- Post-merge `main` CI run `31876830663` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the implementation merge.
- The documentation-only post-merge evidence follow-up changes only `docs/V2_15_FINAL_VALIDATION.md` and `what_changed.md`; it changes no production source, test logic, dependency, package/About identity, persistence format, web build input, preference behavior, Portable-settings format, or runtime behavior. The follow-up itself must pass permanent CI and merge normally before the final default-branch acceptance run.

'''
anchor = '\n\nThis file is the detailed implementation ledger for SpellChecker releases.'
if ledger.count(anchor) != 1:
    raise SystemExit('ledger: expected one V2.15/V2.14 transition anchor')
LEDGER.write_text(ledger.replace(anchor, '\n\n' + final_evidence + 'This file is the detailed implementation ledger for SpellChecker releases.', 1))
