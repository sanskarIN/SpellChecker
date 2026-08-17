import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/core/spell_language_pack.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists every built-in language id', () async {
    final preferences = DictionaryPreferences();

    for (final pack in SpellLanguageRegistry.builtIns) {
      await preferences.saveLanguageId(pack.id);
      expect(await preferences.loadLanguageId(), pack.id);
    }
  });

  test('isolates multilingual personal dictionaries by language id', () async {
    final preferences = DictionaryPreferences();

    await preferences.savePersonalWords(<String>{
      'ব্যক্তিগত',
    }, languageId: 'bn-IN');
    await preferences.savePersonalWords(<String>{
      'Личное',
    }, languageId: 'ru-RU');

    expect(await preferences.loadPersonalWords(languageId: 'bn-IN'), <String>{
      'ব্যক্তিগত',
    });
    expect(await preferences.loadPersonalWords(languageId: 'ru-RU'), <String>{
      'личное',
    });
    expect(await preferences.loadPersonalWords(languageId: 'ta-IN'), isEmpty);
  });

  test(
    'normalizes accented personal words with the selected language pack',
    () async {
      final preferences = DictionaryPreferences();

      await preferences.savePersonalWords(<String>{
        'E\u0301cole',
        'MAN\u0303ANA',
      }, languageId: 'fr-FR');

      expect(await preferences.loadPersonalWords(languageId: 'fr-FR'), <String>{
        'mañana',
        'école',
      });
    },
  );
}
