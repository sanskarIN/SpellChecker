import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../tool/benchmark/analysis_benchmark_command.dart';

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
      expect(errors, isEmpty);
    });

    test('returns usage error for unsupported language', () {
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
      expect(errors.last, contains('--language=ID'));
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
