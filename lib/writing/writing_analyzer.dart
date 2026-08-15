import '../core/spell_language_pack.dart';
import 'rules/missing_punctuation_space_rule.dart';
import 'rules/punctuation_spacing_rule.dart';
import 'rules/repeated_punctuation_rule.dart';
import 'rules/repeated_space_rule.dart';
import 'rules/repeated_word_rule.dart';
import 'rules/sentence_capitalization_rule.dart';
import 'rules/trailing_whitespace_rule.dart';
import 'rules/unmatched_parenthesis_rule.dart';
import 'rules/unmatched_square_bracket_rule.dart';
import 'writing_issue.dart';
import 'writing_rule.dart';

class WritingAnalysisResult {
  WritingAnalysisResult({
    required Iterable<WritingIssue> issues,
    required Iterable<String> analyzedRuleIds,
    required this.languageId,
    this.issueLimit,
    this.isTruncated = false,
    this.totalIssueCount,
    Map<String, int>? totalIssueCountByRule,
  }) : issues = List<WritingIssue>.unmodifiable(issues),
       analyzedRuleIds = Set<String>.unmodifiable(analyzedRuleIds),
       totalIssueCountByRule = totalIssueCountByRule == null
           ? null
           : Map<String, int>.unmodifiable(totalIssueCountByRule) {
    if (issueLimit != null && issueLimit! <= 0) {
      throw ArgumentError.value(issueLimit, 'issueLimit', 'must be positive');
    }
    if (isTruncated && issueLimit == null) {
      throw ArgumentError(
        'A truncated writing analysis result must declare its issue limit.',
      );
    }
    if (issueLimit != null && this.issues.length > issueLimit!) {
      throw ArgumentError(
        'Captured writing issues cannot exceed the declared issue limit.',
      );
    }
    for (final issue in this.issues) {
      if (!this.analyzedRuleIds.contains(issue.ruleId)) {
        throw ArgumentError(
          'Captured writing issues must belong to an analyzed rule.',
        );
      }
      if (issue.languageId != languageId) {
        throw ArgumentError(
          'Captured writing issues must use the result language.',
        );
      }
    }
    if (totalIssueCount != null && totalIssueCount! < this.issues.length) {
      throw ArgumentError.value(
        totalIssueCount,
        'totalIssueCount',
        'cannot be smaller than the captured issue count',
      );
    }
    if (isTruncated &&
        totalIssueCount != null &&
        totalIssueCount! <= this.issues.length) {
      throw ArgumentError(
        'A truncated result with an exact total must report at least one '
        'uncaptured issue.',
      );
    }
    if (!isTruncated &&
        totalIssueCount != null &&
        totalIssueCount != this.issues.length) {
      throw ArgumentError(
        'A complete result with an exact total must capture every issue.',
      );
    }
    if (this.totalIssueCountByRule != null) {
      if (totalIssueCount == null) {
        throw ArgumentError(
          'Per-rule total issue counts require totalIssueCount.',
        );
      }
      var summedCount = 0;
      for (final entry in this.totalIssueCountByRule!.entries) {
        if (!this.analyzedRuleIds.contains(entry.key)) {
          throw ArgumentError(
            'Per-rule total issue counts must belong to analyzed rules.',
          );
        }
        if (entry.value < 0) {
          throw ArgumentError.value(
            entry.value,
            'totalIssueCountByRule[${entry.key}]',
            'must not be negative',
          );
        }
        summedCount += entry.value;
      }
      if (summedCount != totalIssueCount) {
        throw ArgumentError(
          'Per-rule total issue counts must sum to totalIssueCount.',
        );
      }
      final capturedCounts = issueCountByRule;
      for (final entry in capturedCounts.entries) {
        if ((this.totalIssueCountByRule![entry.key] ?? 0) < entry.value) {
          throw ArgumentError(
            'Per-rule total issue counts cannot be smaller than captured '
            'counts.',
          );
        }
      }
    }
  }

  final List<WritingIssue> issues;
  final Set<String> analyzedRuleIds;
  final String languageId;

  /// Maximum number of captured findings requested by the caller.
  ///
  /// `null` means the analysis was unbounded.
  final int? issueLimit;

  /// Whether at least one additional finding existed beyond [issueLimit].
  final bool isTruncated;

  /// Exact number of findings yielded by every analyzed rule, when known.
  ///
  /// Results produced by [WritingAnalyzer] always provide this value. It is
  /// nullable so callers constructing [WritingAnalysisResult] directly using
  /// the V2.7 constructor shape remain source-compatible.
  final int? totalIssueCount;

  /// Exact per-rule finding totals across the analyzed text, when known.
  ///
  /// The map is immutable. Like [totalIssueCount], analyzer-produced results
  /// always provide it while directly constructed compatibility results may
  /// omit it.
  final Map<String, int>? totalIssueCountByRule;

  bool get isClean => issues.isEmpty;
  bool get isComplete => !isTruncated;
  int get capturedIssueCount => issues.length;
  bool get hasExactIssueTotals => totalIssueCount != null;

