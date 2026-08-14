import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  group('missing punctuation space integration', () {
    test('default analyzer includes the seventh built-in rule', () {
      final result = WritingAnalyzer().analyze(
        'Hello,world',
        languagePack: pack,
      );

      expect(result.analyzedRuleIds, hasLength(7));
      expect(
        result.analyzedRuleIds,
        contains('missing-punctuation-space'),
      );
      expect(result.issueCountByRule['missing-punctuation-space'], 1);
      expect(result.totalIssueCountByRule?['missing-punctuation-space'], 1);
    });

    test('registry resolves and enables the stable rule id by default', () {
      expect(
        WritingRuleRegistry.byId('missing-punctuation-space'),
        isA<MissingPunctuationSpaceRule>(),
      );
      expect(
        WritingRuleRegistry.defaultEnabledRuleIds,
        contains('missing-punctuation-space'),
      );
    });

    test('explicit enabled ids can isolate the rule', () {
      final result = WritingAnalyzer().analyze(
        'Hello,world!Again',
        languagePack: pack,
        enabledRuleIds: const <String>{'missing-punctuation-space'},
      );

      expect(
        result.analyzedRuleIds,
        const <String>{'missing-punctuation-space'},
      );
      expect(result.issues, hasLength(2));
      expect(
        result.issues.every(
          (issue) => issue.ruleId == 'missing-punctuation-space',
        ),
        isTrue,
      );
      expect(result.totalIssueCount, 2);
      expect(
        result.totalIssueCountByRule,
        const <String, int>{'missing-punctuation-space': 2},
      );
    });

    test('bounded diagnostics retain exact totals for the new rule', () {
      final result = WritingAnalyzer().analyze(
        'one,two,three,four,five',
        languagePack: pack,
        enabledRuleIds: const <String>{'missing-punctuation-space'},
        maxIssues: 2,
      );

      expect(result.capturedIssueCount, 2);
      expect(result.totalIssueCount, 4);
      expect(result.uncapturedIssueCount, 2);
      expect(result.isTruncated, isTrue);
      expect(
        result.totalIssueCountByRule,
        const <String, int>{'missing-punctuation-space': 4},
      );
    });

    test('adjacent before-and-after punctuation fixes compose in one batch', () {
      const text = 'Hello ,world';
      final result = WritingAnalyzer().analyze(
        text,
        languagePack: pack,
        enabledRuleIds: const <String>{
          'punctuation-spacing',
          'missing-punctuation-space',
        },
      );

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
      expect(correction.text, 'Hello, world');
    });

    test('repeated punctuation remains owned by its specialized rule', () {
      final result = WritingAnalyzer().analyze(
        'Really??Yes!!No',
        languagePack: pack,
        enabledRuleIds: const <String>{
          'missing-punctuation-space',
          'repeated-punctuation',
        },
      );

      expect(result.issueCountByRule['missing-punctuation-space'], isNull);
      expect(result.issueCountByRule['repeated-punctuation'], 2);
    });
  });
}
