import 'package:flutter/material.dart';

import '../../core/spell_checker_engine.dart';
import '../../core/spell_issue.dart';
import '../../core/text_statistics.dart';

class SpellCheckerPage extends StatefulWidget {
  const SpellCheckerPage({super.key});

  @override
  State<SpellCheckerPage> createState() => _SpellCheckerPageState();
}

class _SpellCheckerPageState extends State<SpellCheckerPage> {
  final TextEditingController _controller = TextEditingController();
  final SpellCheckerEngine _engine = SpellCheckerEngine();

  List<SpellIssue> _issues = const <SpellIssue>[];
  TextStatistics _statistics = TextStatistics.fromText('');
  bool _hasChecked = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
      _issues = _engine.check(_controller.text);
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
    final currentText = _controller.text;
    if (issue.start < 0 || issue.end > currentText.length || issue.start >= issue.end) {
      _checkText();
      return;
    }

    final currentWord = currentText.substring(issue.start, issue.end);
    if (currentWord != issue.word) {
      _checkText();
      return;
    }

    final replacement = _matchCase(issue.word, suggestion);
    final updatedText = currentText.replaceRange(issue.start, issue.end, replacement);
    _controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: issue.start + replacement.length),
    );
    _checkText();
  }

  void _addToDictionary(SpellIssue issue) {
    _engine.addToPersonalDictionary(issue.word);
    _checkText();
    _showMessage('Added “${issue.word}” to the session dictionary.');
  }

  void _ignoreWord(SpellIssue issue) {
    _engine.ignoreWord(issue.word);
    _checkText();
    _showMessage('Ignoring “${issue.word}” for this session.');
  }

  void _resetSessionWords() {
    _engine.resetSession();
    _checkText();
    _showMessage('Session dictionary and ignored words were reset.');
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

  Future<void> _showAbout() async {
    await showAboutDialog(
      context: context,
      applicationName: 'SpellChecker',
      applicationVersion: '1.0.0',
      applicationLegalese: 'MIT License • Made by Sanskar',
      children: const <Widget>[
        SizedBox(height: 12),
        Text(
          'A privacy-first open-source spelling utility. Spell checking runs locally in the application.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpellChecker'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Reset session words',
            onPressed: _resetSessionWords,
            icon: const Icon(Icons.restart_alt),
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
    required this.onChanged,
    required this.onCheck,
    required this.onClear,
  });

  final TextEditingController controller;
  final TextStatistics statistics;
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
            Text('Editor', style: Theme.of(context).textTheme.titleLarge),
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
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
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
  final ValueChanged<SpellIssue> onAddToDictionary;
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
                  child: Text('Results', style: Theme.of(context).textTheme.titleLarge),
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
        message: 'Enter text and choose “Check spelling” to review possible mistakes.',
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
      separatorBuilder: (_, __) => const Divider(height: 24),
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
  final VoidCallback onAddToDictionary;
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
              label: const Text('Add word'),
            ),
            TextButton.icon(
              onPressed: onIgnore,
              icon: const Icon(Icons.visibility_off_outlined),
              label: const Text('Ignore'),
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
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
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
