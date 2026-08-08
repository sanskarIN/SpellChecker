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

class WritingBatchCorrectionResult {
  const WritingBatchCorrectionResult({
    required this.text,
    required this.caretOffset,
    required this.appliedCount,
    required this.skippedCount,
  });

  final String text;
  final int caretOffset;
  final int appliedCount;
  final int skippedCount;

  bool get applied => appliedCount > 0;
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

  /// Applies every current, non-overlapping automatic fix as one text update.
  ///
  /// Candidate issues are ordered by source position, then end position, then
  /// rule id. When two fixes overlap, the earlier deterministic candidate is
  /// accepted and the later one is counted as skipped. Stale source ranges and
  /// advisory issues without a replacement are also skipped.
  ///
  /// Accepted edits are applied from the end of the document toward the
  /// beginning so the checked source offsets remain valid throughout the
  /// operation. The returned caret points immediately after the last accepted
  /// source occurrence in the final text.
  static WritingBatchCorrectionResult applyAll(
    String text,
    Iterable<WritingIssue> issues,
  ) {
    final candidates = issues.toList(growable: false)
      ..sort((WritingIssue a, WritingIssue b) {
        final byStart = a.start.compareTo(b.start);
        if (byStart != 0) {
          return byStart;
        }
        final byEnd = a.end.compareTo(b.end);
        if (byEnd != 0) {
          return byEnd;
        }
        return a.ruleId.compareTo(b.ruleId);
      });

    final accepted = <WritingIssue>[];
    var skippedCount = 0;
    var previousEnd = -1;

    for (final issue in candidates) {
      if (issue.replacement == null || !_isCurrentIssue(text, issue)) {
        skippedCount++;
        continue;
      }
      if (issue.start < previousEnd) {
        skippedCount++;
        continue;
      }
      accepted.add(issue);
      previousEnd = issue.end;
    }

    if (accepted.isEmpty) {
      final fallbackOffset = candidates.isEmpty ? 0 : candidates.first.start;
      return WritingBatchCorrectionResult(
        text: text,
        caretOffset: _safeCaret(fallbackOffset, text.length),
        appliedCount: 0,
        skippedCount: skippedCount,
      );
    }

    var updated = text;
    for (final issue in accepted.reversed) {
      updated = updated.replaceRange(
        issue.start,
        issue.end,
        issue.replacement!,
      );
    }

    final lastIssue = accepted.last;
    var lastIssueStart = lastIssue.start;
    for (final issue in accepted) {
      if (identical(issue, lastIssue)) {
        break;
      }
      lastIssueStart += issue.replacement!.length - (issue.end - issue.start);
    }

    return WritingBatchCorrectionResult(
      text: updated,
      caretOffset: _safeCaret(
        lastIssueStart + lastIssue.replacement!.length,
        updated.length,
      ),
      appliedCount: accepted.length,
      skippedCount: skippedCount,
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
