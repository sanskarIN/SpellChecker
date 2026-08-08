from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file = Path(path)
    text = file.read_text()
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{path}: expected exactly one match, found {count}: {old[:80]!r}')
    file.write_text(text.replace(old, new, 1))


def require(path: str, needle: str) -> None:
    text = Path(path).read_text()
    if needle not in text:
        raise RuntimeError(f'{path}: required text missing: {needle!r}')


# Public core barrel.
replace_once(
    'lib/spell_checker.dart',
    "export 'core/spell_issue.dart';\nexport 'core/text_correction.dart';",
    "export 'core/spell_issue.dart';\nexport 'core/spell_language_pack.dart';\nexport 'core/spell_suggestion.dart';\nexport 'core/text_correction.dart';",
)

# Keep the legacy US preference key mirrored during the V1 -> V2 namespace
# transition so existing upgrades and V1.2 compatibility checks keep working.
replace_once(
    'lib/storage/dictionary_preferences.dart',
    "    await preferences.setStringList(_personalWordsKey(pack.id), normalized);\n  }",
    "    await preferences.setStringList(_personalWordsKey(pack.id), normalized);\n    if (pack.id == SpellLanguageRegistry.defaultPack.id) {\n      await preferences.setStringList(_legacyPersonalWordsKey, normalized);\n    }\n  }",
)

# Dictionary manager: selected language drives normalization and V2 import/export.
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "import '../../core/personal_dictionary_codec.dart';\nimport '../../storage/dictionary_preferences.dart';",
    "import '../../core/personal_dictionary_codec.dart';\nimport '../../core/spell_language_pack.dart';\nimport '../../storage/dictionary_preferences.dart';",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "    required this.initialWords,\n    required this.initialSuggestionLimit,",
    "    required this.initialWords,\n    required this.initialSuggestionLimit,\n    required this.languagePack,",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "  final Set<String> initialWords;\n  final int initialSuggestionLimit;",
    "  final Set<String> initialWords;\n  final int initialSuggestionLimit;\n  final SpellLanguagePack languagePack;",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "    final word = PersonalDictionaryCodec.normalizeWord(_wordController.text);",
    "    final word = PersonalDictionaryCodec.normalizeWord(\n      _wordController.text,\n      languagePack: widget.languagePack,\n    );",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "    final export = PersonalDictionaryCodec.encode(_words);",
    "    final export = PersonalDictionaryCodec.encodeForLanguage(\n      _words,\n      languagePack: widget.languagePack,\n    );",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "      final imported = PersonalDictionaryCodec.decode(source);\n      final next = Set<String>.from(_words)..addAll(imported);\n      final addedCount = next.length - _words.length;",
    "      final document = PersonalDictionaryCodec.decodeDocument(\n        source,\n        languagePack: widget.languagePack,\n      );\n      if (document.version == PersonalDictionaryCodec.currentVersion &&\n          document.languageId != widget.languagePack.id) {\n        final sourceLanguage = SpellLanguageRegistry.byId(document.languageId);\n        _showMessage(\n          'This dictionary is for ${sourceLanguage.displayName}. Switch to that language before importing it.',\n        );\n        return;\n      }\n      final next = Set<String>.from(_words)..addAll(document.words);\n      final addedCount = next.length - _words.length;",
)
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "          Expanded(child: Text('Personal dictionary')),",
    "          Expanded(child: Text('Personal dictionary — ${widget.languagePack.displayName}')),")
replace_once(
    'lib/features/editor/dictionary_manager_dialog.dart',
    "                'Personal words are stored on this device and used in future sessions.',",
    "                'Personal words are stored on this device for the selected language pack and used in future sessions.',",
)

