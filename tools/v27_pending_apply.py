# commit-message: docs: explain V2.7 bounded review behavior to users
from pathlib import Path

sections = {
    'docs/USER_GUIDE.md': '''## V2.7 large-document Writing insights

Writing insights captures at most 200 findings in the built-in editor. If more findings exist, the dialog shows a limited-result notice and a `200+`-style count rather than presenting the captured count as the complete document total.

When analysis is limited, search, review presets, Mechanics/Clarity filters, and Automatic fixes only operate on the captured findings. The dialog says this explicitly. A filtered empty state means no **captured** finding matched; it does not claim later uncaptured findings were searched.

Batch buttons also use captured wording in the limited state: **Apply captured safe fixes** when no review filter is active and **Apply visible captured safe fixes** when filters are active. The same stale-source and overlap safety rules apply, and one Undo restores the entire accepted batch.

The 200-finding policy is not a maximum document size. Rules still analyse the supplied text so SpellChecker can retain the correct earliest findings in review order.
''',
    'docs/ACCESSIBILITY.md': '''## V2.7 limited Writing insights accessibility

When Writing insights proves that more findings exist beyond its capture limit, the limited-result explanation is exposed in a semantic container and live region. The message states the captured count, the configured limit, and that review filters and batch actions use captured findings only.

Limited results avoid an unqualified complete count. Batch labels switch to **captured** wording, and a filtered empty state says **No matching captured findings** when uncaptured findings may still exist.

The existing rule switches, preset/filter controls, finding semantics, keyboard shortcut, safe-fix controls, and dialog scrolling remain available. Tests exercise the limited state with a small synthetic cap rather than relying on display color or a particular viewport size.
''',
    'docs/TROUBLESHOOTING.md': '''## Writing insights says results are limited

The built-in V2.7 Writing insights dialog captures at most 200 findings. A limited notice means at least one additional finding exists beyond that captured prefix.

This does not mean analysis failed. Review the captured findings, apply safe captured fixes if desired, edit the text, and open Writing insights again for a fresh analysis. Search and filters only inspect the captured findings while the result is limited.

The limit controls retained finding objects and dialog workload; it is not a hard maximum document length or a promise that rule execution stops after 200 matches.
''',
    'docs/LANGUAGE_PACKS.md': '''## V2.7 bounded writing analysis and language packs

The writing-analysis capture bound does not change language eligibility. `WritingAnalyzer` still checks each enabled rule with the explicitly selected `SpellLanguagePack` and runs only rules whose `supports()` contract matches that pack.

The built-in 200-finding Writing insights policy is shared by English (US) and English (UK). Language selection, per-language personal vocabulary, and per-language writing-rule preferences remain independently persisted exactly as before V2.7.
''',
}

for name, section in sections.items():
    path = Path(name)
    if not path.is_file():
        raise SystemExit(f'Missing documentation file: {name}')
    text = path.read_text()
    marker = next(line for line in section.splitlines() if line.strip())
    if marker in text:
        raise SystemExit(f'V2.7 section already exists in {name}')
    path.write_text(text.rstrip() + '\n\n' + section.strip() + '\n')
