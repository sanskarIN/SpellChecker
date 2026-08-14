import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_scenario.dart';

void main() {
  group('AnalysisBenchmarkScenario', () {
    test('builds deterministic repeated synthetic text', () {
      final scenario = AnalysisBenchmarkScenario(
        name: 'tiny',
        repeats: 3,
        spellingIssueLimit: 10,
        writingIssueLimit: 20,
        suggestionLimit: 2,
        chunk: 'abc ',
      );

      expect(scenario.buildText(), 'abc \nabc \nabc ');
      expect(scenario.characterCount, 14);
      expect(scenario.buildText().length, scenario.characterCount);
    });

    test('metadata describes shape without serializing corpus text', () {
      final scenario = AnalysisBenchmarkScenario(
        name: 'private-safe-shape',
        repeats: 2,
        spellingIssueLimit: 5,
        writingIssueLimit: 6,
        suggestionLimit: 1,
        chunk: 'synthetic-only',
      );

      final metadata = scenario.toJsonMetadata();

      expect(metadata['name'], 'private-safe-shape');
      expect(metadata['characters'], scenario.characterCount);
      expect(metadata.containsKey('chunk'), isFalse);
      expect(metadata.values, isNot(contains('synthetic-only')));
    });

    test('rejects invalid benchmark bounds', () {
      expect(
        () => AnalysisBenchmarkScenario(
          name: '',
          repeats: 1,
          spellingIssueLimit: 1,
          writingIssueLimit: 1,
          suggestionLimit: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkScenario(
          name: 'bad repeats',
          repeats: 0,
          spellingIssueLimit: 1,
          writingIssueLimit: 1,
          suggestionLimit: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkScenario(
          name: 'bad spelling bound',
          repeats: 1,
          spellingIssueLimit: 0,
          writingIssueLimit: 1,
          suggestionLimit: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkScenario(
          name: 'bad writing bound',
          repeats: 1,
          spellingIssueLimit: 1,
          writingIssueLimit: 0,
          suggestionLimit: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkScenario(
          name: 'bad suggestions',
          repeats: 1,
          spellingIssueLimit: 1,
          writingIssueLimit: 1,
          suggestionLimit: -1,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnalysisBenchmarkScenario(
          name: 'empty chunk',
          repeats: 1,
          spellingIssueLimit: 1,
          writingIssueLimit: 1,
          suggestionLimit: 1,
          chunk: '',
        ),
        throwsArgumentError,
      );
    });
  });
}
