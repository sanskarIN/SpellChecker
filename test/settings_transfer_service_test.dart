import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spellchecker/core/settings_transfer_codec.dart';
import 'package:spellchecker/storage/dictionary_preferences.dart';
import 'package:spellchecker/storage/settings_transfer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('SettingsTransferService', () {
    test('exports only durable portable preference state', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'spellchecker.language_id.v1': 'en-GB',
        'spellchecker.suggestion_limit.v1': 8,
        'spellchecker.writing_rule_ids.v1.en-US': <String>[
          'sentence-capitalization',
        ],
        'spellchecker.writing_rule_ids.v1.en-GB': <String>[],
        'spellchecker.personal_words.v2.en-GB': <String>['customword'],
      });
      final service = SettingsTransferService(DictionaryPreferences());

      final document = await service.exportDocument();

      expect(document.languageId, 'en-GB');
      expect(document.suggestionLimit, 8);
      expect(document.writingRuleIdsFor('en-US'), <String>{
        'sentence-capitalization',
      });
      expect(document.hasWritingRuleOverride('en-GB'), isTrue);
      expect(document.writingRuleIdsFor('en-GB'), isEmpty);
    });

    test(
      'imports selected language, limit, and complete override map',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'spellchecker.language_id.v1': 'en-US',
          'spellchecker.suggestion_limit.v1': 5,
          'spellchecker.writing_rule_ids.v1.en-GB': <String>['repeated-word'],
          'spellchecker.personal_words.v2.en-GB': <String>['customword'],
        });
        final preferences = DictionaryPreferences();
        final service = SettingsTransferService(preferences);
        final document = SpellCheckerSettingsDocument(
          languageId: 'en-GB',
          suggestionLimit: 7,
          writingRuleOverrides: <String, Iterable<String>>{
            'en-US': const <String>[],
          },
        );

        await service.importDocument(document);

        expect(await preferences.loadLanguageId(), 'en-GB');
        expect(await preferences.loadSuggestionLimit(), 7);
        expect(
          await preferences.loadWritingRuleIds(languageId: 'en-US'),
          isEmpty,
        );
        expect(
          await preferences.loadWritingRuleIds(languageId: 'en-GB'),
          isNull,
        );
        expect(
          await preferences.loadPersonalWords(languageId: 'en-GB'),
          <String>{'customword'},
        );
      },
    );

    test(
      'best-effort rollback restores previous portable preferences',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{
          'spellchecker.language_id.v1': 'en-US',
          'spellchecker.suggestion_limit.v1': 4,
          'spellchecker.writing_rule_ids.v1.en-US': <String>[
            'sentence-capitalization',
          ],
        });
        final preferences = _FailOncePreferences();
        final service = SettingsTransferService(preferences);
        final imported = SpellCheckerSettingsDocument(
          languageId: 'en-GB',
          suggestionLimit: 9,
          writingRuleOverrides: <String, Iterable<String>>{
            'en-US': const <String>[],
            'en-GB': <String>{'repeated-word'},
          },
        );

        await expectLater(service.importDocument(imported), throwsStateError);

        expect(await preferences.loadLanguageId(), 'en-US');
        expect(await preferences.loadSuggestionLimit(), 4);
        expect(
          await preferences.loadWritingRuleIds(languageId: 'en-US'),
          <String>{'sentence-capitalization'},
        );
        expect(
          await preferences.loadWritingRuleIds(languageId: 'en-GB'),
          isNull,
        );
      },
    );
  });
}

class _FailOncePreferences extends DictionaryPreferences {
  bool _shouldFail = true;

  @override
  Future<void> saveWritingRuleIds(
    Iterable<String> ruleIds, {
    String? languageId,
  }) async {
    if (_shouldFail && languageId == 'en-GB') {
      _shouldFail = false;
      throw StateError('simulated write failure');
    }
    await super.saveWritingRuleIds(ruleIds, languageId: languageId);
  }
}
