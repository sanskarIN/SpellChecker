import '../../core/spell_language_pack.dart';
import '../writing_issue.dart';
import '../writing_rule.dart';

/// Reports literal opening or closing curly braces that have no matching pair.
///
/// The rule is deliberately advisory-only. It owns the unmatched curly brace
/// character as its source range but does not guess whether the intended fix
/// is insertion, deletion, or a wider rewrite.
class UnmatchedCurlyBraceRule extends WritingRule {
  const UnmatchedCurlyBraceRule();

  @override
  String get id => 'unmatched-curly-brace';

  @override
  String get displayName => 'Unmatched curly brace';

  @override
  String get description =>
      'Finds opening or closing curly braces that do not have a matching pair.';

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
      if (codeUnit == _openingCurlyBrace) {
        openings.add(index);
        continue;
      }
      if (codeUnit != _closingCurlyBrace) {
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
      final curlyBrace = text[index];
      final isOpening = curlyBrace == '{';
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: isOpening
            ? 'This opening curly brace has no matching closing curly brace.'
            : 'This closing curly brace has no matching opening curly brace.',
        start: index,
        end: index + 1,
        originalText: curlyBrace,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.warning,
      );
    }
  }

  static const int _openingCurlyBrace = 0x7B;
  static const int _closingCurlyBrace = 0x7D;
}
