import 'package:spellchecker/language.dart';
import 'package:spellchecker/spell_checker.dart';
import 'package:spellchecker/writing.dart';

import 'analysis_benchmark_result.dart';
import 'analysis_benchmark_scenario.dart';

class AnalysisBenchmarkRunner {
  AnalysisBenchmarkRunner({
    required this.scenario,
    required this.languagePack,
    this.warmupIterations = 1,
    this.measuredIterations = 5,
  }) {
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
  }

  static const Set<String> benchmarkDictionary = <String>{
    'a',
    'hello',
    'is',
    'next',
    'sentence',
    'this',
    'world',
  };

  static const Map<String, int> benchmarkFrequencies = <String, int>{
    'hello': 1,
    'world': 2,
    'this': 3,
    'is': 4,
    'a': 5,
    'sentence': 6,
    'next': 7,
  };

  final AnalysisBenchmarkScenario scenario;
  final SpellLanguagePack languagePack;
  final int warmupIterations;
  final int measuredIterations;

  AnalysisBenchmarkSummary run() {
    final text = scenario.buildText();

    for (var index = 0; index < warmupIterations; index++) {
      _runSample(text, index: index);
    }

    final samples = <AnalysisBenchmarkSample>[];
    for (var index = 0; index < measuredIterations; index++) {
      samples.add(_runSample(text, index: index));
    }

    return AnalysisBenchmarkSummary(
      scenario: scenario,
      languageId: languagePack.id,
      warmupIterations: warmupIterations,
      samples: samples,
    );
  }

  AnalysisBenchmarkSample _runSample(String text, {required int index}) {
    final engine = SpellCheckerEngine(
      dictionary: benchmarkDictionary,
      wordFrequencies: benchmarkFrequencies,
      languagePack: languagePack,
    );
    final analyzer = WritingAnalyzer();

    final spellingWatch = Stopwatch()..start();
    final spelling = engine.analyze(
      text,
      suggestionLimit: scenario.suggestionLimit,
      maxIssues: scenario.spellingIssueLimit,
    );
    spellingWatch.stop();

    final writingWatch = Stopwatch()..start();
    final writing = analyzer.analyze(
      text,
      languagePack: languagePack,
      maxIssues: scenario.writingIssueLimit,
    );
    writingWatch.stop();

    return AnalysisBenchmarkSample(
      index: index,
      spellingElapsed: spellingWatch.elapsed,
      writingElapsed: writingWatch.elapsed,
      spellingScannedTokenCount: spelling.scannedTokenCount,
      spellingCapturedIssueCount: spelling.capturedIssueCount,
      spellingTruncated: spelling.isTruncated,
      writingCapturedIssueCount: writing.capturedIssueCount,
      writingTotalIssueCount: writing.totalIssueCount!,
      writingTruncated: writing.isTruncated,
    );
  }
}
