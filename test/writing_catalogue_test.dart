import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final us = SpellLanguageRegistry.englishUs;
  final gb = SpellLanguageRegistry.englishGb;

  group('MissingSpaceAfterPunctuationRule', () {
    test('adds a space after comma and semicolon before letters', () {
      const rule = MissingSpaceAfterPunctuationRule();

      final issues = rule.analyze('Hello,world;again.', us).toList();

      expect(issues, hasLength(2));
      expect(issues.map((WritingIssue issue) => issue.originalText), <String>[
        ',w',
        ';a',
      ]);
      expect(issues.map((WritingIssue issue) => issue.replacement), <String>[
        ', w',
        '; a',
      ]);
      for (final issue in issues) {
        expect(
          'Hello,world;again.'.substring(issue.start, issue.end),
          issue.originalText,
        );
      }
    });

    test('recognizes a Unicode letter after punctuation', () {
      const rule = MissingSpaceAfterPunctuationRule();

      final issue = rule.analyze('Hello,éclair', us).single;

      expect(issue.originalText, ',é');
      expect(issue.replacement, ', é');
    });

    test('ignores already spaced and repeated punctuation', () {
      const rule = MissingSpaceAfterPunctuationRule();

      expect(rule.analyze('Hello, world; again.', us), isEmpty);
      expect(rule.analyze('Hello,,world;;again', us), isEmpty);
    });

    test('supports both built-in English variants', () {
      const rule = MissingSpaceAfterPunctuationRule();

      expect(rule.supports(us), isTrue);
      expect(rule.supports(gb), isTrue);
    });
  });

  group('SpaceBeforePunctuationRule', () {
    test('removes one stray space before common punctuation', () {
      const rule = SpaceBeforePunctuationRule();
      const text = 'Hello , world ! Fine .';

      final issues = rule.analyze(text, us).toList();

      expect(issues, hasLength(3));
      expect(issues.map((WritingIssue issue) => issue.originalText), <String>[
        ' ,',
        ' !',
        ' .',
      ]);
      expect(issues.map((WritingIssue issue) => issue.replacement), <String>[
        ',',
        '!',
        '.',
      ]);
      for (final issue in issues) {
        expect(text.substring(issue.start, issue.end), issue.originalText);
      }
    });

    test('leaves multi-space runs to repeated-space', () {
      const rule = SpaceBeforePunctuationRule();

      expect(rule.analyze('Hello  , world', us), isEmpty);
      expect(
        const RepeatedSpaceRule().analyze('Hello  , world', us),
        isNotEmpty,
      );
    });
  });

  group('V2.6 catalogue integration', () {
    test('registry exposes both new stable rule IDs and defaults', () {
      expect(
        WritingRuleRegistry.byId('missing-space-after-punctuation'),
        isA<MissingSpaceAfterPunctuationRule>(),
      );
      expect(
        WritingRuleRegistry.byId('space-before-punctuation'),
        isA<SpaceBeforePunctuationRule>(),
      );
      expect(
        WritingRuleRegistry.defaultEnabledRuleIds,
        containsAll(<String>{
          'missing-space-after-punctuation',
          'space-before-punctuation',
        }),
      );
      expect(WritingRuleRegistry.builtIns, hasLength(6));
    });

    test('analyzer can run only the two new rules', () {
      final result = WritingAnalyzer().analyze(
        'Hello ,world',
        languagePack: us,
        enabledRuleIds: <String>{
          'missing-space-after-punctuation',
          'space-before-punctuation',
        },
      );

      expect(result.analyzedRuleIds, <String>{
        'missing-space-after-punctuation',
        'space-before-punctuation',
      });
      expect(result.issues, hasLength(2));
    });

    test('overlapping new fixes use existing deterministic batch safety', () {
      const source = 'Hello ,world';
      final result = WritingAnalyzer().analyze(
        source,
        languagePack: us,
        enabledRuleIds: <String>{
          'missing-space-after-punctuation',
          'space-before-punctuation',
        },
      );

      final correction = WritingCorrection.applyAll(source, result.issues);

      expect(correction.text, 'Hello,world');
      expect(correction.appliedCount, 1);
      expect(correction.skippedCount, 1);

      final refreshed = WritingAnalyzer().analyze(
        correction.text,
        languagePack: us,
        enabledRuleIds: <String>{
          'missing-space-after-punctuation',
          'space-before-punctuation',
        },
      );
      final secondPass = WritingCorrection.applyAll(
        correction.text,
        refreshed.issues,
      );
      expect(secondPass.text, 'Hello, world');
      expect(secondPass.appliedCount, 1);
      expect(secondPass.skippedCount, 0);
    });
  });
}
