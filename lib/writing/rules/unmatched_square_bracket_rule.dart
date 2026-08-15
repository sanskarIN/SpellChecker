import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Reports literal opening or closing square brackets that have no matching
/// pair.
///
/// The rule is deliberately advisory-only. It owns the unmatched square
/// bracket character as its source range but does not guess whether the
/// intended fix is insertion, deletion, or a wider rewrite.
class UnmatchedSquareBracketRule extends WritingRule {
  const UnmatchedSquareBracketRule();

  @override
  String get id => 'unmatched-square-bracket';

  @override
  String get displayName => 'Unmatched square bracket';

  @override
  String get description =>
      'Finds opening or closing square brackets that do not have a matching pair.';

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
      if (codeUnit == _openingSquareBracket) {
        openings.add(index);
        continue;
      }
      if (codeUnit != _closingSquareBracket) {
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
      final squareBracket = text[index];
      final isOpening = squareBracket == '[';
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: isOpening
            ? 'This opening square bracket has no matching closing square bracket.'
            : 'This closing square bracket has no matching opening square bracket.',
        start: index,
        end: index + 1,
        originalText: squareBracket,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.warning,
      );
    }
  }

  static const int _openingSquareBracket = 0x5B;
  static const int _closingSquareBracket = 0x5D;
}
