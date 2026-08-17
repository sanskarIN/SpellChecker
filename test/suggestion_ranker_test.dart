import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('SpellSuggestionRanker', () {
    test(
      'default ranker preserves frequency ordering for equal-distance words',
      () {
        final engine = SpellCheckerEngine(
          dictionary: <String>{'cat', 'cut'},
          wordFrequencies: <String, int>{'cut': 1, 'cat': 100},
        );

        expect(engine.suggestionsFor('cot'), <String>['cut', 'cat']);
        expect(engine.suggestionRanker, isA<DefaultSpellSuggestionRanker>());
      },
    );

    test('default ranker compares candidate length by Unicode scalars', () {
      const ranker = DefaultSpellSuggestionRanker();
      final context = SpellSuggestionRankingContext(
        target: 'test',
        languagePack: SpellLanguageRegistry.defaultPack,
      );
      const shorterByScalars = SpellSuggestionCandidate(
        word: '𐐀a',
        distance: 1,
        prefixPenalty: 0,
        frequencyRank: 10,
        source: 'test',
      );
      const longerByScalars = SpellSuggestionCandidate(
        word: 'abc',
        distance: 1,
        prefixPenalty: 0,
        frequencyRank: 10,
        source: 'test',
      );

      expect(shorterByScalars.word.length, longerByScalars.word.length);
      expect(shorterByScalars.word.runes.length, 2);
      expect(longerByScalars.word.runes.length, 3);
      expect(ranker.compare(context, shorterByScalars, longerByScalars), lessThan(0));
    });

    test('custom ranker can replace the default ordering policy', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'cat', 'cut'},
        wordFrequencies: <String, int>{'cat': 1, 'cut': 100},
        suggestionRanker: const _ReverseAlphabeticalRanker(),
      );

      expect(engine.suggestionsFor('cot'), <String>['cut', 'cat']);
    });

    test(
      'engine provides a stable lexical tie-break for custom ranker ties',
      () {
        final engine = SpellCheckerEngine(
          dictionary: <String>{'cut', 'cat'},
          suggestionRanker: const _AllEqualRanker(),
        );

        expect(engine.suggestionsFor('cot'), <String>['cat', 'cut']);
      },
    );

    test('ranker receives normalized stem and active language context', () {
      final ranker = _RecordingRanker();
      final engine = SpellCheckerEngine(
        dictionary: <String>{'hello', 'help'},
        suggestionRanker: ranker,
      );

      final suggestions = engine.suggestionsFor("helo's");

      expect(suggestions, contains("hello's"));
      expect(ranker.lastTarget, 'helo');
      expect(ranker.lastLanguageId, 'en-US');
    });

    test(
      'candidate metadata includes distance, prefix, frequency and source',
      () {
        final ranker = _CandidateRecordingRanker();
        final engine = SpellCheckerEngine(
          dictionary: <String>{'cat', 'cut'},
          wordFrequencies: <String, int>{'cat': 3, 'cut': 7},
          suggestionRanker: ranker,
        );

        engine.suggestionsFor('cot');

        expect(ranker.seen, isNotEmpty);
        final cat = ranker.seen.firstWhere(
          (SpellSuggestionCandidate candidate) => candidate.word == 'cat',
        );
        expect(cat.distance, 1);
        expect(cat.prefixPenalty, 0);
        expect(cat.frequencyRank, 3);
        expect(cat.source, isNotEmpty);
      },
    );

    test('custom ranking never bypasses suggestion eligibility filtering', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'cat', 'encyclopedia'},
        suggestionRanker: const _ReverseAlphabeticalRanker(),
      );

      expect(engine.suggestionsFor('cot'), <String>['cat']);
    });
  });
}

class _ReverseAlphabeticalRanker implements SpellSuggestionRanker {
  const _ReverseAlphabeticalRanker();

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    return b.word.compareTo(a.word);
  }
}

class _AllEqualRanker implements SpellSuggestionRanker {
  const _AllEqualRanker();

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    return 0;
  }
}

class _RecordingRanker implements SpellSuggestionRanker {
  String? lastTarget;
  String? lastLanguageId;

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    lastTarget = context.target;
    lastLanguageId = context.languagePack.id;
    return a.word.compareTo(b.word);
  }
}

class _CandidateRecordingRanker implements SpellSuggestionRanker {
  final Set<SpellSuggestionCandidate> seen = <SpellSuggestionCandidate>{};

  @override
  int compare(
    SpellSuggestionRankingContext context,
    SpellSuggestionCandidate a,
    SpellSuggestionCandidate b,
  ) {
    seen
      ..add(a)
      ..add(b);
    return 0;
  }
}
