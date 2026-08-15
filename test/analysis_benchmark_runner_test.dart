import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';

import '../tool/benchmark/analysis_benchmark_runner.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  const expectedWritingRuleIds = <String>[
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
    'unmatched-parenthesis',
  ];

  group('AnalysisBenchmarkRunner', () {
    test('runs deterministic bounded spelling and writing analysis', () {
      final scenario = AnalysisBenchmarkScenario(
        name: 'runner-test',
        repeats: 4,
        spellingIssueLimit: 2,
        writingIssueLimit: 5,
        suggestionLimit: 2,
      );
      final summary = AnalysisBenchmarkRunner(
        scenario: scenario,
        languagePack: SpellLanguageRegistry.englishUs,
        warmupIterations: 1,
        measuredIterations: 2,
      ).run();
      final sample = summary.representativeSample;

      expect(summary.languageId, 'en-US');
      expect(summary.samples, hasLength(2));
      expect(sample.spellingCapturedIssueCount, 2);
      expect(sample.spellingTruncated, isTrue);
      expect(sample.spellingScannedTokenCount, greaterThan(2));
      expect(sample.writingCapturedIssueCount, 5);
      expect(sample.writingTotalIssueCount, greaterThan(5));
      expect(sample.writingTruncated, isTrue);
      expect(sample.writingAnalyzedRuleIds, expectedWritingRuleIds);
      expect(
        sample.writingTotalIssueCountByRule.values.fold<int>(
          0,
          (total, value) => total + value,
        ),
        sample.writingTotalIssueCount,
      );
      expect(
        summary.medianSpellingElapsed,
        isNot(const Duration(microseconds: -1)),
      );
      expect(
        summary.medianWritingElapsed,
        isNot(const Duration(microseconds: -1)),
      );
    });

    test('materializes exact zero totals for analyzed rules', () {
      final summary = AnalysisBenchmarkRunner(
        scenario: AnalysisBenchmarkScenario(
          name: 'zero-rule-totals',
          repeats: 1,
          spellingIssueLimit: 5,
          writingIssueLimit: 5,
          suggestionLimit: 0,
          chunk: 'Hello world.',
        ),
        languagePack: SpellLanguageRegistry.englishUs,
        warmupIterations: 0,
        measuredIterations: 1,
      ).run();
      final sample = summary.representativeSample;

      expect(sample.writingTotalIssueCount, 0);
      expect(sample.writingCapturedIssueCount, 0);
      expect(sample.writingTruncated, isFalse);
      expect(sample.writingAnalyzedRuleIds, expectedWritingRuleIds);
      expect(
        sample.writingTotalIssueCountByRule.keys,
        orderedEquals(expectedWritingRuleIds),
      );
      expect(sample.writingTotalIssueCountByRule.values, everyElement(0));
    });

    test(
      'supports the UK language pack with the same synthetic dictionary',
      () {
        final summary = AnalysisBenchmarkRunner(
          scenario: AnalysisBenchmarkScenario(
            name: 'uk-runner-test',
            repeats: 1,
            spellingIssueLimit: 10,
            writingIssueLimit: 20,
            suggestionLimit: 0,
          ),
          languagePack: SpellLanguageRegistry.englishGb,
          warmupIterations: 0,
          measuredIterations: 1,
        ).run();
        final sample = summary.representativeSample;

        expect(summary.languageId, 'en-GB');
        expect(sample.spellingCapturedIssueCount, 1);
        expect(sample.spellingTruncated, isFalse);
        expect(sample.writingTotalIssueCount, greaterThan(0));
        expect(sample.writingAnalyzedRuleIds, expectedWritingRuleIds);
        expect(
          sample.writingTotalIssueCountByRule.values.fold<int>(
            0,
            (total, value) => total + value,
          ),
          sample.writingTotalIssueCount,
        );
      },
    );

    test('rejects invalid iteration counts', () {
      final scenario = AnalysisBenchmarkScenario(
        name: 'validation',
        repeats: 1,
        spellingIssueLimit: 1,
        writingIssueLimit: 1,
        suggestionLimit: 0,
      );

      expect(
        () => AnalysisBenchmarkRunner(
          scenario: scenario,
          languagePack: SpellLanguageRegistry.englishUs,
          warmupIterations: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkRunner(
          scenario: scenario,
          languagePack: SpellLanguageRegistry.englishUs,
          measuredIterations: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
