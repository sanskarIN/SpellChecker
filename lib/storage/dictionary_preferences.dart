import 'package:shared_preferences/shared_preferences.dart';

import '../core/personal_dictionary_codec.dart';
import '../core/spell_language_pack.dart';

class DictionaryPreferences {
  DictionaryPreferences({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _legacyPersonalWordsKey = 'spellchecker.personal_words.v1';
  static const String _personalWordsKeyPrefix = 'spellchecker.personal_words.v2.';
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
    await preferences.setString(_languageIdKey, pack.id);
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
        await preferences.setStringList(key, migrated);
        await preferences.setStringList(_legacyPersonalWordsKey, migrated);
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

    await preferences.setStringList(_personalWordsKey(pack.id), normalized);
    if (pack.id == SpellLanguageRegistry.defaultPack.id) {
      await preferences.setStringList(_legacyPersonalWordsKey, normalized);
    }
  }

  Future<int> loadSuggestionLimit() async {
    final preferences = await _instance;
    return normalizeSuggestionLimit(preferences.getInt(_suggestionLimitKey));
  }

  Future<void> saveSuggestionLimit(int value) async {
    final preferences = await _instance;
    await preferences.setInt(
      _suggestionLimitKey,
      normalizeSuggestionLimit(value),
    );
  }

  Future<void> clearPersonalWords({String? languageId}) async {
    final preferences = await _instance;
    final pack = _packFor(languageId);
    await preferences.remove(_personalWordsKey(pack.id));
    if (pack.id == SpellLanguageRegistry.defaultPack.id) {
      await preferences.remove(_legacyPersonalWordsKey);
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
    final normalized = words
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

  static String _personalWordsKey(String languageId) {
    return '$_personalWordsKeyPrefix$languageId';
  }
}
