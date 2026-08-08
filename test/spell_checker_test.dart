import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('SpellCheckerEngine', () {
    test('accepts dictionary words case-insensitively', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello', 'world'});

      expect(engine.isCorrect('HELLO'), isTrue);
      expect(engine.isCorrect('World'), isTrue);
    });

    test('returns unknown words with source positions', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      final issues = engine.check('hello wrld');

      expect(issues, hasLength(1));
      expect(issues.single.word, 'wrld');
      expect(issues.single.start, 6);
      expect(issues.single.end, 10);
    });

    test('returns close suggestions for a misspelling', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'hello', 'help', 'shell'},
      );

      final suggestions = engine.suggestionsFor('helo');

      expect(suggestions, contains('hello'));
      expect(suggestions, isNotEmpty);
    });

    test('orders lower edit-distance suggestions first', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'spell', 'spelling', 'world'},
      );

      final suggestions = engine.suggestionsFor('spel');

      expect(suggestions.first, 'spell');
    });

    test('uses frequency rank when candidates are otherwise equivalent', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'cat', 'cut'},
        wordFrequencies: <String, int>{'cut': 1, 'cat': 100},
      );

      final suggestions = engine.suggestionsFor('cot');

      expect(suggestions, <String>['cut', 'cat']);
    });

    test('limits suggestions during a full text check', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'hello', 'help', 'hero'},
      );

      final issue = engine.check('helo', suggestionLimit: 1).single;

      expect(issue.suggestions, hasLength(1));
    });

    test('accepts regular contractions and possessives from known stems', () {
      final engine = SpellCheckerEngine(
        dictionary: <String>{'teacher', 'we', 'could'},
      );

      expect(engine.isCorrect("teacher's"), isTrue);
      expect(engine.isCorrect("we're"), isTrue);
      expect(engine.isCorrect("couldn't"), isTrue);
    });

    test('preserves recognized suffixes in generated suggestions', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      expect(engine.suggestionsFor("helo's"), contains("hello's"));
    });

    test('accepts words added to the personal dictionary', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      engine.addToPersonalDictionary('OpenAI');

      expect(engine.isCorrect('openai'), isTrue);
      expect(engine.personalDictionary, contains('openai'));
    });

    test('replaces and removes personal dictionary entries', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      engine.replacePersonalDictionary(<String>{'Flutter', 'Dart'});
      expect(engine.personalDictionary, <String>{'flutter', 'dart'});

      expect(engine.removeFromPersonalDictionary('DART'), isTrue);
      expect(engine.personalDictionary, <String>{'flutter'});
      expect(engine.removeFromPersonalDictionary('missing'), isFalse);
    });

    test('ignores a word for the current session', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      engine.ignoreWord('wrld');

      expect(engine.check('hello wrld'), isEmpty);
      expect(engine.ignoredWords, contains('wrld'));
    });

    test('clears only ignored words when requested', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});
      engine.addToPersonalDictionary('custom');
      engine.ignoreWord('temporary');

      engine.clearIgnoredWords();

      expect(engine.personalDictionary, contains('custom'));
      expect(engine.ignoredWords, isEmpty);
    });

    test('resetSession clears personal and ignored words', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});
      engine.addToPersonalDictionary('custom');
      engine.ignoreWord('temporary');

      engine.resetSession();

      expect(engine.personalDictionary, isEmpty);
      expect(engine.ignoredWords, isEmpty);
      expect(engine.isCorrect('custom'), isFalse);
      expect(engine.isCorrect('temporary'), isFalse);
    });

    test('treats apostrophes as part of a word', () {
      final engine = SpellCheckerEngine(dictionary: <String>{"don't", 'stop'});

      expect(engine.check("Don't stop."), isEmpty);
    });

    test('uses the expanded bundled dictionary by default', () {
      final engine = SpellCheckerEngine();

      expect(engine.isCorrect('architecture'), isTrue);
      expect(engine.isCorrect('persistent'), isTrue);
      expect(engine.isCorrect('clipboard'), isTrue);
    });
  });
}
