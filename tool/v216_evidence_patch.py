from pathlib import Path

path = Path('what_changed.md')
text = path.read_text()
marker = '### Release synchronization, formatting, and repository hygiene\n'
if marker not in text:
    anchor = '\n\n## V2.15 — Unmatched Curly Brace Diagnostics'
    if text.count(anchor) != 1:
        raise SystemExit(f'expected one V2.15 anchor, found {text.count(anchor)}')
    section = '''\n\n### Release synchronization, formatting, and repository hygiene
- Guarded release synchronization run `31880102715` updated About source, changelog/README, maintained contributor/security/support/docs surfaces, web metadata, `docs/V2_16_BUG_AUDIT.md`, `what_changed.md`, and `docs/V2_16_FINAL_VALIDATION.md` as separate permanent commits, then removed the temporary working scope, synchronizer, and workflow before pushing.
- Final package-aware formatter run `31880158636` resolved Flutter dependencies, applied canonical formatting, committed only genuine formatter drift, verified an immediate clean second pass and no tracked Dart drift, removed itself, and pushed helper-free formatted head `99f493bf98f6c8fed18c757154b72c1454b0561f`.
- Obsolete historical PR #38 (V2.3 execution-only gate) and superseded PR #71 (older missing-punctuation-space feature branch) were explicitly documented as completed/superseded and closed without merge. The final active implementation path remains PR #83.
- No V2.16 diagnostic, patch, synchronizer, formatter, or working-scope helper is intended to remain in the permanent candidate.
'''
    text = text.replace(anchor, section + anchor, 1)
path.write_text(text)
