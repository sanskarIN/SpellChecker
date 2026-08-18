import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('bounded analysis retains exact totals for V3.3 colon findings', () {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[MissingColonSpaceRule()],
    );

    final result = analyzer.analyze(
      'One:two Three:four Five:six',
      languagePack: pack,
      maxIssues: 2,
    );

    expect(result.capturedIssueCount, 2);
    expect(result.isTruncated, isTrue);
    expect(result.totalIssueCount, 3);
    expect(result.uncapturedIssueCount, 1);
    expect(result.totalIssueCountByRule, <String, int>{
      'missing-colon-space': 3,
    });
    expect(result.issueCountByRule, <String, int>{'missing-colon-space': 2});
  });

  test('complete V3.3 colon analysis reports matching captured totals', () {
    final result = WritingAnalyzer(
      rules: const <WritingRule>[MissingColonSpaceRule()],
    ).analyze('One:two Three:four', languagePack: pack);

    expect(result.isTruncated, isFalse);
    expect(result.totalIssueCount, 2);
    expect(result.totalIssueCountByRule, <String, int>{
      'missing-colon-space': 2,
    });
    expect(result.issueCountByRule, <String, int>{'missing-colon-space': 2});
  });

  test('diagnostic summary reports V3.3 colon totals without source text', () {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[MissingColonSpaceRule()],
    );
    const text = 'Private:example Another:value Third:item';
    final result = analyzer.analyze(
      text,
      languagePack: pack,
      maxIssues: 2,
    );

    final summary = WritingAnalysisDiagnosticSummary.fromResult(
      result,
      rules: analyzer.rules,
    ).toPlainText();

    expect(summary, contains('Analysis status: limited'));
    expect(summary, contains('Captured findings: 2'));
    expect(summary, contains('Total findings: 3'));
    expect(summary, contains('[missing-colon-space] Missing colon space'));
    expect(summary, contains('2 captured; 3 total'));
    expect(summary, isNot(contains(text)));
    expect(summary, isNot(contains('Private:example')));
  });
}
