import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final us = SpellLanguageRegistry.englishUs;
  final gb = SpellLanguageRegistry.englishGb;

  group('MissingPunctuationSpaceRule', () {
    const rule = MissingPunctuationSpaceRule();

    test('finds supported punctuation between words', () {
      const text = 'Hello,world;again!yes?okay';
      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(4));
      expect(
        issues.map((issue) => issue.originalText),
        orderedEquals(const <String>[',', ';', '!', '?']),
      );
      expect(
        issues.map((issue) => issue.replacement),
        orderedEquals(const <String>[', ', '; ', '! ', '? ']),
      );
      for (final issue in issues) {
        expect(text.substring(issue.start, issue.end), issue.originalText);
        expect(issue.ruleId, 'missing-punctuation-space');
      }
    });

    test('supports both built-in English variants', () {
      expect(rule.supports(us), isTrue);
      expect(rule.supports(gb), isTrue);
      expect(rule.analyze('Hello,world', gb), hasLength(1));
    });

    test('ignores punctuation that already has following whitespace', () {
      expect(rule.analyze('Hello, world; again! yes? okay', us), isEmpty);
    });

    test('ignores period and colon boundaries', () {
      expect(rule.analyze('example.com scheme:value', us), isEmpty);
    });

    test('requires letters on both sides of the punctuation boundary', () {
      expect(rule.analyze('1,word word,1 _;word word;_', us), isEmpty);
    });

    test('does not compete with repeated punctuation ownership', () {
      expect(rule.analyze('Really!!yes What??now', us), isEmpty);
    });

    test('owns punctuation only when whitespace exists before it', () {
      const text = 'Hello ,world';
      final issue = rule.analyze(text, us).single;

      expect(issue.originalText, ',');
      expect(issue.replacement, ', ');
      expect(text.substring(issue.start, issue.end), ',');
      expect(issue.start, 6);
      expect(issue.end, 7);
    });
  });
}
