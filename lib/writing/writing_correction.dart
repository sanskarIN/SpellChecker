import 'writing_issue.dart';

class WritingCorrectionResult {
  const WritingCorrectionResult({
    required this.text,
    required this.caretOffset,
    required this.applied,
  });

  final String text;
  final int caretOffset;
  final bool applied;
}

class WritingCorrection {
  const WritingCorrection._();

  static WritingCorrectionResult apply(String text, WritingIssue issue) {
    final replacement = issue.replacement;
    if (replacement == null || !_isCurrentIssue(text, issue)) {
      return WritingCorrectionResult(
        text: text,
        caretOffset: _safeCaret(issue.start, text.length),
        applied: false,
      );
    }

    final updated = text.replaceRange(issue.start, issue.end, replacement);
    return WritingCorrectionResult(
      text: updated,
      caretOffset: issue.start + replacement.length,
      applied: true,
    );
  }

  static bool _isCurrentIssue(String text, WritingIssue issue) {
    return issue.start >= 0 &&
        issue.end <= text.length &&
        issue.start < issue.end &&
        text.substring(issue.start, issue.end) == issue.originalText;
  }

  static int _safeCaret(int value, int textLength) {
    if (value < 0) {
      return 0;
    }
    if (value > textLength) {
      return textLength;
    }
    return value;
  }
}
