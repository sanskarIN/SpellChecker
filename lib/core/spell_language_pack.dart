import '../data/bengali_dictionary.dart';
import '../data/english_dictionary.dart';
import '../data/english_dictionary_extension.dart';
import '../data/english_gb_dictionary.dart';
import '../data/english_word_frequencies.dart';
import '../data/french_dictionary.dart';
import '../data/german_dictionary.dart';
import '../data/hindi_dictionary.dart';
import '../data/italian_dictionary.dart';
import '../data/marathi_dictionary.dart';
import '../data/portuguese_br_dictionary.dart';
import '../data/russian_dictionary.dart';
import '../data/spanish_dictionary.dart';
import '../data/tamil_dictionary.dart';
import '../data/telugu_dictionary.dart';

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
    List<String> recognizedPrefixes = const <String>[],
    List<String> recognizedSuffixes = const <String>[],
    this.suggestionSource = 'bundled',
  }) : dictionary = Set<String>.unmodifiable(dictionary),
       wordFrequencies = Map<String, int>.unmodifiable(wordFrequencies),
       recognizedPrefixes = List<String>.unmodifiable(recognizedPrefixes),
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
  final List<String> recognizedPrefixes;
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
    r"(?:\p{L}\p{M}*)(?:[\u200C\u200D]?(?:\p{L}\p{M}*))*(?:['’\-‐‑](?:\p{L}\p{M}*)(?:[\u200C\u200D]?(?:\p{L}\p{M}*))*)*",
    unicode: true,
  );

  static final RegExp _unicodeValidWordPattern = RegExp(
    r"^(?:\p{L}\p{M}*)(?:[\u200C\u200D]?(?:\p{L}\p{M}*))*(?:['\-](?:\p{L}\p{M}*)(?:[\u200C\u200D]?(?:\p{L}\p{M}*))*)*$",
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
    normalizer: _normalizeUnicodeWord,
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
    normalizer: _normalizeUnicodeWord,
    recognizedSuffixes: _englishSuffixes,
    suggestionSource: 'bundled English (UK)',
  );

  static final SpellLanguagePack hindiIndia = SpellLanguagePack(
    id: 'hi-IN',
    languageCode: 'hi',
    regionCode: 'IN',
    displayName: 'Hindi (India)',
    dictionary: HindiDictionary.words,
    wordFrequencies: HindiDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Hindi (India)',
  );

  static final SpellLanguagePack spanishSpain = SpellLanguagePack(
    id: 'es-ES',
    languageCode: 'es',
    regionCode: 'ES',
    displayName: 'Spanish (Spain)',
    dictionary: SpanishDictionary.words,
    wordFrequencies: SpanishDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Spanish (Spain)',
  );

  static final SpellLanguagePack frenchFrance = SpellLanguagePack(
    id: 'fr-FR',
    languageCode: 'fr',
    regionCode: 'FR',
    displayName: 'French (France)',
    dictionary: FrenchDictionary.words,
    wordFrequencies: FrenchDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    recognizedPrefixes: _frenchPrefixes,
    suggestionSource: 'bundled French (France)',
  );

  static final SpellLanguagePack germanGermany = SpellLanguagePack(
    id: 'de-DE',
    languageCode: 'de',
    regionCode: 'DE',
    displayName: 'German (Germany)',
    dictionary: GermanDictionary.words,
    wordFrequencies: GermanDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled German (Germany)',
  );

  static final SpellLanguagePack portugueseBrazil = SpellLanguagePack(
    id: 'pt-BR',
    languageCode: 'pt',
    regionCode: 'BR',
    displayName: 'Portuguese (Brazil)',
    dictionary: PortugueseBrDictionary.words,
    wordFrequencies: PortugueseBrDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Portuguese (Brazil)',
  );

  static final SpellLanguagePack italianItaly = SpellLanguagePack(
    id: 'it-IT',
    languageCode: 'it',
    regionCode: 'IT',
    displayName: 'Italian (Italy)',
    dictionary: ItalianDictionary.words,
    wordFrequencies: ItalianDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    recognizedPrefixes: _italianPrefixes,
    suggestionSource: 'bundled Italian (Italy)',
  );

  static final SpellLanguagePack bengaliIndia = SpellLanguagePack(
    id: 'bn-IN',
    languageCode: 'bn',
    regionCode: 'IN',
    displayName: 'Bengali (India)',
    dictionary: BengaliDictionary.words,
    wordFrequencies: BengaliDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Bengali (India)',
  );

  static final SpellLanguagePack marathiIndia = SpellLanguagePack(
    id: 'mr-IN',
    languageCode: 'mr',
    regionCode: 'IN',
    displayName: 'Marathi (India)',
    dictionary: MarathiDictionary.words,
    wordFrequencies: MarathiDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Marathi (India)',
  );

  static final SpellLanguagePack tamilIndia = SpellLanguagePack(
    id: 'ta-IN',
    languageCode: 'ta',
    regionCode: 'IN',
    displayName: 'Tamil (India)',
    dictionary: TamilDictionary.words,
    wordFrequencies: TamilDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Tamil (India)',
  );

  static final SpellLanguagePack teluguIndia = SpellLanguagePack(
    id: 'te-IN',
    languageCode: 'te',
    regionCode: 'IN',
    displayName: 'Telugu (India)',
    dictionary: TeluguDictionary.words,
    wordFrequencies: TeluguDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Telugu (India)',
  );

  static final SpellLanguagePack russianRussia = SpellLanguagePack(
    id: 'ru-RU',
    languageCode: 'ru',
    regionCode: 'RU',
    displayName: 'Russian (Russia)',
    dictionary: RussianDictionary.words,
    wordFrequencies: RussianDictionary.ranks,
    tokenPattern: _unicodeTokenPattern,
    validWordPattern: _unicodeValidWordPattern,
    normalizer: _normalizeUnicodeWord,
    suggestionSource: 'bundled Russian (Russia)',
  );

  static List<SpellLanguagePack> get builtIns => <SpellLanguagePack>[
    englishUs,
    englishGb,
    hindiIndia,
    spanishSpain,
    frenchFrance,
    germanGermany,
    portugueseBrazil,
    italianItaly,
    bengaliIndia,
    marathiIndia,
    tamilIndia,
    teluguIndia,
    russianRussia,
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

  static String _normalizeUnicodeWord(String word) {
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

  static const List<String> _frenchPrefixes = <String>[
    "qu'",
    "l'",
    "d'",
    "j'",
    "n'",
    "s'",
    "c'",
    "m'",
    "t'",
  ];

  static const List<String> _italianPrefixes = <String>[
    "nell'",
    "dall'",
    "all'",
    "dell'",
    "sull'",
    "un'",
    "l'",
    "d'",
  ];
}
