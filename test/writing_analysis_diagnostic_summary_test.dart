import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('summary is deterministic and excludes document content', () {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[
        _SummaryRule('zeta', 'Zeta rule', <int>[5, 1]),
        _SummaryRule('alpha', 'Alpha rule', <int>[3, 2, 4]),
      ],
    );

    final result = analyzer.analyze(
      'sample document body',
      languagePack: pack,
      maxIssues: 2,
    );
    final summary = WritingAnalysisDiagnosticSummary.fromResult(
      result,
      rules: analyzer.rules.reversed,
    ).toPlainText();

    expect(summary, contains('Language: en-US'));
    expect(summary, contains('Analysis status: limited'));
    expect(summary, contains('Captured findings: 2'));
    expect(summary, contains('Total findings: 5'));
    expect(summary, contains('Uncaptured findings: 3'));
    expect(summary, contains('Capture limit: 2'));
    expect(summary.indexOf('[alpha]'), lessThan(summary.indexOf('[zeta]')));
    expect(summary, isNot(contains('sample document body')));
    expect(summary, isNot(contains('Synthetic finding')));
  });

  test('summary handles compatibility results without exact totals', () {
    const issue = WritingIssue(
      ruleId: 'alpha',
      ruleName: 'Alpha rule',
      message: 'Sample finding message.',
      start: 0,
      end: 1,
      originalText: 'x',
      replacement: 'X',
      languageId: 'en-US',
    );
    final result = WritingAnalysisResult(
      issues: const <WritingIssue>[issue],
      analyzedRuleIds: const <String>{'alpha'},
      languageId: 'en-US',
      issueLimit: 1,
      isTruncated: true,
    );

    final summary = WritingAnalysisDiagnosticSummary.fromResult(result)
        .toPlainText();

    expect(summary, contains('Total findings: unavailable'));
    expect(summary, contains('Uncaptured findings: unavailable'));
    expect(summary, contains('1 captured; total unavailable'));
    expect(summary, isNot(contains('Sample finding message.')));
    expect(summary, isNot(contains('Text: x')));
  });

  test('empty analysis exports an explicit empty rule section', () {
    final result = WritingAnalyzer(rules: const <WritingRule>[])
        .analyze('', languagePack: pack, maxIssues: 10);

    final summary = WritingAnalysisDiagnosticSummary.fromResult(result)
        .toPlainText();

    expect(summary, contains('Analysis status: complete'));
    expect(summary, contains('Total findings: 0'));
    expect(summary, contains('Rule totals:\n- none'));
  });
}

class _SummaryRule extends WritingRule {
  const _SummaryRule(this.id, this.displayName, this.offsets);

  @override
  final String id;

  @override
  final String displayName;

  final List<int> offsets;

  @override
  String get description => 'Synthetic summary rule.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final offset in offsets) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Synthetic finding at $offset.',
        start: offset,
        end: offset + 1,
        originalText: text.substring(offset, offset + 1),
        replacement: '',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
