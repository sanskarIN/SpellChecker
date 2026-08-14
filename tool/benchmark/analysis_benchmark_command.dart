import 'package:spellchecker/language.dart';

import 'analysis_benchmark_options.dart';
import 'analysis_benchmark_reporter.dart';
import 'analysis_benchmark_result.dart';
import 'analysis_benchmark_runner.dart';

typedef BenchmarkOutputWriter = void Function(String text);
typedef BenchmarkExecutor =
    AnalysisBenchmarkSummary Function(
      AnalysisBenchmarkOptions options,
      SpellLanguagePack languagePack,
    );

int runAnalysisBenchmarkCommand(
  List<String> arguments, {
  required BenchmarkOutputWriter writeOutput,
  required BenchmarkOutputWriter writeError,
  BenchmarkExecutor? executeBenchmark,
}) {
  late final AnalysisBenchmarkOptions options;
  late final SpellLanguagePack languagePack;
  try {
    options = AnalysisBenchmarkOptions.parse(arguments);
    if (options.help) {
      writeOutput(AnalysisBenchmarkOptions.usage.trimRight());
      return 0;
    }
    if (!SpellLanguageRegistry.contains(options.languageId)) {
      throw FormatException(
        'Unsupported language "${options.languageId}". '
        'Use en-US or en-GB.',
      );
    }
    languagePack = SpellLanguageRegistry.byId(options.languageId);
  } on FormatException catch (error) {
    writeError('Benchmark option error: ${error.message}');
    writeError(AnalysisBenchmarkOptions.usage.trimRight());
    return 64;
  } on ArgumentError catch (error) {
    writeError('Benchmark configuration error: $error');
    writeError(AnalysisBenchmarkOptions.usage.trimRight());
    return 64;
  }

  try {
    final summary = (executeBenchmark ?? _executeBenchmark)(
      options,
      languagePack,
    );
    writeOutput(
      options.json
          ? summary.toPrettyJson()
          : formatAnalysisBenchmarkSummary(summary),
    );
    return 0;
  } on ArgumentError catch (error) {
    writeError('Benchmark execution error: $error');
    return 70;
  }
}

AnalysisBenchmarkSummary _executeBenchmark(
  AnalysisBenchmarkOptions options,
  SpellLanguagePack languagePack,
) {
  return AnalysisBenchmarkRunner(
    scenario: options.toScenario(),
    languagePack: languagePack,
    warmupIterations: options.warmupIterations,
    measuredIterations: options.measuredIterations,
  ).run();
}
