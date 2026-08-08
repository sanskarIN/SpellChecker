import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('language selector rechecks text with the selected pack', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('English (US)'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'color');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();
    expect(find.text('No issues found'), findsOneWidget);

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    expect(selector, findsOneWidget);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English (UK)').last);
    await tester.pumpAndSettle();

    expect(find.text('English (UK)'), findsOneWidget);
    expect(find.text('color'), findsWidgets);
    expect(find.text('colour'), findsWidgets);

    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English (US)').last);
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
  });

  testWidgets('personal words are restored only for their language pack', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.language_id.v1': 'en-GB',
      'spellchecker.personal_words.v2.en-US': <String>['zorbax'],
      'spellchecker.personal_words.v2.en-GB': <String>[],
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('English (UK)'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'zorbax');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();
    expect(find.text('zorbax'), findsWidgets);

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English (US)').last);
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
  });
}
