import 'package:flutter/material.dart';
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
    expect(find.text('Save word'), findsOneWidget);
    await tester.tap(find.text('Save word'));
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

    expect(find.text('Personal dictionary'), findsOneWidget);
    expect(find.text('flutter'), findsOneWidget);
  });
}
