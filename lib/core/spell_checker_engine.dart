import 'edit_distance.dart';
import 'spell_issue.dart';
import 'spell_language_pack.dart';
import 'spell_suggestion.dart';
import 'spell_suggestion_ranker.dart';

class SpellCheckerEngine {
  factory SpellCheckerEngine({
    Set<String>? dictionary,
    Map<String, int>? wordFrequencies,
    SpellLanguagePack? languagePack,
    SpellSuggestionRanker suggestionRanker =
        const DefaultSpellSuggestionRanker(),
  }) {
    final pack = languagePack ?? SpellLanguageRegistry.defaultPack;
    return SpellCheckerEngine._(
      languagePack: pack,
      dictionary: dictionary,
      wordFrequencies: wordFrequencies,
      suggestionRanker: suggestionRanker,
    );
  }

  SpellCheckerEngine._({
    required this.languagePack,
    required this.suggestionRanker,
    Set<String>? dictionary,
    Map<String, int>? wordFrequencies,
  }) : _baseDictionary = Set<String>.unmodifiable(
         (dictionary ?? languagePack.dictionary)
             .map(languagePack.normalizeWord)
             .where((String word) => word.isNotEmpty),
       ),
       _wordFrequencies = Map<String, int>.unmodifiable(
         wordFrequencies ?? languagePack.wordFrequencies,
       );

  final SpellLanguagePack languagePack;

  /// Ranking strategy used after candidate eligibility/distance filtering.
  ///
  /// The engine assumes the strategy remains deterministic for its lifetime so
  /// suggestion-cache entries remain valid.
  final SpellSuggestionRanker suggestionRanker;

  final Set<String> _baseDictionary;
  final Map<String, int> _wordFrequencies;
  final Set<String> _personalDictionary = <String>{};
  final Set<String> _ignoredWords = <String>{};
  final Map<String, List<SpellSuggestion>> _suggestionCache =
      <String, List<SpellSuggestion>>{};

  Set<String> get personalDictionary =>
      Set<String>.unmodifiable(_personalDictionary);
  Set<String> get ignoredWords => Set<String>.unmodifiable(_ignoredWords);

  List<SpellIssue> check(String text, {int suggestionLimit = 5}) {
    final issues = <SpellIssue>[];
    final matches = languagePack.tokenize(text);

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
          languageId: languagePack.id,
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
    return suggestionDetailsFor(word, limit: limit)
        .map((SpellSuggestion suggestion) => suggestion.word)
        .toList(growable: false);
  }

  List<SpellSuggestion> suggestionDetailsFor(String word, {int limit = 5}) {
    if (limit <= 0) {
      return const <SpellSuggestion>[];
    }

    final normalized = _normalize(word);
    if (normalized.isEmpty || isCorrect(normalized)) {
      return const <SpellSuggestion>[];
    }

    final cached = _suggestionCache[normalized];
    if (cached != null) {
      return cached.take(limit).toList(growable: false);
    }

    final parts = _splitRecognizedSuffix(normalized);
    final target = parts?.stem ?? normalized;
    final suffix = parts?.suffix ?? '';
    final maxDistance = languagePack.maximumSuggestionDistance(target.length);
    final candidates = <SpellSuggestionCandidate>[];

    for (final candidate in _baseDictionary) {
      _addCandidate(
        candidates: candidates,
        target: target,
        candidate: candidate,
        maxDistance: maxDistance,
        source: languagePack.suggestionSource,
      );
    }

    for (final candidate in _personalDictionary) {
      if (_baseDictionary.contains(candidate)) {
        continue;
      }
      _addCandidate(
        candidates: candidates,
        target: target,
        candidate: candidate,
        maxDistance: maxDistance,
        source: 'personal dictionary (${languagePack.displayName})',
      );
    }

    final rankingContext = SpellSuggestionRankingContext(
      target: target,
      languagePack: languagePack,
    );
    candidates.sort((SpellSuggestionCandidate a, SpellSuggestionCandidate b) {
      final byRanker = suggestionRanker.compare(rankingContext, a, b);
      if (byRanker != 0) {
        return byRanker;
      }
      return a.word.compareTo(b.word);
    });

    final result = candidates
        .map(
          (SpellSuggestionCandidate candidate) => SpellSuggestion(
            word: '${candidate.word}$suffix',
            distance: candidate.distance,
            frequencyRank: candidate.frequencyRank,
            languageId: languagePack.id,
            languageDisplayName: languagePack.displayName,
            source: candidate.source,
          ),
        )
        .toList(growable: false);
    _suggestionCache[normalized] = result;
    return result.take(limit).toList(growable: false);
  }

  void addToPersonalDictionary(String word) {
    final normalized = _normalize(word);
    if (normalized.isEmpty || !languagePack.isValidWord(normalized)) {
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
        words
            .map(_normalize)
            .where(
              (String word) =>
                  word.isNotEmpty && languagePack.isValidWord(word),
            ),
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

  void _addCandidate({
    required List<SpellSuggestionCandidate> candidates,
    required String target,
    required String candidate,
    required int maxDistance,
    required String source,
  }) {
    if (candidate.contains("'") || candidate.contains('-')) {
      return;
    }

    final lengthDifference = (candidate.length - target.length).abs();
    if (lengthDifference > maxDistance) {
      return;
    }

    final distance = damerauLevenshteinDistance(target, candidate);
    if (distance > maxDistance) {
      return;
    }

    final prefixPenalty = target.isNotEmpty && candidate.startsWith(target[0])
        ? 0
        : 1;
    candidates.add(
      SpellSuggestionCandidate(
        word: candidate,
        distance: distance,
        prefixPenalty: prefixPenalty,
        frequencyRank: _wordFrequencies[candidate] ?? 10000,
        source: source,
      ),
    );
  }

  bool _isKnownWord(String word) {
    return _baseDictionary.contains(word) ||
        _personalDictionary.contains(word) ||
        _ignoredWords.contains(word);
  }

  _WordParts? _splitRecognizedSuffix(String word) {
    for (final suffix in languagePack.recognizedSuffixes) {
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

  String _normalize(String word) => languagePack.normalizeWord(word);
}

class _WordParts {
  const _WordParts({required this.stem, required this.suffix});

  final String stem;
  final String suffix;
}
