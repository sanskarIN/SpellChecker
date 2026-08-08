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

  Finder writingInsightsList() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
  }

  Future<void> scrollToFindings(WidgetTester tester) async {
    final insightsList = writingInsightsList();
    expect(insightsList, findsOneWidget);
    await tester.drag(insightsList, const Offset(0, -600));
    await tester.pumpAndSettle();
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
    await tester.drag(insightsList, const Offset(0, 1200));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(label),
      160,
      scrollable: insightsScrollable,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('writing insights apply a safe fix through editor undo history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'hello  world world!!');

    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsOneWidget);
    expect(find.textContaining('Local rules only'), findsOneWidget);
    for (final label in <String>[
      'Sentence capitalization',
      'Repeated spaces',
      'Repeated word',
      'Repeated punctuation',
    ]) {
      await scrollToRule(tester, label);
      expect(find.text(label), findsWidgets);
    }

    await scrollToFindings(tester);

    expect(find.text('Apply safe fix'), findsWidgets);
    await tester.tap(find.text('Apply safe fix').first);
    await tester.pumpAndSettle();

    final textFieldAfterFix = tester.widget<TextField>(editor);
    expect(textFieldAfterFix.controller!.text, isNot('hello  world world!!'));
    expect(find.text('Undo correction'), findsOneWidget);

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();

    final textFieldAfterUndo = tester.widget<TextField>(editor);
    expect(textFieldAfterUndo.controller!.text, 'hello  world world!!');
  });

  testWidgets('apply all writing fixes is one undoable correction', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'hello  world world!!');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToFindings(tester);
    final applyAll = find.byKey(
      const ValueKey<String>('apply-all-writing-fixes'),
    );
    expect(applyAll, findsOneWidget);
    await tester.tap(applyAll);
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(editor).controller!.text, 'Hello world!');

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(editor).controller!.text,
      'hello  world world!!',
    );
  });

  testWidgets('mechanics filter applies only visible safe fixes as one undo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'hello  world world!!');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final mechanics = find.byKey(
      const ValueKey<String>('writing-category-mechanics'),
    );
    expect(mechanics, findsOneWidget);
    await tester.tap(mechanics);
    await tester.pumpAndSettle();

    await scrollToFindings(tester);
    final applyVisible = find.byKey(
      const ValueKey<String>('apply-all-writing-fixes'),
    );
    expect(applyVisible, findsOneWidget);
    expect(find.textContaining('Apply visible safe fixes'), findsOneWidget);
    await tester.tap(applyVisible);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(editor).controller!.text,
      'Hello world world!',
    );

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(editor).controller!.text,
      'hello  world world!!',
    );
  });

  testWidgets('search filters rule management by category metadata', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'hello world world.');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    expect(search, findsOneWidget);
    await tester.enterText(search, 'clarity');
    await tester.pumpAndSettle();
    await scrollToRule(tester, 'Repeated word');

    expect(find.text('Repeated word'), findsWidgets);
    expect(find.text('Repeated spaces'), findsNothing);
    expect(find.text('Sentence capitalization'), findsNothing);
  });

  testWidgets('writing rule switches persist after the dialog closes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello  world.');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Repeated spaces');
    final repeatedSpaceSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(repeatedSpaceSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(repeatedSpaceSwitch).value, isTrue);
    await tester.tap(repeatedSpaceSwitch);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
      isNot(contains('repeated-space')),
    );

    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();
    await scrollToRule(tester, 'Repeated spaces');
    final restoredSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(restoredSwitch, findsOneWidget);
    expect(tester.widget<SwitchListTile>(restoredSwitch).value, isFalse);
  });

  testWidgets('reset rules clears override and restores registry defaults', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.writing_rule_ids.v1.en-US': <String>[
        'sentence-capitalization',
      ],
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Repeated spaces');
    final repeatedSpace = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(tester.widget<SwitchListTile>(repeatedSpace).value, isFalse);

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

    for (final label in <String>[
      'Repeated spaces',
      'Repeated word',
      'Repeated punctuation',
      'Sentence capitalization',
    ]) {
      await scrollToRule(tester, label);
      final ruleSwitch = find.widgetWithText(SwitchListTile, label);
      expect(ruleSwitch, findsOneWidget);
      expect(tester.widget<SwitchListTile>(ruleSwitch).value, isTrue);
    }
  });

  testWidgets('restores persisted writing rules on startup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.writing_rule_ids.v1.en-US': <String>[
        'sentence-capitalization',
      ],
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    await scrollToRule(tester, 'Sentence capitalization');
    final capitalization = find.widgetWithText(
      SwitchListTile,
      'Sentence capitalization',
    );
    expect(tester.widget<SwitchListTile>(capitalization).value, isTrue);
    await scrollToRule(tester, 'Repeated spaces');
    final repeatedSpace = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(tester.widget<SwitchListTile>(repeatedSpace).value, isFalse);
  });

  testWidgets('Ctrl+Shift+Enter opens writing insights', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsOneWidget);
  });
}
