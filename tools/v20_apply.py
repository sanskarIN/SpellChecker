from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected one match, found {count}: {old[:100]!r}')
    file.write_text(text.replace(old, new, 1))


def require(path: str, needle: str) -> None:
    if needle not in Path(path).read_text():
        raise RuntimeError(f'{path}: required text missing: {needle!r}')


page = 'lib/features/editor/spell_checker_page.dart'
require(page, "ValueKey<String>('language-selector')")

# Imports.
replace_once(
    page,
    "import '../../storage/dictionary_preferences.dart';",
    "import '../../storage/dictionary_preferences.dart';\nimport '../../writing/writing_analyzer.dart';\nimport '../../writing/writing_correction.dart';\nimport '../../writing/writing_issue.dart';\nimport 'writing_insights_dialog.dart';",
)

# Analyzer and session-only enabled-rule state.
replace_once(
    page,
    "  late SpellCheckerEngine _engine;",
    "  late SpellCheckerEngine _engine;\n  final WritingAnalyzer _writingAnalyzer = WritingAnalyzer();\n  Set<String> _enabledWritingRuleIds = WritingRuleRegistry.defaultEnabledRuleIds;",
)

# Insert writing workflow before language switching.
replace_once(
    page,
    "  Future<void> _changeLanguage(String? languageId) async {",
    '''  Future<void> _showWritingInsights() async {
    final result = await showDialog<WritingInsightsDialogResult>(
      context: context,
      builder: (BuildContext context) => WritingInsightsDialog(
        text: _controller.text,
        languagePack: _languagePack,
        analyzer: _writingAnalyzer,
        initialEnabledRuleIds: _enabledWritingRuleIds,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _enabledWritingRuleIds = Set<String>.from(result.enabledRuleIds);
    });

    final issue = result.issueToFix;
    if (issue != null) {
      _applyWritingFix(issue);
    }
  }

  void _applyWritingFix(WritingIssue issue) {
    final correction = WritingCorrection.apply(_controller.text, issue);
    if (!correction.applied) {
      _showMessage('Text changed after analysis. Open Writing insights again to refresh findings.');
      return;
    }

    if (_correctionUndoStack.length >= 20) {
      _correctionUndoStack.removeAt(0);
    }
    _correctionUndoStack.add(_controller.value);

    _controller.value = TextEditingValue(
      text: correction.text,
      selection: TextSelection.collapsed(offset: correction.caretOffset),
    );
    _controller.clearIssues();
    setState(() {
      _statistics = TextStatistics.fromText(correction.text);
      _issues = const <SpellIssue>[];
      _activeIssueIndex = -1;
      _hasChecked = false;
    });
    _checkText(preferredOffset: correction.caretOffset);
    _showMessage('Applied ${issue.ruleName}. Undo is available.');
  }

  Future<void> _changeLanguage(String? languageId) async {''',
)

# App-bar entry point.
replace_once(
    page,
    "        actions: <Widget>[",
    "        actions: <Widget>[\n          IconButton(\n            tooltip: 'Writing insights',\n            onPressed: _showWritingInsights,\n            icon: const Icon(Icons.auto_fix_high_outlined),\n          ),",
)

# About/version metadata.
replace_once(page, "applicationVersion: '1.3.0'", "applicationVersion: '2.0.0'")
replace_once(
    page,
    "A privacy-first open-source spelling utility with explicit language packs, Unicode-aware tokenization, local checking, persistent per-language vocabulary, inline issue highlighting, keyboard navigation, replace-all, and undo-friendly corrections.",
    "A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, optional local writing-rule plugins, persistent per-language vocabulary, inline issue review, safe fixes, and undo-friendly corrections.",
)

# Release version.
replace_once('pubspec.yaml', 'version: 1.3.0+4', 'version: 2.0.0+5')

# Web metadata.
replace_once(
    'web/index.html',
    'explicit English language packs, Unicode-aware local checking, inline issue review, persistent personal vocabulary, and undo-friendly corrections.',
    'explicit English language packs, Unicode-aware local spelling, optional local writing insights, persistent personal vocabulary, and undo-friendly corrections.',
)
replace_once(
    'web/manifest.json',
    'explicit English language packs, Unicode-aware local checking, personal vocabulary, and correction workflows.',
    'explicit English language packs, Unicode-aware local spelling, optional local writing insights, personal vocabulary, and safe correction workflows.',
)

for path, needle in (
    (page, "tooltip: 'Writing insights'"),
    (page, 'WritingCorrection.apply'),
    (page, 'WritingRuleRegistry.defaultEnabledRuleIds'),
    ('pubspec.yaml', 'version: 2.0.0+5'),
):
    require(path, needle)

print('V2.0 writing-rules editor integration applied successfully.')
