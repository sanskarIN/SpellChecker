import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists the V3.3 rule id without changing the storage format', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveWritingRuleIds(const <String>{
      'missing-colon-space',
      'repeated-word',
    }, languageId: 'en-US');

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), <String>{
      'missing-colon-space',
      'repeated-word',
    });

    final raw = await SharedPreferences.getInstance();
    expect(
      raw.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
      <String>['missing-colon-space', 'repeated-word'],
    );
  });

  test('keeps the V3.3 rule selection isolated by language', () async {
    final preferences = DictionaryPreferences();

    await preferences.saveWritingRuleIds(const <String>{
      'missing-colon-space',
    }, languageId: 'en-US');
    await preferences.saveWritingRuleIds(const <String>{
      'repeated-space',
    }, languageId: 'en-GB');

    expect(await preferences.loadWritingRuleIds(languageId: 'en-US'), <String>{
      'missing-colon-space',
    });
    expect(await preferences.loadWritingRuleIds(languageId: 'en-GB'), <String>{
      'repeated-space',
    });
  });
}
