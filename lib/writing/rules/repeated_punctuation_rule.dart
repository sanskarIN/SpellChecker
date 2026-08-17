import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

class RepeatedPunctuationRule extends WritingRule {
  const RepeatedPunctuationRule();

  @override
  String get id => 'repeated-punctuation';

  @override
  String get displayName => 'Repeated punctuation';

  @override
  String get description =>
      'Finds accidental runs of the same sentence punctuation mark.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    final pattern = RegExp(r'([!?.,])\1+');
    for (final match in pattern.allMatches(text)) {
      final original = match.group(0)!;
      if (original == '...') {
        continue;
      }
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Repeated punctuation may be accidental.',
        start: match.start,
        end: match.end,
        originalText: original,
        replacement: original.substring(0, 1),
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
