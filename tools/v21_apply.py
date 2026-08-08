from pathlib import Path

page_path = Path('lib/features/editor/spell_checker_page.dart')
text = page_path.read_text()


def replace_once(old: str, new: str) -> None:
    global text
    count = text.count(old)
    if count != 1:
        raise RuntimeError(
            f'expected exactly one page integration match, found {count}: {old[:90]!r}'
        )
    text = text.replace(old, new, 1)


replace_once(
    """      final words = await _preferences.loadPersonalWords(languageId: pack.id);
      final limit = await _preferences.loadSuggestionLimit();
      if (!mounted) {
        return;
      }
      final engine = SpellCheckerEngine(languagePack: pack)
        ..replacePersonalDictionary(words);
      setState(() {
        _languagePack = pack;
        _engine = engine;
        _suggestionLimit = limit;
        _preferencesLoaded = true;
        _storageAvailable = true;
      });""",
    """      final words = await _preferences.loadPersonalWords(languageId: pack.id);
      final storedRuleIds = await _preferences.loadWritingRuleIds(
        languageId: pack.id,
      );
      final limit = await _preferences.loadSuggestionLimit();
      if (!mounted) {
        return;
      }
      final engine = SpellCheckerEngine(languagePack: pack)
        ..replacePersonalDictionary(words);
      setState(() {
        _languagePack = pack;
        _engine = engine;
        _enabledWritingRuleIds = _effectiveWritingRuleIds(storedRuleIds, pack);
        _suggestionLimit = limit;
        _preferencesLoaded = true;
        _storageAvailable = true;
      });""",
)

workflow_start = text.index('  Future<void> _showWritingInsights() async {')
change_language = text.index(
    '  Future<void> _changeLanguage(String? languageId) async {',
    workflow_start,
)
replacement = '''  Set<String> _effectiveWritingRuleIds(
    Set<String>? storedRuleIds,
    SpellLanguagePack languagePack,
  ) {
    final supportedRuleIds = _writingAnalyzer.rules
        .where((rule) => rule.supports(languagePack))
        .map((rule) => rule.id)
        .toSet();
    final requestedRuleIds =
        storedRuleIds ?? WritingRuleRegistry.defaultEnabledRuleIds;
    return requestedRuleIds.where(supportedRuleIds.contains).toSet();
  }

  Future<void> _showWritingInsights() async {
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

    final nextRuleIds = _effectiveWritingRuleIds(
      result.enabledRuleIds,
      _languagePack,
    );
    setState(() {
      _enabledWritingRuleIds = nextRuleIds;
    });

    try {
      await _preferences.saveWritingRuleIds(
        nextRuleIds,
        languageId: _languagePack.id,
      );
      if (mounted) {
        setState(() => _storageAvailable = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _storageAvailable = false);
        _showMessage(
          'Writing rule choices are active for this session but could not be saved locally.',
        );
      }
    }

    if (!mounted) {
      return;
    }

    if (result.issuesToFix.isNotEmpty) {
      _applyWritingFixes(result.issuesToFix);
      return;
    }

    final issue = result.issueToFix;
    if (issue != null) {
      _applyWritingFix(issue);
    }
  }

  void _applyWritingFix(WritingIssue issue) {
    final before = _controller.value;
    final correction = WritingCorrection.apply(before.text, issue);
    if (!correction.applied) {
      _showMessage(
        'Text changed after analysis. Open Writing insights again to refresh findings.',
      );
      return;
    }

    _pushCorrectionUndo(before);
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
    _showCorrectionMessage('Applied ${issue.ruleName}.');
  }

  void _applyWritingFixes(List<WritingIssue> issues) {
    final before = _controller.value;
    final correction = WritingCorrection.applyAll(before.text, issues);
    if (!correction.applied) {
      _showMessage(
        'No current non-overlapping writing fixes were safe to apply. Open Writing insights again to refresh findings.',
      );
      return;
    }

    _pushCorrectionUndo(before);
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

    final skipped = correction.skippedCount == 0
        ? ''
        : ' ${correction.skippedCount} overlapping, stale, or advisory ${correction.skippedCount == 1 ? 'finding was' : 'findings were'} skipped.';
    _showCorrectionMessage(
      'Applied ${correction.appliedCount} safe writing ${correction.appliedCount == 1 ? 'fix' : 'fixes'}.$skipped',
    );
  }

'''
text = text[:workflow_start] + replacement + text[change_language:]

replace_once(
    """    final nextPack = SpellLanguageRegistry.byId(languageId);
    var nextWords = <String>{};
    var storageAvailable = true;
    try {
      nextWords = await _preferences.loadPersonalWords(languageId: nextPack.id);
      await _preferences.saveLanguageId(nextPack.id);
    } catch (_) {
      storageAvailable = false;
    }""",
    """    final nextPack = SpellLanguageRegistry.byId(languageId);
    var nextWords = <String>{};
    Set<String>? storedRuleIds;
    var storageAvailable = true;
    try {
      nextWords = await _preferences.loadPersonalWords(languageId: nextPack.id);
      storedRuleIds = await _preferences.loadWritingRuleIds(
        languageId: nextPack.id,
      );
      await _preferences.saveLanguageId(nextPack.id);
    } catch (_) {
      storageAvailable = false;
    }""",
)
replace_once(
    """      _languagePack = nextPack;
      _engine = nextEngine;
      _issues = const <SpellIssue>[];""",
    """      _languagePack = nextPack;
      _engine = nextEngine;
      _enabledWritingRuleIds = _effectiveWritingRuleIds(
        storedRuleIds,
        nextPack,
      );
      _issues = const <SpellIssue>[];""",
)

replace_once(
    """      const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
          _checkText(),
      const SingleActivator(LogicalKeyboardKey.f7): () => _moveActiveIssue(1),""",
    """      const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
          _checkText(),
      const SingleActivator(
        LogicalKeyboardKey.enter,
        control: true,
        shift: true,
      ): () => unawaited(_showWritingInsights()),
      const SingleActivator(
        LogicalKeyboardKey.enter,
        meta: true,
        shift: true,
      ): () => unawaited(_showWritingInsights()),
      const SingleActivator(LogicalKeyboardKey.f7): () => _moveActiveIssue(1),""",
)
replace_once(
    "tooltip: 'Writing insights',",
    "tooltip: 'Writing insights (Ctrl/⌘+Shift+Enter)',",
)
replace_once(
    "applicationVersion: '2.0.0'",
    "applicationVersion: '2.1.0'",
)
replace_once(
    'optional local writing-rule plugins, persistent per-language vocabulary, inline issue review, safe fixes, and undo-friendly corrections.',
    'optional local writing-rule plugins, persistent per-language vocabulary and rule choices, batch-safe writing fixes, inline issue review, keyboard workflows, and undo-friendly corrections.',
)

page_path.write_text(text)

pubspec = Path('pubspec.yaml')
pubspec_text = pubspec.read_text()
if pubspec_text.count('version: 2.0.0+5') != 1:
    raise RuntimeError('expected V2.0 package version before V2.1 bump')
pubspec.write_text(pubspec_text.replace('version: 2.0.0+5', 'version: 2.1.0+6', 1))

print('V2.1 editor integration applied successfully.')
