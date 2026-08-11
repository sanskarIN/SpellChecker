# commit-message: chore: update About metadata for V2.7
from pathlib import Path

path = Path('lib/features/editor/spell_checker_page.dart')
text = path.read_text()
old_version = "applicationVersion: '2.6.0'"
new_version = "applicationVersion: '2.7.0'"
old_description = "A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, deterministic extensible suggestion ranking, bounded large-document spelling results, expanded deterministic local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections."
new_description = "A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, deterministic extensible suggestion ranking, bounded large-document spelling and Writing insights results, expanded deterministic local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections."

for marker in (old_version, old_description):
    if text.count(marker) != 1:
        raise SystemExit(f'Expected exactly one marker: {marker!r}')

text = text.replace(old_version, new_version).replace(old_description, new_description)
path.write_text(text)
