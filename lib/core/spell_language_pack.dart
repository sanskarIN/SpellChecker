import '../data/english_dictionary.dart';
import '../data/english_dictionary_extension.dart';
import '../data/english_gb_dictionary.dart';
import '../data/english_word_frequencies.dart';

typedef SpellWordNormalizer = String Function(String word);

class SpellLanguagePack {
  SpellLanguagePack({
    required this.id,
    required this.languageCode,
    required this.regionCode,
    required this.displayName,
    required Set<String> dictionary,
    required Map<String, int> wordFrequencies,
    required this.tokenPattern,
    required this.validWordPattern,
    required this.normalizer,
    List<String> recognizedSuffixes = const <String>[],
    this.suggestionSource = 'bundled',
  }) : dictionary = Set<String>.unmodifiable(dictionary),
       wordFrequencies = Map<String, int>.unmodifiable(wordFrequencies),
       recognizedSuffixes = List<String>.unmodifiable(recognizedSuffixes);

  final String id;
  final String languageCode;
  final String regionCode;
  final String displayName;
  final Set<String> dictionary;
  final Map<String, int> wordFrequencies;
  final RegExp tokenPattern;
  final RegExp validWordPattern;
  final SpellWordNormalizer normalizer;
  final List<String> recognizedSuffixes;

  /// Human-readable source label carried into detailed suggestion metadata.
  final String suggestionSource;

  String normalizeWord(String word) => normalizer(word);

  Iterable<RegExpMatch> tokenize(String text) => tokenPattern.allMatches(text);

  bool isValidWord(String word) {
    final normalized = normalizeWord(word);
    return normalized.isNotEmpty && validWordPattern.hasMatch(normalized);
  }

  int maximumSuggestionDistance(int wordLength) {
    if (wordLength <= 4) {
      return 1;
    }
    if (wordLength <= 8) {
      return 2;
    }
    return 3;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SpellLanguagePack && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class SpellLanguageRegistry {
  const SpellLanguageRegistry._();

  static final RegExp _unicodeTokenPattern = RegExp(
    r"(?:\p{L}\p{M}*)+(?:['’\-‐‑](?:\p{L}\p{M}*)+)*",
    unicode: true,
  );

  static final RegExp _unicodeValidWordPattern = RegExp(
    r"^(?:\p{L}\p{M}*)+(?:['\-](?:\p{L}\p{M}*)+)*$",
    unicode: true,
  );

  static const Set<String> _unicodeLoanwords = <String>{
    'café',
    'façade',
    'jalapeño',
    'naïve',
    'résumé',
  };

  static const Set<String> _usVariantWords = <String>{
    'behavior',
    'catalog',
    'defense',
    'favor',
    'favorite',
    'honor',
    'labor',
    'neighbor',
    'neighborhood',
    'organize',
    'realize',
    'recognize',
    'theater',
    'traveler',
    'traveling',
  };

  static final SpellLanguagePack englishUs = SpellLanguagePack(
    id: 'en-US',
    languageCode: 'en',
    regionCode: 'US',
    displayName: 'English (US)',
    dictionary: _buildEnglishUsDictionary(),
    wordFrequencies: EnglishWordFrequencies.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeEnglishWord,
    recognizedSuffixes: _englishSuffixes,
    suggestionSource: 'bundled English (US)',
  );

  static final SpellLanguagePack englishGb = SpellLanguagePack(
    id: 'en-GB',
    languageCode: 'en',
    regionCode: 'GB',
    displayName: 'English (UK)',
    dictionary: _buildEnglishGbDictionary(),
    wordFrequencies: <String, int>{
      ...EnglishWordFrequencies.ranks,
      'colour': 210,
      'centre': 220,
      'organisation': 260,
      'favourite': 270,
      'neighbour': 280,
      'travelling': 290,
      'theatre': 300,
    },
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeEnglishWord,
    recognizedSuffixes: _englishSuffixes,
    suggestionSource: 'bundled English (UK)',
  );

  static List<SpellLanguagePack> get builtIns => <SpellLanguagePack>[
    englishUs,
    englishGb,
  ];

  static SpellLanguagePack get defaultPack => englishUs;

  static SpellLanguagePack byId(String? id) {
    if (id == null || id.isEmpty) {
      return defaultPack;
    }
    for (final pack in builtIns) {
      if (pack.id == id) {
        return pack;
      }
    }
    return defaultPack;
  }

  static bool contains(String id) => builtIns.any((pack) => pack.id == id);

  static Set<String> _buildEnglishUsDictionary() {
    final words = <String>{
      ...EnglishDictionary.words,
      ...EnglishDictionaryExtension.words,
      ..._unicodeLoanwords,
      ..._usVariantWords,
    };
    words.removeAll(EnglishGbDictionary.words);
    words.addAll(_usVariantWords);
    return words;
  }

  static Set<String> _buildEnglishGbDictionary() {
    final words = <String>{
      ...EnglishDictionary.words,
      ...EnglishDictionaryExtension.words,
      ..._unicodeLoanwords,
    };
    words
      ..removeAll(EnglishGbDictionary.excludedUsVariants)
      ..addAll(EnglishGbDictionary.words);
    return words;
  }

  static String _normalizeEnglishWord(String word) {
    var normalized = word
        .trim()
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('‐', '-')
        .replaceAll('‑', '-');
    for (final entry in _commonLatinCompositions.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized;
  }

  static const Map<String, String> _commonLatinCompositions = <String, String>{
    'a\u0300': 'à',
    'a\u0301': 'á',
    'a\u0302': 'â',
    'a\u0303': 'ã',
    'a\u0308': 'ä',
    'a\u030a': 'å',
    'c\u0327': 'ç',
    'e\u0300': 'è',
    'e\u0301': 'é',
    'e\u0302': 'ê',
    'e\u0308': 'ë',
    'i\u0300': 'ì',
    'i\u0301': 'í',
    'i\u0302': 'î',
    'i\u0308': 'ï',
    'n\u0303': 'ñ',
    'o\u0300': 'ò',
    'o\u0301': 'ó',
    'o\u0302': 'ô',
    'o\u0303': 'õ',
    'o\u0308': 'ö',
    'u\u0300': 'ù',
    'u\u0301': 'ú',
    'u\u0302': 'û',
    'u\u0308': 'ü',
    'y\u0301': 'ý',
    'y\u0308': 'ÿ',
  };

  static const List<String> _englishSuffixes = <String>[
    "n't",
    "'re",
    "'ve",
    "'ll",
    "'d",
    "'m",
    "'s",
  ];
}
