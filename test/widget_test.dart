import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/features/editor/spell_checker_page.dart';
import 'package:spellchecker/main.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('checks text and displays a spelling issue', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'helo world');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('helo'), findsOneWidget);
    expect(find.text('hello'), findsWidgets);
  });

  testWidgets('shows a dedicated blank-input result state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to check yet'), findsOneWidget);
  });

  testWidgets('F7 moves to the next spelling issue', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'helo wurld');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Issue 1 of 2'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.f7);
    await tester.pumpAndSettle();

    expect(find.textContaining('Issue 2 of 2'), findsOneWidget);
  });

  testWidgets('replace all can be undone as one correction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'helo helo');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    final replaceAll = find.widgetWithText(TextButton, 'Replace all');
    expect(replaceAll, findsOneWidget);
    await tester.tap(replaceAll);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller?.text, 'hello hello');

    await tester.tap(find.byTooltip('Undo correction'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller?.text, 'helo helo');
  });

  testWidgets('saves a personal word through the editor workflow', (
    WidgetTester tester,
  ) async {
    final preferences = DictionaryPreferences();
    await tester.pumpWidget(
      MaterialApp(home: SpellCheckerPage(preferences: preferences)),
    );
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'flutter');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('flutter'), findsOneWidget);
    await tester.tap(find.text('Add to personal dictionary'));
    await tester.pumpAndSettle();

    expect(
      await preferences.loadPersonalWords(languageId: 'en-US'),
      contains('flutter'),
    );
  });

  testWidgets('opens dictionary manager after preferences load', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.personal_words.v2.en-US': <String>['flutter'],
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('8 suggestions'), findsOneWidget);
    await tester.tap(find.byTooltip('Manage personal dictionary'));
    await tester.pumpAndSettle();

    expect(find.text('Personal dictionary — English (US)'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
  });

  testWidgets('About dialog reports the V3.1 multilingual release', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('About SpellChecker'));
    await tester.pumpAndSettle();

    expect(find.textContaining('3.1.1'), findsOneWidget);
  });
}
