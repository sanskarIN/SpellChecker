import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/features/editor/spell_checker_page.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  testWidgets('refreshes an early spelling check after saved language loads', (
    WidgetTester tester,
  ) async {
    final preferences = _DelayedDictionaryPreferences();
    await tester.pumpWidget(
      MaterialApp(home: SpellCheckerPage(preferences: preferences)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'colour');
    await tester.tap(find.text('Check spelling'));
    await tester.pump();

    expect(find.text('colour'), findsWidgets);
    expect(find.text('Issue 1 of 1'), findsOneWidget);

    preferences.completeLanguage('en-GB');
    await tester.pumpAndSettle();

    expect(find.text('No issues found'), findsOneWidget);
    expect(find.text('Issue 1 of 1'), findsNothing);
  });

  testWidgets(
    'Writing insights waits for saved preferences to finish loading',
    (WidgetTester tester) async {
      final preferences = _DelayedDictionaryPreferences();
      await tester.pumpWidget(
        MaterialApp(home: SpellCheckerPage(preferences: preferences)),
      );
      await tester.pump();

      await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
      await tester.pump();

      expect(find.text('Writing insights'), findsNothing);
      expect(
        find.text('Dictionary preferences are still loading.'),
        findsOneWidget,
      );

      preferences.completeLanguage('en-US');
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Ignore once cannot mutate the temporary startup engine', (
    WidgetTester tester,
  ) async {
    final preferences = _DelayedDictionaryPreferences();
    await tester.pumpWidget(
      MaterialApp(home: SpellCheckerPage(preferences: preferences)),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'zorbax');
    await tester.tap(find.text('Check spelling'));
    await tester.pump();
    expect(find.text('Issue 1 of 1'), findsOneWidget);

    final ignoreOnce = find.text('Ignore once');
    await tester.ensureVisible(ignoreOnce);
    await tester.pumpAndSettle();
    expect(ignoreOnce, findsOneWidget);
    await tester.tap(ignoreOnce);
    await tester.pump();

    expect(find.text('Issue 1 of 1'), findsOneWidget);
    expect(
      find.text('Dictionary preferences are still loading.'),
      findsOneWidget,
    );

    preferences.completeLanguage('en-US');
    await tester.pumpAndSettle();

    expect(find.text('Issue 1 of 1'), findsOneWidget);
  });
}

class _DelayedDictionaryPreferences extends DictionaryPreferences {
  final Completer<String> _language = Completer<String>();

  void completeLanguage(String languageId) {
    if (!_language.isCompleted) {
      _language.complete(languageId);
    }
  }

  @override
  Future<String> loadLanguageId() => _language.future;

  @override
  Future<Set<String>> loadPersonalWords({String? languageId}) async =>
      <String>{};

  @override
  Future<Set<String>?> loadWritingRuleIds({String? languageId}) async => null;

  @override
  Future<int> loadSuggestionLimit() async =>
      DictionaryPreferences.defaultSuggestionLimit;
}
