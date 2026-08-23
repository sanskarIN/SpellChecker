import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

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

    expect(find.text('Ready to check'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Helo world');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Helo'), findsOneWidget);
    expect(find.byType(ActionChip), findsWidgets);
    expect(find.text('Suggestions'), findsOneWidget);
    expect(find.text('Issue 1 of 1'), findsOneWidget);
  });

  testWidgets('shows a dedicated blank-input result state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Nothing to check'), findsOneWidget);
  });

  testWidgets('F1 opens the keyboard shortcut reference', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.f1);
    await tester.pumpAndSettle();

    expect(find.text('Keyboard shortcuts'), findsOneWidget);
    expect(find.text('Check spelling'), findsWidgets);
    expect(find.text('Ctrl/⌘ + Enter'), findsOneWidget);
    expect(find.text('Ctrl/⌘ + Shift + Enter'), findsOneWidget);
    expect(find.text('F7'), findsOneWidget);
    expect(find.text('Shift + F7'), findsOneWidget);
    expect(find.text('F1'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard shortcuts'), findsNothing);
  });

  testWidgets('F7 moves to the next spelling issue', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Zorbax Qwertyx');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Issue 1 of 2'), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.f7);
    await tester.pumpAndSettle();

    expect(find.text('Issue 2 of 2'), findsOneWidget);
  });

  testWidgets('replace all can be undone as one correction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Helo world Helo world');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('2 occurrences'), findsWidgets);
    expect(find.text('Replace all…'), findsWidgets);

    final replaceAll = find.text('Replace all…').first;
    await tester.ensureVisible(replaceAll);
    await tester.pumpAndSettle();
    await tester.tap(replaceAll);
    await tester.pumpAndSettle();

    final replacementItems = find.byType(PopupMenuItem<String>);
    expect(replacementItems, findsWidgets);
    await tester.tap(replacementItems.first);
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('2 occurrences'), findsWidgets);
    expect(find.text('Replace all…'), findsWidgets);
    expect(find.textContaining('Issue '), findsWidgets);
  });

  testWidgets('saves a personal word through the editor workflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Zorbax');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('Zorbax'), findsNWidgets(2));
    final saveWord = find.text('Save word');
    expect(saveWord, findsOneWidget);
    await tester.ensureVisible(saveWord);
    await tester.pumpAndSettle();
    await tester.tap(saveWord);
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('spellchecker.personal_words.v1'),
      contains('zorbax'),
    );
  });

  testWidgets('opens dictionary manager after preferences load', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.personal_words.v1': <String>['flutter'],
      'spellchecker.suggestion_limit.v1': 8,
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('8 suggestions'), findsOneWidget);
    await tester.tap(find.byTooltip('Manage personal dictionary'));
    await tester.pumpAndSettle();

    expect(find.text('Personal dictionary — English (US)'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
  });

  testWidgets('About dialog reports the V3.2 multilingual release', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('About SpellChecker'));
    await tester.pumpAndSettle();

    expect(find.textContaining('3.2.0'), findsOneWidget);
  });
}
