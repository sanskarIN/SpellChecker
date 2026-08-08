from pathlib import Path

page_path = Path('lib/features/editor/spell_checker_page.dart')
text = page_path.read_text()

old = """    final nextRuleIds = _effectiveWritingRuleIds(
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
"""

new = """    if (result.resetRulePreferences) {
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
"""

count = text.count(old)
if count != 1:
    raise RuntimeError(
        f'expected exactly one V2.1 writing insights persistence block, found {count}'
    )
text = text.replace(old, new, 1)

about_old = "applicationVersion: '2.1.0'"
if text.count(about_old) != 1:
    raise RuntimeError('expected exactly one V2.1 About version')
text = text.replace(about_old, "applicationVersion: '2.2.0'", 1)

about_description_old = (
    'A privacy-first open-source writing utility with explicit language packs, '
    'Unicode-aware local spelling, optional local writing-rule plugins, persistent '
    'per-language vocabulary and rule choices, batch-safe writing fixes, inline '
    'issue review, keyboard workflows, and undo-friendly corrections.'
)
about_description_new = (
    'A privacy-first open-source writing utility with explicit language packs, '
    'Unicode-aware local spelling, categorized local writing rules, temporary '
    'review search and filters, per-language rule choices with reset-to-defaults, '
    'batch-safe writing fixes, keyboard workflows, and undo-friendly corrections.'
)
if text.count(about_description_old) != 1:
    raise RuntimeError('expected exactly one V2.1 About description')
text = text.replace(about_description_old, about_description_new, 1)

page_path.write_text(text)

pubspec_path = Path('pubspec.yaml')
pubspec = pubspec_path.read_text()
if pubspec.count('version: 2.1.0+6') != 1:
    raise RuntimeError('expected V2.1 package version before V2.2 bump')
pubspec_path.write_text(pubspec.replace('version: 2.1.0+6', 'version: 2.2.0+7', 1))

print('V2.2 page integration and version update applied successfully.')
