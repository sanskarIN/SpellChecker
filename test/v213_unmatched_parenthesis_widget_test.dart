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

    for (var index = 0; index < 16 && target.evaluate().isEmpty; index++) {
      await tester.drag(insightsList(), const Offset(0, -180));
      await tester.pumpAndSettle();
    }

    expect(target, findsOneWidget);
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  testWidgets('unmatched parenthesis is enabled and advisory-only', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello (world');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Unmatched parenthesis',
    );
    await scrollTo(tester, ruleSwitch);
    expect(tester.widget<SwitchListTile>(ruleSwitch).value, isTrue);

    final finding = find.text(
      'This opening parenthesis has no matching closing parenthesis.',
    );
    await scrollTo(tester, finding);
    expect(finding, findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('apply-all-writing-fixes')),
      findsNothing,
    );
  });

  testWidgets('automatic fixes only hides unmatched parenthesis findings', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello (world');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final automaticOnly = find.byKey(
      const ValueKey<String>('automatic-fixes-only'),
    );
    await scrollTo(tester, automaticOnly);
    await tester.tap(automaticOnly);
    await tester.pumpAndSettle();

    final countFinder = find.byKey(
      const ValueKey<String>('writing-findings-visible-count'),
    );
    await scrollTo(tester, countFinder);
    final count = tester.widget<Semantics>(countFinder);
    expect(
      count.properties.label,
      '0 visible findings of 1 captured findings.',
    );
    expect(
      find.byKey(const ValueKey<String>('apply-all-writing-fixes')),
      findsNothing,
    );
  });

  testWidgets('explicit unmatched parenthesis disable persists', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello (world');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Unmatched parenthesis',
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
    expect(stored, isNot(contains('unmatched-parenthesis')));
    expect(stored, contains('missing-punctuation-space'));
    expect(stored, contains('repeated-word'));
  });
}
