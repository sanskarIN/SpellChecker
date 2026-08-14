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
    required Iterable<String> writingAnalyzedRuleIds,
    required Map<String, int> writingTotalIssueCountByRule,
  }) : writingAnalyzedRuleIds = List<String>.unmodifiable(
         _sortedStrings(writingAnalyzedRuleIds),
       ),
       writingTotalIssueCountByRule = Map<String, int>.unmodifiable(
         _sortedIntMap(writingTotalIssueCountByRule),
       ) {
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
    if (spellingCapturedIssueCount > spellingScannedTokenCount) {
      throw ArgumentError.value(
        spellingCapturedIssueCount,
        'spellingCapturedIssueCount',
        'cannot exceed spellingScannedTokenCount',
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
    final hasUncapturedWritingIssues =
        writingTotalIssueCount > writingCapturedIssueCount;
    if (writingTruncated != hasUncapturedWritingIssues) {
      throw ArgumentError.value(
        writingTruncated,
        'writingTruncated',
        'must match whether exact writing totals contain uncaptured issues',
      );
    }
    _validateWritingRuleMetadata();
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
  final List<String> writingAnalyzedRuleIds;
  final Map<String, int> writingTotalIssueCountByRule;

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
    'writingAnalyzedRuleIds': writingAnalyzedRuleIds,
    'writingTotalIssuesByRule': writingTotalIssueCountByRule,
  };

  void _validateWritingRuleMetadata() {
    String? previousRuleId;
    for (final ruleId in writingAnalyzedRuleIds) {
      if (ruleId.trim().isEmpty) {
        throw ArgumentError.value(
          ruleId,
          'writingAnalyzedRuleIds',
          'must not contain blank rule IDs',
        );
      }
      if (ruleId == previousRuleId) {
        throw ArgumentError.value(
          ruleId,
          'writingAnalyzedRuleIds',
          'must not contain duplicate rule IDs',
        );
      }
      previousRuleId = ruleId;
    }

    var summedTotal = 0;
    for (final entry in writingTotalIssueCountByRule.entries) {
      if (!writingAnalyzedRuleIds.contains(entry.key)) {
        throw ArgumentError.value(
          entry.key,
          'writingTotalIssueCountByRule',
          'must belong to an analyzed writing rule',
        );
      }
      if (entry.value < 0) {
        throw ArgumentError.value(
          entry.value,
          'writingTotalIssueCountByRule[${entry.key}]',
          'must not be negative',
        );
      }
      summedTotal += entry.value;
    }
    if (summedTotal != writingTotalIssueCount) {
      throw ArgumentError(
        'Per-rule writing totals must sum to writingTotalIssueCount.',
      );
    }
  }
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
    _validateScenarioConsistency();
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
      'writingAnalyzedRuleIds': representativeSample.writingAnalyzedRuleIds,
      'writingTotalIssuesByRule':
          representativeSample.writingTotalIssueCountByRule,
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

  void _validateScenarioConsistency() {
    for (final sample in samples) {
      if (sample.spellingCapturedIssueCount > scenario.spellingIssueLimit) {
        throw ArgumentError(
          'Spelling captured issues cannot exceed the scenario issue limit.',
        );
      }
      if (sample.spellingTruncated &&
          sample.spellingCapturedIssueCount != scenario.spellingIssueLimit) {
        throw ArgumentError(
          'A truncated spelling sample must fill the scenario issue limit.',
        );
      }
      if (sample.writingCapturedIssueCount > scenario.writingIssueLimit) {
        throw ArgumentError(
          'Writing captured findings cannot exceed the scenario issue limit.',
        );
      }
      if (sample.writingTruncated &&
          sample.writingCapturedIssueCount != scenario.writingIssueLimit) {
        throw ArgumentError(
          'A truncated writing sample must fill the scenario issue limit.',
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
          sample.writingTruncated == first.writingTruncated &&
          _sameStrings(
            sample.writingAnalyzedRuleIds,
            first.writingAnalyzedRuleIds,
          ) &&
          _sameIntMap(
            sample.writingTotalIssueCountByRule,
            first.writingTotalIssueCountByRule,
          );
      if (!matches) {
        throw ArgumentError(
          'All measured samples must produce the same deterministic analysis '
          'outcome.',
        );
      }
    }
  }
}

List<String> _sortedStrings(Iterable<String> values) {
  return values.toList(growable: false)..sort();
}

Map<String, int> _sortedIntMap(Map<String, int> values) {
  final entries = values.entries.toList(growable: false)
    ..sort((left, right) => left.key.compareTo(right.key));
  return <String, int>{for (final entry in entries) entry.key: entry.value};
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

bool _sameIntMap(Map<String, int> left, Map<String, int> right) {
  if (left.length != right.length) {
    return false;
  }
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }
  return true;
}

Duration _median(Iterable<Duration> values) {
  final sorted = values.map((value) => value.inMicroseconds).toList()..sort();
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) {
    return Duration(microseconds: sorted[middle]);
  }
  return Duration(microseconds: (sorted[middle - 1] + sorted[middle]) ~/ 2);
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
