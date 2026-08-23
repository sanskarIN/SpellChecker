import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';

import '../tool/benchmark/analysis_benchmark_command.dart';
import '../tool/benchmark/analysis_benchmark_result.dart';

void main() {
  group('runAnalysisBenchmarkCommand', () {
    test('prints help without running a benchmark', () {
      final output = <String>[];
      final errors = <String>[];

      final code = runAnalysisBenchmarkCommand(
        const <String>['--help'],
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(code, 0);
      expect(output.single, contains('benchmark_large_document.dart'));
      expect(output.single, contains('Any built-in language ID'));
      expect(errors, isEmpty);
    });

    test('returns usage error with current built-in languages', () {
      final output = <String>[];
      final errors = <String>[];

      final code = runAnalysisBenchmarkCommand(
        const <String>['--language=xx-ZZ'],
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(code, 64);
      expect(output, isEmpty);
      expect(errors.first, contains('Unsupported language'));
      for (final languagePack in SpellLanguageRegistry.builtIns) {
        expect(errors.first, contains(languagePack.id));
      }
      expect(errors.last, contains('--language=ID'));
    });

    test('accepts every current built-in language ID before execution', () {
      for (final languagePack in SpellLanguageRegistry.builtIns) {
        final output = <String>[];
        final errors = <String>[];
        SpellLanguagePack? receivedLanguagePack;

        final code = runAnalysisBenchmarkCommand(
          <String>['--language=${languagePack.id}', '--json'],
          writeOutput: output.add,
          writeError: errors.add,
          executeBenchmark: (options, pack) {
            receivedLanguagePack = pack;
            return AnalysisBenchmarkSummary(
              scenario: options.toScenario(),
              languageId: pack.id,
              warmupIterations: options.warmupIterations,
              samples: <AnalysisBenchmarkSample>[
                AnalysisBenchmarkSample(
                  index: 0,
                  spellingElapsed: Duration.zero,
                  writingElapsed: Duration.zero,
                  spellingScannedTokenCount: 0,
                  spellingCapturedIssueCount: 0,
                  spellingTruncated: false,
                  writingCapturedIssueCount: 0,
                  writingTotalIssueCount: 0,
                  writingTruncated: false,
                  writingAnalyzedRuleIds: const <String>[],
                  writingTotalIssueCountByRule: const <String, int>{},
                ),
              ],
            );
          },
        );

        expect(code, 0, reason: languagePack.id);
        expect(errors, isEmpty, reason: languagePack.id);
        expect(receivedLanguagePack?.id, languagePack.id);
        expect(output.single, contains('"language": "${languagePack.id}"'));
      }
    });

    test('returns software error for deterministic execution failure', () {
      final output = <String>[];
      final errors = <String>[];

      final code = runAnalysisBenchmarkCommand(
        const <String>['--repeats=2'],
        writeOutput: output.add,
        writeError: errors.add,
        executeBenchmark: (_, _) {
          throw ArgumentError('unstable benchmark outcome');
        },
      );

      expect(code, 70);
      expect(output, isEmpty);
      expect(errors, hasLength(1));
      expect(errors.single, contains('Benchmark execution error'));
      expect(errors.single, contains('unstable benchmark outcome'));
      expect(errors.single, isNot(contains('Usage:')));
    });

    test('runs a small JSON benchmark successfully', () {
      final output = <String>[];
      final errors = <String>[];

      final code = runAnalysisBenchmarkCommand(
        const <String>[
          '--repeats=2',
          '--warmup=0',
          '--iterations=1',
          '--spelling-limit=1',
          '--writing-limit=2',
          '--suggestions=0',
          '--language=en-US',
          '--json',
        ],
        writeOutput: output.add,
        writeError: errors.add,
      );

      expect(code, 0);
      expect(errors, isEmpty);
      expect(output, hasLength(1));
      final report = jsonDecode(output.single) as Map<String, dynamic>;
      expect(report['formatVersion'], 1);
      expect(report['language'], 'en-US');
      expect(report['measuredIterations'], 1);
      expect(output.single, isNot(contains('hello wrld')));
    });
  });
}
