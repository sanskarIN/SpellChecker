import '../data/english_dictionary.dart';
import 'edit_distance.dart';
import 'spell_issue.dart';

class SpellCheckerEngine {
  SpellCheckerEngine({Set<String>? dictionary})
      : _baseDictionary = Set<String>.unmodifiable(
          (dictionary ?? EnglishDictionary.words).map(_normalize),
        );

  final Set<String> _baseDictionary;
  final Set<String> _personalDictionary = <String>{};
  final Set<String> _ignoredWords = <String>{};
  final Map<String, List<String>> _suggestionCache = <String, List<String>>{};

  Set<String> get personalDictionary => Set<String>.unmodifiable(_personalDictionary);
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
    return _baseDictionary.contains(normalized) ||
        _personalDictionary.contains(normalized) ||
        _ignoredWords.contains(normalized);
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

    final maxDistance = normalized.length <= 4 ? 1 : (normalized.length <= 8 ? 2 : 3);
    final candidates = <_Candidate>[];

    for (final candidate in _baseDictionary.followedBy(_personalDictionary)) {
      final lengthDifference = (candidate.length - normalized.length).abs();
      if (lengthDifference > maxDistance) {
        continue;
      }

      final distance = damerauLevenshteinDistance(normalized, candidate);
      if (distance > maxDistance) {
        continue;
      }

      final prefixPenalty = candidate.startsWith(normalized[0]) ? 0 : 1;
      candidates.add(
        _Candidate(
          word: candidate,
          distance: distance,
          prefixPenalty: prefixPenalty,
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
      final byLength = a.word.length.compareTo(b.word.length);
      if (byLength != 0) {
        return byLength;
      }
      return a.word.compareTo(b.word);
    });

    final result = candidates.map((candidate) => candidate.word).toList(growable: false);
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

  void ignoreWord(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty) {
      return;
    }
    _ignoredWords.add(normalized);
  }

  void resetSession() {
    _personalDictionary.clear();
    _ignoredWords.clear();
    _suggestionCache.clear();
  }

  static String _normalize(String word) {
    return word.trim().toLowerCase().replaceAll('’', "'");
  }
}

class _Candidate {
  const _Candidate({
    required this.word,
    required this.distance,
    required this.prefixPenalty,
  });

  final String word;
  final int distance;
  final int prefixPenalty;
}
