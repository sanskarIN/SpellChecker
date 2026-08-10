import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Removes horizontal whitespace immediately before a line ending or the end
/// of the document.
class TrailingWhitespaceRule extends WritingRule {
  const TrailingWhitespaceRule();

  @override
  String get id => 'trailing-whitespace';

  @override
  String get displayName => 'Trailing whitespace';

  @override
  String get description =>
      'Finds horizontal whitespace at the end of a line or document.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in RegExp(r'[ \t]+(?=\r?(?:\n|$))').allMatches(text)) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Remove trailing whitespace here.',
        start: match.start,
        end: match.end,
        originalText: match.group(0)!,
        replacement: '',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
