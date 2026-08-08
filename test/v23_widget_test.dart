import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/app.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Finder settingsTransferList() {
    return find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(ListView),
    );
  }

  Future<void> scrollPortableSettingsToImport(WidgetTester tester) async {
    final list = settingsTransferList();
    expect(list, findsOneWidget);
    await tester.drag(list, const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('portable-settings-import')),
      findsOneWidget,
    );
  }

  testWidgets('review presets project onto temporary review filters', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'hello world world.');
    await tester.tap(find.byTooltip('Writing insights (Ctrl/⌘+Shift+Enter)'));
    await tester.pumpAndSettle();

    final search = find.byKey(const ValueKey<String>('writing-review-search'));
    await tester.enterText(search, 'repeat');
    await tester.pumpAndSettle();

    final clarityPreset = find.byKey(
      const ValueKey<String>('writing-preset-clarity'),
    );
    expect(clarityPreset, findsOneWidget);
    await tester.tap(clarityPreset);
    await tester.pumpAndSettle();

    expect(
      tester.widget<FilterChip>(
        find.byKey(const ValueKey<String>('writing-category-clarity')),
      ).selected,
      isTrue,
    );
    expect(
      tester.widget<FilterChip>(
        find.byKey(const ValueKey<String>('writing-category-mechanics')),
      ).selected,
      isFalse,
    );
    expect(tester.widget<TextField>(search).controller!.text, 'repeat');

    final automaticPreset = find.byKey(
      const ValueKey<String>('writing-preset-automatic-fixes'),
    );
    await tester.tap(automaticPreset);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const ValueKey<String>('automatic-fixes-only')),
      ).value,
      isTrue,
    );
    expect(
      tester.widget<FilterChip>(
        find.byKey(const ValueKey<String>('writing-category-clarity')),
      ).selected,
      isFalse,
    );
    expect(tester.widget<TextField>(search).controller!.text, 'repeat');

    await tester.tap(
      find.byKey(const ValueKey<String>('writing-preset-all-findings')),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(
        find.byKey(const ValueKey<String>('automatic-fixes-only')),
      ).value,
      isFalse,
    );
  });

  testWidgets(
    'portable settings import preserves editor text and personal vocabulary',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'spellchecker.language_id.v1': 'en-US',
        'spellchecker.suggestion_limit.v1': 5,
        'spellchecker.writing_rule_ids.v1.en-US': <String>[
          'sentence-capitalization',
        ],
        'spellchecker.personal_words.v2.en-GB': <String>['customword'],
      });

      await tester.pumpWidget(const SpellCheckerApp());
      await tester.pumpAndSettle();

      final editor = find.byType(TextField).first;
      await tester.enterText(editor, 'colour customword');
      await tester.tap(find.byTooltip('Portable settings'));
      await tester.pumpAndSettle();

      expect(find.text('Portable settings'), findsOneWidget);
      final imported = SpellCheckerSettingsDocument(
        languageId: 'en-GB',
        suggestionLimit: 8,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-GB': <String>{'sentence-capitalization'},
        },
      );
      await scrollPortableSettingsToImport(tester);
      await tester.enterText(
        find.byKey(const ValueKey<String>('portable-settings-import')),
        SpellCheckerSettingsCodec.encode(imported),
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('import-portable-settings')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Portable settings'), findsNothing);
      expect(
        tester.widget<TextField>(editor).controller!.text,
        'colour customword',
      );
      expect(find.text('English (UK)'), findsWidgets);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('spellchecker.language_id.v1'), 'en-GB');
      expect(preferences.getInt('spellchecker.suggestion_limit.v1'), 8);
      expect(
        preferences.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
        isNull,
      );
      expect(
        preferences.getStringList('spellchecker.writing_rule_ids.v1.en-GB'),
        <String>['sentence-capitalization'],
      );
      expect(
        preferences.getStringList('spellchecker.personal_words.v2.en-GB'),
        <String>['customword'],
      );
    },
  );

  testWidgets('portable settings export reflects explicit empty overrides', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.language_id.v1': 'en-US',
      'spellchecker.suggestion_limit.v1': 6,
      'spellchecker.writing_rule_ids.v1.en-US': <String>[],
    });

    await tester.pumpWidget(const SpellCheckerApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Portable settings'));
    await tester.pumpAndSettle();

    final export = tester.widget<SelectableText>(
      find.byKey(const ValueKey<String>('portable-settings-export')),
    );
    final exportedText = export.data!;
    final decoded = SpellCheckerSettingsCodec.decode(exportedText);

    expect(decoded.languageId, 'en-US');
    expect(decoded.suggestionLimit, 6);
    expect(decoded.hasWritingRuleOverride('en-US'), isTrue);
    expect(decoded.writingRuleIdsFor('en-US'), isEmpty);
    expect(decoded.hasWritingRuleOverride('en-GB'), isFalse);
  });
}
