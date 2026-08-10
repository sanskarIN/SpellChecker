import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final pack = SpellLanguageRegistry.englishUs;

  group('V2.6 writing-rule interactions', () {
    test('specialized punctuation spacing owns terminal space ranges', () {
      final analyzer = WritingAnalyzer();
      const text = 'Hello  !';

      final result = analyzer.analyze(text, languagePack: pack);
      final spacingIssues = result.issues
          .where(
            (issue) =>
                issue.start == 5 &&
                issue.end == 7 &&
                <String>{
                  'punctuation-spacing',
                  'repeated-space',
                }.contains(issue.ruleId),
          )
          .toList(growable: false);

      expect(spacingIssues, hasLength(1));
      expect(spacingIssues.single.ruleId, 'punctuation-spacing');
      final correction = WritingCorrection.applyAll(text, result.issues);

      expect(correction.applied, isTrue);
      expect(correction.text, 'Hello!');
      expect(correction.appliedCount, 1);
      expect(correction.skippedCount, 0);
    });

    test('new mechanics compose with repeated punctuation in one batch', () {
      final analyzer = WritingAnalyzer();
      const text = 'Hello !  \nWorld??   ';

      final result = analyzer.analyze(text, languagePack: pack);
      final correction = WritingCorrection.applyAll(text, result.issues);

      expect(
        result.issues.map((issue) => issue.ruleId),
        containsAll(<String>{
          'punctuation-spacing',
          'trailing-whitespace',
          'repeated-punctuation',
        }),
      );
      expect(correction.applied, isTrue);
      expect(correction.text, 'Hello!\nWorld?');
    });

    test('individual new-rule fixes validate their exact source ranges', () {
      final analyzer = WritingAnalyzer();
      const text = 'Hello ,\nWorld  ';
      final issues = analyzer.analyze(text, languagePack: pack).issues;
      final punctuation = issues.singleWhere(
        (issue) => issue.ruleId == 'punctuation-spacing',
      );
      final trailing = issues.singleWhere(
        (issue) => issue.ruleId == 'trailing-whitespace',
      );

      expect(text.substring(punctuation.start, punctuation.end), ' ');
      expect(text.substring(trailing.start, trailing.end), '  ');
      expect(WritingCorrection.apply(text, punctuation).text, 'Hello,\nWorld  ');

      final stale = WritingCorrection.apply('Hello,\nWorld  ', punctuation);
      expect(stale.applied, isFalse);
    });
  });

  group('V2.6 Writing insights UI', () {
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
      final list = insightsList();
      final scrollable = insightsScrollable();
      expect(list, findsOneWidget);
      expect(scrollable, findsOneWidget);
      await tester.drag(list, const Offset(0, 1200));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        target,
        160,
        scrollable: scrollable,
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Writing insights exposes both new rule switches', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();

      final editor = find.byType(TextField).first;
      await tester.enterText(editor, 'Hello !\nWorld  ');
      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pumpAndSettle();

      for (final label in <String>[
        'Punctuation spacing',
        'Trailing whitespace',
      ]) {
        final target = find.text(label);
        await scrollTo(tester, target);
        expect(target, findsWidgets);
      }
    });

    testWidgets('apply all fixes new mechanics and undo restores exact text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();

      final editor = find.byType(TextField).first;
      const original = 'Hello  !\nWorld  ';
      await tester.enterText(editor, original);
      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pumpAndSettle();

      final applyAll = find.byKey(
        const ValueKey<String>('apply-all-writing-fixes'),
      );
      await scrollTo(tester, applyAll);
      expect(applyAll, findsOneWidget);
      await tester.tap(applyAll);
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(editor).controller!.text, 'Hello!\nWorld');
      await tester.tap(find.text('Undo correction'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(editor).controller!.text, original);
    });
  });
}
