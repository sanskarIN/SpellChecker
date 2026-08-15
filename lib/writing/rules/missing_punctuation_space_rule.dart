import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Finds selected punctuation between Unicode letter clusters when the
/// punctuation is not followed by horizontal whitespace.
///
/// The rule owns only the punctuation source range. Optional horizontal
/// whitespace before the punctuation is intentionally left to
/// `punctuation-spacing` so the two automatic fixes remain adjacent and
/// non-overlapping when they appear together.
class MissingPunctuationSpaceRule extends WritingRule {
  const MissingPunctuationSpaceRule();

  static final RegExp _pattern = RegExp(
    r'\p{L}\p{M}*[ \t]*([,;!?])(?=\p{L})',
    unicode: true,
  );

  @override
  String get id => 'missing-punctuation-space';

  @override
  String get displayName => 'Missing punctuation space';

  @override
  String get description =>
      'Finds commas, semicolons, question marks, and exclamation marks '
      'between words when a following space is missing.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in _pattern.allMatches(text)) {
      final punctuation = match.group(1)!;
      final punctuationStart = match.end - punctuation.length;

      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Add a space after this punctuation mark.',
        start: punctuationStart,
        end: match.end,
        originalText: punctuation,
        replacement: '$punctuation ',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
