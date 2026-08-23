import 'package:spellchecker/core/spell_checker_engine.dart';
import 'package:spellchecker/core/spell_suggestion_ranker.dart';

/// Example deterministic ranking policy that prefers candidate length before
/// frequency after edit distance.
class LengthFirstSuggestionRanker implements SpellSuggestionRanker {
  const LengthFirstSuggestionRanker();

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

    final targetLength = context.target.runes.length;
    final aLengthDelta = (a.word.runes.length - targetLength).abs();
    final bLengthDelta = (b.word.runes.length - targetLength).abs();
    final byLength = aLengthDelta.compareTo(bLengthDelta);
    if (byLength != 0) {
      return byLength;
    }

    return a.frequencyRank.compareTo(b.frequencyRank);
  }
}

void main() {
  final engine = SpellCheckerEngine(
    dictionary: const <String>{'cat', 'coat'},
    wordFrequencies: const <String, int>{'cat': 100, 'coat': 1},
    suggestionRanker: const LengthFirstSuggestionRanker(),
  );

  final issue = engine.check('cot', suggestionLimit: 2).single;
  print(issue.suggestions.map((suggestion) => suggestion.word).join(', '));
}
