import '../core/spell_language_pack.dart';
import 'rules/missing_space_after_punctuation_rule.dart';
import 'rules/repeated_punctuation_rule.dart';
import 'rules/repeated_space_rule.dart';
import 'rules/repeated_word_rule.dart';
import 'rules/sentence_capitalization_rule.dart';
import 'rules/space_before_punctuation_rule.dart';
import 'writing_issue.dart';
import 'writing_rule.dart';

class WritingAnalysisResult {
  WritingAnalysisResult({
    required Iterable<WritingIssue> issues,
    required Iterable<String> analyzedRuleIds,
    required this.languageId,
  }) : issues = List<WritingIssue>.unmodifiable(issues),
       analyzedRuleIds = Set<String>.unmodifiable(analyzedRuleIds);

  final List<WritingIssue> issues;
  final Set<String> analyzedRuleIds;
  final String languageId;

  bool get isClean => issues.isEmpty;

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
  }) {
    final issues = <WritingIssue>[];
    final analyzedRuleIds = <String>{};

    for (final rule in _rules) {
      if (!rule.supports(languagePack) ||
          (enabledRuleIds != null && !enabledRuleIds.contains(rule.id))) {
        continue;
      }
      analyzedRuleIds.add(rule.id);
      issues.addAll(rule.analyze(text, languagePack));
    }

    issues.sort((WritingIssue a, WritingIssue b) {
      final byStart = a.start.compareTo(b.start);
      if (byStart != 0) {
        return byStart;
      }
      final bySeverity = b.severity.index.compareTo(a.severity.index);
      if (bySeverity != 0) {
        return bySeverity;
      }
      return a.ruleId.compareTo(b.ruleId);
    });

    return WritingAnalysisResult(
      issues: issues,
      analyzedRuleIds: analyzedRuleIds,
      languageId: languagePack.id,
    );
  }
}

class WritingRuleRegistry {
  const WritingRuleRegistry._();

  static const List<WritingRule> builtIns = <WritingRule>[
    RepeatedWordRule(),
    SentenceCapitalizationRule(),
    RepeatedSpaceRule(),
    RepeatedPunctuationRule(),
    MissingSpaceAfterPunctuationRule(),
    SpaceBeforePunctuationRule(),
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
