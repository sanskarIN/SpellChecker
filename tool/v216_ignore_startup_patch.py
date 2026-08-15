from pathlib import Path

path = Path('lib/features/editor/spell_checker_page.dart')
text = path.read_text()
old = """  void _ignoreWord(SpellIssue issue) {\n    _engine.ignoreWord(issue.word);\n    _checkText(preferredOffset: issue.start);\n    _showMessage('Ignoring “${issue.word}” for this session.');\n  }\n"""
new = """  void _ignoreWord(SpellIssue issue) {\n    if (!_preferencesLoaded) {\n      _showMessage('Dictionary preferences are still loading.');\n      return;\n    }\n\n    _engine.ignoreWord(issue.word);\n    _checkText(preferredOffset: issue.start);\n    _showMessage('Ignoring “${issue.word}” for this session.');\n  }\n"""
if text.count(old) != 1:
    raise SystemExit('ignore-word anchor drifted')
path.write_text(text.replace(old, new, 1))
