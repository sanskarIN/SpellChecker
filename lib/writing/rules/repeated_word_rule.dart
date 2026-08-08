import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';
import '../writing_rule_category.dart';

class RepeatedWordRule extends WritingRule {
  const RepeatedWordRule();

  @override
  String get id => 'repeated-word';

  @override
  String get displayName => 'Repeated word';

  @override
  String get description =>
      'Finds the same word repeated consecutively with only whitespace between occurrences.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  WritingRuleCategory get category => WritingRuleCategory.clarity;

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    final matches = languagePack.tokenize(text).toList(growable: false);
    if (matches.length < 2) {
      return;
    }

    for (var index = 1; index < matches.length; index++) {
      final previous = matches[index - 1];
      final current = matches[index];
      final previousWord = previous.group(0)!;
      final currentWord = current.group(0)!;
      final gap = text.substring(previous.end, current.start);

      if (gap.trim().isNotEmpty ||
          languagePack.normalizeWord(previousWord) !=
              languagePack.normalizeWord(currentWord)) {
        continue;
      }

      final originalText = text.substring(previous.end, current.end);
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: '“$currentWord” is repeated.',
        start: previous.end,
        end: current.end,
        originalText: originalText,
        replacement: '',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.warning,
      );
    }
  }
}
