import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

class RepeatedSpaceRule extends WritingRule {
  const RepeatedSpaceRule();

  @override
  String get id => 'repeated-space';

  @override
  String get displayName => 'Repeated spaces';

  @override
  String get description =>
      'Finds runs of two or more horizontal spaces inside prose.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in RegExp(r' {2,}').allMatches(text)) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Use a single space here.',
        start: match.start,
        end: match.end,
        originalText: match.group(0)!,
        replacement: ' ',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
