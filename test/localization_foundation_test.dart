import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';
import 'package:spellchecker/features/editor/spell_checker_page.dart';
import 'package:spellchecker/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('localization foundation exposes only the reviewed English locale', () {
    expect(AppLocalizations.supportedLocales, const <Locale>[Locale('en')]);
  });

  testWidgets(
    'app shell and searchable language picker use generated strings',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();

      expect(find.text('SpellChecker'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('language-selector')));
      await tester.pumpAndSettle();

      expect(find.text('Choose spelling language'), findsOneWidget);
      expect(find.text('Search languages'), findsOneWidget);
      expect(find.text('Name or language ID'), findsOneWidget);
    },
  );

  testWidgets('spelling-language changes never change the UI locale', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    BuildContext pageContext = tester.element(find.byType(SpellCheckerPage));
    expect(Localizations.localeOf(pageContext), const Locale('en'));

    await tester.tap(find.byKey(const ValueKey<String>('language-selector')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('language-picker-search')),
      'hi-IN',
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('language-option-hi-IN')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hindi'), findsOneWidget);
    pageContext = tester.element(find.byType(SpellCheckerPage));
    expect(Localizations.localeOf(pageContext), const Locale('en'));
  });
}