# Editor: mutable engine and selected language state.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "import '../../core/spell_issue.dart';\nimport '../../core/text_correction.dart';",
    "import '../../core/spell_issue.dart';\nimport '../../core/spell_language_pack.dart';\nimport '../../core/text_correction.dart';",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "  final FocusNode _editorFocusNode = FocusNode(debugLabel: 'SpellChecker editor');\n  final SpellCheckerEngine _engine = SpellCheckerEngine();",
    "  final FocusNode _editorFocusNode = FocusNode(debugLabel: 'SpellChecker editor');\n  late SpellCheckerEngine _engine;",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "  int _suggestionLimit = DictionaryPreferences.defaultSuggestionLimit;\n  int _activeIssueIndex = -1;",
    "  int _suggestionLimit = DictionaryPreferences.defaultSuggestionLimit;\n  SpellLanguagePack _languagePack = SpellLanguageRegistry.defaultPack;\n  int _activeIssueIndex = -1;",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "    _preferences = widget.preferences ?? DictionaryPreferences();\n    unawaited(_restorePreferences());",
    "    _preferences = widget.preferences ?? DictionaryPreferences();\n    _engine = SpellCheckerEngine(languagePack: _languagePack);\n    unawaited(_restorePreferences());",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "      final words = await _preferences.loadPersonalWords();\n      final limit = await _preferences.loadSuggestionLimit();\n      if (!mounted) {\n        return;\n      }\n      _engine.replacePersonalDictionary(words);\n      setState(() {\n        _suggestionLimit = limit;\n        _preferencesLoaded = true;\n        _storageAvailable = true;\n      });",
    "      final languageId = await _preferences.loadLanguageId();\n      final pack = SpellLanguageRegistry.byId(languageId);\n      final words = await _preferences.loadPersonalWords(languageId: pack.id);\n      final limit = await _preferences.loadSuggestionLimit();\n      if (!mounted) {\n        return;\n      }\n      final engine = SpellCheckerEngine(languagePack: pack)\n        ..replacePersonalDictionary(words);\n      setState(() {\n        _languagePack = pack;\n        _engine = engine;\n        _suggestionLimit = limit;\n        _preferencesLoaded = true;\n        _storageAvailable = true;\n      });",
)

# Insert language switching before normal text-change handling.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "  void _onTextChanged(String value) {",
    "  Future<void> _changeLanguage(String? languageId) async {\n    if (languageId == null || languageId == _languagePack.id) {\n      return;\n    }\n\n    final nextPack = SpellLanguageRegistry.byId(languageId);\n    var nextWords = <String>{};\n    var storageAvailable = true;\n    try {\n      nextWords = await _preferences.loadPersonalWords(languageId: nextPack.id);\n      await _preferences.saveLanguageId(nextPack.id);\n    } catch (_) {\n      storageAvailable = false;\n    }\n\n    if (!mounted) {\n      return;\n    }\n\n    final nextEngine = SpellCheckerEngine(languagePack: nextPack)\n      ..replacePersonalDictionary(nextWords);\n    _correctionUndoStack.clear();\n    _controller.clearIssues();\n    setState(() {\n      _languagePack = nextPack;\n      _engine = nextEngine;\n      _issues = const <SpellIssue>[];\n      _activeIssueIndex = -1;\n      _hasChecked = false;\n      _storageAvailable = storageAvailable;\n    });\n\n    if (_controller.text.trim().isNotEmpty) {\n      _checkText();\n    }\n    _showMessage('Language changed to ${nextPack.displayName}.');\n  }\n\n  void _onTextChanged(String value) {",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "      await _preferences.savePersonalWords(_engine.personalDictionary);",
    "      await _preferences.savePersonalWords(\n        _engine.personalDictionary,\n        languageId: _languagePack.id,\n      );",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "        initialWords: _engine.personalDictionary,\n        initialSuggestionLimit: _suggestionLimit,",
    "        initialWords: _engine.personalDictionary,\n        initialSuggestionLimit: _suggestionLimit,\n        languagePack: _languagePack,",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "      await _preferences.savePersonalWords(words);",
    "      await _preferences.savePersonalWords(\n        words,\n        languageId: _languagePack.id,\n      );",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "      applicationVersion: '1.2.0',",
    "      applicationVersion: '1.3.0',",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "          'A privacy-first open-source spelling utility with local checking, persistent personal vocabulary, inline issue highlighting, keyboard issue navigation, replace-all, and undo-friendly corrections.',",
    "          'A privacy-first open-source spelling utility with explicit language packs, Unicode-aware tokenization, local checking, persistent per-language vocabulary, inline issue highlighting, keyboard navigation, replace-all, and undo-friendly corrections.',",
)

