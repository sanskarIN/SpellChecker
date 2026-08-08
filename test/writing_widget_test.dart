import 'package:flutter/material.dart';
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

  testWidgets('writing insights apply a safe fix through editor undo history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    final editor = find.byType(TextField).first;
    await tester.enterText(editor, 'hello  world world!!');

    await tester.tap(find.byTooltip('Writing insights'));
    await tester.pumpAndSettle();

    expect(find.text('Writing insights'), findsOneWidget);
    expect(find.textContaining('Local rules only'), findsOneWidget);
    expect(find.text('Sentence capitalization'), findsWidgets);
    expect(find.text('Repeated spaces'), findsWidgets);
    expect(find.text('Repeated word'), findsWidgets);
    expect(find.text('Repeated punctuation'), findsWidgets);

    final insightsList = writingInsightsList();
    expect(insightsList, findsOneWidget);
    await tester.drag(insightsList, const Offset(0, -520));
    await tester.pumpAndSettle();

    expect(find.text('Apply safe fix'), findsWidgets);
    await tester.tap(find.text('Apply safe fix').first);
    await tester.pumpAndSettle();

    final textFieldAfterFix = tester.widget<TextField>(editor);
    expect(textFieldAfterFix.controller!.text, startsWith('Hello'));
    expect(find.text('Undo correction'), findsOneWidget);

    await tester.tap(find.text('Undo correction'));
    await tester.pumpAndSettle();

    final textFieldAfterUndo = tester.widget<TextField>(editor);
    expect(textFieldAfterUndo.controller!.text, 'hello  world world!!');
  });

  testWidgets('writing rule switches can disable a finding category', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Hello  world.');
    await tester.tap(find.byTooltip('Writing insights'));
    await tester.pumpAndSettle();

    final insightsList = writingInsightsList();
    expect(insightsList, findsOneWidget);

    await tester.drag(insightsList, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Use a single space here.'), findsOneWidget);

    await tester.drag(insightsList, const Offset(0, 420));
    await tester.pumpAndSettle();

    final repeatedSpaceSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(repeatedSpaceSwitch, findsOneWidget);
    await tester.tap(repeatedSpaceSwitch);
    await tester.pumpAndSettle();

    await tester.drag(insightsList, const Offset(0, -420));
    await tester.pumpAndSettle();
    expect(find.text('Use a single space here.'), findsNothing);
    expect(find.text('No enabled-rule findings'), findsOneWidget);
  });
}
