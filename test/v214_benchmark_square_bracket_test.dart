import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';

import '../tool/benchmark/analysis_benchmark_runner.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  test('benchmark reports exact unmatched square bracket totals', () {
    final summary = AnalysisBenchmarkRunner(
      scenario: AnalysisBenchmarkScenario(
        name: 'v214-square-bracket',
        repeats: 1,
        spellingIssueLimit: 10,
        writingIssueLimit: 10,
        suggestionLimit: 0,
        chunk: 'Hello [world.',
      ),
      languagePack: SpellLanguageRegistry.englishUs,
      warmupIterations: 0,
      measuredIterations: 1,
    ).run();
    final sample = summary.representativeSample;

    expect(sample.writingTruncated, isFalse);
    expect(sample.writingTotalIssueCount, 1);
    expect(sample.writingCapturedIssueCount, 1);
    expect(
      sample.writingAnalyzedRuleIds,
      contains('unmatched-square-bracket'),
    );
    expect(
      sample.writingTotalIssueCountByRule['unmatched-square-bracket'],
      1,
    );
    expect(
      sample.writingTotalIssueCountByRule.values.fold<int>(
        0,
        (total, value) => total + value,
      ),
      1,
    );
  });
}
