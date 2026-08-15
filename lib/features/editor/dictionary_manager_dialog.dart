import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/personal_dictionary_codec.dart';
import '../../core/spell_language_pack.dart';
import '../../storage/dictionary_preferences.dart';

class DictionaryManagerDialog extends StatefulWidget {
  const DictionaryManagerDialog({
    required this.initialWords,
    required this.initialSuggestionLimit,
    required this.languagePack,
    required this.onWordsChanged,
    required this.onSuggestionLimitChanged,
    super.key,
  });

  final Set<String> initialWords;
  final int initialSuggestionLimit;
  final SpellLanguagePack languagePack;
  final Future<void> Function(Set<String> words) onWordsChanged;
  final Future<void> Function(int limit) onSuggestionLimitChanged;

  @override
  State<DictionaryManagerDialog> createState() =>
      _DictionaryManagerDialogState();
}

class _DictionaryManagerDialogState extends State<DictionaryManagerDialog> {
  final TextEditingController _wordController = TextEditingController();

  late Set<String> _words;
  late int _suggestionLimit;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _words = Set<String>.from(widget.initialWords);
    _suggestionLimit = DictionaryPreferences.normalizeSuggestionLimit(
      widget.initialSuggestionLimit,
    );
  }

  @override
  void dispose() {
    _wordController.dispose();
    super.dispose();
  }

  Future<void> _addWord() async {
    final word = PersonalDictionaryCodec.normalizeWord(
      _wordController.text,
      languagePack: widget.languagePack,
    );
    if (word.isEmpty) {
      _showMessage(
        'Enter one valid word. Apostrophes and hyphens are supported.',
      );
      return;
    }
    if (_words.contains(word)) {
      _showMessage('“$word” is already in your personal dictionary.');
      return;
    }

    final next = Set<String>.from(_words)..add(word);
    if (await _persistWords(next)) {
      _wordController.clear();
      _showMessage('Added “$word”.');
    }
  }

  Future<void> _removeWord(String word) async {
    final next = Set<String>.from(_words)..remove(word);
    if (await _persistWords(next)) {
      _showMessage('Removed “$word”.');
    }
  }

  Future<void> _clearWords() async {
    if (_words.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Clear personal dictionary?'),
        content: Text(
          'This removes all ${_words.length} saved personal words from this device.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed == true && await _persistWords(<String>{})) {
      _showMessage('Personal dictionary cleared.');
    }
  }

  Future<bool> _persistWords(Set<String> next) async {
    setState(() => _busy = true);
    try {
      await widget.onWordsChanged(next);
      if (!mounted) {
        return true;
      }
      setState(() => _words = next);
      return true;
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save the personal dictionary.');
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _changeSuggestionLimit(int? value) async {
    if (value == null || value == _suggestionLimit) {
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.onSuggestionLimitChanged(value);
      if (mounted) {
        setState(() => _suggestionLimit = value);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not save the suggestion preference.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _copyExport() async {
    final export = PersonalDictionaryCodec.encodeForLanguage(
      _words,
      languagePack: widget.languagePack,
    );
    await Clipboard.setData(ClipboardData(text: export));
    if (mounted) {
      _showMessage('Dictionary export copied to the clipboard.');
    }
  }

  Future<void> _importWords() async {
    final controller = TextEditingController();
    final source = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Import personal words'),
        content: SizedBox(
          width: 520,
          child: TextField(
            controller: controller,
            autofocus: true,
            minLines: 8,
            maxLines: 14,
            decoration: const InputDecoration(
              hintText:
                  'Paste a SpellChecker JSON export, JSON array, or one word per line.',
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (source == null || source.trim().isEmpty) {
      return;
    }

    try {
      final document = PersonalDictionaryCodec.decodeDocument(
        source,
        languagePack: widget.languagePack,
      );
      if (document.version == PersonalDictionaryCodec.currentVersion &&
          document.languageId != widget.languagePack.id) {
        final sourceLanguage = SpellLanguageRegistry.byId(document.languageId);
        _showMessage(
          'This dictionary is for ${sourceLanguage.displayName}. Switch to that language before importing it.',
        );
        return;
      }
      final next = Set<String>.from(_words)..addAll(document.words);
      final addedCount = next.length - _words.length;
      if (await _persistWords(next)) {
        _showMessage(
          addedCount == 0
              ? 'No new words were found in the import.'
              : 'Imported $addedCount new ${addedCount == 1 ? 'word' : 'words'}.',
        );
      }
    } on FormatException catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final sortedWords = _words.toList()..sort();

    return AlertDialog(
      title: Row(
        children: <Widget>[
          const Icon(Icons.menu_book_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Personal dictionary — ${widget.languagePack.displayName}',
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Personal words are stored on this device for the selected language pack and used in future sessions.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _suggestionLimit,
                decoration: const InputDecoration(
                  labelText: 'Suggestions per spelling issue',
                  prefixIcon: Icon(Icons.tune),
                ),
                items: <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
                    .map(
                      (int value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      ),
                    )
                    .toList(growable: false),
                onChanged: _busy ? null : _changeSuggestionLimit,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _wordController,
                      enabled: !_busy,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addWord(),
                      decoration: const InputDecoration(
                        labelText: 'Add a personal word',
                        hintText: 'Example: Flutter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _addWord,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${sortedWords.length} saved ${sortedWords.length == 1 ? 'word' : 'words'}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _busy || _words.isEmpty ? null : _clearWords,
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear all'),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 230),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: sortedWords.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text('No personal words saved yet.'),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: sortedWords.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (BuildContext context, int index) {
                          final word = sortedWords[index];
                          return ListTile(
                            dense: true,
                            title: Text(word),
                            trailing: IconButton(
                              tooltip: 'Remove $word',
                              onPressed: _busy ? null : () => _removeWord(word),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _importWords,
                    icon: const Icon(Icons.content_paste_go_outlined),
                    label: const Text('Import'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _copyExport,
                    icon: const Icon(Icons.copy_all_outlined),
                    label: const Text('Copy export'),
                  ),
                ],
              ),
              if (_busy) ...<Widget>[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
