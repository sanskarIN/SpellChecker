import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/writing.dart';

import '../lib/storage/dictionary_preferences.dart';

void main() {
  const preferences = DictionaryPreferences();

  group('writing-rule preferences', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('missing key remains distinguishable from explicit empty', () async {
      expect(await preferences.loadWritingRuleIds('en-US'), isNull);

      await preferences.saveWritingRuleIds('en-US', const <String>{});

      expect(await preferences.loadWritingRuleIds('en-US'), <String>{});
    });

    test('stores sorted stable IDs per language', () async {
      await preferences.saveWritingRuleIds('en-US', const <String>{
        'sentence-capitalization',
        'repeated-space',
      });
      await preferences.saveWritingRuleIds('en-GB', const <String>{
        'repeated-word',
      });

      expect(await preferences.loadWritingRuleIds('en-US'), <String>{
        'sentence-capitalization',
        'repeated-space',
      });
      expect(await preferences.loadWritingRuleIds('en-GB'), <String>{
        'repeated-word',
      });

      final store = await SharedPreferences.getInstance();
      expect(
        store.getStringList('spellchecker.writing_rule_ids.v1.en-US'),
        <String>['repeated-space', 'sentence-capitalization'],
      );
    });

    test('unset preferences resolve to current seven-rule defaults', () async {
      final stored = await preferences.loadWritingRuleIds('en-US');
      final effective = stored ?? WritingRuleRegistry.defaultEnabledRuleIds;

      expect(stored, isNull);
      expect(effective, hasLength(7));
      expect(effective, contains('missing-punctuation-space'));
    });

    test('historical explicit six-rule set does not gain V2.11 rule', () async {
      const historicalSixRuleOverride = <String>{
        'punctuation-spacing',
        'repeated-punctuation',
        'repeated-space',
        'repeated-word',
        'sentence-capitalization',
        'trailing-whitespace',
      };
      await preferences.saveWritingRuleIds('en-US', historicalSixRuleOverride);

      final stored = await preferences.loadWritingRuleIds('en-US');
      final effective = stored ?? WritingRuleRegistry.defaultEnabledRuleIds;

      expect(stored, historicalSixRuleOverride);
      expect(effective, hasLength(6));
      expect(effective, isNot(contains('missing-punctuation-space')));
    });

    test('explicit disable-all remains empty after V2.11 rule addition', () async {
      await preferences.saveWritingRuleIds('en-US', const <String>{});

      final stored = await preferences.loadWritingRuleIds('en-US');
      final effective = stored ?? WritingRuleRegistry.defaultEnabledRuleIds;

      expect(stored, isEmpty);
      expect(effective, isEmpty);
    });

    test('removing an override restores current seven-rule defaults', () async {
      await preferences.saveWritingRuleIds('en-US', const <String>{
        'repeated-space',
      });
      await preferences.removeWritingRuleIds('en-US');

      final stored = await preferences.loadWritingRuleIds('en-US');
      final effective = stored ?? WritingRuleRegistry.defaultEnabledRuleIds;

      expect(stored, isNull);
      expect(effective, hasLength(7));
      expect(effective, contains('missing-punctuation-space'));
    });

    test('reset removes only the selected language override', () async {
      await preferences.saveWritingRuleIds('en-US', const <String>{
        'repeated-space',
      });
      await preferences.saveWritingRuleIds('en-GB', const <String>{
        'repeated-word',
      });

      await preferences.removeWritingRuleIds('en-US');

      expect(await preferences.loadWritingRuleIds('en-US'), isNull);
      expect(await preferences.loadWritingRuleIds('en-GB'), <String>{
        'repeated-word',
      });
    });
  });
}
