import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/features/editor/writing_insights_dialog.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('Writing insights exposes exact multi-rule totals when limited', (
    WidgetTester tester,
  ) async {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[
        _NamedOffsetsRule('alpha', <int>[0, 4, 8]),
        _NamedOffsetsRule('beta', <int>[2, 6]),
      ],
    );

    await _openInsights(tester, analyzer: analyzer);

    final scrollable = _dialogScrollable();
    for (final expected in <String>['Total findings: 3', 'Total findings: 2']) {
      final finder = find.textContaining(expected);
      await tester.scrollUntilVisible(finder, 120, scrollable: scrollable);
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget);
    }

    final exactNotice = find.textContaining(
      'Showing the first 2 of 5 findings in review order.',
    );
    await tester.scrollUntilVisible(exactNotice, 160, scrollable: scrollable);
    await tester.pumpAndSettle();

    expect(exactNotice, findsOneWidget);
    expect(
      find.textContaining(
        '3 additional findings are not retained by the 2-finding capture limit.',
      ),
      findsOneWidget,
    );

    final diagnosticsBadge = find.byKey(
      const ValueKey<String>('writing-findings-total-badge'),
    );
    for (
      var attempt = 0;
      attempt < 6 && diagnosticsBadge.evaluate().isEmpty;
      attempt++
    ) {
      await tester.drag(_dialogList(), const Offset(0, 140));
      await tester.pumpAndSettle();
    }
    expect(diagnosticsBadge, findsOneWidget);
    final badge = tester.widget<Badge>(diagnosticsBadge);
    expect(badge.label, isA<Text>());
    expect((badge.label! as Text).data, '2/5');
  });

  testWidgets('Copy diagnostic summary excludes document finding details', (
    WidgetTester tester,
  ) async {
    String? copiedText;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == 'Clipboard.setData') {
            final arguments = methodCall.arguments as Map<Object?, Object?>;
            copiedText = arguments['text'] as String?;
          }
          return null;
        });

    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[
        _NamedOffsetsRule('alpha', <int>[0, 4, 8]),
        _NamedOffsetsRule('beta', <int>[2, 6]),
      ],
    );

    await _openInsights(tester, analyzer: analyzer);

    final copyButton = find.byKey(
      const ValueKey<String>('copy-writing-diagnostics'),
    );
    await tester.scrollUntilVisible(
      copyButton,
      160,
      scrollable: _dialogScrollable(),
    );
    await tester.pumpAndSettle();
    await tester.tap(copyButton);
    await tester.pumpAndSettle();

    expect(copiedText, isNotNull);
    expect(copiedText, contains('SpellChecker writing analysis diagnostics'));
    expect(copiedText, contains('Language: en-US'));
    expect(copiedText, contains('Captured findings: 2'));
    expect(copiedText, contains('Total findings: 5'));
    expect(copiedText, contains('ALPHA [alpha]'));
    expect(copiedText, contains('BETA [beta]'));
    expect(copiedText, isNot(contains('abcdefghij')));
    expect(copiedText, isNot(contains('Synthetic finding')));
    expect(
      find.text(
        'Diagnostic summary copied. Editor text and finding excerpts were excluded.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _openInsights(
  WidgetTester tester, {
  required WritingAnalyzer analyzer,
}) async {
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
                      text: 'abcdefghij',
                      languagePack: SpellLanguageRegistry.englishUs,
                      analyzer: analyzer,
                      initialEnabledRuleIds: const <String>{'alpha', 'beta'},
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

class _NamedOffsetsRule extends WritingRule {
  const _NamedOffsetsRule(this.id, this.offsets);

  @override
  final String id;

  final List<int> offsets;

  @override
  String get displayName => id.toUpperCase();

  @override
  String get description => 'Synthetic diagnostics widget rule.';

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
        message: 'Synthetic finding at $offset.',
        start: offset,
        end: offset + 1,
        originalText: text.substring(offset, offset + 1),
        replacement: '',
        languageId: languagePack.id,
        severity: WritingIssueSeverity.info,
      );
    }
  }
}
