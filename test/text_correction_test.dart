import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_issue.dart';
import 'package:spellchecker/core/text_correction.dart';

void main() {
  group('TextCorrection', () {
    test('replaces one current issue and preserves title case', () {
      const issue = SpellIssue(word: 'Helo', start: 0, end: 4);

      final result = TextCorrection.replaceOne('Helo world', issue, 'hello');

      expect(result.text, 'Hello world');
      expect(result.caretOffset, 5);
      expect(result.replacements, 1);
      expect(result.changed, isTrue);
    });

    test('does not apply a stale issue', () {
      const issue = SpellIssue(word: 'Helo', start: 0, end: 4);

      final result = TextCorrection.replaceOne('Hello world', issue, 'hello');

      expect(result.text, 'Hello world');
      expect(result.replacements, 0);
      expect(result.changed, isFalse);
    });

    test('replaces all matching checked occurrences from the end', () {
      const issues = <SpellIssue>[
        SpellIssue(word: 'Helo', start: 0, end: 4),
        SpellIssue(word: 'helo', start: 11, end: 15),
      ];

      final result = TextCorrection.replaceAll(
        'Helo world helo',
        issues,
        'helo',
        'hello',
      );

      expect(result.text, 'Hello world hello');
      expect(result.replacements, 2);
      expect(result.changed, isTrue);
    });

    test('replace all ignores unrelated issues', () {
      const issues = <SpellIssue>[
        SpellIssue(word: 'Helo', start: 0, end: 4),
        SpellIssue(word: 'wrld', start: 5, end: 9),
      ];

      final result = TextCorrection.replaceAll(
        'Helo wrld',
        issues,
        'helo',
        'hello',
      );

      expect(result.text, 'Hello wrld');
      expect(result.replacements, 1);
    });

    test('matchCase preserves upper and title capitalization', () {
      expect(TextCorrection.matchCase('HELO', 'hello'), 'HELLO');
      expect(TextCorrection.matchCase('Helo', 'hello'), 'Hello');
      expect(TextCorrection.matchCase('helo', 'hello'), 'hello');
    });
  });
}
