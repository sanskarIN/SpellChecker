import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists and restores normalized personal words', () async {
    final preferences = DictionaryPreferences();

    await preferences.savePersonalWords(<String>{'Flutter', 'Open-Source'});

    expect(
      await preferences.loadPersonalWords(),
      unorderedEquals(<String>['flutter', 'open-source']),
    );
  });

  test('persists suggestion limit', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveSuggestionLimit(8);

    expect(await preferences.loadSuggestionLimit(), 8);
  });

  test('clamps suggestion limit to supported range', () {
    expect(DictionaryPreferences.normalizeSuggestionLimit(-4), 1);
    expect(DictionaryPreferences.normalizeSuggestionLimit(4), 4);
    expect(DictionaryPreferences.normalizeSuggestionLimit(99), 10);
    expect(DictionaryPreferences.normalizeSuggestionLimit(null), 5);
  });

  test('clears persisted personal words', () async {
    final preferences = DictionaryPreferences();
    await preferences.savePersonalWords(<String>{'flutter'});

    await preferences.clearPersonalWords();

    expect(await preferences.loadPersonalWords(), isEmpty);
  });
}
