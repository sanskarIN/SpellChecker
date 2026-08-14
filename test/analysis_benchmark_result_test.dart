import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_result.dart';
import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  AnalysisBenchmarkSample sample({
    required int index,
    required int spellingMicros,
    required int writingMicros,
    int spellingScannedTokens = 20,
    int spellingCapturedIssues = 4,
    bool spellingTruncated = true,
    int writingCapturedIssues = 5,
    int writingTotalIssues = 9,
    bool writingTruncated = true,
  }) {
    return AnalysisBenchmarkSample(
      index: index,
      spellingElapsed: Duration(microseconds: spellingMicros),
      writingElapsed: Duration(microseconds: writingMicros),
      spellingScannedTokenCount: spellingScannedTokens,
      spellingCapturedIssueCount: spellingCapturedIssues,
      spellingTruncated: spellingTruncated,
      writingCapturedIssueCount: writingCapturedIssues,
      writingTotalIssueCount: writingTotalIssues,
      writingTruncated: writingTruncated,
    );
  }

  final scenario = AnalysisBenchmarkScenario(
    name: 'result-test',
    repeats: 2,
    spellingIssueLimit: 4,
    writingIssueLimit: 5,
    suggestionLimit: 2,
    chunk: 'do-not-export-this-text',
  );

  group('AnalysisBenchmarkSample', () {
    test('rejects impossible counts and negative durations', () {
      expect(
        () => AnalysisBenchmarkSample(
          index: 0,
          spellingElapsed: const Duration(microseconds: -1),
          writingElapsed: Duration.zero,
          spellingScannedTokenCount: 0,
          spellingCapturedIssueCount: 0,
          spellingTruncated: false,
          writingCapturedIssueCount: 0,
          writingTotalIssueCount: 0,
          writingTruncated: false,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkSample(
          index: 0,
          spellingElapsed: Duration.zero,
          writingElapsed: Duration.zero,
          spellingScannedTokenCount: 0,
          spellingCapturedIssueCount: 0,
          spellingTruncated: false,
          writingCapturedIssueCount: 2,
          writingTotalIssueCount: 1,
          writingTruncated: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => sample(
          index: 0,
          spellingMicros: 1,
          writingMicros: 1,
          spellingScannedTokens: 2,
          spellingCapturedIssues: 3,
        ),
        throwsArgumentError,
      );
    });

    test('requires writing truncation to match exact uncaptured findings', () {
      expect(
        () => sample(
          index: 0,
          spellingMicros: 1,
          writingMicros: 1,
          writingCapturedIssues: 5,
          writingTotalIssues: 9,
          writingTruncated: false,
        ),
        throwsArgumentError,
      );
      expect(
        () => sample(
          index: 0,
          spellingMicros: 1,
          writingMicros: 1,
          writingCapturedIssues: 5,
          writingTotalIssues: 5,
          writingTruncated: true,
        ),
        throwsArgumentError,
      );
    });
  });

  group('AnalysisBenchmarkSummary', () {
    test('computes stable aggregate timings and immutable samples', () {
      final source = <AnalysisBenchmarkSample>[
        sample(index: 0, spellingMicros: 30, writingMicros: 80),
        sample(index: 1, spellingMicros: 10, writingMicros: 20),
        sample(index: 2, spellingMicros: 20, writingMicros: 50),
      ];
      final summary = AnalysisBenchmarkSummary(
        scenario: scenario,
        languageId: 'en-US',
        warmupIterations: 1,
        samples: source,
      );
      source.clear();

      expect(summary.samples, hasLength(3));
      expect(summary.minSpellingElapsed.inMicroseconds, 10);
      expect(summary.medianSpellingElapsed.inMicroseconds, 20);
      expect(summary.maxSpellingElapsed.inMicroseconds, 30);
      expect(summary.minWritingElapsed.inMicroseconds, 20);
      expect(summary.medianWritingElapsed.inMicroseconds, 50);
      expect(summary.maxWritingElapsed.inMicroseconds, 80);
      expect(
        () => summary.samples.add(summary.samples.first),
        throwsUnsupportedError,
      );
    });

    test('uses midpoint average for an even sample count', () {
      final summary = AnalysisBenchmarkSummary(
        scenario: scenario,
        languageId: 'en-US',
        warmupIterations: 0,
        samples: <AnalysisBenchmarkSample>[
          sample(index: 0, spellingMicros: 10, writingMicros: 100),
          sample(index: 1, spellingMicros: 20, writingMicros: 200),
          sample(index: 2, spellingMicros: 30, writingMicros: 300),
          sample(index: 3, spellingMicros: 40, writingMicros: 400),
        ],
      );

      expect(summary.medianSpellingElapsed.inMicroseconds, 25);
      expect(summary.medianWritingElapsed.inMicroseconds, 250);
    });

    test('rejects non-contiguous indexes and changing analysis outcomes', () {
      expect(
        () => AnalysisBenchmarkSummary(
          scenario: scenario,
          languageId: 'en-US',
          warmupIterations: 0,
          samples: <AnalysisBenchmarkSample>[
            sample(index: 1, spellingMicros: 1, writingMicros: 1),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => AnalysisBenchmarkSummary(
          scenario: scenario,
          languageId: 'en-US',
          warmupIterations: 0,
          samples: <AnalysisBenchmarkSample>[
            sample(index: 0, spellingMicros: 1, writingMicros: 1),
            sample(
              index: 1,
              spellingMicros: 2,
              writingMicros: 2,
              writingTotalIssues: 10,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('rejects samples that contradict scenario capture limits', () {
      expect(
        () => AnalysisBenchmarkSummary(
          scenario: scenario,
          languageId: 'en-US',
          warmupIterations: 0,
          samples: <AnalysisBenchmarkSample>[
            sample(
              index: 0,
              spellingMicros: 1,
              writingMicros: 1,
              spellingCapturedIssues: 5,
              spellingTruncated: false,
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => AnalysisBenchmarkSummary(
          scenario: scenario,
          languageId: 'en-US',
          warmupIterations: 0,
          samples: <AnalysisBenchmarkSample>[
            sample(
              index: 0,
              spellingMicros: 1,
              writingMicros: 1,
              spellingCapturedIssues: 3,
            ),
          ],
        ),
        throwsArgumentError,
      );

      expect(
        () => AnalysisBenchmarkSummary(
          scenario: scenario,
          languageId: 'en-US',
          warmupIterations: 0,
          samples: <AnalysisBenchmarkSample>[
            sample(
              index: 0,
              spellingMicros: 1,
              writingMicros: 1,
              writingCapturedIssues: 4,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('JSON report contains metadata and timings but no corpus text', () {
      final summary = AnalysisBenchmarkSummary(
        scenario: scenario,
        languageId: 'en-US',
        warmupIterations: 2,
        samples: <AnalysisBenchmarkSample>[
          sample(index: 0, spellingMicros: 12, writingMicros: 34),
        ],
      );
      final decoded =
          jsonDecode(summary.toPrettyJson()) as Map<String, dynamic>;

      expect(decoded['formatVersion'], AnalysisBenchmarkSummary.formatVersion);
      expect(decoded['language'], 'en-US');
      expect(decoded['warmupIterations'], 2);
      expect(decoded['measuredIterations'], 1);
      expect(
        summary.toPrettyJson(),
        isNot(contains('do-not-export-this-text')),
      );
    });
  });
}
