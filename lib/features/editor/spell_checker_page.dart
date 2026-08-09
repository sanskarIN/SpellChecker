import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/settings_transfer_codec.dart';
import '../../core/spell_checker_engine.dart';
import '../../core/spell_issue.dart';
import '../../core/spell_language_pack.dart';
import '../../core/text_correction.dart';
import '../../core/text_statistics.dart';
import '../../storage/dictionary_preferences.dart';
import '../../storage/settings_transfer_service.dart';
import '../../writing/writing_analyzer.dart';
import '../../writing/writing_correction.dart';
import '../../writing/writing_issue.dart';
import 'settings_transfer_dialog.dart';
import 'writing_insights_dialog.dart';
import 'dictionary_manager_dialog.dart';
import 'spell_check_editing_controller.dart';

class SpellCheckerPage extends StatefulWidget {
  const SpellCheckerPage({this.preferences, super.key});

  final DictionaryPreferences? preferences;

  @override
  State<SpellCheckerPage> createState() => _SpellCheckerPageState();
}

class _SpellCheckerPageState extends State<SpellCheckerPage> {
  static const int _maxCorrectionUndoDepth = 20;
  static const int _maxVisibleSpellingIssues = 200;

  final SpellCheckEditingController _controller = SpellCheckEditingController();
  final FocusNode _editorFocusNode = FocusNode(
    debugLabel: 'SpellChecker editor',
  );
  late SpellCheckerEngine _engine;
  final WritingAnalyzer _writingAnalyzer = WritingAnalyzer();
  Set<String> _enabledWritingRuleIds =
      WritingRuleRegistry.defaultEnabledRuleIds;
  final List<TextEditingValue> _correctionUndoStack = <TextEditingValue>[];

