import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const v214RuleIds = <String>[
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
    'unmatched-parenthesis',
    'unmatched-square-bracket',
  ];

  Finder insightsList() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(ListView),
  );

  Future<void> scrollToRule(WidgetTester tester, String label) async {
    final list = insightsList();
    expect(list, findsOneWidget);

    await tester.drag(list, const Offset(0, 1800));
    await tester.pumpAndSettle();

    final target = find.text(label);
    for (var index = 0; index < 28 && target.evaluate().isEmpty; index++) {
      await tester.drag(list, const Offset(0, -180));
      await tester.pumpAndSettle();
    }

    expect(target, findsWidgets);
    await tester.ensureVisible(target.first);
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.writing_rule_ids.v1.en-US': v214RuleIds,
    });
  });

  testWidgets(
    'explicit V2.14 nine-rule override does not auto-add V2.15 rule',
    (WidgetTester tester) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pumpAndSettle();

      await scrollToRule(tester, 'Unmatched square bracket');
      final previousRule = find.widgetWithText(
        SwitchListTile,
        'Unmatched square bracket',
      );
      expect(previousRule, findsOneWidget);
      expect(tester.widget<SwitchListTile>(previousRule).value, isTrue);

      await scrollToRule(tester, 'Unmatched curly brace');
      final newRule = find.widgetWithText(
        SwitchListTile,
        'Unmatched curly brace',
      );
      expect(newRule, findsOneWidget);
      expect(tester.widget<SwitchListTile>(newRule).value, isFalse);
    },
  );

  testWidgets('reset clears V2.14 override and adopts ten-rule defaults', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Unmatched curly brace');
    final newRule = find.widgetWithText(
      SwitchListTile,
      'Unmatched curly brace',
    );
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
    await scrollToRule(tester, 'Unmatched curly brace');

    final restored = find.widgetWithText(
      SwitchListTile,
      'Unmatched curly brace',
    );
    expect(restored, findsOneWidget);
    expect(tester.widget<SwitchListTile>(restored).value, isTrue);
  });
}
