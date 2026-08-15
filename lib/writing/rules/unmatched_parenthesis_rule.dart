import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Reports literal opening or closing parentheses that have no matching pair.
///
/// The rule is deliberately advisory-only. It owns the unmatched parenthesis
/// character as its source range but does not guess whether the intended fix
/// is insertion, deletion, or a wider rewrite.
class UnmatchedParenthesisRule extends WritingRule {
  const UnmatchedParenthesisRule();

  @override
  String get id => 'unmatched-parenthesis';

  @override
  String get displayName => 'Unmatched parenthesis';

  @override
  String get description =>
      'Finds opening or closing parentheses that do not have a matching pair.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    final openings = <int>[];
    final unmatched = <int>[];

    for (var index = 0; index < text.length; index++) {
      final codeUnit = text.codeUnitAt(index);
      if (codeUnit == _openingParenthesis) {
        openings.add(index);
        continue;
      }
      if (codeUnit != _closingParenthesis) {
        continue;
      }
      if (openings.isEmpty) {
        unmatched.add(index);
      } else {
        openings.removeLast();
      }
    }

    unmatched
      ..addAll(openings)
      ..sort();

    for (final index in unmatched) {
      final parenthesis = text[index];
      final isOpening = parenthesis == '(';
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: isOpening
            ? 'This opening parenthesis has no matching closing parenthesis.'
            : 'This closing parenthesis has no matching opening parenthesis.',
        start: index,
        end: index + 1,
        originalText: parenthesis,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.warning,
      );
    }
  }

  static const int _openingParenthesis = 0x28;
  static const int _closingParenthesis = 0x29;
}
