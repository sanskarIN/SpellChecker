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

    test('accepts words added to the personal dictionary', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      engine.addToPersonalDictionary('OpenAI');

      expect(engine.isCorrect('openai'), isTrue);
      expect(engine.personalDictionary, contains('openai'));
    });

    test('ignores a word for the current session', () {
      final engine = SpellCheckerEngine(dictionary: <String>{'hello'});

      engine.ignoreWord('wrld');

      expect(engine.check('hello wrld'), isEmpty);
      expect(engine.ignoredWords, contains('wrld'));
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
  });
}
