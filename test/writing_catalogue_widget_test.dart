import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Finder insightsList() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(ListView),
  );

  Finder insightsScrollable() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Scrollable &&
          widget.axisDirection == AxisDirection.down &&
          widget.physics is AlwaysScrollableScrollPhysics,
    ),
  );

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    final list = insightsList();
    final scrollable = insightsScrollable();
    expect(list, findsOneWidget);
    expect(scrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      target,
      180,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('new catalogue rules are enabled for an unset profile', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    for (final label in <String>[
      'Missing space after punctuation',
      'Space before punctuation',
    ]) {
      final target = find.widgetWithText(SwitchListTile, label);
      await scrollTo(tester, target);
      expect(target, findsOneWidget);
      expect(tester.widget<SwitchListTile>(target).value, isTrue);
    }
  });

  testWidgets('new punctuation fixes batch through existing one-step undo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    const source = 'Hello , world;again.';
    await tester.enterText(editor, source);
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final applyAll = find.byKey(
      const ValueKey<String>('apply-all-writing-fixes'),
    );
    await scrollTo(tester, applyAll);
    expect(applyAll, findsOneWidget);
    await tester.tap(applyAll);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(editor).controller!.text,
      'Hello, world; again.',
    );
    expect(find.text('Undo correction'), findsOneWidget);

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(editor).controller!.text, source);
  });
}
