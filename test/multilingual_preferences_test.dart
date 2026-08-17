import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists every new built-in language id', () async {
    final preferences = DictionaryPreferences();

    for (final id in <String>[
      'hi-IN',
      'es-ES',
      'fr-FR',
      'de-DE',
      'pt-BR',
      'it-IT',
    ]) {
      await preferences.saveLanguageId(id);
      expect(await preferences.loadLanguageId(), id);
    }
  });

  test('isolates multilingual personal dictionaries by language id', () async {
    final preferences = DictionaryPreferences();

    await preferences.savePersonalWords(<String>{
      'Sanskar',
    }, languageId: 'hi-IN');
    await preferences.savePersonalWords(<String>{
      'ProyectoX',
    }, languageId: 'es-ES');

    expect(
      await preferences.loadPersonalWords(languageId: 'hi-IN'),
      <String>{'sanskar'},
    );
    expect(
      await preferences.loadPersonalWords(languageId: 'es-ES'),
      <String>{'proyectox'},
    );
    expect(
      await preferences.loadPersonalWords(languageId: 'fr-FR'),
      isEmpty,
    );
  });

  test('normalizes accented personal words with the selected language pack', () async {
    final preferences = DictionaryPreferences();

    await preferences.savePersonalWords(<String>{
      'E\u0301cole',
      'MAN\u0303ANA',
    }, languageId: 'fr-FR');

    expect(
      await preferences.loadPersonalWords(languageId: 'fr-FR'),
      <String>{'mañana', 'école'},
    );
  });
}
