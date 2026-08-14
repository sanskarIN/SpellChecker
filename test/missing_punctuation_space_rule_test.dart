import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final us = SpellLanguageRegistry.englishUs;
  final gb = SpellLanguageRegistry.englishGb;

  group('MissingPunctuationSpaceRule', () {
    const rule = MissingPunctuationSpaceRule();

    test('uses a stable public mechanics contract', () {
      expect(rule.id, 'missing-punctuation-space');
      expect(rule.displayName, 'Missing punctuation space');
      expect(rule.category, WritingRuleCategory.mechanics);
      expect(rule.supports(us), isTrue);
      expect(rule.supports(gb), isTrue);
    });

    test('finds comma semicolon question and exclamation boundaries', () {
      const text = 'Hello,world;again?Yes!Absolutely';

      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(4));
      expect(
        issues.map((issue) => issue.originalText),
        orderedEquals(const <String>[',', ';', '?', '!']),
      );
      expect(
        issues.map((issue) => issue.replacement),
        orderedEquals(const <String>[', ', '; ', '? ', '! ']),
      );
      for (final issue in issues) {
        expect(issue.ruleId, rule.id);
        expect(issue.languageId, 'en-US');
        expect(issue.severity, WritingIssueSeverity.info);
        expect(text.substring(issue.start, issue.end), issue.originalText);
        expect(issue.end - issue.start, 1);
      }
    });

    test('finds overlapping comma boundaries without skipping the next word', () {
      const text = 'one,two,three,four';

      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(3));
      expect(issues.map((issue) => issue.start), orderedEquals(<int>[3, 7, 13]));
    });

    test('supports Unicode letters while preserving UTF-16 source offsets', () {
      const text = 'café,naïve!Résumé';

      final issues = rule.analyze(text, gb).toList();

      expect(issues, hasLength(2));
      expect(issues.map((issue) => issue.originalText), <String>[',', '!']);
      for (final issue in issues) {
        expect(text.substring(issue.start, issue.end), issue.originalText);
        expect(issue.languageId, 'en-GB');
      }
    });

    test('ignores already spaced punctuation and line boundaries', () {
      expect(
        rule.analyze('Hello, world; again? Yes!\nNext', us),
        isEmpty,
      );
    });

    test('intentionally excludes periods and colons', () {
      expect(
        rule.analyze(
          'Visit example.com and mailto:user@example.com at 12:30.',
          us,
        ),
        isEmpty,
      );
    });

    test('ignores numeric separators and non-letter neighbors', () {
      expect(
        rule.analyze('1,000;2 ?word!  value,_name;9', us),
        isEmpty,
      );
    });

    test('leaves repeated punctuation to repeated-punctuation ownership', () {
      expect(rule.analyze('Really??Yes!!No,,Maybe;;Fine', us), isEmpty);
    });

    test('owns only the punctuation character for a safe replacement', () {
      const text = 'Hello,world';
      final issue = rule.analyze(text, us).single;

      expect(issue.start, 5);
      expect(issue.end, 6);
      expect(issue.originalText, ',');
      expect(issue.replacement, ', ');

      final correction = WritingCorrection.apply(text, issue);
      expect(correction.applied, isTrue);
      expect(correction.text, 'Hello, world');
      expect(correction.caretOffset, 7);
    });
  });
}
