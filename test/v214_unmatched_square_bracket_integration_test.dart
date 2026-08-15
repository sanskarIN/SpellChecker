import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('public registry exposes nine built-in writing rules', () {
    expect(WritingRuleRegistry.builtIns, hasLength(9));
    expect(
      WritingRuleRegistry.byId('unmatched-square-bracket'),
      isA<UnmatchedSquareBracketRule>(),
    );
    expect(
      WritingRuleRegistry.defaultEnabledRuleIds,
      contains('unmatched-square-bracket'),
    );
    expect(WritingRuleRegistry.defaultEnabledRuleIds, hasLength(9));
  });

  test('default analyzer includes unmatched square bracket findings', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'Balanced [text] and unfinished [text',
      languagePack: pack,
    );

    expect(result.analyzedRuleIds, contains('unmatched-square-bracket'));
    expect(result.issueCountByRule['unmatched-square-bracket'], 1);
    final issue = result.issues.singleWhere(
      (issue) => issue.ruleId == 'unmatched-square-bracket',
    );
    expect(issue.originalText, '[');
    expect(issue.hasAutomaticFix, isFalse);
  });

  test(
    'explicit enabled rules can isolate unmatched square bracket analysis',
    () {
      final analyzer = WritingAnalyzer();
      final result = analyzer.analyze(
        'hello  [world',
        languagePack: pack,
        enabledRuleIds: const <String>{'unmatched-square-bracket'},
      );

      expect(result.analyzedRuleIds, const <String>{
        'unmatched-square-bracket',
      });
      expect(result.issues, hasLength(1));
      expect(result.issues.single.ruleId, 'unmatched-square-bracket');
    },
  );

  test(
    'batch correction skips advisory square bracket and applies safe fixes',
    () {
      const text = 'Hello  [world';
      final analyzer = WritingAnalyzer();
      final analysis = analyzer.analyze(
        text,
        languagePack: pack,
        enabledRuleIds: const <String>{
          'repeated-space',
          'unmatched-square-bracket',
        },
      );

      expect(analysis.issues, hasLength(2));
      final result = WritingCorrection.applyAll(text, analysis.issues);

      expect(result.text, 'Hello [world');
      expect(result.appliedCount, 1);
      expect(result.skippedCount, 1);
      expect(result.applied, isTrue);
    },
  );

  test('square-bracket-only advisory batch leaves source text unchanged', () {
    const text = 'Hello [world';
    final issue = const UnmatchedSquareBracketRule().analyze(text, pack).single;

    final result = WritingCorrection.applyAll(text, <WritingIssue>[issue]);

    expect(result.text, text);
    expect(result.appliedCount, 0);
    expect(result.skippedCount, 1);
    expect(result.applied, isFalse);
  });

  test('parenthesis and square bracket diagnostics remain independent', () {
    const text = '([text';
    final result = WritingAnalyzer().analyze(
      text,
      languagePack: pack,
      enabledRuleIds: const <String>{
        'unmatched-parenthesis',
        'unmatched-square-bracket',
      },
    );

    expect(result.issues, hasLength(2));
    expect(
      result.issues.map((issue) => issue.ruleId),
      orderedEquals(const <String>[
        'unmatched-parenthesis',
        'unmatched-square-bracket',
      ]),
    );
    expect(
      result.issues.map((issue) => issue.originalText),
      orderedEquals(const <String>['(', '[']),
    );
  });
}
