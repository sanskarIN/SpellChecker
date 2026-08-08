import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/core/spell_language_pack.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('returns null when writing rules were never configured', () async {
    final preferences = DictionaryPreferences();

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), isNull);
  });

  test('persists normalized deterministic writing rule ids', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveWritingRuleIds(<String>[
      ' repeated-space ',
      'repeated-word',
      'repeated-space',
      '',
    ], languageId: 'en-US');

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), <String>{
      'repeated-space',
      'repeated-word',
    });

    final raw = await SharedPreferences.getInstance();
    expect(
      raw.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
      <String>['repeated-space', 'repeated-word'],
    );
  });

  test('preserves an explicitly empty writing rule set', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveWritingRuleIds(const <String>[], languageId: 'en-US');

    final restored = await preferences.loadWritingRuleIds(languageId: 'en-US');
    expect(restored, isNotNull);
    expect(restored, isEmpty);
  });

  test('isolates writing rule choices by language', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveWritingRuleIds(const <String>{
      'repeated-space',
    }, languageId: SpellLanguageRegistry.englishUs.id);
    await preferences.saveWritingRuleIds(const <String>{
      'sentence-capitalization',
    }, languageId: SpellLanguageRegistry.englishGb.id);

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), <String>{
      'repeated-space',
    });
    expect(await preferences.loadWritingRuleIds(languageId: 'en-GB'), <String>{
      'sentence-capitalization',
    });
  });

  test(
    'clearing one language restores unset state without touching another',
    () async {
      final preferences = DictionaryPreferences();

      await preferences.saveWritingRuleIds(const <String>{
        'repeated-space',
      }, languageId: 'en-US');
      await preferences.saveWritingRuleIds(const <String>{
        'repeated-word',
      }, languageId: 'en-GB');

      await preferences.clearWritingRuleIds(languageId: 'en-US');

      expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), isNull);
      expect(
        await preferences.loadWritingRuleIds(languageId: 'en-GB'),
        <String>{'repeated-word'},
      );
    },
  );
}
