import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  test('diagnostic summary includes unmatched square bracket metadata only', () {
    const source = 'Sensitive project [codename';
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      source,
      languagePack: SpellLanguageRegistry.englishUs,
    );
    final summary = WritingAnalysisDiagnosticSummary.fromResult(
      result,
      rules: analyzer.rules,
    );
    final output = summary.toPlainText();

    final rule = summary.rules.singleWhere(
      (rule) => rule.ruleId == 'unmatched-square-bracket',
    );
    expect(rule.displayName, 'Unmatched square bracket');
    expect(rule.capturedIssueCount, 1);
    expect(rule.totalIssueCount, 1);
    expect(
      output,
      contains(
        '- Unmatched square bracket [unmatched-square-bracket]: 1/1 captured/total',
      ),
    );
    expect(output, isNot(contains(source)));
    expect(output, isNot(contains('Sensitive project')));
    expect(output, isNot(contains('codename')));
    expect(output, contains('editor text and finding excerpts are excluded'));
  });

  test('clean diagnostics materialize a zero total for the ninth rule', () {
    final analyzer = WritingAnalyzer();
    final result = analyzer.analyze(
      'Balanced [text].',
      languagePack: SpellLanguageRegistry.englishUs,
    );
    final summary = WritingAnalysisDiagnosticSummary.fromResult(
      result,
      rules: analyzer.rules,
    );

    final rule = summary.rules.singleWhere(
      (rule) => rule.ruleId == 'unmatched-square-bracket',
    );
    expect(rule.capturedIssueCount, 0);
    expect(rule.totalIssueCount, 0);
  });
}
