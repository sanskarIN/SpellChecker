import 'analysis_benchmark_result.dart';

String formatAnalysisBenchmarkSummary(AnalysisBenchmarkSummary summary) {
  final scenario = summary.scenario;
  final sample = summary.representativeSample;
  final writingRuleIds = sample.writingAnalyzedRuleIds.join(', ');
  final writingTotals = sample.writingTotalIssueCountByRule.entries
      .map((entry) => '${entry.key}=${entry.value}')
      .join(', ');
  final lines = <String>[
    'SpellChecker deterministic analysis benchmark',
    'Language: ${summary.languageId}',
    'Scenario: ${scenario.name}',
    'Synthetic repetitions: ${scenario.repeats}',
    'Synthetic characters: ${scenario.characterCount}',
    'Warmup iterations: ${summary.warmupIterations}',
    'Measured iterations: ${summary.samples.length}',
    '',
    'Analysis outcome',
    '  Spelling scanned tokens: ${sample.spellingScannedTokenCount}',
    '  Spelling captured issues: ${sample.spellingCapturedIssueCount}',
    '  Spelling truncated: ${sample.spellingTruncated}',
    '  Writing captured findings: ${sample.writingCapturedIssueCount}',
    '  Writing total findings: ${sample.writingTotalIssueCount}',
    '  Writing truncated: ${sample.writingTruncated}',
    '  Writing analyzed rules: ${writingRuleIds.isEmpty ? '(none)' : writingRuleIds}',
    '  Writing exact totals by rule: ${writingTotals.isEmpty ? '(none)' : writingTotals}',
    '',
    'Timing (microseconds)',
    '  Spelling min/median/p95/max: '
        '${summary.minSpellingElapsed.inMicroseconds}/'
        '${summary.medianSpellingElapsed.inMicroseconds}/'
        '${summary.p95SpellingElapsed.inMicroseconds}/'
        '${summary.maxSpellingElapsed.inMicroseconds}',
    '  Writing min/median/p95/max: '
        '${summary.minWritingElapsed.inMicroseconds}/'
        '${summary.medianWritingElapsed.inMicroseconds}/'
        '${summary.p95WritingElapsed.inMicroseconds}/'
        '${summary.maxWritingElapsed.inMicroseconds}',
    '',
    'Note: timings are machine-dependent. The benchmark corpus is generated '
        'synthetically and report output does not include corpus text.',
  ];
  return lines.join('\n');
}
