import 'writing_analyzer.dart';
import 'writing_rule.dart';

/// Privacy-safe, deterministic metadata for one analyzed writing rule.
class WritingRuleDiagnosticSummary {
  const WritingRuleDiagnosticSummary({
    required this.ruleId,
    required this.displayName,
    required this.capturedIssueCount,
    required this.totalIssueCount,
  });

  final String ruleId;
  final String displayName;
  final int capturedIssueCount;
  final int? totalIssueCount;
}

/// A deterministic, non-document summary of a writing-analysis result.
///
/// The summary intentionally contains counts and rule metadata only. It never
/// reads or serializes editor text, finding messages, source excerpts,
/// replacements, or source offsets.
class WritingAnalysisDiagnosticSummary {
  WritingAnalysisDiagnosticSummary._({
    required this.languageId,
    required this.capturedIssueCount,
    required this.totalIssueCount,
    required this.issueLimit,
    required this.isTruncated,
    required Iterable<WritingRuleDiagnosticSummary> rules,
  }) : rules = List<WritingRuleDiagnosticSummary>.unmodifiable(rules);

  /// Builds a diagnostic summary from [result].
  ///
  /// [rules] is used only to resolve stable rule display names. Rule rows are
  /// ordered lexically by rule ID so the exported text is deterministic even
  /// when callers provide sets or rule iterables with different iteration
  /// orders.
  factory WritingAnalysisDiagnosticSummary.fromResult(
    WritingAnalysisResult result, {
    Iterable<WritingRule> rules = const <WritingRule>[],
  }) {
    final ruleById = <String, WritingRule>{
      for (final rule in rules) rule.id: rule,
    };
    final capturedByRule = result.issueCountByRule;
    final exactByRule = result.totalIssueCountByRule;
    final analyzedRuleIds = result.analyzedRuleIds.toList()..sort();

    return WritingAnalysisDiagnosticSummary._(
      languageId: result.languageId,
      capturedIssueCount: result.capturedIssueCount,
      totalIssueCount: result.totalIssueCount,
      issueLimit: result.issueLimit,
      isTruncated: result.isTruncated,
      rules: <WritingRuleDiagnosticSummary>[
        for (final ruleId in analyzedRuleIds)
          WritingRuleDiagnosticSummary(
            ruleId: ruleId,
            displayName: ruleById[ruleId]?.displayName ?? ruleId,
            capturedIssueCount: capturedByRule[ruleId] ?? 0,
            totalIssueCount: exactByRule == null
                ? null
                : exactByRule[ruleId] ?? 0,
          ),
      ],
    );
  }

  static const int formatVersion = 1;

  final String languageId;
  final int capturedIssueCount;
  final int? totalIssueCount;
  final int? issueLimit;
  final bool isTruncated;
  final List<WritingRuleDiagnosticSummary> rules;

  bool get hasExactIssueTotals => totalIssueCount != null;

  int? get uncapturedIssueCount => totalIssueCount == null
      ? null
      : totalIssueCount! - capturedIssueCount;

  /// Formats the summary as deterministic plain text suitable for copying into
  /// a bug report, performance note, or support discussion.
  String toPlainText() {
    final buffer = StringBuffer()
      ..writeln('SpellChecker writing analysis diagnostics')
      ..writeln('Format version: $formatVersion')
      ..writeln('Language: $languageId')
      ..writeln('Analysis status: ${isTruncated ? 'limited' : 'complete'}')
      ..writeln('Captured findings: $capturedIssueCount')
      ..writeln(
        'Total findings: ${totalIssueCount?.toString() ?? 'unavailable'}',
      )
      ..writeln(
        'Uncaptured findings: '
        '${uncapturedIssueCount?.toString() ?? 'unavailable'}',
      )
      ..writeln('Capture limit: ${issueLimit?.toString() ?? 'none'}')
      ..writeln('Rule totals:');

    if (rules.isEmpty) {
      buffer.writeln('- none');
    } else {
      for (final rule in rules) {
        final total = rule.totalIssueCount;
        if (total == null) {
          buffer.writeln(
            '- ${rule.displayName} [${rule.ruleId}]: '
            '${rule.capturedIssueCount} captured; total unavailable',
          );
        } else {
          buffer.writeln(
            '- ${rule.displayName} [${rule.ruleId}]: '
            '${rule.capturedIssueCount}/$total captured/total',
          );
        }
      }
    }

    buffer.write(
      'Privacy: counts and rule metadata only; editor text and finding '
      'excerpts are excluded.',
    );
    return buffer.toString();
  }
}
