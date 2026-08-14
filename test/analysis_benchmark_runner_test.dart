import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';

import '../tool/benchmark/analysis_benchmark_runner.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
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

      expect(summary.languageId, 'en-US');
      expect(summary.samples, hasLength(2));
      expect(summary.representativeSample.spellingCapturedIssueCount, 2);
      expect(summary.representativeSample.spellingTruncated, isTrue);
      expect(
        summary.representativeSample.spellingScannedTokenCount,
        greaterThan(2),
      );
      expect(summary.representativeSample.writingCapturedIssueCount, 5);
      expect(
        summary.representativeSample.writingTotalIssueCount,
        greaterThan(5),
      );
      expect(summary.representativeSample.writingTruncated, isTrue);
      expect(
        summary.medianSpellingElapsed,
        isNot(const Duration(microseconds: -1)),
      );
      expect(
        summary.medianWritingElapsed,
        isNot(const Duration(microseconds: -1)),
      );
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

        expect(summary.languageId, 'en-GB');
        expect(summary.representativeSample.spellingCapturedIssueCount, 1);
        expect(summary.representativeSample.spellingTruncated, isFalse);
        expect(
          summary.representativeSample.writingTotalIssueCount,
          greaterThan(0),
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