  /// Exact number of findings not retained because of [issueLimit], when the
  /// total is known.
  int? get uncapturedIssueCount =>
      totalIssueCount == null ? null : totalIssueCount! - capturedIssueCount;

  Map<String, int> get issueCountByRule {
    final counts = <String, int>{};
    for (final issue in issues) {
      counts.update(issue.ruleId, (int value) => value + 1, ifAbsent: () => 1);
    }
    return Map<String, int>.unmodifiable(counts);
  }
}

class WritingAnalyzer {
  WritingAnalyzer({Iterable<WritingRule>? rules})
    : _rules = _validateRules(rules ?? WritingRuleRegistry.builtIns);

  final List<WritingRule> _rules;

  List<WritingRule> get rules => List<WritingRule>.unmodifiable(_rules);

  WritingAnalysisResult analyze(
    String text, {
    required SpellLanguagePack languagePack,
    Set<String>? enabledRuleIds,
    int? maxIssues,
  }) {
    if (maxIssues != null && maxIssues <= 0) {
      throw ArgumentError.value(maxIssues, 'maxIssues', 'must be positive');
    }

    final issues = <WritingIssue>[];
    final boundedIssues = maxIssues == null
        ? null
        : _BoundedWritingIssueCollector(maxIssues);
    final analyzedRuleIds = <String>{};
    final totalIssueCountByRule = <String, int>{};
    var totalIssueCount = 0;

    for (final rule in _rules) {
      if (!rule.supports(languagePack) ||
          (enabledRuleIds != null && !enabledRuleIds.contains(rule.id))) {
        continue;
      }
      analyzedRuleIds.add(rule.id);
      for (final issue in rule.analyze(text, languagePack)) {
        totalIssueCount += 1;
        totalIssueCountByRule.update(
          issue.ruleId,
          (int value) => value + 1,
          ifAbsent: () => 1,
        );
        if (boundedIssues == null) {
          issues.add(issue);
        } else {
          boundedIssues.add(issue);
        }
      }
    }

    if (boundedIssues == null) {
      issues.sort(_compareWritingIssues);
    }

    return WritingAnalysisResult(
      issues: boundedIssues?.issues ?? issues,
      analyzedRuleIds: analyzedRuleIds,
      languageId: languagePack.id,
      issueLimit: maxIssues,
      isTruncated: boundedIssues?.isTruncated ?? false,
      totalIssueCount: totalIssueCount,
      totalIssueCountByRule: totalIssueCountByRule,
    );
  }
}

List<WritingRule> _validateRules(Iterable<WritingRule> rules) {
  final result = rules.toList(growable: false);
  final ruleIds = <String>{};
  for (final rule in result) {
    if (!ruleIds.add(rule.id)) {
      throw ArgumentError.value(
        rule.id,
        'rules',
        'contains a duplicate writing-rule ID',
      );
    }
  }
  return List<WritingRule>.unmodifiable(result);
}

int _compareWritingIssues(WritingIssue a, WritingIssue b) {
  final byStart = a.start.compareTo(b.start);
  if (byStart != 0) {
    return byStart;
  }
  final bySeverity = b.severity.index.compareTo(a.severity.index);
  if (bySeverity != 0) {
    return bySeverity;
  }
  return a.ruleId.compareTo(b.ruleId);
}

class _BoundedWritingIssueCollector {
  _BoundedWritingIssueCollector(this.limit);

  final int limit;
  final List<WritingIssue> _issues = <WritingIssue>[];
  bool isTruncated = false;

  List<WritingIssue> get issues => List<WritingIssue>.unmodifiable(_issues);

  void add(WritingIssue issue) {
    final insertionIndex = _lowerBound(issue);

    if (_issues.length < limit) {
      _issues.insert(insertionIndex, issue);
      return;
    }

    isTruncated = true;
    if (insertionIndex >= limit) {
      return;
    }

    _issues.insert(insertionIndex, issue);
    _issues.removeLast();
  }

  int _lowerBound(WritingIssue issue) {
    var low = 0;
    var high = _issues.length;

    while (low < high) {
      final middle = low + ((high - low) >> 1);
      if (_compareWritingIssues(_issues[middle], issue) < 0) {
        low = middle + 1;
      } else {
        high = middle;
      }
    }

    return low;
  }
}

class WritingRuleRegistry {
  const WritingRuleRegistry._();

  static const List<WritingRule> builtIns = <WritingRule>[
    RepeatedWordRule(),
    SentenceCapitalizationRule(),
    RepeatedSpaceRule(),
    PunctuationSpacingRule(),
    MissingPunctuationSpaceRule(),
    TrailingWhitespaceRule(),
    RepeatedPunctuationRule(),
    UnmatchedParenthesisRule(),
    UnmatchedSquareBracketRule(),
  ];

  static WritingRule? byId(String id) {
    for (final rule in builtIns) {
      if (rule.id == id) {
        return rule;
      }
    }
    return null;
  }

  static Set<String> get defaultEnabledRuleIds =>
      builtIns.map((WritingRule rule) => rule.id).toSet();
}
