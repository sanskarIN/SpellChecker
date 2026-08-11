import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/features/editor/writing_insights_dialog.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Writing insights default capture limit is 200', () {
    expect(WritingInsightsDialog.defaultMaxIssues, 200);
  });

  testWidgets('limited analysis shows captured wording and returns captured fixes', (
    WidgetTester tester,
  ) async {
    WritingInsightsDialogResult? returnedResult;
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[
        _SyntheticAutomaticRule(<int>[0, 2, 4]),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () async {
                    returnedResult = await showDialog<WritingInsightsDialogResult>(
                      context: context,
                      builder: (BuildContext context) => WritingInsightsDialog(
                        text: 'abcdef',
                        languagePack: SpellLanguageRegistry.englishUs,
                        analyzer: analyzer,
                        initialEnabledRuleIds: const <String>{'synthetic'},
                        maxIssues: 2,
                      ),
                    );
                  },
                  child: const Text('Open insights'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open insights'));
    await tester.pumpAndSettle();

    final list = _dialogList();
    final scrollable = _dialogScrollable();
    expect(list, findsOneWidget);
    expect(scrollable, findsOneWidget);

    final limitedText = find.textContaining(
      'More findings exist beyond the 2-finding capture limit',
    );
    await tester.scrollUntilVisible(
      limitedText,
      160,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(limitedText, findsOneWidget);
    expect(find.text('2+'), findsWidgets);

    final applyCaptured = find.text('Apply captured safe fixes (2)');
    await tester.scrollUntilVisible(
      applyCaptured,
      120,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();
    expect(applyCaptured, findsOneWidget);

    await tester.tap(applyCaptured);
    await tester.pumpAndSettle();

    expect(returnedResult, isNotNull);
    expect(returnedResult!.issuesToFix, hasLength(2));
    expect(
      returnedResult!.issuesToFix.map((WritingIssue issue) => issue.start),
      <int>[0, 2],
    );
  });

  testWidgets('limited filtered state names captured findings truthfully', (
    WidgetTester tester,
  ) async {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[
        _SyntheticAutomaticRule(<int>[0, 2, 4]),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () {
                    showDialog<WritingInsightsDialogResult>(
                      context: context,
                      builder: (BuildContext context) => WritingInsightsDialog(
                        text: 'abcdef',
                        languagePack: SpellLanguageRegistry.englishUs,
                        analyzer: analyzer,
                        initialEnabledRuleIds: const <String>{'synthetic'},
                        maxIssues: 2,
                      ),
                    );
                  },
                  child: const Text('Open insights'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open insights'));
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    expect(search, findsOneWidget);
    await tester.enterText(search, 'no-such-finding');
    await tester.pumpAndSettle();

    final emptyTitle = find.text('No matching captured findings');
    await tester.scrollUntilVisible(
      emptyTitle,
      160,
      scrollable: _dialogScrollable(),
    );
    await tester.pumpAndSettle();

    expect(emptyTitle, findsOneWidget);
    expect(
      find.textContaining('Additional uncaptured findings may exist.'),
      findsOneWidget,
    );
  });
}

Finder _dialogList() {
  return find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(ListView),
  );
}

Finder _dialogScrollable() {
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

class _SyntheticAutomaticRule extends WritingRule {
  const _SyntheticAutomaticRule(this.offsets);

  final List<int> offsets;

  @override
  String get id => 'synthetic';

  @override
  String get displayName => 'Synthetic';

  @override
  String get description => 'Synthetic bounded-analysis widget rule.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(
    String text,
    SpellLanguagePack languagePack,
  ) sync* {
    for (final offset in offsets) {
      yield WritingIssue(
        ruleId: id,
        ruleName: displayName,
        message: 'Synthetic finding.',
        start: offset,
        end: offset + 1,
        originalText: text.substring(offset, offset + 1),
        replacement: text.substring(offset, offset + 1).toUpperCase(),
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
