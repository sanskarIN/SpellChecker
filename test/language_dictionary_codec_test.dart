import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/personal_dictionary_codec.dart';
import 'package:spellchecker/core/spell_language_pack.dart';

void main() {
  group('language-aware personal dictionary documents', () {
    test('exports version 2 with language metadata', () {
      final export = PersonalDictionaryCodec.encodeForLanguage(
        <String>{'Colour', 'Writer’s'},
        languagePack: SpellLanguageRegistry.englishGb,
      );

      expect(export, contains('"version": 2'));
      expect(export, contains('"language": "en-GB"'));
      expect(export, contains('colour'));
      expect(export, contains("writer's"));
    });

    test('decodes version 2 using the document language pack', () {
      final document = PersonalDictionaryCodec.decodeDocument(
        '{"version":2,"language":"en-GB","words":["Colour","Café"]}',
      );

      expect(document.version, 2);
      expect(document.languageId, 'en-GB');
      expect(document.words, unorderedEquals(<String>['colour', 'café']));
    });

    test('version 1 documents inherit the caller language', () {
      final document = PersonalDictionaryCodec.decodeDocument(
        '{"version":1,"words":["Colour"]}',
        languagePack: SpellLanguageRegistry.englishGb,
      );

      expect(document.version, 1);
      expect(document.languageId, 'en-GB');
      expect(document.words, <String>{'colour'});
    });

    test('plain Unicode word lists use the selected language', () {
      final document = PersonalDictionaryCodec.decodeDocument(
        'café\nnaïve\ncolour',
        languagePack: SpellLanguageRegistry.englishGb,
      );

      expect(document.languageId, 'en-GB');
      expect(
        document.words,
        unorderedEquals(<String>['café', 'naïve', 'colour']),
      );
    });

    test('rejects an unknown language id in a version 2 document', () {
      expect(
        () => PersonalDictionaryCodec.decodeDocument(
          '{"version":2,"language":"xx-ZZ","words":["example"]}',
        ),
        throwsFormatException,
      );
    });

    test('legacy encode remains version 1 compatible', () {
      final export = PersonalDictionaryCodec.encode(<String>{'Flutter'});

      expect(export, contains('"version": 1'));
      expect(export, isNot(contains('"language"')));
    });
  });
}
