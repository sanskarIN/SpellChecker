import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('public registry exposes ten built-in writing rules', () {
    expect(WritingRuleRegistry.builtIns, hasLength(10));
    expect(
      WritingRuleRegistry.byId('unmatched-curly-brace'),
      isA<UnmatchedCurlyBraceRule>(),
    );
    expect(
      WritingRuleRegistry.defaultEnabledRuleIds,
      contains('unmatched-curly-brace'),
    );
    expect(WritingRuleRegistry.defaultEnabledRuleIds, hasLength(10));
  });

  test('default analyzer includes unmatched curly brace findings', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'Balanced {text} and unfinished {text',
      languagePack: pack,
    );

    expect(result.analyzedRuleIds, contains('unmatched-curly-brace'));
    expect(result.issueCountByRule['unmatched-curly-brace'], 1);
    final issue = result.issues.singleWhere(
      (issue) => issue.ruleId == 'unmatched-curly-brace',
    );
    expect(issue.originalText, '{');
    expect(issue.hasAutomaticFix, isFalse);
  });

  test('explicit enabled rules can isolate unmatched curly brace analysis', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'hello  {world',
      languagePack: pack,
      enabledRuleIds: const <String>{'unmatched-curly-brace'},
    );

    expect(result.analyzedRuleIds, const <String>{'unmatched-curly-brace'});
    expect(result.issues, hasLength(1));
    expect(result.issues.single.ruleId, 'unmatched-curly-brace');
  });

  test('batch correction skips advisory curly brace and applies safe fixes', () {
    const text = 'Hello  {world';
    final analyzer = WritingAnalyzer();
    final analysis = analyzer.analyze(
      text,
      languagePack: pack,
      enabledRuleIds: const <String>{
        'repeated-space',
        'unmatched-curly-brace',
      },
    );

    expect(analysis.issues, hasLength(2));
    final result = WritingCorrection.applyAll(text, analysis.issues);

    expect(result.text, 'Hello {world');
    expect(result.appliedCount, 1);
    expect(result.skippedCount, 1);
    expect(result.applied, isTrue);
  });

  test('curly-brace-only advisory batch leaves source text unchanged', () {
    const text = 'Hello {world';
    final issue = const UnmatchedCurlyBraceRule().analyze(text, pack).single;

    final result = WritingCorrection.applyAll(text, <WritingIssue>[issue]);

    expect(result.text, text);
    expect(result.appliedCount, 0);
    expect(result.skippedCount, 1);
    expect(result.applied, isFalse);
  });

  test('all three structural delimiter families remain independent', () {
    const text = '([{text';
    final result = WritingAnalyzer().analyze(
      text,
      languagePack: pack,
      enabledRuleIds: const <String>{
        'unmatched-parenthesis',
        'unmatched-square-bracket',
        'unmatched-curly-brace',
      },
    );

    expect(result.issues, hasLength(3));
    expect(
      result.issues.map((issue) => issue.ruleId),
      orderedEquals(const <String>[
        'unmatched-parenthesis',
        'unmatched-square-bracket',
        'unmatched-curly-brace',
      ]),
    );
    expect(
      result.issues.map((issue) => issue.originalText),
      orderedEquals(const <String>['(', '[', '{']),
    );
  });
}
