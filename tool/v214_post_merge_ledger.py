from pathlib import Path
import subprocess

path = Path('what_changed.md')
text = path.read_text()
marker = '## V2.13 — Unmatched Parenthesis Diagnostics'
section_title = '### Final V2.14 validation and merged-main evidence'

if text.count(marker) != 1:
    raise SystemExit(f'expected one V2.13 marker, found {text.count(marker)}')
if section_title in text:
    raise SystemExit('final V2.14 merge-evidence section already exists')
if '## V2.14 — Unmatched Square Bracket Diagnostics' not in text:
    raise SystemExit('V2.14 engineering ledger is missing')

block = '''### Final V2.14 validation and merged-main evidence

After release metadata and documentation synchronization, permanent synchronized-candidate CI run `31872668004` passed formatting, static analysis, the complete Flutter suite, and benchmark smoke on the V2.14 release tree.

Independent release-gate run `31872872493` repeated those checks, built the production web application with `flutter build web --release`, passed `git diff --check`, and verified package/About identity, the public `UnmatchedSquareBracketRule` export, built-in registration, stable rule ID, exactly nine built-in constructors, focused V2.14 regression files, explicit V2.13 preference compatibility, `what_changed.md`, changelog/README/web-manifest metadata, unchanged direct runtime dependencies, generated web outputs, absence of the superseded working-scope document, and zero unexpected V2.14 helper residue. The one-time gate removed itself in cleanup commit `d408e0d923ee5f45ac625098d0cc75de6e60bbd5`.

The release-gate evidence update received final green permanent PR CI run `31873000788` on exact PR head `199e8f6c17a659c2eb5d7fd54a3fde9187f333df`. PR #79 contained 60 branch commits and 45 permanent changed files and was merged with a normal merge commit, preserving that granular history. The V2.14 implementation merge commit is `ae2e66669747b44b408297f663d500f86c254369`.

Post-merge `main` CI run `31873077140` passed dependency resolution, canonical formatting, `flutter analyze`, the complete Flutter test suite, and deterministic benchmark smoke on the implementation merge. The merge tree `c859fdb14f1867b84773300fa6db1c8c8d205845` is identical to the already-green final PR tree.

A documentation-only post-merge evidence change records these now-known merge/main-CI identifiers in both the validation record and this engineering ledger. It changes no production source, test logic, dependency, release identity, persistence format, web build input, or runtime behavior; the evidence change is itself required to pass permanent CI before the repository's final V2.14 default-branch head is accepted.
'''

path.write_text(text.replace(marker, block + '\n\n' + marker, 1))
subprocess.run(['git', 'add', str(path)], check=True)
subprocess.run(
    ['git', 'commit', '-m', 'docs(ledger): record final V2.14 merge validation evidence'],
    check=True,
)
