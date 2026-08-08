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

    test('applies multiple current fixes as one deterministic batch', () {
      const issues = <WritingIssue>[
        WritingIssue(
          ruleId: 'sentence-capitalization',
          ruleName: 'Sentence capitalization',
          message: 'Start with a capital letter.',
          start: 0,
          end: 5,
          originalText: 'hello',
          replacement: 'Hello',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'repeated-space',
          ruleName: 'Repeated spaces',
          message: 'Use a single space here.',
          start: 5,
          end: 7,
          originalText: '  ',
          replacement: ' ',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'repeated-punctuation',
          ruleName: 'Repeated punctuation',
          message: 'Use one punctuation mark here.',
          start: 12,
          end: 14,
          originalText: '!!',
          replacement: '!',
          languageId: 'en-US',
        ),
      ];

      final result = WritingCorrection.applyAll('hello  world!!', issues);

      expect(result.applied, isTrue);
      expect(result.appliedCount, 3);
      expect(result.skippedCount, 0);
      expect(result.text, 'Hello world!');
      expect(result.caretOffset, result.text.length);
    });

    test('skips stale and advisory issues while applying current fixes', () {
      const issues = <WritingIssue>[
        WritingIssue(
          ruleId: 'stale',
          ruleName: 'Stale',
          message: 'Stale issue.',
          start: 0,
          end: 5,
          originalText: 'Hello',
          replacement: 'HELLO',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'repeated-space',
          ruleName: 'Repeated spaces',
          message: 'Use a single space here.',
          start: 5,
          end: 7,
          originalText: '  ',
          replacement: ' ',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'advisory',
          ruleName: 'Advisory',
          message: 'Review this.',
          start: 7,
          end: 12,
          originalText: 'world',
          languageId: 'en-US',
        ),
      ];

      final result = WritingCorrection.applyAll('hello  world', issues);

      expect(result.applied, isTrue);
      expect(result.appliedCount, 1);
      expect(result.skippedCount, 2);
      expect(result.text, 'hello world');
    });

    test('keeps the earliest deterministic issue when fixes overlap', () {
      const issues = <WritingIssue>[
        WritingIssue(
          ruleId: 'z-rule',
          ruleName: 'Later candidate',
          message: 'Replace overlap.',
          start: 1,
          end: 4,
          originalText: 'bcd',
          replacement: 'X',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'a-rule',
          ruleName: 'Earlier candidate',
          message: 'Replace first range.',
          start: 0,
          end: 3,
          originalText: 'abc',
          replacement: 'Y',
          languageId: 'en-US',
        ),
      ];

      final result = WritingCorrection.applyAll('abcde', issues);

      expect(result.appliedCount, 1);
      expect(result.skippedCount, 1);
      expect(result.text, 'Yde');
    });

    test('reports no batch mutation when every issue is unsafe', () {
      const issues = <WritingIssue>[
        WritingIssue(
          ruleId: 'stale',
          ruleName: 'Stale',
          message: 'Stale issue.',
          start: 0,
          end: 4,
          originalText: 'text',
          replacement: 'Text',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'advisory',
          ruleName: 'Advisory',
          message: 'Review this.',
          start: 0,
          end: 5,
          originalText: 'Hello',
          languageId: 'en-US',
        ),
      ];

      final result = WritingCorrection.applyAll('Hello', issues);

      expect(result.applied, isFalse);
      expect(result.appliedCount, 0);
      expect(result.skippedCount, 2);
      expect(result.text, 'Hello');
    });
  });
}
