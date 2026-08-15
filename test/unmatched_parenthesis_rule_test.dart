import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing/rules/unmatched_parenthesis_rule.dart';
import 'package:spellchecker/writing/writing_issue.dart';

void main() {
  final us = SpellLanguageRegistry.englishUs;
  final gb = SpellLanguageRegistry.englishGb;

  group('UnmatchedParenthesisRule', () {
    const rule = UnmatchedParenthesisRule();

    test('accepts balanced and nested parentheses', () {
      expect(rule.analyze('Plain text.', us), isEmpty);
      expect(rule.analyze('One (balanced) pair.', us), isEmpty);
      expect(rule.analyze('Nested ((content) here).', us), isEmpty);
      expect(rule.analyze('()(()())', us), isEmpty);
    });

    test('reports an unmatched opening parenthesis as advisory-only', () {
      const text = 'Keep (this text';
      final issue = rule.analyze(text, us).single;

      expect(issue.ruleId, 'unmatched-parenthesis');
      expect(issue.ruleName, 'Unmatched parenthesis');
      expect(issue.message, contains('opening parenthesis'));
      expect(issue.originalText, '(');
      expect(issue.start, 5);
      expect(issue.end, 6);
      expect(text.substring(issue.start, issue.end), '(');
      expect(issue.replacement, isNull);
      expect(issue.hasAutomaticFix, isFalse);
      expect(issue.severity, WritingIssueSeverity.warning);
      expect(issue.languageId, us.id);
    });

    test('reports an unmatched closing parenthesis as advisory-only', () {
      const text = 'Keep this) text';
      final issue = rule.analyze(text, us).single;

      expect(issue.message, contains('closing parenthesis'));
      expect(issue.originalText, ')');
      expect(issue.start, 9);
      expect(issue.end, 10);
      expect(text.substring(issue.start, issue.end), ')');
      expect(issue.replacement, isNull);
      expect(issue.hasAutomaticFix, isFalse);
      expect(issue.severity, WritingIssueSeverity.warning);
    });

    test('reports malformed ordering in deterministic source order', () {
      const text = ')middle(';
      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(2));
      expect(
        issues.map((issue) => issue.originalText),
        orderedEquals(const <String>[')', '(']),
      );
      expect(
        issues.map((issue) => issue.start),
        orderedEquals(const <int>[0, 7]),
      );
    });

    test('preserves the outer unmatched opening in a partial nest', () {
      const text = '(()';
      final issue = rule.analyze(text, us).single;

      expect(issue.originalText, '(');
      expect(issue.start, 0);
      expect(issue.end, 1);
    });

    test('preserves the final unmatched closing after a valid pair', () {
      const text = '())';
      final issue = rule.analyze(text, us).single;

      expect(issue.originalText, ')');
      expect(issue.start, 2);
      expect(issue.end, 3);
    });

    test('reports every unmatched opening in source order', () {
      const text = '((unfinished';
      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(2));
      expect(
        issues.map((issue) => issue.start),
        orderedEquals(const <int>[0, 1]),
      );
      expect(issues.every((issue) => issue.originalText == '('), isTrue);
    });

    test('uses UTF-16 source offsets around non-BMP text', () {
      const text = '😀)';
      final issue = rule.analyze(text, us).single;

      expect(text.length, 3);
      expect(issue.start, 2);
      expect(issue.end, 3);
      expect(text.substring(issue.start, issue.end), ')');
    });

    test('does not claim square or curly bracket ownership', () {
      expect(rule.analyze('[text] {text} ] }', us), isEmpty);
    });

    test('supports both built-in English variants', () {
      expect(rule.supports(us), isTrue);
      expect(rule.supports(gb), isTrue);
      expect(rule.analyze('(text', gb), hasLength(1));
    });
  });
}
