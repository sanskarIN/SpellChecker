// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpellChecker';

  @override
  String get keyboardShortcutsTitle => 'Keyboard shortcuts';

  @override
  String get keyboardShortcutsIntro =>
      'Use these shortcuts while SpellChecker has focus. On macOS, ⌘ replaces Ctrl for the primary command shortcuts.';

  @override
  String get shortcutCheckSpelling => 'Check spelling';

  @override
  String get shortcutOpenWritingInsights => 'Open Writing insights';

  @override
  String get shortcutNextSpellingIssue => 'Next spelling issue';

  @override
  String get shortcutPreviousSpellingIssue => 'Previous spelling issue';

  @override
  String get shortcutOpenHelp => 'Open keyboard shortcut help';

  @override
  String get keyboardShortcutsVisibleActions =>
      'All commands also remain available through visible buttons so keyboard access is never required.';

  @override
  String get close => 'Close';

  @override
  String shortcutSemantics(String action, String shortcut) {
    return '$action shortcut: $shortcut';
  }

  @override
  String spellingLanguageSemantics(String displayName, String languageId) {
    return 'Spelling language. Current language $displayName, $languageId.';
  }

  @override
  String get chooseSpellingLanguage => 'Choose spelling language';

  @override
  String get searchLanguages => 'Search languages';

  @override
  String get languageSearchHint => 'Name or language ID';

  @override
  String get clearLanguageSearch => 'Clear language search';

  @override
  String spellingLanguageOptionSemantics(
    String displayName,
    String languageId,
    String selectedSuffix,
  ) {
    return '$displayName, spelling language $languageId$selectedSuffix';
  }

  @override
  String get selectedSuffix => ', selected';

  @override
  String get selectedLanguage => 'Selected language';

  @override
  String get cancel => 'Cancel';

  @override
  String get noSpellingLanguagesMatch =>
      'No spelling languages match the current search.';

  @override
  String get noMatchingLanguages => 'No matching languages';
}
