import 'dart:convert';

import 'analysis_benchmark_scenario.dart';

class AnalysisBenchmarkSample {
  AnalysisBenchmarkSample({
    required this.index,
    required this.spellingElapsed,
    required this.writingElapsed,
    required this.spellingScannedTokenCount,
    required this.spellingCapturedIssueCount,
    required this.spellingTruncated,
    required this.writingCapturedIssueCount,
    required this.writingTotalIssueCount,
    required this.writingTruncated,
  }) {
    if (index < 0) {
      throw ArgumentError.value(index, 'index', 'must not be negative');
    }
    if (spellingElapsed.isNegative) {
      throw ArgumentError.value(
        spellingElapsed,
        'spellingElapsed',
        'must not be negative',
      );
    }
    if (writingElapsed.isNegative) {
      throw ArgumentError.value(
        writingElapsed,
        'writingElapsed',
        'must not be negative',
      );
    }
    if (spellingScannedTokenCount < 0) {
      throw ArgumentError.value(
        spellingScannedTokenCount,
        'spellingScannedTokenCount',
        'must not be negative',
      );
    }
    if (spellingCapturedIssueCount < 0) {
      throw ArgumentError.value(
        spellingCapturedIssueCount,
        'spellingCapturedIssueCount',
        'must not be negative',
      );
    }
    if (writingCapturedIssueCount < 0) {
      throw ArgumentError.value(
        writingCapturedIssueCount,
        'writingCapturedIssueCount',
        'must not be negative',
      );
    }
    if (writingTotalIssueCount < writingCapturedIssueCount) {
      throw ArgumentError.value(
        writingTotalIssueCount,
        'writingTotalIssueCount',
        'cannot be smaller than writingCapturedIssueCount',
      );
    }
  }

  final int index;
  final Duration spellingElapsed;
  final Duration writingElapsed;
  final int spellingScannedTokenCount;
  final int spellingCapturedIssueCount;
  final bool spellingTruncated;
  final int writingCapturedIssueCount;
  final int writingTotalIssueCount;
  final bool writingTruncated;

  Map<String, Object> toJson() => <String, Object>{
    'index': index,
    'spellingMicroseconds': spellingElapsed.inMicroseconds,
    'writingMicroseconds': writingElapsed.inMicroseconds,
    'spellingScannedTokens': spellingScannedTokenCount,
    'spellingCapturedIssues': spellingCapturedIssueCount,
    'spellingTruncated': spellingTruncated,
    'writingCapturedIssues': writingCapturedIssueCount,
    'writingTotalIssues': writingTotalIssueCount,
    'writingTruncated': writingTruncated,
  };
}

class AnalysisBenchmarkSummary {
  AnalysisBenchmarkSummary({
    required this.scenario,
    required this.languageId,
    required this.warmupIterations,
    required Iterable<AnalysisBenchmarkSample> samples,
  }) : samples = List<AnalysisBenchmarkSample>.unmodifiable(samples) {
    if (languageId.trim().isEmpty) {
      throw ArgumentError.value(languageId, 'languageId', 'must not be blank');
    }
    if (warmupIterations < 0) {
      throw ArgumentError.value(
        warmupIterations,
        'warmupIterations',
        'must not be negative',
      );
    }
    if (this.samples.isEmpty) {
      throw ArgumentError.value(samples, 'samples', 'must not be empty');
    }
    _validateSampleIndexes();
    _validateStableAnalysisOutcome();
  }

  static const int formatVersion = 1;

  final AnalysisBenchmarkScenario scenario;
  final String languageId;
  final int warmupIterations;
  final List<AnalysisBenchmarkSample> samples;

  Duration get medianSpellingElapsed =>
      _median(samples.map((sample) => sample.spellingElapsed));
  Duration get minSpellingElapsed =>
      _minimum(samples.map((sample) => sample.spellingElapsed));
  Duration get maxSpellingElapsed =>
      _maximum(samples.map((sample) => sample.spellingElapsed));

  Duration get medianWritingElapsed =>
      _median(samples.map((sample) => sample.writingElapsed));
  Duration get minWritingElapsed =>
      _minimum(samples.map((sample) => sample.writingElapsed));
  Duration get maxWritingElapsed =>
      _maximum(samples.map((sample) => sample.writingElapsed));

  AnalysisBenchmarkSample get representativeSample => samples.first;

  Map<String, Object> toJson() => <String, Object>{
    'formatVersion': formatVersion,
    'language': languageId,
    'scenario': scenario.toJsonMetadata(),
    'warmupIterations': warmupIterations,
    'measuredIterations': samples.length,
    'aggregate': <String, Object>{
      'spellingMedianMicroseconds': medianSpellingElapsed.inMicroseconds,
      'spellingMinMicroseconds': minSpellingElapsed.inMicroseconds,
      'spellingMaxMicroseconds': maxSpellingElapsed.inMicroseconds,
      'writingMedianMicroseconds': medianWritingElapsed.inMicroseconds,
      'writingMinMicroseconds': minWritingElapsed.inMicroseconds,
      'writingMaxMicroseconds': maxWritingElapsed.inMicroseconds,
    },
    'analysisOutcome': <String, Object>{
      'spellingScannedTokens': representativeSample.spellingScannedTokenCount,
      'spellingCapturedIssues': representativeSample.spellingCapturedIssueCount,
      'spellingTruncated': representativeSample.spellingTruncated,
      'writingCapturedIssues': representativeSample.writingCapturedIssueCount,
      'writingTotalIssues': representativeSample.writingTotalIssueCount,
      'writingTruncated': representativeSample.writingTruncated,
    },
    'samples': samples
        .map((AnalysisBenchmarkSample sample) => sample.toJson())
        .toList(growable: false),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  void _validateSampleIndexes() {
    for (var index = 0; index < samples.length; index++) {
      if (samples[index].index != index) {
        throw ArgumentError(
          'Benchmark sample indexes must be contiguous and zero-based.',
        );
      }
    }
  }

  void _validateStableAnalysisOutcome() {
    final first = samples.first;
    for (final sample in samples.skip(1)) {
      final matches =
          sample.spellingScannedTokenCount == first.spellingScannedTokenCount &&
          sample.spellingCapturedIssueCount ==
              first.spellingCapturedIssueCount &&
          sample.spellingTruncated == first.spellingTruncated &&
          sample.writingCapturedIssueCount == first.writingCapturedIssueCount &&
          sample.writingTotalIssueCount == first.writingTotalIssueCount &&
          sample.writingTruncated == first.writingTruncated;
      if (!matches) {
        throw ArgumentError(
          'All measured samples must produce the same deterministic analysis '
          'outcome.',
        );
      }
    }
  }
}

Duration _median(Iterable<Duration> values) {
  final sorted = values.map((value) => value.inMicroseconds).toList()..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return Duration(microseconds: sorted[middle]);
  }
  return Duration(
    microseconds: (sorted[middle - 1] + sorted[middle]) ~/ 2,
  );
}

Duration _minimum(Iterable<Duration> values) {
  return Duration(
    microseconds: values
        .map((value) => value.inMicroseconds)
        .reduce((left, right) => left < right ? left : right),
  );
}

Duration _maximum(Iterable<Duration> values) {
  return Duration(
    microseconds: values
        .map((value) => value.inMicroseconds)
        .reduce((left, right) => left > right ? left : right),
  );
}
