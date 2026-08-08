from pathlib import Path

path = Path('test/writing_widget_test.dart')
text = path.read_text()

# Keep the findings scroll moderate so actions remain inside the dialog viewport.
if 'await tester.drag(insightsList, const Offset(0, -900));' in text:
    text = text.replace(
        'await tester.drag(insightsList, const Offset(0, -900));',
        'await tester.drag(insightsList, const Offset(0, -600));',
        1,
    )
elif 'await tester.drag(insightsList, const Offset(0, -600));' not in text:
    raise RuntimeError('writing insights scroll helper has an unexpected shape')

helper_marker = "  testWidgets('writing insights apply a safe fix through editor undo history', ("
helper = """  Finder writingInsightsScrollable() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Scrollable),
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

"""
if 'Future<void> scrollToRule' not in text:
    if text.count(helper_marker) != 1:
        raise RuntimeError('unable to insert scrollToRule helper')
    text = text.replace(helper_marker, helper + helper_marker, 1)

replacements = {
"""    expect(find.text('Writing insights'), findsOneWidget);
    expect(find.textContaining('Local rules only'), findsOneWidget);
    expect(find.text('Sentence capitalization'), findsWidgets);
    expect(find.text('Repeated spaces'), findsWidgets);
    expect(find.text('Repeated word'), findsWidgets);
    expect(find.text('Repeated punctuation'), findsWidgets);

    await scrollToFindings(tester);
""": """    expect(find.text('Writing insights'), findsOneWidget);
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
""",
"""    await tester.enterText(search, 'clarity');
    await tester.pumpAndSettle();

    expect(find.text('Repeated word'), findsWidgets);
""": """    await tester.enterText(search, 'clarity');
    await tester.pumpAndSettle();
    await scrollToRule(tester, 'Repeated word');

    expect(find.text('Repeated word'), findsWidgets);
""",
"""    final repeatedSpaceSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""": """    await scrollToRule(tester, 'Repeated spaces');
    final repeatedSpaceSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""",
"""    final restoredSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""": """    await scrollToRule(tester, 'Repeated spaces');
    final restoredSwitch = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""",
"""    final repeatedSpace = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""": """    await scrollToRule(tester, 'Repeated spaces');
    final repeatedSpace = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
""",
"""    for (final label in <String>[
      'Repeated spaces',
      'Repeated word',
      'Repeated punctuation',
      'Sentence capitalization',
    ]) {
      final ruleSwitch = find.widgetWithText(SwitchListTile, label);
""": """    for (final label in <String>[
      'Repeated spaces',
      'Repeated word',
      'Repeated punctuation',
      'Sentence capitalization',
    ]) {
      await scrollToRule(tester, label);
      final ruleSwitch = find.widgetWithText(SwitchListTile, label);
""",
"""    final capitalization = find.widgetWithText(
      SwitchListTile,
      'Sentence capitalization',
    );
    final repeatedSpace = find.widgetWithText(
      SwitchListTile,
      'Repeated spaces',
    );
    expect(tester.widget<SwitchListTile>(capitalization).value, isTrue);
    expect(tester.widget<SwitchListTile>(repeatedSpace).value, isFalse);
""": """    await scrollToRule(tester, 'Sentence capitalization');
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
""",
}

for old, new in replacements.items():
    if old in text:
        text = text.replace(old, new, 1)
    elif new not in text:
        raise RuntimeError(f'expected widget-test block not found: {old[:80]!r}')

path.write_text(text)
print('V2.2 widget viewport/lazy-list tests hardened successfully.')
