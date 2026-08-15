import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Finder insightsList() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
  }

  Finder insightsScrollable() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is Scrollable &&
            widget.axisDirection == AxisDirection.down &&
            widget.physics is AlwaysScrollableScrollPhysics,
      ),
    );
  }

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    expect(insightsList(), findsOneWidget);
    expect(insightsScrollable(), findsOneWidget);
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: insightsScrollable(),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('missing punctuation space is enabled and batch-fixable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    const original = 'Hello ,world!Again';
    await tester.enterText(editor, original);
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Missing punctuation space',
    );
    await scrollTo(tester, ruleSwitch);
    expect(ruleSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(ruleSwitch).value, isTrue);

    final applyAll = find.byKey(
      const ValueKey<String>('apply-all-writing-fixes'),
    );
    await scrollTo(tester, applyAll);
    expect(applyAll, findsOneWidget);
    await tester.tap(applyAll);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(editor).controller!.text,
      'Hello, world! Again',
    );

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(editor).controller!.text, original);
  });

  testWidgets(
    'explicit rule disable persists without disabling other defaults',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Hello,world');
      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pumpAndSettle();

      final ruleSwitch = find.widgetWithText(
        SwitchListTile,
        'Missing punctuation space',
      );
      await scrollTo(tester, ruleSwitch);
      await tester.tap(ruleSwitch);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      final stored = preferences.getStringList(
        'spellchecker.writing_rule_ids.v1.en-US',
      );
      expect(stored, isNotNull);
      expect(stored, isNot(contains('missing-punctuation-space')));
      expect(stored, contains('punctuation-spacing'));
      expect(stored, contains('repeated-word'));
    },
  );
}
