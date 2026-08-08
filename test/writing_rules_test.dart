import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  group('built-in writing rules', () {
    test('repeated word rule finds adjacent duplicates only', () {
      const rule = RepeatedWordRule();

      final issues = rule.analyze('This is is fine. Is this is?', pack).toList();

      expect(issues, hasLength(1));
      expect(issues.single.ruleId, 'repeated-word');
      expect(issues.single.originalText, ' is');
      expect(issues.single.replacement, '');
    });

    test('sentence capitalization finds first words after boundaries', () {
      const rule = SentenceCapitalizationRule();

      final issues = rule.analyze('hello world. next sentence!', pack).toList();

      expect(issues, hasLength(2));
      expect(issues.map((issue) => issue.originalText), <String>['hello', 'next']);
      expect(issues.map((issue) => issue.replacement), <String>['Hello', 'Next']);
    });

    test('repeated space rule keeps newlines outside its scope', () {
      const rule = RepeatedSpaceRule();

      final issues = rule.analyze('one  two\n  three', pack).toList();

      expect(issues, hasLength(2));
      expect(issues.every((issue) => issue.replacement == ' '), isTrue);
    });

    test('repeated punctuation rule collapses identical punctuation runs', () {
      const rule = RepeatedPunctuationRule();

      final issues = rule.analyze('Really?? Yes!! Wait...', pack).toList();

      expect(issues, hasLength(3));
      expect(issues.map((issue) => issue.replacement), <String>['?', '!', '.']);
    });
  });

  group('WritingAnalyzer', () {
    test('runs enabled rules and returns sorted issues', () {
      final analyzer = WritingAnalyzer();

      final result = analyzer.analyze(
        'hello  world world!!',
        languagePack: pack,
      );

      expect(result.languageId, 'en-US');
      expect(result.isClean, isFalse);
      expect(result.analyzedRuleIds, hasLength(4));
      expect(result.issues.map((issue) => issue.start), orderedEquals(
        result.issues.map((issue) => issue.start).toList()..sort(),
      ));
      expect(result.issueCountByRule['repeated-word'], 1);
      expect(result.issueCountByRule['sentence-capitalization'], 1);
      expect(result.issueCountByRule['repeated-space'], 1);
      expect(result.issueCountByRule['repeated-punctuation'], 1);
    });

    test('can disable all but one rule', () {
      final analyzer = WritingAnalyzer();

      final result = analyzer.analyze(
        'hello  hello!!',
        languagePack: pack,
        enabledRuleIds: <String>{'repeated-space'},
      );

      expect(result.analyzedRuleIds, <String>{'repeated-space'});
      expect(result.issues, hasLength(1));
      expect(result.issues.single.ruleId, 'repeated-space');
    });

    test('English rules support both built-in English packs', () {
      const rule = RepeatedWordRule();

      expect(rule.supports(SpellLanguageRegistry.englishUs), isTrue);
      expect(rule.supports(SpellLanguageRegistry.englishGb), isTrue);
    });
  });
}
