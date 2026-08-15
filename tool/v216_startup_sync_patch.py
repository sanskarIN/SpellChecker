from pathlib import Path

path = Path('lib/features/editor/spell_checker_page.dart')
text = path.read_text()

old_restore = """      setState(() {\n        _languagePack = pack;\n        _engine = engine;\n        _enabledWritingRuleIds = _effectiveWritingRuleIds(storedRuleIds, pack);\n        _suggestionLimit = limit;\n        _preferencesLoaded = true;\n        _storageAvailable = true;\n      });\n"""
new_restore = """      setState(() {\n        _languagePack = pack;\n        _engine = engine;\n        _enabledWritingRuleIds = _effectiveWritingRuleIds(storedRuleIds, pack);\n        _suggestionLimit = limit;\n        _preferencesLoaded = true;\n        _storageAvailable = true;\n      });\n      if (_hasChecked && _controller.text.trim().isNotEmpty) {\n        final selectionOffset = _controller.selection.extentOffset;\n        _checkText(preferredOffset: selectionOffset < 0 ? null : selectionOffset);\n      }\n"""
if text.count(old_restore) != 1:
    raise SystemExit('restore anchor drifted')
text = text.replace(old_restore, new_restore, 1)

old_insights = """  Future<void> _showWritingInsights() async {\n    final result = await showDialog<WritingInsightsDialogResult>(\n"""
new_insights = """  Future<void> _showWritingInsights() async {\n    if (!_preferencesLoaded) {\n      _showMessage('Dictionary preferences are still loading.');\n      return;\n    }\n\n    final result = await showDialog<WritingInsightsDialogResult>(\n"""
if text.count(old_insights) != 1:
    raise SystemExit('Writing insights anchor drifted')
text = text.replace(old_insights, new_insights, 1)

path.write_text(text)
