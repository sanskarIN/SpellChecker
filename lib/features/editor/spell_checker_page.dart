import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/spell_checker_engine.dart';
import '../../core/spell_issue.dart';
import '../../core/text_statistics.dart';
import '../../storage/dictionary_preferences.dart';
import 'dictionary_manager_dialog.dart';

class SpellCheckerPage extends StatefulWidget {
  const SpellCheckerPage({this.preferences, super.key});

  final DictionaryPreferences? preferences;

  @override
  State<SpellCheckerPage> createState() => _SpellCheckerPageState();
}

class _SpellCheckerPageState extends State<SpellCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  final SpellCheckerEngine _engine = SpellCheckerEngine();

  late final DictionaryPreferences _preferences;
  List<SpellIssue> _issues = const <SpellIssue>[];
  TextStatistics _statistics = TextStatistics.fromText('');
  int _suggestionLimit = DictionaryPreferences.defaultSuggestionLimit;
  bool _hasChecked = false;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? DictionaryPreferences();
    unawaited(_restorePreferences());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _restorePreferences() async {
    try {
      final words = await _preferences.loadPersonalWords();
      final limit = await _preferences.loadSuggestionLimit();
      if (!mounted) {
        return;
      }
      _engine.replacePersonalDictionary(words);
      setState(() {
        _suggestionLimit = limit;
        _preferencesLoaded = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _preferencesLoaded = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showMessage(
            'Saved dictionary preferences could not be loaded. Session mode is still available.',
          );
        }
      });
    }
  }

  void _onTextChanged(String value) {
    setState(() {
      _statistics = TextStatistics.fromText(value);
      _issues = const <SpellIssue>[];
      _hasChecked = false;
    });
  }

  void _checkText() {
    setState(() {
      _statistics = TextStatistics.fromText(_controller.text);
      _issues = _engine.check(
        _controller.text,
        suggestionLimit: _suggestionLimit,
      );
      _hasChecked = true;
    });
  }

  void _clearText() {
    _controller.clear();
    setState(() {
      _statistics = TextStatistics.fromText('');
      _issues = const <SpellIssue>[];
      _hasChecked = false;
    });
  }

  void _replaceIssue(SpellIssue issue, String suggestion) {
    final text = _controller.text;
    if (issue.start < 0 || issue.end > text.length || issue.start >= issue.end) {
      _checkText();
      return;
    }

    if (text.substring(issue.start, issue.end) != issue.word) {
      _checkText();
      return;
    }

    final replacement = _matchCase(issue.word, suggestion);
    final updated = text.replaceRange(issue.start, issue.end, replacement);
    _controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(
        offset: issue.start + replacement.length,
      ),
    );
    _checkText();
  }

  Future<void> _addToDictionary(SpellIssue issue) async {
    if (!_preferencesLoaded) {
      _showMessage('Dictionary preferences are still loading.');
      return;
    }

    final before = _engine.personalDictionary;
    _engine.addToPersonalDictionary(issue.word);
    try {
      await _preferences.savePersonalWords(_engine.personalDictionary);
      if (!mounted) {
        return;
      }
      _checkText();
      _showMessage('Saved “${issue.word}” to your personal dictionary.');
    } catch (_) {
      _engine.replacePersonalDictionary(before);
      if (!mounted) {
        return;
      }
      _checkText();
      _showMessage('Could not save “${issue.word}”.');
    }
  }

  void _ignoreWord(SpellIssue issue) {
    _engine.ignoreWord(issue.word);
    _checkText();
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
        onWordsChanged: _applyPersonalWords,
        onSuggestionLimitChanged: _applySuggestionLimit,
      ),
    );
  }

  Future<void> _applyPersonalWords(Set<String> words) async {
    await _preferences.savePersonalWords(words);
    _engine.replacePersonalDictionary(words);
    if (!mounted) {
      return;
    }
    if (_hasChecked) {
      _checkText();
    } else {
      setState(() {});
    }
  }

  Future<void> _applySuggestionLimit(int limit) async {
    await _preferences.saveSuggestionLimit(limit);
    if (!mounted) {
      return;
    }
    setState(() => _suggestionLimit = limit);
    if (_hasChecked) {
      _checkText();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _matchCase(String original, String suggestion) {
    if (original == original.toUpperCase()) {
      return suggestion.toUpperCase();
    }
    if (original.isNotEmpty && original[0] == original[0].toUpperCase()) {
      return '${suggestion[0].toUpperCase()}${suggestion.substring(1)}';
    }
    return suggestion;
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SpellChecker',
      applicationVersion: '1.1.0',
      applicationLegalese: 'MIT License • Made by Sanskar',
      children: const <Widget>[
        SizedBox(height: 12),
        Text(
          'A privacy-first open-source spelling utility. Spell checking runs locally, and personal dictionary words are stored only on this device.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final personalWordCount = _engine.personalDictionary.length;
    final ignoredWordCount = _engine.ignoredWords.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpellChecker'),
        actions: <Widget>[
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
              statistics: _statistics,
              suggestionLimit: _suggestionLimit,
              preferencesLoaded: _preferencesLoaded,
              onChanged: _onTextChanged,
              onCheck: _checkText,
              onClear: _clearText,
            );
            final results = _ResultsPanel(
              issues: _issues,
              hasChecked: _hasChecked,
              onReplace: _replaceIssue,
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
    );
  }
}

class _EditorPanel extends StatelessWidget {
  const _EditorPanel({
    required this.controller,
    required this.statistics,
    required this.suggestionLimit,
    required this.preferencesLoaded,
    required this.onChanged,
    required this.onCheck,
    required this.onClear,
  });

  final TextEditingController controller;
  final TextStatistics statistics;
  final int suggestionLimit;
  final bool preferencesLoaded;
  final ValueChanged<String> onChanged;
  final VoidCallback onCheck;
  final VoidCallback onClear;

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
                if (!preferencesLoaded)
                  const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Write or paste text below. Your text is checked locally.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: controller,
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

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label));
}

class _ResultsPanel extends StatelessWidget {
  const _ResultsPanel({
    required this.issues,
    required this.hasChecked,
    required this.onReplace,
    required this.onAddToDictionary,
    required this.onIgnore,
  });

  final List<SpellIssue> issues;
  final bool hasChecked;
  final void Function(SpellIssue issue, String suggestion) onReplace;
  final Future<void> Function(SpellIssue issue) onAddToDictionary;
  final ValueChanged<SpellIssue> onIgnore;

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
                if (hasChecked)
                  Badge(
                    label: Text('${issues.length}'),
                    child: const Icon(Icons.rule),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (!hasChecked) {
      return const _EmptyState(
        icon: Icons.edit_note,
        title: 'Ready to check',
        message:
            'Enter text and choose “Check spelling” to review possible mistakes.',
      );
    }

    if (issues.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        title: 'No issues found',
        message: 'No unknown words were found in the current text.',
      );
    }

    return ListView.separated(
      itemCount: issues.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (BuildContext context, int index) {
        final issue = issues[index];
        return _IssueTile(
          issue: issue,
          onReplace: (String suggestion) => onReplace(issue, suggestion),
          onAddToDictionary: () => onAddToDictionary(issue),
          onIgnore: () => onIgnore(issue),
        );
      },
    );
  }
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.issue,
    required this.onReplace,
    required this.onAddToDictionary,
    required this.onIgnore,
  });

  final SpellIssue issue;
  final ValueChanged<String> onReplace;
  final Future<void> Function() onAddToDictionary;
  final VoidCallback onIgnore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          issue.word,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        const SizedBox(height: 4),
        Text('Characters ${issue.start + 1}–${issue.end}'),
        const SizedBox(height: 8),
        if (issue.suggestions.isEmpty)
          const Text('No close suggestions found.')
        else ...<Widget>[
          Text('Suggestions', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: issue.suggestions
                .map(
                  (String suggestion) => ActionChip(
                    tooltip: 'Replace with $suggestion',
                    label: Text(suggestion),
                    onPressed: () => onReplace(suggestion),
                  ),
                )
                .toList(growable: false),
          ),
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
    return Center(
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
    );
  }
}
