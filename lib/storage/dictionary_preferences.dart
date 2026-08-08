import 'package:shared_preferences/shared_preferences.dart';

import '../core/personal_dictionary_codec.dart';

class DictionaryPreferences {
  DictionaryPreferences({SharedPreferences? preferences}) : _preferences = preferences;

  static const String _personalWordsKey = 'spellchecker.personal_words.v1';
  static const String _suggestionLimitKey = 'spellchecker.suggestion_limit.v1';
  static const int defaultSuggestionLimit = 5;
  static const int minSuggestionLimit = 1;
  static const int maxSuggestionLimit = 10;

  SharedPreferences? _preferences;

  Future<SharedPreferences> get _instance async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<Set<String>> loadPersonalWords() async {
    final preferences = await _instance;
    final stored = preferences.getStringList(_personalWordsKey) ?? const <String>[];
    return stored
        .map(PersonalDictionaryCodec.normalizeWord)
        .where((String word) => word.isNotEmpty)
        .toSet();
  }

  Future<void> savePersonalWords(Iterable<String> words) async {
    final preferences = await _instance;
    final normalized = words
        .map(PersonalDictionaryCodec.normalizeWord)
        .where((String word) => word.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    await preferences.setStringList(_personalWordsKey, normalized);
  }

  Future<int> loadSuggestionLimit() async {
    final preferences = await _instance;
    return normalizeSuggestionLimit(preferences.getInt(_suggestionLimitKey));
  }

  Future<void> saveSuggestionLimit(int value) async {
    final preferences = await _instance;
    await preferences.setInt(_suggestionLimitKey, normalizeSuggestionLimit(value));
  }

  Future<void> clearPersonalWords() async {
    final preferences = await _instance;
    await preferences.remove(_personalWordsKey);
  }

  static int normalizeSuggestionLimit(int? value) {
    if (value == null) {
      return defaultSuggestionLimit;
    }
    return value.clamp(minSuggestionLimit, maxSuggestionLimit);
  }
}
