import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('language selector exposes all multilingual packs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    expect(selector, findsOneWidget);

    await tester.tap(selector);
    await tester.pumpAndSettle();

    for (final label in <String>[
      'English (US)',
      'English (UK)',
      'Hindi (India)',
      'Spanish (Spain)',
      'French (France)',
      'German (Germany)',
      'Portuguese (Brazil)',
      'Italian (Italy)',
    ]) {
      expect(find.text(label), findsWidgets);
    }
  });

  testWidgets('switching to Spanish rechecks the current text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'hola mundo gracias');
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();
    expect(find.text('hola'), findsWidgets);

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish (Spain)').last);
    await tester.pumpAndSettle();

    expect(find.text('Spanish (Spain)'), findsOneWidget);
    expect(find.text('No issues found'), findsOneWidget);
  });

  testWidgets('non-English writing insights explain the English-only rule boundary', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final selector = find.byKey(const ValueKey<String>('language-selector'));
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish (Spain)').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'hola mundo gracias');
    await tester.tap(
      find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Writing rules not available for this language'),
      findsOneWidget,
    );
    expect(
      find.textContaining('current Writing Insights rules are English-only'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Spelling and the personal dictionary still work'),
      findsOneWidget,
    );
  });

  testWidgets('restores Hindi as the persisted selected language', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.language_id.v1': 'hi-IN',
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    expect(find.text('Hindi (India)'), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).first,
      'नमस्ते दुनिया धन्यवाद',
    );
    await tester.tap(find.text('Check spelling'));
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
  });
}
