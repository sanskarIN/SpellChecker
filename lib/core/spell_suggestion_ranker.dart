import 'spell_language_pack.dart';

/// Public candidate metadata supplied to a [SpellSuggestionRanker].
class SpellSuggestionCandidate {
  const SpellSuggestionCandidate({
    required this.word,
    required this.distance,
    required this.prefixPenalty,
    required this.frequencyRank,
    required this.source,
  });

  final String word;
  final int distance;
  final int prefixPenalty;
  final int frequencyRank;
  final String source;
}

/// Immutable context for one suggestion-ranking operation.
class SpellSuggestionRankingContext {
  const SpellSuggestionRankingContext({
    required this.target,
    required this.languagePack,
  });

  /// Normalized word stem being corrected. Recognized suffixes are ranked on
  /// the stem and reattached after ranking.
  final String target;

  final SpellLanguagePack languagePack;
}

/// Strategy interface for ordering already-eligible spelling candidates.
///
/// Implementations should be deterministic and side-effect free. The engine
/// applies a final lexical word tie-break when [compare] returns zero, so equal
/// custom scores still produce a stable result independent of set iteration.
abstract interface class SpellSuggestionRanker {
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  );
}

/// The ranking used by SpellChecker before the strategy became injectable.
///
/// Order is: edit distance, first-character/prefix penalty, frequency rank,
/// Unicode scalar length, then the engine's final lexical tie-break.
class DefaultSpellSuggestionRanker implements SpellSuggestionRanker {
  const DefaultSpellSuggestionRanker();

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
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

    return a.word.runes.length.compareTo(b.word.runes.length);
  }
}
