import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final us = SpellLanguageRegistry.englishUs;

  group('MissingPunctuationSpaceRule decomposed Unicode', () {
    const rule = MissingPunctuationSpaceRule();

    test('finds punctuation after a decomposed accented letter cluster', () {
      const text = 'cafe\u0301,naive';

      final issue = rule.analyze(text, us).single;

      expect(issue.originalText, ',');
      expect(issue.replacement, ', ');
      expect(text.substring(issue.start, issue.end), ',');
      expect(issue.start, 5);
      expect(issue.end, 6);
    });

    test('supports multiple combining marks before punctuation', () {
      const text = 'a\u0301\u0327;word';

      final issue = rule.analyze(text, us).single;

      expect(issue.originalText, ';');
      expect(issue.start, 3);
      expect(issue.end, 4);
    });

    test('keeps punctuation ownership when pre-punctuation space exists', () {
      const text = 'cafe\u0301 ,naive';

      final result = WritingAnalyzer(
        rules: const <WritingRule>[
          PunctuationSpacingRule(),
          MissingPunctuationSpaceRule(),
        ],
      ).analyze(text, languagePack: us);

      expect(result.issues, hasLength(2));
      expect(
        result.issues.map((issue) => issue.ruleId),
        orderedEquals(const <String>[
          'punctuation-spacing',
          'missing-punctuation-space',
        ]),
      );
      expect(result.issues[0].end, result.issues[1].start);

      final correction = WritingCorrection.applyAll(text, result.issues);
      expect(correction.appliedCount, 2);
      expect(correction.skippedCount, 0);
      expect(correction.text, 'cafe\u0301, naive');
    });

    test('does not treat a combining mark alone as a word boundary', () {
      expect(rule.analyze('\u0301,word', us), isEmpty);
    });

    test('still ignores periods and colons with combining marks', () {
      expect(rule.analyze('cafe\u0301.example cafe\u0301:word', us), isEmpty);
    });

    test('preserves non-BMP following-letter offsets', () {
      const text = 'cafe\u0301,\u{10400}word';
      final issue = rule.analyze(text, us).single;

      expect(issue.start, 5);
      expect(issue.end, 6);
      expect(text.substring(issue.start, issue.end), ',');
    });
  });
}
