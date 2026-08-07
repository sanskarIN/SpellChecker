import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('SpellCheckerEngine', () {
    test('accepts known words case-insensitively', () {
      final engine = SpellCheckerEngine();

      expect(engine.isCorrect('Hello'), isTrue);
      expect(engine.isCorrect('WORLD'), isTrue);
    });

    test('reports unknown words with positions', () {
      final engine = SpellCheckerEngine(dictionary: {'hello'});
      final issues = engine.check('hello wrld');

      expect(issues, hasLength(1));
      expect(issues.first.word, 'wrld');
      expect(issues.first.start, 6);
      expect(issues.first.end, 10);
    });

    test('ignores punctuation around known words', () {
      final engine = SpellCheckerEngine(dictionary: {'hello', 'world'});

      expect(engine.check('Hello, world!'), isEmpty);
    });
  });
}
