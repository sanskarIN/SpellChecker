import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const v32RuleIds = <String>[
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
    'unmatched-curly-brace',
    'unmatched-parenthesis',
    'unmatched-square-bracket',
  ];

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
    expect(insightsList(), findsOneWidget);
    expect(insightsScrollable(), findsOneWidget);
    await tester.scrollUntilVisible(
      target,
      200,
      scrollable: insightsScrollable(),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToRule(WidgetTester tester, String label) async {
    final list = insightsList();
    expect(list, findsOneWidget);

    await tester.drag(list, const Offset(0, 2200));
    await tester.pumpAndSettle();

    final target = find.text(label);
    for (var index = 0; index < 32 && target.evaluate().isEmpty; index++) {
      await tester.drag(list, const Offset(0, -180));
      await tester.pumpAndSettle();
    }

    expect(target, findsWidgets);
    await tester.ensureVisible(target.first);
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.writing_rule_ids.v1.en-US': v32RuleIds,
    });
  });

  testWidgets(
    'explicit V3.2 ten-rule override does not auto-add V3.3 rule',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pumpAndSettle();

      await scrollToRule(tester, 'Unmatched curly brace');
      final previousRule = find.widgetWithText(
        SwitchListTile,
        'Unmatched curly brace',
      );
      expect(previousRule, findsOneWidget);
      expect(tester.widget<SwitchListTile>(previousRule).value, isTrue);

      await scrollToRule(tester, 'Missing colon space');
      final newRule = find.widgetWithText(SwitchListTile, 'Missing colon space');
      expect(newRule, findsOneWidget);
      expect(tester.widget<SwitchListTile>(newRule).value, isFalse);
    },
  );

  testWidgets('reset clears V3.2 override and adopts eleven-rule defaults', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Missing colon space');
    final newRule = find.widgetWithText(SwitchListTile, 'Missing colon space');
    expect(tester.widget<SwitchListTile>(newRule).value, isFalse);

    final reset = find.byKey(const ValueKey<String>('reset-writing-rules'));
    expect(reset, findsOneWidget);
    await tester.tap(reset);
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
      isNull,
    );

    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();
    await scrollToRule(tester, 'Missing colon space');

    final restored = find.widgetWithText(SwitchListTile, 'Missing colon space');
    expect(restored, findsOneWidget);
    expect(tester.widget<SwitchListTile>(restored).value, isTrue);
  });

  testWidgets('V3.3 default colon fix is batch-fixable and undoable', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    const original = 'Label :value';
    await tester.enterText(editor, original);
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Missing colon space',
    );
    await scrollTo(tester, ruleSwitch);
    expect(tester.widget<SwitchListTile>(ruleSwitch).value, isTrue);

    final applyAll = find.byKey(
      const ValueKey<String>('apply-all-writing-fixes'),
    );
    await scrollTo(tester, applyAll);
    expect(applyAll, findsOneWidget);
    await tester.tap(applyAll);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller!.text, 'Label: value');

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(editor).controller!.text, original);
  });
}
