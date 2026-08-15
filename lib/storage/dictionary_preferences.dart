import 'package:shared_preferences/shared_preferences.dart';

import '../core/personal_dictionary_codec.dart';
import '../core/spell_language_pack.dart';

class DictionaryPreferences {
  DictionaryPreferences({SharedPreferences? preferences})
    : _preferences = preferences;

  static const String _legacyPersonalWordsKey =
      'spellchecker.personal_words.v1';
  static const String _personalWordsKeyPrefix =
      'spellchecker.personal_words.v2.';
  static const String _writingRuleIdsKeyPrefix =
      'spellchecker.writing_rule_ids.v1.';
  static const String _languageIdKey = 'spellchecker.language_id.v1';
  static const String _suggestionLimitKey = 'spellchecker.suggestion_limit.v1';

  static const int defaultSuggestionLimit = 5;
  static const int minSuggestionLimit = 1;
  static const int maxSuggestionLimit = 10;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _instance async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<String> loadLanguageId() async {
    final preferences = await _instance;
    final stored = preferences.getString(_languageIdKey);
    if (stored == null || !SpellLanguageRegistry.contains(stored)) {
      return SpellLanguageRegistry.defaultPack.id;
    }
    return stored;
  }

  Future<void> saveLanguageId(String languageId) async {
    final preferences = await _instance;
    final pack = SpellLanguageRegistry.byId(languageId);
    await _requireSuccessfulWrite(
      preferences.setString(_languageIdKey, pack.id),
      'save the selected language',
    );
  }

  Future<Set<String>> loadPersonalWords({String? languageId}) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    final key = _personalWordsKey(pack.id);

    var stored = preferences.getStringList(key);
    if (stored == null && pack.id == SpellLanguageRegistry.defaultPack.id) {
      final legacy = preferences.getStringList(_legacyPersonalWordsKey);
      if (legacy != null) {
        final migrated = _normalizeWords(legacy, pack);
        await _requireSuccessfulWrite(
          preferences.setStringList(key, migrated),
          'migrate personal dictionary words',
        );
        await _requireSuccessfulWrite(
          preferences.setStringList(_legacyPersonalWordsKey, migrated),
          'synchronize legacy personal dictionary words',
        );
        stored = migrated;
      }
    }

    return _normalizeWords(stored ?? const <String>[], pack).toSet();
  }

  Future<void> savePersonalWords(
    Iterable<String> words, {
    String? languageId,
  }) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    final normalized = _normalizeWords(words, pack);

    await _requireSuccessfulWrite(
      preferences.setStringList(_personalWordsKey(pack.id), normalized),
      'save personal dictionary words for ${pack.id}',
    );
    if (pack.id == SpellLanguageRegistry.defaultPack.id) {
      await _requireSuccessfulWrite(
        preferences.setStringList(_legacyPersonalWordsKey, normalized),
        'synchronize legacy personal dictionary words',
      );
    }
  }

  /// Returns the stored rule ids for one language, or `null` when the user has
  /// never configured writing rules for that language.
  ///
  /// An empty set is meaningful and represents an explicit "disable all"
  /// choice, so callers must not collapse it into the default rule set.
  Future<Set<String>?> loadWritingRuleIds({String? languageId}) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    final stored = preferences.getStringList(_writingRuleIdsKey(pack.id));
    if (stored == null) {
      return null;
    }
    return _normalizeRuleIds(stored).toSet();
  }

  Future<void> saveWritingRuleIds(
    Iterable<String> ruleIds, {
    String? languageId,
  }) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    await _requireSuccessfulWrite(
      preferences.setStringList(
        _writingRuleIdsKey(pack.id),
        _normalizeRuleIds(ruleIds),
      ),
      'save writing-rule choices for ${pack.id}',
    );
  }

  Future<void> clearWritingRuleIds({String? languageId}) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    await _requireSuccessfulWrite(
      preferences.remove(_writingRuleIdsKey(pack.id)),
      'clear writing-rule choices for ${pack.id}',
    );
  }

  Future<int> loadSuggestionLimit() async {
    final preferences = await _instance;
    return normalizeSuggestionLimit(preferences.getInt(_suggestionLimitKey));
  }

  Future<void> saveSuggestionLimit(int value) async {
    final preferences = await _instance;
    await _requireSuccessfulWrite(
      preferences.setInt(_suggestionLimitKey, normalizeSuggestionLimit(value)),
      'save the suggestion limit',
    );
  }

  Future<void> clearPersonalWords({String? languageId}) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    await _requireSuccessfulWrite(
      preferences.remove(_personalWordsKey(pack.id)),
      'clear personal dictionary words for ${pack.id}',
    );
    if (pack.id == SpellLanguageRegistry.defaultPack.id) {
      await _requireSuccessfulWrite(
        preferences.remove(_legacyPersonalWordsKey),
        'clear legacy personal dictionary words',
      );
    }
  }

  static int normalizeSuggestionLimit(int? value) {
    if (value == null) {
      return defaultSuggestionLimit;
    }
    if (value < minSuggestionLimit) {
      return minSuggestionLimit;
    }
    if (value > maxSuggestionLimit) {
      return maxSuggestionLimit;
    }
    return value;
  }

  static SpellLanguagePack _packFor(String? languageId) {
    if (languageId == null) {
      return SpellLanguageRegistry.defaultPack;
    }
    return SpellLanguageRegistry.byId(languageId);
  }

  static List<String> _normalizeWords(
    Iterable<String> words,
    SpellLanguagePack pack,
  ) {
    final normalized =
        words
            .map(
              (String word) => PersonalDictionaryCodec.normalizeWord(
                word,
                languagePack: pack,
              ),
            )
            .where((String word) => word.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return normalized;
  }

  static List<String> _normalizeRuleIds(Iterable<String> ruleIds) {
    final normalized =
        ruleIds
            .map((String ruleId) => ruleId.trim())
            .where((String ruleId) => ruleId.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return normalized;
  }

  static String _personalWordsKey(String languageId) {
    return '$_personalWordsKeyPrefix$languageId';
  }

  static String _writingRuleIdsKey(String languageId) {
    return '$_writingRuleIdsKeyPrefix$languageId';
  }

  static Future<void> _requireSuccessfulWrite(
    Future<bool> operation,
    String action,
  ) async {
    if (!await operation) {
      throw StateError('Local preference storage failed to $action.');
    }
  }
}
