import '../core/spell_language_pack.dart';
import 'writing_issue.dart';

abstract class WritingRule {
  const WritingRule();

  String get id;
  String get displayName;
  String get description;
  Set<String> get supportedLanguageIds;

  bool supports(SpellLanguagePack languagePack) {
    return supportedLanguageIds.contains(languagePack.id) ||
        supportedLanguageIds.contains(languagePack.languageCode);
  }

  Iterable<WritingIssue> analyze(String text, SpellLanguagePack languagePack);
}
