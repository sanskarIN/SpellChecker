import 'spell_issue.dart';

/// Result metadata for a spelling analysis that may intentionally stop
/// capturing issues after a configured limit.
class SpellCheckReport {
  SpellCheckReport({
    required Iterable<SpellIssue> issues,
    required this.scannedTokenCount,
    required this.truncated,
    this.issueLimit,
  }) : issues = List<SpellIssue>.unmodifiable(issues) {
    if (scannedTokenCount < 0) {
      throw ArgumentError.value(
        scannedTokenCount,
        'scannedTokenCount',
        'must not be negative',
      );
    }
    if (issueLimit != null && issueLimit! <= 0) {
      throw ArgumentError.value(issueLimit, 'issueLimit', 'must be positive');
    }
    if (truncated && issueLimit == null) {
      throw ArgumentError(
        'A truncated spelling report must declare its issue limit.',
      );
    }
    if (issueLimit != null && this.issues.length > issueLimit!) {
      throw ArgumentError(
        'Captured spelling issues cannot exceed the declared issue limit.',
      );
    }
    if (scannedTokenCount < this.issues.length) {
      throw ArgumentError(
        'The scanned token count cannot be smaller than the captured issue '
        'count.',
      );
    }
  }

  /// Captured spelling issues in source order.
  final List<SpellIssue> issues;

  /// Number of word tokens inspected before analysis completed or proved that
  /// at least one additional issue exists beyond [issueLimit].
  final int scannedTokenCount;

  /// Whether at least one issue exists beyond the captured [issues].
  final bool truncated;

  /// Maximum captured issues requested by the caller, or `null` for an
  /// unbounded analysis.
  final int? issueLimit;

  /// Whether the complete token stream was scanned without omitting an issue.
  bool get complete => !truncated;

  /// Number of issues captured in this report.
  int get capturedIssueCount => issues.length;
}
