import '../core/settings_transfer_codec.dart';
import '../core/spell_language_pack.dart';
import 'dictionary_preferences.dart';

/// Bridges the pure portable-settings document with local durable preferences.
///
/// This service never reads or writes editor text, personal vocabulary,
/// ignored words, findings, or correction history.
class SettingsTransferService {
  const SettingsTransferService(this.preferences);

  final DictionaryPreferences preferences;

  Future<SpellCheckerSettingsDocument> exportDocument() async {
    final languageId = await preferences.loadLanguageId();
    final suggestionLimit = await preferences.loadSuggestionLimit();
    final overrides = <String, Iterable<String>>{};

    for (final pack in SpellLanguageRegistry.builtIns) {
      final ruleIds = await preferences.loadWritingRuleIds(languageId: pack.id);
      if (ruleIds != null) {
        overrides[pack.id] = ruleIds;
      }
    }

    return SpellCheckerSettingsDocument(
      languageId: languageId,
      suggestionLimit: suggestionLimit,
      writingRuleOverrides: overrides,
    );
  }

  /// Replaces all portable settings and restores the previous durable document
  /// on a best-effort basis if any write fails.
  Future<void> importDocument(SpellCheckerSettingsDocument document) async {
    final previous = await exportDocument();
    try {
      await _writeDocument(document);
    } catch (_) {
      try {
        await _writeDocument(previous);
      } catch (_) {
        // Preserve the original import failure. SharedPreferences does not offer
        // transactions, so rollback is intentionally best effort.
      }
      rethrow;
    }
  }

  Future<void> _writeDocument(SpellCheckerSettingsDocument document) async {
    await preferences.saveLanguageId(document.languageId);
    await preferences.saveSuggestionLimit(document.suggestionLimit);

    for (final pack in SpellLanguageRegistry.builtIns) {
      final ruleIds = document.writingRuleIdsFor(pack.id);
      if (ruleIds == null) {
        await preferences.clearWritingRuleIds(languageId: pack.id);
      } else {
        await preferences.saveWritingRuleIds(ruleIds, languageId: pack.id);
      }
    }
  }
}
