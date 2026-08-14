import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Adds one horizontal space after selected punctuation when that punctuation
/// is directly surrounded by letters.
///
/// Periods and colons are intentionally excluded to avoid common domain,
/// abbreviation, URI-scheme, and time-like false positives. Repeated
/// punctuation is also naturally excluded because the punctuation must be
/// surrounded by letters.
class MissingPunctuationSpaceRule extends WritingRule {
  const MissingPunctuationSpaceRule();

  static final RegExp _candidate = RegExp(
    r'(\p{L})([,;!?])(\p{L})',
    unicode: true,
  );

  @override
  String get id => 'missing-punctuation-space';

  @override
  String get displayName => 'Missing punctuation space';

  @override
  String get description =>
      'Finds missing spaces after commas, semicolons, question marks, and '
      'exclamation marks between words.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (var index = 0; index < text.length; index++) {
      final match = _candidate.matchAsPrefix(text, index);
      if (match == null) {
        continue;
      }

      final leadingLetter = match.group(1)!;
      final punctuation = match.group(2)!;
      final punctuationStart = index + leadingLetter.length;

      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Add a space after this punctuation mark.',
        start: punctuationStart,
        end: punctuationStart + punctuation.length,
        originalText: punctuation,
        replacement: '$punctuation ',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
