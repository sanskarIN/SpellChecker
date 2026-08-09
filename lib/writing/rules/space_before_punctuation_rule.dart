import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Finds one stray ASCII space directly before common prose punctuation.
///
/// Runs of multiple spaces are intentionally skipped so the existing
/// `repeated-space` rule keeps ownership of that source range. After that rule
/// is applied and analysis is refreshed, a remaining single stray space can be
/// handled here without duplicate overlapping findings from the two rules.
class SpaceBeforePunctuationRule extends WritingRule {
  const SpaceBeforePunctuationRule();

  static final RegExp _candidatePattern = RegExp(r' [,.;:!?]');

  @override
  String get id => 'space-before-punctuation';

  @override
  String get displayName => 'Space before punctuation';

  @override
  String get description =>
      'Finds one stray space directly before common punctuation.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in _candidatePattern.allMatches(text)) {
      if (match.start > 0) {
        final preceding = text.substring(match.start - 1, match.start);
        if (preceding == ' ' || preceding == '\t') {
          continue;
        }
      }

      final original = match.group(0)!;
      final punctuation = original.substring(original.length - 1);
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Remove the space before this punctuation mark.',
        start: match.start,
        end: match.end,
        originalText: original,
        replacement: punctuation,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
