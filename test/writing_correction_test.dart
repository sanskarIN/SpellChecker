import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/writing.dart';

void main() {
  group('WritingCorrection', () {
    test('applies a current automatic fix', () {
      const issue = WritingIssue(
        ruleId: 'sentence-capitalization',
        ruleName: 'Sentence capitalization',
        message: 'Start with a capital letter.',
        start: 0,
        end: 5,
        originalText: 'hello',
        replacement: 'Hello',
        languageId: 'en-US',
      );

      final result = WritingCorrection.apply('hello world', issue);

      expect(result.applied, isTrue);
      expect(result.text, 'Hello world');
      expect(result.caretOffset, 5);
    });

    test('refuses a stale source range', () {
      const issue = WritingIssue(
        ruleId: 'sentence-capitalization',
        ruleName: 'Sentence capitalization',
        message: 'Start with a capital letter.',
        start: 0,
        end: 5,
        originalText: 'hello',
        replacement: 'Hello',
        languageId: 'en-US',
      );

      final result = WritingCorrection.apply('Hello world', issue);

      expect(result.applied, isFalse);
      expect(result.text, 'Hello world');
    });

    test('does not mutate an issue without an automatic replacement', () {
      const issue = WritingIssue(
        ruleId: 'advisory',
        ruleName: 'Advisory',
        message: 'Review this text.',
        start: 0,
        end: 4,
        originalText: 'text',
        languageId: 'en-GB',
      );

      final result = WritingCorrection.apply('text only', issue);

      expect(result.applied, isFalse);
      expect(result.text, 'text only');
    });
  });
}
