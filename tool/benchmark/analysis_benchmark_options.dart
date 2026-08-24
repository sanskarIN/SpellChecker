import 'analysis_benchmark_scenario.dart';

class AnalysisBenchmarkOptions {
  AnalysisBenchmarkOptions({
    this.repeats = 2000,
    this.warmupIterations = 1,
    this.measuredIterations = 5,
    this.spellingIssueLimit = 200,
    this.writingIssueLimit = 200,
    this.suggestionLimit = 5,
    this.languageId = 'en-US',
    this.json = false,
    this.help = false,
  }) {
    if (repeats <= 0) {
      throw ArgumentError.value(repeats, 'repeats', 'must be positive');
    }
    if (warmupIterations < 0) {
      throw ArgumentError.value(
        warmupIterations,
        'warmupIterations',
        'must not be negative',
      );
    }
    if (measuredIterations <= 0) {
      throw ArgumentError.value(
        measuredIterations,
        'measuredIterations',
        'must be positive',
      );
    }
    if (spellingIssueLimit <= 0) {
      throw ArgumentError.value(
        spellingIssueLimit,
        'spellingIssueLimit',
        'must be positive',
      );
    }
    if (writingIssueLimit <= 0) {
      throw ArgumentError.value(
        writingIssueLimit,
        'writingIssueLimit',
        'must be positive',
      );
    }
    if (suggestionLimit < 0) {
      throw ArgumentError.value(
        suggestionLimit,
        'suggestionLimit',
        'must not be negative',
      );
    }
    if (languageId.trim().isEmpty) {
      throw ArgumentError.value(languageId, 'languageId', 'must not be blank');
    }
  }

  final int repeats;
  final int warmupIterations;
  final int measuredIterations;
  final int spellingIssueLimit;
  final int writingIssueLimit;
  final int suggestionLimit;
  final String languageId;
  final bool json;
  final bool help;

  AnalysisBenchmarkScenario toScenario() => AnalysisBenchmarkScenario(
    name: 'large-document',
    repeats: repeats,
    spellingIssueLimit: spellingIssueLimit,
    writingIssueLimit: writingIssueLimit,
    suggestionLimit: suggestionLimit,
  );

  static AnalysisBenchmarkOptions parse(List<String> arguments) {
    var repeats = 2000;
    var warmupIterations = 1;
    var measuredIterations = 5;
    var spellingIssueLimit = 200;
    var writingIssueLimit = 200;
    var suggestionLimit = 5;
    var languageId = 'en-US';
    var json = false;
    var help = false;
    final seen = <String>{};

    for (final argument in arguments) {
      if (argument == '--json' || argument == '--help') {
        if (!seen.add(argument)) {
          throw FormatException('Duplicate option: $argument');
        }
        if (argument == '--json') {
          json = true;
        } else {
          help = true;
        }
        continue;
      }

      final separatorIndex = argument.indexOf('=');
      if (!argument.startsWith('--') || separatorIndex <= 2) {
        throw FormatException('Unknown benchmark option: $argument');
      }
      final key = argument.substring(0, separatorIndex);
      final value = argument.substring(separatorIndex + 1);
      if (!seen.add(key)) {
        throw FormatException('Duplicate option: $key');
      }
      if (value.isEmpty) {
        throw FormatException('Missing value for $key');
      }

      switch (key) {
        case '--repeats':
          repeats = _parseInt(key, value);
        case '--warmup':
          warmupIterations = _parseInt(key, value);
        case '--iterations':
          measuredIterations = _parseInt(key, value);
        case '--spelling-limit':
          spellingIssueLimit = _parseInt(key, value);
        case '--writing-limit':
          writingIssueLimit = _parseInt(key, value);
        case '--suggestions':
          suggestionLimit = _parseInt(key, value);
        case '--language':
          languageId = value;
        default:
          throw FormatException('Unknown benchmark option: $key');
      }
    }

    return AnalysisBenchmarkOptions(
      repeats: repeats,
      warmupIterations: warmupIterations,
      measuredIterations: measuredIterations,
      spellingIssueLimit: spellingIssueLimit,
      writingIssueLimit: writingIssueLimit,
      suggestionLimit: suggestionLimit,
      languageId: languageId,
      json: json,
      help: help,
    );
  }

  static String get usage => '''
Usage: dart run tool/benchmark_large_document.dart [options]

Options:
  --repeats=N          Synthetic chunk repetitions (default: 2000)
  --warmup=N           Unmeasured warmup iterations (default: 1)
  --iterations=N       Measured iterations (default: 5)
  --spelling-limit=N   Captured spelling issue limit (default: 200)
  --writing-limit=N    Captured writing finding limit (default: 200)
  --suggestions=N      Suggestions requested per spelling issue (default: 5)
  --language=ID        Any built-in language ID (default: en-US)
  --json               Print the versioned JSON report
  --help               Print this help text
''';
}

int _parseInt(String option, String value) {
  final parsed = int.tryParse(value);
  if (parsed == null) {
    throw FormatException('$option expects an integer, received "$value".');
  }
  return parsed;
}
