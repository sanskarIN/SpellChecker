import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Application title.
  ///
  /// In en, this message translates to:
  /// **'SpellChecker'**
  String get appTitle;

  /// Title of the keyboard shortcut help dialog.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get keyboardShortcutsTitle;

  /// Introductory text for keyboard shortcut help.
  ///
  /// In en, this message translates to:
  /// **'Use these shortcuts while SpellChecker has focus. On macOS, ⌘ replaces Ctrl for the primary command shortcuts.'**
  String get keyboardShortcutsIntro;

  /// Keyboard shortcut action label for spelling analysis.
  ///
  /// In en, this message translates to:
  /// **'Check spelling'**
  String get shortcutCheckSpelling;

  /// Keyboard shortcut action label for Writing insights.
  ///
  /// In en, this message translates to:
  /// **'Open Writing insights'**
  String get shortcutOpenWritingInsights;

  /// Keyboard shortcut action label for moving to the next spelling issue.
  ///
  /// In en, this message translates to:
  /// **'Next spelling issue'**
  String get shortcutNextSpellingIssue;

  /// Keyboard shortcut action label for moving to the previous spelling issue.
  ///
  /// In en, this message translates to:
  /// **'Previous spelling issue'**
  String get shortcutPreviousSpellingIssue;

  /// Keyboard shortcut action label for opening help.
  ///
  /// In en, this message translates to:
  /// **'Open keyboard shortcut help'**
  String get shortcutOpenHelp;

  /// Accessibility note in keyboard shortcut help.
  ///
  /// In en, this message translates to:
  /// **'All commands also remain available through visible buttons so keyboard access is never required.'**
  String get keyboardShortcutsVisibleActions;

  /// Generic close action.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Screen-reader label for a shortcut row.
  ///
  /// In en, this message translates to:
  /// **'{action} shortcut: {shortcut}'**
  String shortcutSemantics(String action, String shortcut);

  /// Screen-reader label for the spelling-language selector.
  ///
  /// In en, this message translates to:
  /// **'Spelling language. Current language {displayName}, {languageId}.'**
  String spellingLanguageSemantics(String displayName, String languageId);

  /// Title of the searchable spelling-language picker.
  ///
  /// In en, this message translates to:
  /// **'Choose spelling language'**
  String get chooseSpellingLanguage;

  /// Label for the language-picker search field.
  ///
  /// In en, this message translates to:
  /// **'Search languages'**
  String get searchLanguages;

  /// Hint for searchable language identifiers.
  ///
  /// In en, this message translates to:
  /// **'Name or language ID'**
  String get languageSearchHint;

  /// Tooltip for clearing the language search query.
  ///
  /// In en, this message translates to:
  /// **'Clear language search'**
  String get clearLanguageSearch;

  /// Screen-reader label for one spelling-language option.
  ///
  /// In en, this message translates to:
  /// **'{displayName}, spelling language {languageId}{selectedSuffix}'**
  String spellingLanguageOptionSemantics(
    String displayName,
    String languageId,
    String selectedSuffix,
  );

  /// Suffix appended to the selected language option semantics.
  ///
  /// In en, this message translates to:
  /// **', selected'**
  String get selectedSuffix;

  /// Semantic label for the selected-language check icon.
  ///
  /// In en, this message translates to:
  /// **'Selected language'**
  String get selectedLanguage;

  /// Generic cancel action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Live-region text when language search has no matches.
  ///
  /// In en, this message translates to:
  /// **'No spelling languages match the current search.'**
  String get noSpellingLanguagesMatch;

  /// Visible empty-state text for language search.
  ///
  /// In en, this message translates to:
  /// **'No matching languages'**
  String get noMatchingLanguages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
