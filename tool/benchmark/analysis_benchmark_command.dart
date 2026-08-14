import 'package:spellchecker/language.dart';

import 'analysis_benchmark_options.dart';
import 'analysis_benchmark_reporter.dart';
import 'analysis_benchmark_runner.dart';

typedef BenchmarkOutputWriter = void Function(String text);

int runAnalysisBenchmarkCommand(
  List<String> arguments, {
  required BenchmarkOutputWriter writeOutput,
  required BenchmarkOutputWriter writeError,
}) {
  try {
    final options = AnalysisBenchmarkOptions.parse(arguments);
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

    final summary = AnalysisBenchmarkRunner(
      scenario: options.toScenario(),
      languagePack: SpellLanguageRegistry.byId(options.languageId),
      warmupIterations: options.warmupIterations,
      measuredIterations: options.measuredIterations,
    ).run();

    writeOutput(
      options.json
          ? summary.toPrettyJson()
          : formatAnalysisBenchmarkSummary(summary),
    );
    return 0;
  } on FormatException catch (error) {
    writeError('Benchmark option error: ${error.message}');
    writeError(AnalysisBenchmarkOptions.usage.trimRight());
    return 64;
  } on ArgumentError catch (error) {
    writeError('Benchmark configuration error: $error');
    writeError(AnalysisBenchmarkOptions.usage.trimRight());
    return 64;
  }
}
