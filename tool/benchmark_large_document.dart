import 'dart:io';

import 'benchmark/analysis_benchmark_command.dart';

void main(List<String> arguments) {
  exitCode = runAnalysisBenchmarkCommand(
    arguments,
    writeOutput: stdout.writeln,
    writeError: stderr.writeln,
  );
}
