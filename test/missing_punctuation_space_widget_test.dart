import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Finder writingInsightsList() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
  }

  Finder writingInsightsScrollable() {
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

  Future<void> scrollToRule(WidgetTester tester, String label) async {
    final insightsList = writingInsightsList();
    final insightsScrollable = writingInsightsScrollable();
    expect(insightsList, findsOneWidget);
    expect(insightsScrollable, findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(label),
      160,
      scrollable: insightsScrollable,
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToFindings(WidgetTester tester) async {
    final insightsList = writingInsightsList();
    expect(insightsList, findsOneWidget);
    await tester.drag(insightsList, const Offset(0, -1400));
    await tester.pumpAndSettle();
  }

  testWidgets('unset preferences enable and apply the V2.11 rule by default', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'Hello,world');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Missing punctuation space');
    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Missing punctuation space',
    );
    expect(ruleSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(ruleSwitch).value, isTrue);

    await scrollToFindings(tester);
    expect(
      find.text('Add a space after this punctuation mark.'),
      findsOneWidget,
    );
    expect(find.text('Apply safe fix'), findsOneWidget);
    await tester.tap(find.text('Apply safe fix'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller!.text, 'Hello, world');
    expect(find.text('Undo correction'), findsOneWidget);
  });

  testWidgets('explicit V2.10 six-rule override does not enable V2.11 rule', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.writing_rule_ids.v1.en-US': <String>[
        'punctuation-spacing',
        'repeated-punctuation',
        'repeated-space',
        'repeated-word',
        'sentence-capitalization',
        'trailing-whitespace',
      ],
    });
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello,world');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Missing punctuation space');
    final ruleSwitch = find.widgetWithText(
      SwitchListTile,
      'Missing punctuation space',
    );
    expect(ruleSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(ruleSwitch).value, isFalse);

    await scrollToFindings(tester);
    expect(find.text('Add a space after this punctuation mark.'), findsNothing);
    expect(find.text('No enabled-rule findings'), findsOneWidget);
  });
}
