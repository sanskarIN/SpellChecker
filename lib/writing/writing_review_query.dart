import 'writing_issue.dart';
import 'writing_rule.dart';
import 'writing_rule_category.dart';

class WritingReviewQuery {
  WritingReviewQuery({
    String search = '',
    Iterable<WritingRuleCategory> categories = const <WritingRuleCategory>[],
    this.automaticFixesOnly = false,
  }) : search = search.trim().toLowerCase(),
       categories = Set<WritingRuleCategory>.unmodifiable(categories);

  final String search;
  final Set<WritingRuleCategory> categories;
  final bool automaticFixesOnly;

  bool get isEmpty =>
      search.isEmpty && categories.isEmpty && !automaticFixesOnly;

  List<WritingRule> filterRules(Iterable<WritingRule> rules) {
    return rules.where(matchesRule).toList(growable: false);
  }

  List<WritingIssue> filterIssues(
    Iterable<WritingIssue> issues, {
    required Iterable<WritingRule> rules,
  }) {
    final ruleById = <String, WritingRule>{
      for (final rule in rules) rule.id: rule,
    };

    return issues
        .where((WritingIssue issue) {
          if (automaticFixesOnly && !issue.hasAutomaticFix) {
            return false;
          }

          final rule = ruleById[issue.ruleId];
          if (categories.isNotEmpty &&
              (rule == null || !categories.contains(rule.category))) {
            return false;
          }

          if (search.isEmpty) {
            return true;
          }

          return _containsSearch(issue.ruleId) ||
              _containsSearch(issue.ruleName) ||
              _containsSearch(issue.message) ||
              _containsSearch(issue.originalText) ||
              _containsSearch(issue.replacement ?? '') ||
              (rule != null &&
                  (_containsSearch(rule.displayName) ||
                      _containsSearch(rule.description) ||
                      _containsSearch(rule.category.displayName)));
        })
        .toList(growable: false);
  }

  bool matchesRule(WritingRule rule) {
    if (categories.isNotEmpty && !categories.contains(rule.category)) {
      return false;
    }
    if (search.isEmpty) {
      return true;
    }
    return _containsSearch(rule.id) ||
        _containsSearch(rule.displayName) ||
        _containsSearch(rule.description) ||
        _containsSearch(rule.category.displayName);
  }

  bool _containsSearch(String value) {
    return value.toLowerCase().contains(search);
  }
}
