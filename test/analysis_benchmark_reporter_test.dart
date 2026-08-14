import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_reporter.dart';
import '../tool/benchmark/analysis_benchmark_result.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  test('human report includes outcomes and timings without corpus text', () {
    final scenario = AnalysisBenchmarkScenario(
      name: 'report-test',
      repeats: 2,
      spellingIssueLimit: 3,
      writingIssueLimit: 4,
      suggestionLimit: 1,
      chunk: 'never-print-this-corpus',
    );
    final summary = AnalysisBenchmarkSummary(
      scenario: scenario,
      languageId: 'en-US',
      warmupIterations: 1,
      samples: <AnalysisBenchmarkSample>[
        AnalysisBenchmarkSample(
          index: 0,
          spellingElapsed: const Duration(microseconds: 10),
          writingElapsed: const Duration(microseconds: 20),
          spellingScannedTokenCount: 12,
          spellingCapturedIssueCount: 3,
          spellingTruncated: true,
          writingCapturedIssueCount: 4,
          writingTotalIssueCount: 8,
          writingTruncated: true,
          writingAnalyzedRuleIds: const <String>['rule-b', 'rule-a'],
          writingTotalIssueCountByRule: const <String, int>{
            'rule-b': 3,
            'rule-a': 5,
          },
        ),
      ],
    );

    final report = formatAnalysisBenchmarkSummary(summary);

    expect(report, contains('SpellChecker deterministic analysis benchmark'));
    expect(report, contains('Language: en-US'));
    expect(report, contains('Spelling min/median/max: 10/10/10'));
    expect(report, contains('Writing total findings: 8'));
    expect(report, contains('Writing analyzed rules: rule-a, rule-b'));
    expect(
      report,
      contains('Writing exact totals by rule: rule-a=5, rule-b=3'),
    );
    expect(report, contains('generated synthetically'));
    expect(report, isNot(contains('never-print-this-corpus')));
  });
}
