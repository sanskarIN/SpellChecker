import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('public registry exposes eight built-in writing rules', () {
    expect(WritingRuleRegistry.builtIns, hasLength(8));
    expect(
      WritingRuleRegistry.byId('unmatched-parenthesis'),
      isA<UnmatchedParenthesisRule>(),
    );
    expect(
      WritingRuleRegistry.defaultEnabledRuleIds,
      contains('unmatched-parenthesis'),
    );
    expect(WritingRuleRegistry.defaultEnabledRuleIds, hasLength(8));
  });

  test('default analyzer includes unmatched parenthesis findings', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'Balanced (text) and unfinished (text',
      languagePack: pack,
    );

    expect(result.analyzedRuleIds, contains('unmatched-parenthesis'));
    expect(result.issueCountByRule['unmatched-parenthesis'], 1);
    final issue = result.issues.singleWhere(
      (issue) => issue.ruleId == 'unmatched-parenthesis',
    );
    expect(issue.originalText, '(');
    expect(issue.hasAutomaticFix, isFalse);
  });

  test('explicit enabled rules can isolate unmatched parenthesis analysis', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'hello  (world',
      languagePack: pack,
      enabledRuleIds: const <String>{'unmatched-parenthesis'},
    );

    expect(result.analyzedRuleIds, const <String>{'unmatched-parenthesis'});
    expect(result.issues, hasLength(1));
    expect(result.issues.single.ruleId, 'unmatched-parenthesis');
  });

  test('batch correction skips advisory parenthesis and applies safe fixes', () {
    const text = 'Hello  (world';
    final analyzer = WritingAnalyzer();
    final analysis = analyzer.analyze(
      text,
      languagePack: pack,
      enabledRuleIds: const <String>{
        'repeated-space',
        'unmatched-parenthesis',
      },
    );

    expect(analysis.issues, hasLength(2));
    final result = WritingCorrection.applyAll(text, analysis.issues);

    expect(result.text, 'Hello (world');
    expect(result.appliedCount, 1);
    expect(result.skippedCount, 1);
    expect(result.applied, isTrue);
  });

  test('parenthesis-only advisory batch leaves source text unchanged', () {
    const text = 'Hello (world';
    final issue = const UnmatchedParenthesisRule().analyze(text, pack).single;

    final result = WritingCorrection.applyAll(text, <WritingIssue>[issue]);

    expect(result.text, text);
    expect(result.appliedCount, 0);
    expect(result.skippedCount, 1);
    expect(result.applied, isFalse);
  });
}
