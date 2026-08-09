import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Finds a comma or semicolon followed immediately by a letter.
///
/// The scope is intentionally narrow. Colons are excluded because compact
/// scheme/label forms are common, and periods/question/exclamation marks need
/// richer sentence/abbreviation context before an automatic insertion is safe.
class MissingSpaceAfterPunctuationRule extends WritingRule {
  const MissingSpaceAfterPunctuationRule();

  static final RegExp _candidatePattern = RegExp(r'[,;]\p{L}', unicode: true);

  static const Set<String> _reviewPunctuation = <String>{
    ',',
    ';',
    ':',
    '.',
    '!',
    '?',
  };

  @override
  String get id => 'missing-space-after-punctuation';

  @override
  String get displayName => 'Missing space after punctuation';

  @override
  String get description =>
      'Finds a comma or semicolon followed immediately by a letter.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in _candidatePattern.allMatches(text)) {
      if (match.start > 0 &&
          _reviewPunctuation.contains(
            text.substring(match.start - 1, match.start),
          )) {
        // Leave repeated/clustered punctuation to its dedicated rule. This
        // also avoids overlapping an automatic spacing fix with that run.
        continue;
      }

      final original = match.group(0)!;
      final punctuation = original.substring(0, 1);
      final followingLetter = original.substring(1);
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Add a space after this punctuation mark.',
        start: match.start,
        end: match.end,
        originalText: original,
        replacement: '$punctuation $followingLetter',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
