import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_options.dart';

void main() {
  group('AnalysisBenchmarkOptions', () {
    test('uses documented defaults', () {
      final options = AnalysisBenchmarkOptions.parse(const <String>[]);

      expect(options.repeats, 2000);
      expect(options.warmupIterations, 1);
      expect(options.measuredIterations, 5);
      expect(options.spellingIssueLimit, 200);
      expect(options.writingIssueLimit, 200);
      expect(options.suggestionLimit, 5);
      expect(options.languageId, 'en-US');
      expect(options.json, isFalse);
      expect(options.help, isFalse);
    });

    test('parses every supported option and maps scenario bounds', () {
      final options = AnalysisBenchmarkOptions.parse(const <String>[
        '--repeats=30',
        '--warmup=2',
        '--iterations=7',
        '--spelling-limit=40',
        '--writing-limit=50',
        '--suggestions=3',
        '--language=en-GB',
        '--json',
      ]);

      expect(options.repeats, 30);
      expect(options.warmupIterations, 2);
      expect(options.measuredIterations, 7);
      expect(options.spellingIssueLimit, 40);
      expect(options.writingIssueLimit, 50);
      expect(options.suggestionLimit, 3);
      expect(options.languageId, 'en-GB');
      expect(options.json, isTrue);

      final scenario = options.toScenario();
      expect(scenario.repeats, 30);
      expect(scenario.spellingIssueLimit, 40);
      expect(scenario.writingIssueLimit, 50);
      expect(scenario.suggestionLimit, 3);
    });

    test('recognizes help without weakening other validation', () {
      final options = AnalysisBenchmarkOptions.parse(const <String>['--help']);
      expect(options.help, isTrue);
      expect(AnalysisBenchmarkOptions.usage, contains('--iterations=N'));
      expect(
        AnalysisBenchmarkOptions.usage,
        contains('Any built-in language ID'),
      );
      expect(AnalysisBenchmarkOptions.usage, isNot(contains('en-US or en-GB')));
    });

    test('parses a non-English built-in-shaped language ID', () {
      final options = AnalysisBenchmarkOptions.parse(const <String>[
        '--language=hi-IN',
      ]);

      expect(options.languageId, 'hi-IN');
    });

    test('rejects malformed unknown duplicate and invalid values', () {
      expect(
        () => AnalysisBenchmarkOptions.parse(const <String>['repeats=2']),
        throwsFormatException,
      );
      expect(
        () => AnalysisBenchmarkOptions.parse(const <String>['--unknown=2']),
        throwsFormatException,
      );
      expect(
        () => AnalysisBenchmarkOptions.parse(const <String>[
          '--repeats=2',
          '--repeats=3',
        ]),
        throwsFormatException,
      );
      expect(
        () => AnalysisBenchmarkOptions.parse(const <String>['--warmup=nope']),
        throwsFormatException,
      );
      expect(
        () => AnalysisBenchmarkOptions.parse(const <String>['--iterations=0']),
        throwsArgumentError,
      );
      expect(
        () =>
            AnalysisBenchmarkOptions.parse(const <String>['--suggestions=-1']),
        throwsArgumentError,
      );
    });
  });
}
