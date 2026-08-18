import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Finds a colon between Unicode letter clusters when no following horizontal
/// space is present.
///
/// The rule owns only the colon source range. Optional horizontal whitespace
/// before the colon is intentionally left to `punctuation-spacing` so both
/// automatic fixes remain adjacent and non-overlapping.
class MissingColonSpaceRule extends WritingRule {
  const MissingColonSpaceRule();

  static final RegExp _pattern = RegExp(
    r'\p{L}\p{M}*[ \t]*(:)(?=\p{L})',
    unicode: true,
  );

  @override
  String get id => 'missing-colon-space';

  @override
  String get displayName => 'Missing colon space';

  @override
  String get description =>
      'Finds colons between words when a following space is missing.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in _pattern.allMatches(text)) {
      final colon = match.group(1)!;
      final colonStart = match.end - colon.length;

      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Add a space after this colon.',
        start: colonStart,
        end: match.end,
        originalText: colon,
        replacement: '$colon ',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
