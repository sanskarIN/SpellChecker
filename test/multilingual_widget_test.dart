import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';
import 'package:spellchecker/core/spell_language_pack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('language selector exposes every registered pack', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    expect(selector, findsOneWidget);

    final dropdown = tester.widget<DropdownButton<String>>(selector);
    final items = dropdown.items ?? const <DropdownMenuItem<String>>[];

    expect(
      items.map((item) => item.value).toList(),
      SpellLanguageRegistry.builtIns.map((pack) => pack.id).toList(),
    );
    expect(
      items.map((item) => (item.child as Text).data).toList(),
      SpellLanguageRegistry.builtIns.map((pack) => pack.displayName).toList(),
    );
  });

  testWidgets('switching to Bengali rechecks the current text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField).first,
      'নমস্কার বিশ্ব ধন্যবাদ',
    );
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();
    expect(find.text('নমস্কার'), findsWidgets);

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bengali (India)').last);
    await tester.pumpAndSettle();

    expect(find.text('Bengali (India)'), findsOneWidget);
    expect(find.text('No issues found'), findsOneWidget);
  });

  testWidgets('restores Telugu as the persisted selected language', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.language_id.v1': 'te-IN',
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('Telugu (India)'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'నమస్కారం ప్రపంచం ధన్యవాదాలు',
    );
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
  });
}
