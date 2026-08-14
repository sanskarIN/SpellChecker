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
    r"\p{L}+(?:['’\-‐‑]\p{L}+)*",
    unicode: true,
  );

  static final RegExp _unicodeValidWordPattern = RegExp(
    r"^\p{L}+(?:['\-]\p{L}+)*$",
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
    return word
        .trim()
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('‐', '-')
        .replaceAll('‑', '-');
  }

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