  late final DictionaryPreferences _preferences;
  late final SettingsTransferService _settingsTransferService;
  List<SpellIssue> _issues = const <SpellIssue>[];
  TextStatistics _statistics = TextStatistics.fromText('');
  int _suggestionLimit = DictionaryPreferences.defaultSuggestionLimit;
  SpellLanguagePack _languagePack = SpellLanguageRegistry.defaultPack;
  int _activeIssueIndex = -1;
  bool _hasChecked = false;
  bool _spellingResultsTruncated = false;
  bool _preferencesLoaded = false;
  bool _storageAvailable = true;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? DictionaryPreferences();
    _settingsTransferService = SettingsTransferService(_preferences);
    _engine = SpellCheckerEngine(languagePack: _languagePack);
    unawaited(_restorePreferences());
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  Future<void> _restorePreferences() async {
    try {
      final languageId = await _preferences.loadLanguageId();
      final pack = SpellLanguageRegistry.byId(languageId);
      final words = await _preferences.loadPersonalWords(languageId: pack.id);
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
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _preferencesLoaded = true;
        _storageAvailable = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showMessage(
            'Saved dictionary preferences could not be loaded. Spelling still works in session mode.',
          );
        }
      });
    }
  }

  Set<String> _effectiveWritingRuleIds(
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

  Future<void> _showPortableSettings() async {
    if (!_preferencesLoaded) {
      _showMessage('Dictionary preferences are still loading.');
      return;
    }

    SpellCheckerSettingsDocument currentDocument;
    try {
      currentDocument = await _settingsTransferService.exportDocument();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _storageAvailable = false);
      _showMessage(
        'Portable settings could not be read because local preference storage is unavailable.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final imported = await showDialog<SpellCheckerSettingsDocument>(
      context: context,
      builder: (BuildContext context) =>
          SettingsTransferDialog(initialDocument: currentDocument),
    );

    if (!mounted || imported == null) {
      return;
    }

    await _applyPortableSettings(imported);
  }

  Future<void> _applyPortableSettings(
    SpellCheckerSettingsDocument document,
  ) async {
    final nextPack = SpellLanguageRegistry.byId(document.languageId);
    Set<String> nextPersonalWords;

    try {
      // Read target-language vocabulary before any portable setting is written.
      // The transfer format never contains or mutates personal words.
      nextPersonalWords = await _preferences.loadPersonalWords(
        languageId: nextPack.id,
      );
      await _settingsTransferService.importDocument(document);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _storageAvailable = false);
      _showMessage(
        'Portable settings were not imported. Previous durable settings were restored when possible.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final nextEngine = SpellCheckerEngine(languagePack: nextPack)
      ..replacePersonalDictionary(nextPersonalWords);
    _correctionUndoStack.clear();
    _controller.clearIssues();
    setState(() {
      _languagePack = nextPack;
      _engine = nextEngine;
      _enabledWritingRuleIds = _effectiveWritingRuleIds(
        document.writingRuleIdsFor(nextPack.id),
        nextPack,
      );
      _suggestionLimit = document.suggestionLimit;
      _issues = const <SpellIssue>[];
      _activeIssueIndex = -1;
      _hasChecked = false;
      _spellingResultsTruncated = false;
      _storageAvailable = true;
    });

    if (_controller.text.trim().isNotEmpty) {
      _checkText();
    }
    _showMessage('Portable settings imported for ${nextPack.displayName}.');
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

    if (result.resetRulePreferences) {
      final defaultRuleIds = _effectiveWritingRuleIds(null, _languagePack);
      setState(() {
        _enabledWritingRuleIds = defaultRuleIds;
      });

      try {
        await _preferences.clearWritingRuleIds(languageId: _languagePack.id);
        if (mounted) {
          setState(() => _storageAvailable = true);
          _showMessage(
            'Writing rules reset to built-in defaults for ${_languagePack.displayName}.',
          );
        }
      } catch (_) {
        if (mounted) {
          setState(() => _storageAvailable = false);
          _showMessage(
            'Built-in writing rule defaults are active for this session but the saved override could not be cleared.',
          );
        }
      }
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
      _spellingResultsTruncated = false;
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
      _spellingResultsTruncated = false;
    });
    _checkText(preferredOffset: correction.caretOffset);

    final skipped = correction.skippedCount == 0
        ? ''
        : ' ${correction.skippedCount} overlapping, stale, or advisory ${correction.skippedCount == 1 ? 'finding was' : 'findings were'} skipped.';
    _showCorrectionMessage(
      'Applied ${correction.appliedCount} safe writing ${correction.appliedCount == 1 ? 'fix' : 'fixes'}.$skipped',
    );
  }

  Future<void> _changeLanguage(String? languageId) async {
    if (languageId == null || languageId == _languagePack.id) {
      return;
    }

    final nextPack = SpellLanguageRegistry.byId(languageId);
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
    }

    if (!mounted) {
      return;
    }

    final nextEngine = SpellCheckerEngine(languagePack: nextPack)
      ..replacePersonalDictionary(nextWords);
    _correctionUndoStack.clear();
    _controller.clearIssues();
    setState(() {
      _languagePack = nextPack;
      _engine = nextEngine;
      _enabledWritingRuleIds = _effectiveWritingRuleIds(
        storedRuleIds,
        nextPack,
      );
      _issues = const <SpellIssue>[];
      _activeIssueIndex = -1;
      _hasChecked = false;
      _spellingResultsTruncated = false;
      _storageAvailable = storageAvailable;
    });

    if (_controller.text.trim().isNotEmpty) {
      _checkText();
    }
    _showMessage('Language changed to ${nextPack.displayName}.');
  }

  void _onTextChanged(String value) {
    _correctionUndoStack.clear();
    _controller.clearIssues();
    setState(() {
      _statistics = TextStatistics.fromText(value);
      _issues = const <SpellIssue>[];
      _activeIssueIndex = -1;
      _hasChecked = false;
      _spellingResultsTruncated = false;
    });
  }

  void _checkText({int? preferredOffset}) {
    final text = _controller.text;
    final report = _engine.analyze(
      text,
      suggestionLimit: _suggestionLimit,
      maxIssues: _maxVisibleSpellingIssues,
    );
    final issues = report.issues;
    final activeIndex = _chooseActiveIssueIndex(issues, preferredOffset);

    setState(() {
      _statistics = TextStatistics.fromText(text);
      _issues = issues;
      _activeIssueIndex = activeIndex;
      _hasChecked = true;
      _spellingResultsTruncated = report.truncated;
    });
    _controller.setIssues(issues, activeIssueIndex: activeIndex);
  }

  int _chooseActiveIssueIndex(List<SpellIssue> issues, int? preferredOffset) {
    if (issues.isEmpty) {
      return -1;
    }

    if (preferredOffset != null) {
      for (var index = 0; index < issues.length; index++) {
        if (issues[index].start >= preferredOffset) {
          return index;
        }
      }
      return issues.length - 1;
    }

    if (_activeIssueIndex >= 0 && _activeIssueIndex < issues.length) {
      return _activeIssueIndex;
    }
    return 0;
  }

  void _clearText() {
    _correctionUndoStack.clear();
    _controller
      ..clear()
      ..clearIssues();
    setState(() {
      _statistics = TextStatistics.fromText('');
      _issues = const <SpellIssue>[];
      _activeIssueIndex = -1;
      _hasChecked = false;
      _spellingResultsTruncated = false;
    });
  }

  void _replaceIssue(SpellIssue issue, String suggestion) {
    final before = _controller.value;
    final result = TextCorrection.replaceOne(before.text, issue, suggestion);

    if (!result.changed) {
      _checkText(preferredOffset: issue.start);
      _showMessage(
        'The text changed after checking, so spelling results were refreshed.',
      );
      return;
    }

    _pushCorrectionUndo(before);
    _controller.value = TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.caretOffset),
    );
    _checkText(preferredOffset: result.caretOffset);
    _showCorrectionMessage(
      'Replaced “${issue.word}” with “${TextCorrection.matchCase(issue.word, suggestion)}”.',
    );
  }

  void _replaceAllIssues(SpellIssue issue, String suggestion) {
    final before = _controller.value;
    final result = TextCorrection.replaceAll(
      before.text,
      _issues,
      issue.word,
      suggestion,
    );

    if (!result.changed) {
      _checkText(preferredOffset: issue.start);
      _showMessage(
        'No current matching occurrences were available to replace.',
      );
      return;
    }

    _pushCorrectionUndo(before);
    _controller.value = TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.caretOffset),
    );
    _checkText(preferredOffset: result.caretOffset);
    _showCorrectionMessage(
      'Replaced ${result.replacements} ${result.replacements == 1 ? 'occurrence' : 'occurrences'} of “${issue.word}”.',
    );
  }

  void _pushCorrectionUndo(TextEditingValue value) {
    _correctionUndoStack.add(value);
    if (_correctionUndoStack.length > _maxCorrectionUndoDepth) {
      _correctionUndoStack.removeAt(0);
    }
    setState(() {});
  }

  void _undoLastCorrection() {
    if (_correctionUndoStack.isEmpty) {
      _showMessage('There is no spelling correction to undo.');
      return;
    }

    final previous = _correctionUndoStack.removeLast();
    _controller.value = previous;
    _checkText(preferredOffset: previous.selection.extentOffset);
    setState(() {});
    _showMessage('Undid the last spelling correction.');
  }

  void _showCorrectionMessage(String message) {
    _showMessage(
      message,
      action: SnackBarAction(label: 'Undo', onPressed: _undoLastCorrection),
    );
  }

  void _activateIssue(int index, {bool focusEditor = true}) {
    if (index < 0 || index >= _issues.length) {
      return;
    }

    final issue = _issues[index];
    setState(() => _activeIssueIndex = index);
    _controller
      ..setActiveIssue(index)
      ..selection = TextSelection(
        baseOffset: issue.start,
        extentOffset: issue.end,
      );
    if (focusEditor) {
      _editorFocusNode.requestFocus();
    }
  }

  void _moveActiveIssue(int delta) {
    if (_issues.isEmpty) {
      if (!_hasChecked && _controller.text.trim().isNotEmpty) {
        _checkText();
      }
      if (_issues.isEmpty) {
        _showMessage(
          _controller.text.trim().isEmpty
              ? 'Enter text before navigating spelling issues.'
              : 'There are no spelling issues to navigate.',
        );
        return;
      }
    }

    final current = _activeIssueIndex;
    final next = current < 0
        ? (delta >= 0 ? 0 : _issues.length - 1)
        : (current + delta) % _issues.length;
    _activateIssue(next < 0 ? next + _issues.length : next);
  }

  int _occurrenceCount(SpellIssue issue) {
    final target = issue.word.toLowerCase();
    return _issues
        .where((SpellIssue candidate) => candidate.word.toLowerCase() == target)
        .length;
  }

  Future<void> _addToDictionary(SpellIssue issue) async {
    if (!_preferencesLoaded) {
      _showMessage('Dictionary preferences are still loading.');
      return;
    }

    final before = _engine.personalDictionary;
    _engine.addToPersonalDictionary(issue.word);
    try {
      await _preferences.savePersonalWords(
        _engine.personalDictionary,
        languageId: _languagePack.id,
      );
      if (!mounted) {
        return;
      }
      setState(() => _storageAvailable = true);
      _checkText(preferredOffset: issue.start);
      _showMessage('Saved “${issue.word}” to your personal dictionary.');
    } catch (_) {
      _engine.replacePersonalDictionary(before);
      if (!mounted) {
        return;
      }
      setState(() => _storageAvailable = false);
      _checkText(preferredOffset: issue.start);
      _showMessage(
        'Could not save “${issue.word}”. Local preference storage is unavailable.',
      );
    }
  }

  void _ignoreWord(SpellIssue issue) {
    _engine.ignoreWord(issue.word);
    _checkText(preferredOffset: issue.start);
    _showMessage('Ignoring “${issue.word}” for this session.');
  }

  void _clearIgnoredWords() {
    final count = _engine.ignoredWords.length;
    _engine.clearIgnoredWords();
    if (_hasChecked) {
      _checkText();
    } else {
      setState(() {});
    }
    _showMessage(
      count == 0
          ? 'There were no ignored session words.'
          : 'Cleared $count ignored session ${count == 1 ? 'word' : 'words'}.',
    );
  }

  Future<void> _showDictionaryManager() async {
    if (!_preferencesLoaded) {
      _showMessage('Dictionary preferences are still loading.');
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) => DictionaryManagerDialog(
        initialWords: _engine.personalDictionary,
        initialSuggestionLimit: _suggestionLimit,
        languagePack: _languagePack,
        onWordsChanged: _applyPersonalWords,
        onSuggestionLimitChanged: _applySuggestionLimit,
      ),
    );
  }

  Future<void> _applyPersonalWords(Set<String> words) async {
    try {
      await _preferences.savePersonalWords(words, languageId: _languagePack.id);
    } catch (_) {
      if (mounted) {
        setState(() => _storageAvailable = false);
      }
      rethrow;
    }

    _engine.replacePersonalDictionary(words);
    if (!mounted) {
      return;
    }
    setState(() => _storageAvailable = true);
    if (_hasChecked) {
      _checkText();
    } else {
      setState(() {});
    }
  }

  Future<void> _applySuggestionLimit(int limit) async {
    try {
      await _preferences.saveSuggestionLimit(limit);
    } catch (_) {
      if (mounted) {
        setState(() => _storageAvailable = false);
      }
      rethrow;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _suggestionLimit = limit;
      _storageAvailable = true;
    });
    if (_hasChecked) {
      _checkText();
    }
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SpellChecker',
      applicationVersion: '2.5.0',
      applicationLegalese: 'MIT License • Made by Sanskar',
      children: const <Widget>[
        SizedBox(height: 12),
        Text(
          'A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, deterministic extensible suggestion ranking, bounded large-document spelling results, categorized local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final personalWordCount = _engine.personalDictionary.length;
    final ignoredWordCount = _engine.ignoredWords.length;

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.enter, control: true): () =>
          _checkText(),
      const SingleActivator(LogicalKeyboardKey.enter, meta: true): () =>
          _checkText(),
      const SingleActivator(
        LogicalKeyboardKey.enter,
        control: true,
        shift: true,
      ): () =>
          unawaited(_showWritingInsights()),
      const SingleActivator(
        LogicalKeyboardKey.enter,
        meta: true,
        shift: true,
      ): () =>
          unawaited(_showWritingInsights()),
      const SingleActivator(LogicalKeyboardKey.f7): () => _moveActiveIssue(1),
      const SingleActivator(LogicalKeyboardKey.f7, shift: true): () =>
          _moveActiveIssue(-1),
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: FocusTraversalGroup(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('SpellChecker'),
              actions: <Widget>[
                IconButton(
                  tooltip: 'Writing insights (Ctrl/⌘+Shift+Enter)',
                  onPressed: _showWritingInsights,
                  icon: const Icon(Icons.auto_fix_high_outlined),
                ),
                IconButton(
                  tooltip: 'Previous spelling issue (Shift+F7)',
                  onPressed: _issues.isEmpty
                      ? null
                      : () => _moveActiveIssue(-1),
                  icon: const Icon(Icons.keyboard_arrow_up),
                ),
                IconButton(
                  tooltip: 'Next spelling issue (F7)',
                  onPressed: _issues.isEmpty ? null : () => _moveActiveIssue(1),
                  icon: const Icon(Icons.keyboard_arrow_down),
                ),
                IconButton(
                  tooltip: 'Portable settings',
                  onPressed: _preferencesLoaded ? _showPortableSettings : null,
                  icon: const Icon(Icons.settings_backup_restore_outlined),
                ),
                IconButton(
                  tooltip: 'Manage personal dictionary',
                  onPressed: _preferencesLoaded ? _showDictionaryManager : null,
                  icon: Badge(
                    isLabelVisible: personalWordCount > 0,
                    label: Text('$personalWordCount'),
                    child: const Icon(Icons.menu_book_outlined),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear ignored session words',
                  onPressed: _clearIgnoredWords,
                  icon: Badge(
                    isLabelVisible: ignoredWordCount > 0,
                    label: Text('$ignoredWordCount'),
                    child: const Icon(Icons.visibility_outlined),
                  ),
                ),
                IconButton(
                  tooltip: 'About SpellChecker',
                  onPressed: _showAbout,
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final editor = _EditorPanel(
                    controller: _controller,
                    focusNode: _editorFocusNode,
                    statistics: _statistics,
                    suggestionLimit: _suggestionLimit,
                    languagePack: _languagePack,
                    languagePacks: SpellLanguageRegistry.builtIns,
                    preferencesLoaded: _preferencesLoaded,
                    storageAvailable: _storageAvailable,
                    canUndoCorrection: _correctionUndoStack.isNotEmpty,
                    onChanged: _onTextChanged,
                    onLanguageChanged: _changeLanguage,
                    onCheck: () => _checkText(),
                    onClear: _clearText,
                    onUndoCorrection: _undoLastCorrection,
                  );
                  final results = _ResultsPanel(
                    issues: _issues,
                    activeIssueIndex: _activeIssueIndex,
                    hasChecked: _hasChecked,
                    resultsTruncated: _spellingResultsTruncated,
                    issueLimit: _maxVisibleSpellingIssues,
                    inputIsBlank: _controller.text.trim().isEmpty,
                    occurrenceCount: _occurrenceCount,
                    onActivate: (int index) => _activateIssue(index),
                    onPrevious: () => _moveActiveIssue(-1),
                    onNext: () => _moveActiveIssue(1),
                    onReplace: _replaceIssue,
                    onReplaceAll: _replaceAllIssues,
                    onAddToDictionary: _addToDictionary,
                    onIgnore: _ignoreWord,
                  );

                  if (constraints.maxWidth >= 900) {
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(flex: 3, child: editor),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: results),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 3, child: editor),
                        const SizedBox(height: 12),
                        Expanded(flex: 2, child: results),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.controller,
    required this.focusNode,
    required this.statistics,
    required this.suggestionLimit,
    required this.languagePack,
    required this.languagePacks,
    required this.preferencesLoaded,
    required this.storageAvailable,
    required this.canUndoCorrection,
    required this.onChanged,
    required this.onLanguageChanged,
    required this.onCheck,
    required this.onClear,
    required this.onUndoCorrection,
  });

  final SpellCheckEditingController controller;
  final FocusNode focusNode;
  final TextStatistics statistics;
  final int suggestionLimit;
  final SpellLanguagePack languagePack;
  final List<SpellLanguagePack> languagePacks;
  final bool preferencesLoaded;
  final bool storageAvailable;
  final bool canUndoCorrection;
  final ValueChanged<String> onChanged;
  final ValueChanged<String?> onLanguageChanged;
  final VoidCallback onCheck;
  final VoidCallback onClear;
  final VoidCallback onUndoCorrection;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Editor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: Semantics(
                    label: 'Spelling language',
                    child: DropdownButton<String>(
                      key: const ValueKey<String>('language-selector'),
                      value: languagePack.id,
                      isDense: true,
                      isExpanded: true,
                      items: languagePacks
                          .map(
                            (SpellLanguagePack pack) =>
                                DropdownMenuItem<String>(
                                  value: pack.id,
                                  child: Text(pack.displayName),
                                ),
                          )
                          .toList(growable: false),
                      onChanged: preferencesLoaded ? onLanguageChanged : null,
                    ),
                  ),
                ),
                if (!preferencesLoaded) ...<Widget>[
                  const SizedBox(width: 8),
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Write or paste text below. Check with Ctrl/⌘+Enter; move through issues with F7 and Shift+F7.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!storageAvailable) ...<Widget>[
              const SizedBox(height: 10),
              const _StorageWarning(),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: Semantics(
                textField: true,
                label:
                    'SpellChecker editor. Checked spelling issues are underlined after a spelling check.',
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Start writing here…',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: onCheck,
                  icon: const Icon(Icons.spellcheck),
                  label: const Text('Check spelling'),
                ),
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                OutlinedButton.icon(
                  onPressed: canUndoCorrection ? onUndoCorrection : null,
                  icon: const Icon(Icons.undo),
                  label: const Text('Undo correction'),
                ),
                _StatChip(label: '${statistics.words} words'),
                _StatChip(label: '${statistics.characters} characters'),
                _StatChip(label: '${statistics.sentences} sentences'),
                _StatChip(label: '$suggestionLimit suggestions'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StorageWarning extends StatelessWidget {
  const _StorageWarning();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      label:
          'Warning: local dictionary storage is unavailable. Spelling still works in session mode.',
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.warning_amber_rounded,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Local dictionary storage is unavailable. Spell checking still works, but saved words/preferences may not persist.',
                style: TextStyle(color: colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}

class _ResultsPanel extends StatefulWidget {
  const _ResultsPanel({
    required this.issues,
    required this.activeIssueIndex,
    required this.hasChecked,
    required this.resultsTruncated,
    required this.issueLimit,
    required this.inputIsBlank,
    required this.occurrenceCount,
    required this.onActivate,
    required this.onPrevious,
    required this.onNext,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onAddToDictionary,
    required this.onIgnore,
  });

  final List<SpellIssue> issues;
  final int activeIssueIndex;
  final bool hasChecked;
  final bool resultsTruncated;
  final int issueLimit;
  final bool inputIsBlank;
  final int Function(SpellIssue issue) occurrenceCount;
  final ValueChanged<int> onActivate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final void Function(SpellIssue issue, String suggestion) onReplace;
  final void Function(SpellIssue issue, String suggestion) onReplaceAll;
  final Future<void> Function(SpellIssue issue) onAddToDictionary;
  final ValueChanged<SpellIssue> onIgnore;

  @override
  State<_ResultsPanel> createState() => _ResultsPanelState();
}

class _ResultsPanelState extends State<_ResultsPanel> {
  final Map<String, GlobalKey> _issueKeys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(covariant _ResultsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIssueIndex != oldWidget.activeIssueIndex ||
        widget.issues != oldWidget.issues) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _ensureActiveVisible(),
      );
    }
  }

  void _ensureActiveVisible() {
    final index = widget.activeIssueIndex;
    if (index < 0 || index >= widget.issues.length) {
      return;
    }
    final issue = widget.issues[index];
    final context = _keyFor(issue).currentContext;
    if (context == null) {
      return;
    }
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 180),
      alignment: 0.25,
    );
  }

  GlobalKey _keyFor(SpellIssue issue) {
    final id = '${issue.start}:${issue.end}:${issue.word}';
    return _issueKeys.putIfAbsent(id, GlobalKey.new);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (widget.hasChecked)
                  Semantics(
                    liveRegion: true,
                    label: widget.resultsTruncated
                        ? 'At least ${widget.issues.length} spelling issues found. Results are limited.'
                        : '${widget.issues.length} spelling ${widget.issues.length == 1 ? 'issue' : 'issues'} found',
                    child: Badge(
                      label: Text(
                        widget.resultsTruncated
                            ? '${widget.issues.length}+'
                            : '${widget.issues.length}',
                      ),
                      child: const Icon(Icons.rule),
                    ),
                  ),
              ],
            ),
            if (widget.issues.isNotEmpty) ...<Widget>[
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Previous issue (Shift+F7)',
                    onPressed: widget.onPrevious,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Text(
                      widget.activeIssueIndex >= 0
                          ? 'Issue ${widget.activeIssueIndex + 1} of ${widget.issues.length}'
                          : '${widget.issues.length} issues',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next issue (F7)',
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!widget.hasChecked) {
      return const _EmptyState(
        icon: Icons.edit_note,
        title: 'Ready to check',
        message:
            'Enter text and choose “Check spelling” or press Ctrl/⌘+Enter.',
      );
    }

    if (widget.inputIsBlank) {
      return const _EmptyState(
        icon: Icons.notes_outlined,
        title: 'Nothing to check',
        message:
            'The editor is empty. Add text before running a spelling check.',
      );
    }

    if (widget.issues.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No issues found',
        message: 'No unknown words were found in the current text.',
      );
    }

    final resultOffset = widget.resultsTruncated ? 1 : 0;
    return ListView.separated(
      itemCount: widget.issues.length + resultOffset,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        if (widget.resultsTruncated && index == 0) {
          return _ResultLimitNotice(issueLimit: widget.issueLimit);
        }

        final issueIndex = index - resultOffset;
        final issue = widget.issues[issueIndex];
        final isActive = issueIndex == widget.activeIssueIndex;
        return KeyedSubtree(
          key: _keyFor(issue),
          child: _IssueTile(
            issue: issue,
            index: issueIndex,
            totalIssues: widget.issues.length,
            occurrenceCount: widget.occurrenceCount(issue),
            allowReplaceAll: !widget.resultsTruncated,
            isActive: isActive,
            onActivate: () => widget.onActivate(issueIndex),
            onReplace: (String suggestion) =>
                widget.onReplace(issue, suggestion),
            onReplaceAll: (String suggestion) =>
                widget.onReplaceAll(issue, suggestion),
            onAddToDictionary: () => widget.onAddToDictionary(issue),
            onIgnore: () => widget.onIgnore(issue),
          ),
        );
      },
    );
  }
}

