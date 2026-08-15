import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('PersonalDictionaryCodec', () {
    test('exports normalized sorted versioned JSON', () {
      final export = PersonalDictionaryCodec.encode(<String>{
        'Flutter',
        'open-source',
        "Writer's",
      });

      expect(export, contains('"version": 1'));
      expect(
        export.indexOf('flutter'),
        lessThan(export.indexOf('open-source')),
      );
      expect(export, contains("writer's"));
    });

    test('imports a SpellChecker JSON object', () {
      final words = PersonalDictionaryCodec.decode(
        '{"version":1,"words":["Flutter","Open-Source"]}',
      );

      expect(words, unorderedEquals(<String>['flutter', 'open-source']));
    });

    test('keeps missing object version backward-compatible with legacy V1', () {
      final document = PersonalDictionaryCodec.decodeDocument(
        '{"words":["Flutter"]}',
      );

      expect(document.version, PersonalDictionaryCodec.legacyVersion);
      expect(document.words, <String>{'flutter'});
    });

    test('rejects a present non-integer object version', () {
      expect(
        () => PersonalDictionaryCodec.decode(
          '{"version":"1","words":["flutter"]}',
        ),
        throwsFormatException,
      );
      expect(
        () => PersonalDictionaryCodec.decode(
          '{"version":null,"words":["flutter"]}',
        ),
        throwsFormatException,
      );
    });

    test('imports a JSON array', () {
      final words = PersonalDictionaryCodec.decode('["Alpha", "Beta"]');

      expect(words, unorderedEquals(<String>['alpha', 'beta']));
    });

    test('imports newline and comma separated text', () {
      final words = PersonalDictionaryCodec.decode('Alpha\nBeta, Gamma');

      expect(words, unorderedEquals(<String>['alpha', 'beta', 'gamma']));
    });

    test('normalizes curly apostrophes', () {
      expect(PersonalDictionaryCodec.normalizeWord('Writer’s'), "writer's");
    });

    test('normalizes decomposed common Latin accents', () {
      expect(PersonalDictionaryCodec.normalizeWord('Cafe\u0301'), 'café');
    });

    test('rejects malformed word entries', () {
      expect(
        () => PersonalDictionaryCodec.decode('valid\nnot a word'),
        throwsFormatException,
      );
    });

    test('rejects unsupported format versions', () {
      expect(
        () =>
            PersonalDictionaryCodec.decode('{"version":2,"words":["flutter"]}'),
        throwsFormatException,
      );
    });
  });
}
