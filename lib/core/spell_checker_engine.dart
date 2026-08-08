import '../data/english_dictionary.dart';
import '../data/english_dictionary_extension.dart';
import '../data/english_word_frequencies.dart';
import 'edit_distance.dart';
import 'spell_issue.dart';

class SpellCheckerEngine {
  SpellCheckerEngine({
    Set<String>? dictionary,
    Map<String, int>? wordFrequencies,
  })  : _baseDictionary = Set<String>.unmodifiable(
          (dictionary ?? _defaultWords).map(_normalize),
        ),
        _wordFrequencies = Map<String, int>.unmodifiable(
          wordFrequencies ?? EnglishWordFrequencies.ranks,
        );

  static final Set<String> _defaultWords = <String>{
    ...EnglishDictionary.words,
    ...EnglishDictionaryExtension.words,
  };

  final Set<String> _baseDictionary;
  final Map<String, int> _wordFrequencies;
  final Set<String> _personalDictionary = <String>{};
  final Set<String> _ignoredWords = <String>{};
  final Map<String, List<String>> _suggestionCache = <String, List<String>>{};

  Set<String> get personalDictionary =>
      Set<String>.unmodifiable(_personalDictionary);
  Set<String> get ignoredWords => Set<String>.unmodifiable(_ignoredWords);

  List<SpellIssue> check(String text, {int suggestionLimit = 5}) {
    final issues = <SpellIssue>[];
    final matches = RegExp(r"[A-Za-z]+(?:['’-][A-Za-z]+)*").allMatches(text);

    for (final match in matches) {
      final word = match.group(0)!;
      if (isCorrect(word)) {
        continue;
      }

      issues.add(
        SpellIssue(
          word: word,
          start: match.start,
          end: match.end,
          suggestions: suggestionsFor(word, limit: suggestionLimit),
        ),
      );
    }

    return issues;
  }

  bool isCorrect(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) {
      return true;
    }

    if (_isKnownWord(normalized)) {
      return true;
    }

    final parts = _splitRecognizedSuffix(normalized);
    return parts != null && _isKnownWord(parts.stem);
  }

  List<String> suggestionsFor(String word, {int limit = 5}) {
    if (limit <= 0) {
      return const <String>[];
    }

    final normalized = _normalize(word);
    if (normalized.isEmpty || isCorrect(normalized)) {
      return const <String>[];
    }

    final cached = _suggestionCache[normalized];
    if (cached != null) {
      return cached.take(limit).toList(growable: false);
    }

    final parts = _splitRecognizedSuffix(normalized);
    final target = parts?.stem ?? normalized;
    final suffix = parts?.suffix ?? '';
    final maxDistance = target.length <= 4 ? 1 : (target.length <= 8 ? 2 : 3);
    final candidates = <_Candidate>[];

    for (final candidate in _baseDictionary.followedBy(_personalDictionary)) {
      if (candidate.contains("'") || candidate.contains('-')) {
        continue;
      }

      final lengthDifference = (candidate.length - target.length).abs();
      if (lengthDifference > maxDistance) {
        continue;
      }

      final distance = damerauLevenshteinDistance(target, candidate);
      if (distance > maxDistance) {
        continue;
      }

      final prefixPenalty = target.isNotEmpty && candidate.startsWith(target[0])
          ? 0
          : 1;
      candidates.add(
        _Candidate(
          word: candidate,
          distance: distance,
          prefixPenalty: prefixPenalty,
          frequencyRank: _wordFrequencies[candidate] ?? 10000,
        ),
      );
    }

    candidates.sort((a, b) {
      final byDistance = a.distance.compareTo(b.distance);
      if (byDistance != 0) {
        return byDistance;
      }
      final byPrefix = a.prefixPenalty.compareTo(b.prefixPenalty);
      if (byPrefix != 0) {
        return byPrefix;
      }
      final byFrequency = a.frequencyRank.compareTo(b.frequencyRank);
      if (byFrequency != 0) {
        return byFrequency;
      }
      final byLength = a.word.length.compareTo(b.word.length);
      if (byLength != 0) {
        return byLength;
      }
      return a.word.compareTo(b.word);
    });

    final result = candidates
        .map((candidate) => '${candidate.word}$suffix')
        .toList(growable: false);
    _suggestionCache[normalized] = result;
    return result.take(limit).toList(growable: false);
  }

  void addToPersonalDictionary(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) {
      return;
    }
    _personalDictionary.add(normalized);
    _suggestionCache.clear();
  }

  bool removeFromPersonalDictionary(String word) {
    final removed = _personalDictionary.remove(_normalize(word));
    if (removed) {
      _suggestionCache.clear();
    }
    return removed;
  }

  void replacePersonalDictionary(Iterable<String> words) {
    _personalDictionary
      ..clear()
      ..addAll(
        words.map(_normalize).where((String word) => word.isNotEmpty),
      );
    _suggestionCache.clear();
  }

  void clearPersonalDictionary() {
    if (_personalDictionary.isEmpty) {
      return;
    }
    _personalDictionary.clear();
    _suggestionCache.clear();
  }

  void ignoreWord(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) {
      return;
    }
    _ignoredWords.add(normalized);
  }

  void clearIgnoredWords() {
    _ignoredWords.clear();
  }

  void resetSession() {
    _personalDictionary.clear();
    _ignoredWords.clear();
    _suggestionCache.clear();
  }

  bool _isKnownWord(String word) {
    return _baseDictionary.contains(word) ||
        _personalDictionary.contains(word) ||
        _ignoredWords.contains(word);
  }

  static _WordParts? _splitRecognizedSuffix(String word) {
    for (final suffix in _recognizedSuffixes) {
      if (word.length <= suffix.length || !word.endsWith(suffix)) {
        continue;
      }
      final stem = word.substring(0, word.length - suffix.length);
      if (stem.isNotEmpty) {
        return _WordParts(stem: stem, suffix: suffix);
      }
    }
    return null;
  }

  static String _normalize(String word) {
    return word.trim().toLowerCase().replaceAll('’', "'");
  }

  static const List<String> _recognizedSuffixes = <String>[
    "n't",
    "'re",
    "'ve",
    "'ll",
    "'d",
    "'m",
    "'s",
  ];
}

class _Candidate {
  const _Candidate({
    required this.word,
    required this.distance,
    required this.prefixPenalty,
    required this.frequencyRank,
  });

  final String word;
  final int distance;
  final int prefixPenalty;
  final int frequencyRank;
}

class _WordParts {
  const _WordParts({required this.stem, required this.suffix});

  final String stem;
  final String suffix;
}
