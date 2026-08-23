import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_checker_engine.dart';

import '../tool/examples/custom_suggestion_ranker.dart';

void main() {
  test('custom suggestion ranker example changes deterministic ordering', () {
    final custom = SpellCheckerEngine(
      dictionary: const <String>{'cat', 'coat'},
      wordFrequencies: const <String, int>{'cat': 100, 'coat': 1},
      suggestionRanker: const LengthFirstSuggestionRanker(),
    );
    final standard = SpellCheckerEngine(
      dictionary: const <String>{'cat', 'coat'},
      wordFrequencies: const <String, int>{'cat': 100, 'coat': 1},
    );

    expect(
      custom.check('cot', suggestionLimit: 2).single.suggestions
          .map((suggestion) => suggestion.word),
      orderedEquals(const <String>['cat', 'coat']),
    );
    expect(
      standard.check('cot', suggestionLimit: 2).single.suggestions
          .map((suggestion) => suggestion.word),
      orderedEquals(const <String>['coat', 'cat']),
    );
  });
}
