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

  test('propagates failed language persistence writes', () async {
    final preferences = DictionaryPreferences(
      preferences: _FailingSharedPreferences(),
    );

    await expectLater(preferences.saveLanguageId('en-GB'), throwsStateError);
  });

  test('propagates failed personal-word persistence writes', () async {
    final preferences = DictionaryPreferences(
      preferences: _FailingSharedPreferences(),
    );

    await expectLater(
      preferences.savePersonalWords(<String>{'flutter'}),
      throwsStateError,
    );
  });

  test('propagates failed writing-rule persistence writes', () async {
    final preferences = DictionaryPreferences(
      preferences: _FailingSharedPreferences(),
    );

    await expectLater(
      preferences.saveWritingRuleIds(<String>{'repeated-space'}),
      throwsStateError,
    );
    await expectLater(preferences.clearWritingRuleIds(), throwsStateError);
  });

  test('propagates failed suggestion-limit persistence writes', () async {
    final preferences = DictionaryPreferences(
      preferences: _FailingSharedPreferences(),
    );

    await expectLater(preferences.saveSuggestionLimit(7), throwsStateError);
  });

  test('propagates failed personal-word removal writes', () async {
    final preferences = DictionaryPreferences(
      preferences: _FailingSharedPreferences(),
    );

    await expectLater(preferences.clearPersonalWords(), throwsStateError);
  });

  test(
    'does not report legacy migration as successful after a failed write',
    () async {
      final preferences = DictionaryPreferences(
        preferences: _FailingSharedPreferences(
          stringLists: <String, List<String>>{
            'spellchecker.personal_words.v1': <String>['Flutter'],
          },
        ),
      );

      await expectLater(preferences.loadPersonalWords(), throwsStateError);
    },
  );
}

class _FailingSharedPreferences implements SharedPreferences {
  _FailingSharedPreferences({
    Map<String, String> strings = const <String, String>{},
    Map<String, int> ints = const <String, int>{},
    Map<String, List<String>> stringLists = const <String, List<String>>{},
  }) : _strings = strings,
       _ints = ints,
       _stringLists = stringLists;

  final Map<String, String> _strings;
  final Map<String, int> _ints;
  final Map<String, List<String>> _stringLists;

  @override
  String? getString(String key) => _strings[key];

  @override
  int? getInt(String key) => _ints[key];

  @override
  List<String>? getStringList(String key) => _stringLists[key];

  @override
  Future<bool> setString(String key, String value) async => false;

  @override
  Future<bool> setInt(String key, int value) async => false;

  @override
  Future<bool> setStringList(String key, List<String> value) async => false;

  @override
  Future<bool> remove(String key) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
