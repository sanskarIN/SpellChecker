import '../core/spell_language_pack.dart';
import 'rules/punctuation_spacing_rule.dart';
import 'rules/repeated_punctuation_rule.dart';
import 'rules/repeated_space_rule.dart';
import 'rules/repeated_word_rule.dart';
import 'rules/sentence_capitalization_rule.dart';
import 'rules/trailing_whitespace_rule.dart';
import 'writing_issue.dart';
import 'writing_rule.dart';

class WritingAnalysisResult {
  WritingAnalysisResult({
    required Iterable<WritingIssue> issues,
    required Iterable<String> analyzedRuleIds,
    required this.languageId,
    this.issueLimit,
    this.isTruncated = false,
  }) : issues = List<WritingIssue>.unmodifiable(issues),
       analyzedRuleIds = Set<String>.unmodifiable(analyzedRuleIds) {
    if (issueLimit != null && issueLimit! <= 0) {
      throw ArgumentError.value(issueLimit, 'issueLimit', 'must be positive');
    }
    if (isTruncated && issueLimit == null) {
      throw ArgumentError(
        'A truncated writing analysis result must declare its issue limit.',
      );
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

  bool get isClean => issues.isEmpty;
  bool get isComplete => !isTruncated;
  int get capturedIssueCount => issues.length;

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
    : _rules = List<WritingRule>.unmodifiable(
        rules ?? WritingRuleRegistry.builtIns,
      );

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

    for (final rule in _rules) {
      if (!rule.supports(languagePack) ||
          (enabledRuleIds != null && !enabledRuleIds.contains(rule.id))) {
        continue;
      }
      analyzedRuleIds.add(rule.id);
      for (final issue in rule.analyze(text, languagePack)) {
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
    );
  }
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
    TrailingWhitespaceRule(),
    RepeatedPunctuationRule(),
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
