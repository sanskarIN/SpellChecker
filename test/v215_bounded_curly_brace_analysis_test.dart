import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('exactly-at-limit unmatched curly brace analysis stays complete', () {
    final result = WritingAnalyzer().analyze(
      'unfinished {text',
      languagePack: pack,
      enabledRuleIds: const <String>{'unmatched-curly-brace'},
      maxIssues: 1,
    );

    expect(result.capturedIssueCount, 1);
    expect(result.totalIssueCount, 1);
    expect(result.uncapturedIssueCount, 0);
    expect(result.isTruncated, isFalse);
    expect(result.totalIssueCountByRule?['unmatched-curly-brace'], 1);
  });

  test('bounded analysis reports exact omitted curly brace findings', () {
    final result = WritingAnalyzer().analyze(
      '}middle{',
      languagePack: pack,
      enabledRuleIds: const <String>{'unmatched-curly-brace'},
      maxIssues: 1,
    );

    expect(result.capturedIssueCount, 1);
    expect(result.totalIssueCount, 2);
    expect(result.uncapturedIssueCount, 1);
    expect(result.isTruncated, isTrue);
    expect(result.issues.single.start, 0);
    expect(result.issues.single.originalText, '}');
    expect(result.totalIssueCountByRule?['unmatched-curly-brace'], 2);
  });

  test('global bounded ordering keeps earlier findings from other rules', () {
    final result = WritingAnalyzer().analyze(
      'hello  world}',
      languagePack: pack,
      enabledRuleIds: const <String>{
        'sentence-capitalization',
        'repeated-space',
        'unmatched-curly-brace',
      },
      maxIssues: 1,
    );

    expect(result.capturedIssueCount, 1);
    expect(result.totalIssueCount, 3);
    expect(result.isTruncated, isTrue);
    expect(result.issues.single.ruleId, 'sentence-capitalization');
    expect(result.totalIssueCountByRule?['sentence-capitalization'], 1);
    expect(result.totalIssueCountByRule?['repeated-space'], 1);
    expect(result.totalIssueCountByRule?['unmatched-curly-brace'], 1);
  });
}