# Feed language controls into the editor panel.
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "                    statistics: _statistics,\n                    suggestionLimit: _suggestionLimit,\n                    preferencesLoaded: _preferencesLoaded,",
    "                    statistics: _statistics,\n                    suggestionLimit: _suggestionLimit,\n                    languagePack: _languagePack,\n                    languagePacks: SpellLanguageRegistry.builtIns,\n                    preferencesLoaded: _preferencesLoaded,",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "                    onChanged: _onTextChanged,\n                    onCheck: () => _checkText(),",
    "                    onChanged: _onTextChanged,\n                    onLanguageChanged: _changeLanguage,\n                    onCheck: () => _checkText(),",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "    required this.statistics,\n    required this.suggestionLimit,\n    required this.preferencesLoaded,",
    "    required this.statistics,\n    required this.suggestionLimit,\n    required this.languagePack,\n    required this.languagePacks,\n    required this.preferencesLoaded,",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "    required this.onChanged,\n    required this.onCheck,",
    "    required this.onChanged,\n    required this.onLanguageChanged,\n    required this.onCheck,",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "  final TextStatistics statistics;\n  final int suggestionLimit;\n  final bool preferencesLoaded;",
    "  final TextStatistics statistics;\n  final int suggestionLimit;\n  final SpellLanguagePack languagePack;\n  final List<SpellLanguagePack> languagePacks;\n  final bool preferencesLoaded;",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "  final ValueChanged<String> onChanged;\n  final VoidCallback onCheck;",
    "  final ValueChanged<String> onChanged;\n  final ValueChanged<String?> onLanguageChanged;\n  final VoidCallback onCheck;",
)
replace_once(
    'lib/features/editor/spell_checker_page.dart',
    "            if (!storageAvailable) ...<Widget>[\n              const SizedBox(height: 10),\n              const _StorageWarning(),\n            ],\n            const SizedBox(height: 12),\n            Expanded(",
    "            if (!storageAvailable) ...<Widget>[\n              const SizedBox(height: 10),\n              const _StorageWarning(),\n            ],\n            const SizedBox(height: 10),\n            Row(\n              children: <Widget>[\n                const Icon(Icons.language, size: 20),\n                const SizedBox(width: 8),\n                Expanded(\n                  child: DropdownButton<String>(\n                    key: const ValueKey<String>('language-selector'),\n                    value: languagePack.id,\n                    isExpanded: true,\n                    items: languagePacks\n                        .map(\n                          (SpellLanguagePack pack) => DropdownMenuItem<String>(\n                            value: pack.id,\n                            child: Text(pack.displayName),\n                          ),\n                        )\n                        .toList(growable: false),\n                    onChanged: preferencesLoaded ? onLanguageChanged : null,\n                  ),\n                ),\n              ],\n            ),\n            const SizedBox(height: 12),\n            Expanded(",
)

# Release version.
replace_once('pubspec.yaml', 'version: 1.2.0+3', 'version: 1.3.0+4')

# Web metadata remains local-first but now mentions explicit language packs.
replace_once(
    'web/index.html',
    'inline issue review, persistent personal vocabulary, and undo-friendly corrections.',
    'explicit English language packs, Unicode-aware local checking, inline issue review, persistent personal vocabulary, and undo-friendly corrections.',
)
replace_once(
    'web/manifest.json',
    'local inline issue review, personal vocabulary, and correction workflows.',
    'explicit English language packs, Unicode-aware local checking, personal vocabulary, and correction workflows.',
)

# Sanity guards before committing.
require('lib/features/editor/spell_checker_page.dart', "key: const ValueKey<String>('language-selector')")
require('lib/features/editor/dictionary_manager_dialog.dart', 'encodeForLanguage')
require('lib/storage/dictionary_preferences.dart', '_legacyPersonalWordsKey, normalized')
require('lib/spell_checker.dart', "export 'core/spell_language_pack.dart';")
require('pubspec.yaml', 'version: 1.3.0+4')

print('V1.3 application integration applied successfully.')
