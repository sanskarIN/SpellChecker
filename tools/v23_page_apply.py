from pathlib import Path


def replace_once(text: str, old: str, new: str, label: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f'{label}: expected exactly one marker, found {count}')
    return text.replace(old, new, 1)


page_path = Path('lib/features/editor/spell_checker_page.dart')
page = page_path.read_text()

page = replace_once(
    page,
    "import '../../core/spell_checker_engine.dart';\n",
    "import '../../core/settings_transfer_codec.dart';\n"
    "import '../../core/spell_checker_engine.dart';\n",
    'settings codec import',
)
page = replace_once(
    page,
    "import '../../storage/dictionary_preferences.dart';\n",
    "import '../../storage/dictionary_preferences.dart';\n"
    "import '../../storage/settings_transfer_service.dart';\n",
    'settings service import',
)
page = replace_once(
    page,
    "import 'writing_insights_dialog.dart';\n",
    "import 'settings_transfer_dialog.dart';\n"
    "import 'writing_insights_dialog.dart';\n",
    'settings dialog import',
)
page = replace_once(
    page,
    "  late final DictionaryPreferences _preferences;\n",
    "  late final DictionaryPreferences _preferences;\n"
    "  late final SettingsTransferService _settingsTransferService;\n",
    'settings service field',
)
page = replace_once(
    page,
    "    _preferences = widget.preferences ?? DictionaryPreferences();\n"
    "    _engine = SpellCheckerEngine(languagePack: _languagePack);\n",
    "    _preferences = widget.preferences ?? DictionaryPreferences();\n"
    "    _settingsTransferService = SettingsTransferService(_preferences);\n"
    "    _engine = SpellCheckerEngine(languagePack: _languagePack);\n",
    'settings service initialization',
)

portable_methods = r'''  Future<void> _showPortableSettings() async {
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
      builder: (BuildContext context) => SettingsTransferDialog(
        initialDocument: currentDocument,
      ),
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
      _storageAvailable = true;
    });

    if (_controller.text.trim().isNotEmpty) {
      _checkText();
    }
    _showMessage(
      'Portable settings imported for ${nextPack.displayName}.',
    );
  }

'''
page = replace_once(
    page,
    "  Future<void> _showWritingInsights() async {\n",
    portable_methods + "  Future<void> _showWritingInsights() async {\n",
    'portable settings methods',
)

app_bar_marker = r'''                IconButton(
                  tooltip: 'Manage personal dictionary',
                  onPressed: _preferencesLoaded ? _showDictionaryManager : null,
                  icon: Badge(
'''
app_bar_replacement = r'''                IconButton(
                  tooltip: 'Portable settings',
                  onPressed: _preferencesLoaded ? _showPortableSettings : null,
                  icon: const Icon(Icons.settings_backup_restore_outlined),
                ),
                IconButton(
                  tooltip: 'Manage personal dictionary',
                  onPressed: _preferencesLoaded ? _showDictionaryManager : null,
                  icon: Badge(
'''
page = replace_once(
    page,
    app_bar_marker,
    app_bar_replacement,
    'portable settings app-bar action',
)
page = replace_once(
    page,
    "      applicationVersion: '2.2.0',\n",
    "      applicationVersion: '2.3.0',\n",
    'about version',
)
page = replace_once(
    page,
    "          'A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, categorized local writing rules, temporary review search and filters, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.',\n",
    "          'A privacy-first open-source writing utility with explicit language packs, Unicode-aware local spelling, categorized local writing rules, temporary review presets/search/filters, portable non-document preferences, per-language rule choices with reset-to-defaults, batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.',\n",
    'about description',
)
page_path.write_text(page)

pubspec_path = Path('pubspec.yaml')
pubspec = pubspec_path.read_text()
pubspec = replace_once(
    pubspec,
    'version: 2.2.0+7\n',
    'version: 2.3.0+8\n',
    'package version',
)
pubspec_path.write_text(pubspec)

print('V2.3 page and release metadata integration applied successfully.')
