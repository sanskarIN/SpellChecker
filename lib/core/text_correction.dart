import 'spell_issue.dart';

class TextCorrectionResult {
  const TextCorrectionResult({
    required this.text,
    required this.caretOffset,
    required this.replacements,
  });

  final String text;
  final int caretOffset;
  final int replacements;

  bool get changed => replacements > 0;
}

class TextCorrection {
  const TextCorrection._();

  static TextCorrectionResult replaceOne(
    String text,
    SpellIssue issue,
    String suggestion,
  ) {
    if (!_isCurrentIssue(text, issue) || suggestion.isEmpty) {
      return TextCorrectionResult(
        text: text,
        caretOffset: _safeCaret(issue.start, text.length),
        replacements: 0,
      );
    }

    final replacement = matchCase(issue.word, suggestion);
    final updated = text.replaceRange(issue.start, issue.end, replacement);
    return TextCorrectionResult(
      text: updated,
      caretOffset: issue.start + replacement.length,
      replacements: 1,
    );
  }

  static TextCorrectionResult replaceAll(
    String text,
    Iterable<SpellIssue> issues,
    String sourceWord,
    String suggestion,
  ) {
    if (sourceWord.isEmpty || suggestion.isEmpty) {
      return TextCorrectionResult(
        text: text,
        caretOffset: text.length,
        replacements: 0,
      );
    }

    final target = sourceWord.toLowerCase();
    final matching = issues
        .where(
          (SpellIssue issue) =>
              issue.word.toLowerCase() == target && _isCurrentIssue(text, issue),
        )
        .toList(growable: false)
      ..sort((SpellIssue a, SpellIssue b) => b.start.compareTo(a.start));

    if (matching.isEmpty) {
      return TextCorrectionResult(
        text: text,
        caretOffset: text.length,
        replacements: 0,
      );
    }

    var updated = text;
    var earliestCaret = text.length;
    for (final issue in matching) {
      final replacement = matchCase(issue.word, suggestion);
      updated = updated.replaceRange(issue.start, issue.end, replacement);
      earliestCaret = issue.start + replacement.length;
    }

    return TextCorrectionResult(
      text: updated,
      caretOffset: _safeCaret(earliestCaret, updated.length),
      replacements: matching.length,
    );
  }

  static String matchCase(String original, String suggestion) {
    if (original.isEmpty || suggestion.isEmpty) {
      return suggestion;
    }

    if (original == original.toUpperCase()) {
      return suggestion.toUpperCase();
    }

    if (original[0] == original[0].toUpperCase()) {
      return '${suggestion[0].toUpperCase()}${suggestion.substring(1)}';
    }

    return suggestion;
  }

  static bool _isCurrentIssue(String text, SpellIssue issue) {
    return issue.start >= 0 &&
        issue.end <= text.length &&
        issue.start < issue.end &&
        text.substring(issue.start, issue.end) == issue.word;
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
