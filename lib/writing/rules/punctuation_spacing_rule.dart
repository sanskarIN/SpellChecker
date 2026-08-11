import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Removes horizontal whitespace immediately before common English
/// punctuation marks.
class PunctuationSpacingRule extends WritingRule {
  const PunctuationSpacingRule();

  @override
  String get id => 'punctuation-spacing';

  @override
  String get displayName => 'Punctuation spacing';

  @override
  String get description =>
      'Finds horizontal whitespace immediately before common punctuation.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in RegExp(r'[ \t]+(?=[,.;:!?])').allMatches(text)) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Remove the space before this punctuation mark.',
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
