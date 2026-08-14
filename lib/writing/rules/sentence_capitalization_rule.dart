import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

class SentenceCapitalizationRule extends WritingRule {
  const SentenceCapitalizationRule();

  @override
  String get id => 'sentence-capitalization';

  @override
  String get displayName => 'Sentence capitalization';

  @override
  String get description =>
      'Suggests capitalization for the first word of an English sentence.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    final matches = languagePack.tokenize(text).toList(growable: false);
    if (matches.isEmpty) {
      return;
    }

    RegExpMatch? previous;
    for (final match in matches) {
      final word = match.group(0)!;
      final atSentenceStart =
          previous == null ||
          _endsSentence(text.substring(previous.end, match.start));

      if (atSentenceStart && _startsWithLowercaseLetter(word)) {
        final replacement = '${word[0].toUpperCase()}${word.substring(1)}';
        yield WritingIssue(
          ruleId: id,
          ruleName: displayName,
          message: 'Start this sentence with a capital letter.',
          start: match.start,
          end: match.end,
          originalText: word,
          replacement: replacement,
          languageId: languagePack.id,
          severity: WritingIssueSeverity.suggestion,
        );
      }
      previous = match;
    }
  }

  static bool _endsSentence(String gap) {
    return RegExp(r'''[.!?]["'’”\)\]]*\s+$''').hasMatch(gap);
  }

  static bool _startsWithLowercaseLetter(String word) {
    if (word.isEmpty) {
      return false;
    }
    final first = word.substring(0, 1);
    return first.toLowerCase() == first && first.toUpperCase() != first;
  }
}
