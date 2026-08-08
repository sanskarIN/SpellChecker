enum WritingIssueSeverity {
  info,
  suggestion,
  warning,
}

class WritingIssue {
  const WritingIssue({
    required this.ruleId,
    required this.ruleName,
    required this.message,
    required this.start,
    required this.end,
    required this.originalText,
    required this.languageId,
    this.replacement,
    this.severity = WritingIssueSeverity.suggestion,
  });

  final String ruleId;
  final String ruleName;
  final String message;
  final int start;
  final int end;
  final String originalText;
  final String? replacement;
  final String languageId;
  final WritingIssueSeverity severity;

  bool get hasAutomaticFix => replacement != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WritingIssue &&
            other.ruleId == ruleId &&
            other.ruleName == ruleName &&
            other.message == message &&
            other.start == start &&
            other.end == end &&
            other.originalText == originalText &&
            other.replacement == replacement &&
            other.languageId == languageId &&
            other.severity == severity;
  }

  @override
  int get hashCode => Object.hash(
        ruleId,
        ruleName,
        message,
        start,
        end,
        originalText,
        replacement,
        languageId,
        severity,
      );
}
