import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists and restores explicit language selection', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveLanguageId('en-GB');

    expect(await preferences.loadLanguageId(), 'en-GB');
  });

  test('falls back to en-US for unsupported stored language', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.language_id.v1': 'xx-ZZ',
    });
    final preferences = DictionaryPreferences();

    expect(await preferences.loadLanguageId(), 'en-US');
  });

  test('rejects unsupported explicit language writes', () async {
    final preferences = DictionaryPreferences();

    await expectLater(preferences.saveLanguageId('xx-ZZ'), throwsArgumentError);

    final storage = await SharedPreferences.getInstance();
    expect(storage.getString('spellchecker.language_id.v1'), isNull);
  });

  test(
    'unsupported ids cannot write into the default personal namespace',
    () async {
      final preferences = DictionaryPreferences();

      await expectLater(
        preferences.savePersonalWords(<String>{
          'must-not-leak',
        }, languageId: 'xx-ZZ'),
        throwsArgumentError,
      );

      expect(await preferences.loadPersonalWords(languageId: 'en-US'), isEmpty);
      final storage = await SharedPreferences.getInstance();
      expect(
        storage.getStringList('spellchecker.personal_words.v2.en-US'),
        isNull,
      );
      expect(storage.getStringList('spellchecker.personal_words.v1'), isNull);
    },
  );

  test('unsupported ids cannot mutate writing-rule namespaces', () async {
    final preferences = DictionaryPreferences();
    await preferences.saveWritingRuleIds(<String>{
      'repeated-word',
    }, languageId: 'en-US');

    await expectLater(
      preferences.saveWritingRuleIds(<String>{
        'trailing-whitespace',
      }, languageId: 'xx-ZZ'),
      throwsArgumentError,
    );
    await expectLater(
      preferences.clearWritingRuleIds(languageId: 'xx-ZZ'),
      throwsArgumentError,
    );

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), <String>{
      'repeated-word',
    });
  });

  test('isolates saved personal words by language', () async {
    final preferences = DictionaryPreferences();

    await preferences.savePersonalWords(<String>{
      'usword',
    }, languageId: 'en-US');
    await preferences.savePersonalWords(<String>{
      'ukword',
    }, languageId: 'en-GB');

    expect(await preferences.loadPersonalWords(languageId: 'en-US'), <String>{
      'usword',
    });
    expect(await preferences.loadPersonalWords(languageId: 'en-GB'), <String>{
      'ukword',
    });
  });

  test('migrates legacy V1 words into the default US namespace', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'spellchecker.personal_words.v1': <String>['LegacyWord'],
    });
    final preferences = DictionaryPreferences();

    final words = await preferences.loadPersonalWords(languageId: 'en-US');
    final storage = await SharedPreferences.getInstance();

    expect(words, <String>{'legacyword'});
    expect(
      storage.getStringList('spellchecker.personal_words.v2.en-US'),
      <String>['legacyword'],
    );
  });

  test('clearing one language does not clear another language', () async {
    final preferences = DictionaryPreferences();
    await preferences.savePersonalWords(<String>{
      'usword',
    }, languageId: 'en-US');
    await preferences.savePersonalWords(<String>{
      'ukword',
    }, languageId: 'en-GB');

    await preferences.clearPersonalWords(languageId: 'en-US');

    expect(await preferences.loadPersonalWords(languageId: 'en-US'), isEmpty);
    expect(await preferences.loadPersonalWords(languageId: 'en-GB'), <String>{
      'ukword',
    });
  });
}
