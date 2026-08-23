import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_result.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  test('summary reports nearest-rank p95 latency in format version 2', () {
    final scenario = AnalysisBenchmarkScenario(
      name: 'percentile-test',
      repeats: 1,
      spellingIssueLimit: 10,
      writingIssueLimit: 10,
      suggestionLimit: 0,
    );
    final samples = List<AnalysisBenchmarkSample>.generate(20, (index) {
      final ordinal = index + 1;
      return AnalysisBenchmarkSample(
        index: index,
        spellingElapsed: Duration(microseconds: ordinal),
        writingElapsed: Duration(microseconds: ordinal * 100),
        spellingScannedTokenCount: 10,
        spellingCapturedIssueCount: 1,
        spellingTruncated: false,
        writingCapturedIssueCount: 1,
        writingTotalIssueCount: 1,
        writingTruncated: false,
        writingAnalyzedRuleIds: const <String>['rule-a'],
        writingTotalIssueCountByRule: const <String, int>{'rule-a': 1},
      );
    });

    final summary = AnalysisBenchmarkSummary(
      scenario: scenario,
      languageId: 'en-US',
      warmupIterations: 1,
      samples: samples,
    );
    final aggregate = summary.toJson()['aggregate'] as Map<String, Object>;

    expect(AnalysisBenchmarkSummary.formatVersion, 2);
    expect(summary.p95SpellingElapsed.inMicroseconds, 19);
    expect(summary.p95WritingElapsed.inMicroseconds, 1900);
    expect(aggregate['spellingP95Microseconds'], 19);
    expect(aggregate['writingP95Microseconds'], 1900);
  });
}
