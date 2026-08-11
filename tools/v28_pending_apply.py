# commit-message: fix: add stable key for exact diagnostics badge
from pathlib import Path

path = Path('lib/features/editor/writing_insights_dialog.dart')
text = path.read_text()
old = '''                    child: Badge(
                      label: Text(
'''
new = '''                    child: Badge(
                      key: const ValueKey<String>('writing-findings-total-badge'),
                      label: Text(
'''
if text.count(old) != 1:
    raise SystemExit('Expected exactly one findings diagnostics Badge marker.')
path.write_text(text.replace(old, new))
