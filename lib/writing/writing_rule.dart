import '../core/spell_language_pack.dart';
import 'writing_issue.dart';
import 'writing_rule_category.dart';

abstract class WritingRule {
  const WritingRule();

  String get id;
  String get displayName;
  String get description;
  Set<String> get supportedLanguageIds;

  /// Broad user-facing review category.
  ///
  /// The concrete default keeps the V2.2 API source-compatible with external
  /// 2.x rules that implemented the original V2.0 contract before categories
  /// existed. Rules can override this getter when a different category fits.
  WritingRuleCategory get category => WritingRuleCategory.mechanics;

  bool supports(SpellLanguagePack languagePack) {
    return supportedLanguageIds.contains(languagePack.id) ||
        supportedLanguageIds.contains(languagePack.languageCode);
  }

  Iterable<WritingIssue> analyze(String text, SpellLanguagePack languagePack);
}
