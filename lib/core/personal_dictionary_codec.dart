import 'dart:convert';

import 'spell_language_pack.dart';

class PersonalDictionaryDocument {
  PersonalDictionaryDocument({
    required this.version,
    required this.languageId,
    required Iterable<String> words,
  }) : words = Set<String>.unmodifiable(words);

  final int version;
  final String languageId;
  final Set<String> words;
}

class PersonalDictionaryCodec {
  const PersonalDictionaryCodec._();

  static const int legacyVersion = 1;
  static const int currentVersion = 2;

  static String encode(Iterable<String> words) {
    final normalized = _normalizeWords(
      words,
      languagePack: SpellLanguageRegistry.defaultPack,
    );
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(<String, Object>{'version': legacyVersion, 'words': normalized});
  }

  static String encodeForLanguage(
    Iterable<String> words, {
    required SpellLanguagePack languagePack,
  }) {
    final normalized = _normalizeWords(words, languagePack: languagePack);
    return const JsonEncoder.withIndent('  ').convert(<String, Object>{
      'version': currentVersion,
      'language': languagePack.id,
      'words': normalized,
    });
  }

  static Set<String> decode(String source, {SpellLanguagePack? languagePack}) {
    return decodeDocument(source, languagePack: languagePack).words;
  }

  static PersonalDictionaryDocument decodeDocument(
    String source, {
    SpellLanguagePack? languagePack,
  }) {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      final pack = languagePack ?? SpellLanguageRegistry.defaultPack;
      return PersonalDictionaryDocument(
        version: currentVersion,
        languageId: pack.id,
        words: const <String>{},
      );
    }

    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) {
      final pack = languagePack ?? SpellLanguageRegistry.defaultPack;
      return PersonalDictionaryDocument(
        version: legacyVersion,
        languageId: pack.id,
        words: _decodeIterable(
          trimmed.split(RegExp(r'[\r\n,]+')),
          languagePack: pack,
        ),
      );
    }

    final dynamic decoded;
    try {
      decoded = jsonDecode(trimmed);
    } on FormatException catch (error) {
      throw FormatException(
        'The dictionary data is not valid JSON: ${error.message}',
      );
    }

    if (decoded is List<dynamic>) {
      final pack = languagePack ?? SpellLanguageRegistry.defaultPack;
      return PersonalDictionaryDocument(
        version: legacyVersion,
        languageId: pack.id,
        words: _decodeIterable(decoded, languagePack: pack),
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Dictionary data must be a JSON object, JSON array, or plain word list.',
      );
    }

    return _decodeMap(decoded, fallbackPack: languagePack);
  }

  static String normalizeWord(
    Object? value, {
    SpellLanguagePack? languagePack,
  }) {
    if (value is! String) {
      return '';
    }
    final pack = languagePack ?? SpellLanguageRegistry.defaultPack;
    final normalized = pack.normalizeWord(value);
    return pack.isValidWord(normalized) ? normalized : '';
  }

  static PersonalDictionaryDocument _decodeMap(
    Map<String, dynamic> map, {
    SpellLanguagePack? fallbackPack,
  }) {
    final rawVersion = map['version'];
    final version = rawVersion is int ? rawVersion : legacyVersion;
    if (version != legacyVersion && version != currentVersion) {
      throw FormatException('Unsupported dictionary format version: $version.');
    }

    final rawWords = map['words'];
    if (rawWords is! List<dynamic>) {
      throw const FormatException(
        'Dictionary JSON must contain a "words" array.',
      );
    }

    if (version == legacyVersion) {
      final pack = fallbackPack ?? SpellLanguageRegistry.defaultPack;
      return PersonalDictionaryDocument(
        version: legacyVersion,
        languageId: pack.id,
        words: _decodeIterable(rawWords, languagePack: pack),
      );
    }

    final rawLanguage = map['language'];
    if (rawLanguage is! String || rawLanguage.trim().isEmpty) {
      throw const FormatException(
        'Version 2 personal dictionaries must contain a language identifier.',
      );
    }

    final languageId = rawLanguage.trim();
    if (!SpellLanguageRegistry.contains(languageId)) {
      throw FormatException('Unsupported dictionary language: $languageId.');
    }
    final documentPack = SpellLanguageRegistry.byId(languageId);
    return PersonalDictionaryDocument(
      version: currentVersion,
      languageId: languageId,
      words: _decodeIterable(rawWords, languagePack: documentPack),
    );
  }

  static Set<String> _decodeIterable(
    Iterable<dynamic> values, {
    required SpellLanguagePack languagePack,
  }) {
    final result = <String>{};
    final invalid = <Object?>[];

    for (final value in values) {
      final normalized = normalizeWord(value, languagePack: languagePack);
      if (normalized.isEmpty) {
        if (value is String && value.trim().isEmpty) {
          continue;
        }
        invalid.add(value);
        continue;
      }
      result.add(normalized);
    }

    if (invalid.isNotEmpty) {
      throw FormatException(
        'Dictionary contains invalid word entries: ${invalid.take(3).join(', ')}.',
      );
    }
    return result;
  }

  static List<String> _normalizeWords(
    Iterable<String> words, {
    required SpellLanguagePack languagePack,
  }) {
    final normalized =
        words
            .map(
              (String word) => normalizeWord(word, languagePack: languagePack),
            )
            .where((String word) => word.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return normalized;
  }
}
