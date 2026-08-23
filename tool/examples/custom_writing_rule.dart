import 'package:spellchecker/core/spell_language_pack.dart';
import 'package:spellchecker/writing/writing_analyzer.dart';
import 'package:spellchecker/writing/writing_issue.dart';
import 'package:spellchecker/writing/writing_rule.dart';
import 'package:spellchecker/writing/writing_rule_category.dart';

/// Example caller-supplied advisory rule.
///
/// It flags the English word "very" for human review without guessing an
/// automatic replacement. Real integrations should choose IDs that are stable
/// and namespaced to their own package/application.
class AvoidVeryRule extends WritingRule {
  const AvoidVeryRule();

  @override
  String get id => 'example.avoid-very';

  @override
  String get displayName => 'Review “very”';

  @override
  String get description =>
      'Flags “very” so the writer can consider a more precise phrase.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  WritingRuleCategory get category => WritingRuleCategory.clarity;

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final match in RegExp(r'\bvery\b', caseSensitive: false).allMatches(text)) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Consider whether a more precise word would be clearer.',
        start: match.start,
        end: match.end,
        originalText: match.group(0)!,
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}

void main() {
  final languagePack = SpellLanguageRegistry.defaultPack;
  final analyzer = WritingAnalyzer(rules: const <WritingRule>[
    AvoidVeryRule(),
  ]);
  final result = analyzer.analyze(
    'This is very useful, but that claim is VERY broad.',
    languagePack: languagePack,
  );

  for (final issue in result.issues) {
    print('${issue.ruleId}: ${issue.originalText} @ ${issue.start}-${issue.end}');
  }
}