class _ResultLimitNotice extends StatelessWidget {
  const _ResultLimitNotice({required this.issueLimit});

  final int issueLimit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final message =
        'Showing the first $issueLimit spelling issues. More unknown words exist later in the document. Replace all is unavailable for limited results; use single fixes or check a smaller section.';
    return Semantics(
      liveRegion: true,
      label: message,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.issue,
    required this.index,
    required this.totalIssues,
    required this.occurrenceCount,
    required this.allowReplaceAll,
    required this.isActive,
    required this.onActivate,
    required this.onReplace,
    required this.onReplaceAll,
    required this.onAddToDictionary,
    required this.onIgnore,
  });

  final SpellIssue issue;
  final int index;
  final int totalIssues;
  final int occurrenceCount;
  final bool allowReplaceAll;
  final bool isActive;
  final VoidCallback onActivate;
  final ValueChanged<String> onReplace;
  final ValueChanged<String> onReplaceAll;
  final Future<void> Function() onAddToDictionary;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      selected: isActive,
      label:
          'Spelling issue ${index + 1} of $totalIssues: ${issue.word}, characters ${issue.start + 1} through ${issue.end}.',
      child: Material(
        color: isActive ? colorScheme.errorContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onActivate,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        issue.word,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: isActive
                                  ? colorScheme.onErrorContainer
                                  : colorScheme.error,
                              fontWeight: isActive ? FontWeight.w700 : null,
                            ),
                      ),
                    ),
                    if (occurrenceCount > 1)
                      Chip(
                        label: Text(
                          allowReplaceAll
                              ? '$occurrenceCount occurrences'
                              : '$occurrenceCount captured occurrences',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Characters ${issue.start + 1}–${issue.end}'),
                const SizedBox(height: 8),
                if (issue.suggestions.isEmpty)
                  const Text('No close suggestions found.')
                else ...<Widget>[
                  Text(
                    'Suggestions',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: issue.suggestions
                        .map(
                          (String suggestion) => ActionChip(
                            tooltip: 'Replace ${issue.word} with $suggestion',
                            label: Text(suggestion),
                            onPressed: () => onReplace(suggestion),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  if (occurrenceCount > 1 && allowReplaceAll) ...<Widget>[
                    const SizedBox(height: 8),
                    PopupMenuButton<String>(
                      tooltip: 'Replace all ${issue.word} occurrences',
                      onSelected: onReplaceAll,
                      itemBuilder: (BuildContext context) => issue.suggestions
                          .map(
                            (String suggestion) => PopupMenuItem<String>(
                              value: suggestion,
                              child: Text('Replace all with $suggestion'),
                            ),
                          )
                          .toList(growable: false),
                      child: const Chip(
                        avatar: Icon(Icons.find_replace, size: 18),
                        label: Text('Replace all…'),
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: <Widget>[
                    TextButton.icon(
                      onPressed: onAddToDictionary,
                      icon: const Icon(Icons.library_add_outlined),
                      label: const Text('Save word'),
                    ),
                    TextButton.icon(
                      onPressed: onIgnore,
                      icon: const Icon(Icons.visibility_off_outlined),
                      label: const Text('Ignore once'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: '$title. $message',
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
