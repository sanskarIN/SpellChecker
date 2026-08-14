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

  Future<void> openWritingInsights(WidgetTester tester) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField).first,
      'hello  world world!!',
    );
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();
  }

  Future<void> sendControlF(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  testWidgets('Ctrl+F focuses Writing insights search', (
    WidgetTester tester,
  ) async {
    await openWritingInsights(tester);

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    expect(search, findsOneWidget);
    final searchField = tester.widget<TextField>(search);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(searchField.focusNode!.hasFocus, isFalse);

    await sendControlF(tester);

    expect(searchField.focusNode!.hasFocus, isTrue);
    expect(find.text('Writing insights'), findsOneWidget);
  });

  testWidgets('Escape clears active review filters before closing dialog', (
    WidgetTester tester,
  ) async {
    await openWritingInsights(tester);

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    await tester.enterText(search, 'clarity');
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('clear-writing-review-filters')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsOneWidget);
    expect(tester.widget<TextField>(search).controller!.text, isEmpty);
    expect(
      find.byKey(const ValueKey<String>('clear-writing-review-filters')),
      findsNothing,
    );
    expect(tester.widget<TextField>(search).focusNode!.hasFocus, isTrue);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsNothing);
  });

  testWidgets('Escape clears category and automatic-fix filters together', (
    WidgetTester tester,
  ) async {
    await openWritingInsights(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('writing-category-mechanics')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('automatic-fixes-only')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('clear-writing-review-filters')),
      findsOneWidget,
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(
            find.byKey(const ValueKey<String>('writing-category-mechanics')),
          )
          .selected,
      isFalse,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.byKey(const ValueKey<String>('automatic-fixes-only')),
          )
          .value,
      isFalse,
    );
  });
}
