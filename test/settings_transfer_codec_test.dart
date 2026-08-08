import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('SpellCheckerSettingsCodec', () {
    test('round-trips selected language, limit, and explicit overrides', () {
      final document = SpellCheckerSettingsDocument(
        languageId: 'en-GB',
        suggestionLimit: 7,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-US': <String>{'repeated-space', 'future-rule'},
          'en-GB': const <String>[],
        },
      );

      final encoded = SpellCheckerSettingsCodec.encode(document);
      final decoded = SpellCheckerSettingsCodec.decode(encoded);

      expect(decoded.languageId, 'en-GB');
      expect(decoded.suggestionLimit, 7);
      expect(decoded.writingRuleIdsFor('en-US'), <String>{
        'future-rule',
        'repeated-space',
      });
      expect(decoded.hasWritingRuleOverride('en-GB'), isTrue);
      expect(decoded.writingRuleIdsFor('en-GB'), isEmpty);
    });

    test('absent language override remains unset after round-trip', () {
      final decoded = SpellCheckerSettingsCodec.decode(
        SpellCheckerSettingsCodec.encode(
          SpellCheckerSettingsDocument(
            languageId: 'en-US',
            suggestionLimit: 5,
            writingRuleOverrides: <String, Iterable<String>>{
              'en-GB': const <String>[],
            },
          ),
        ),
      );

      expect(decoded.hasWritingRuleOverride('en-US'), isFalse);
      expect(decoded.writingRuleIdsFor('en-US'), isNull);
      expect(decoded.hasWritingRuleOverride('en-GB'), isTrue);
    });

    test('encoding is deterministic across map and set insertion order', () {
      final first = SpellCheckerSettingsDocument(
        languageId: 'en-US',
        suggestionLimit: 4,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-US': <String>{'z-rule', 'a-rule'},
          'en-GB': <String>{'clarity-rule'},
        },
      );
      final second = SpellCheckerSettingsDocument(
        languageId: 'en-US',
        suggestionLimit: 4,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-GB': <String>{'clarity-rule'},
          'en-US': <String>{'a-rule', 'z-rule'},
        },
      );

      expect(
        SpellCheckerSettingsCodec.encode(first),
        SpellCheckerSettingsCodec.encode(second),
      );
    });

    test('encoded format contains no document or vocabulary fields', () {
      final encoded = SpellCheckerSettingsCodec.encode(
        SpellCheckerSettingsDocument(languageId: 'en-US', suggestionLimit: 5),
      );
      final json = jsonDecode(encoded) as Map<String, dynamic>;

      expect(json.keys, <String>{
        'format',
        'version',
        'languageId',
        'suggestionLimit',
        'writingRuleOverrides',
      });
      expect(encoded, isNot(contains('personalWords')));
      expect(encoded, isNot(contains('editorText')));
      expect(encoded, isNot(contains('findings')));
      expect(encoded, isNot(contains('correctionHistory')));
    });

    test('preserves valid unknown future rule IDs', () {
      const source = '''
{
  "format": "spellchecker-settings",
  "version": 1,
  "languageId": "en-US",
  "suggestionLimit": 5,
  "writingRuleOverrides": {
    "en-US": ["future.rule-2"]
  }
}
''';

      final decoded = SpellCheckerSettingsCodec.decode(source);

      expect(decoded.writingRuleIdsFor('en-US'), <String>{'future.rule-2'});
    });

    test('rejects malformed JSON and non-object documents', () {
      expect(
        () => SpellCheckerSettingsCodec.decode('{not-json'),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SpellCheckerSettingsCodec.decode('[]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unsupported format and version', () {
      expect(
        () => SpellCheckerSettingsCodec.decode(
          _documentJson(format: 'other-settings'),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SpellCheckerSettingsCodec.decode(_documentJson(version: 2)),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects unsupported selected and override languages', () {
      expect(
        () => SpellCheckerSettingsCodec.decode(
          _documentJson(languageId: 'fr-FR'),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SpellCheckerSettingsCodec.decode(
          _documentJson(overrides: <String, Object?>{'fr-FR': <String>[]}),
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects suggestion limits outside the public 1-10 contract', () {
      expect(
        () => SpellCheckerSettingsCodec.decode(_documentJson(limit: 0)),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SpellCheckerSettingsCodec.decode(_documentJson(limit: 11)),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects malformed writing-rule IDs and override values', () {
      expect(
        () => SpellCheckerSettingsCodec.decode(
          _documentJson(
            overrides: <String, Object?>{
              'en-US': <String>['Bad Rule ID'],
            },
          ),
        ),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => SpellCheckerSettingsCodec.decode(
          _documentJson(overrides: <String, Object?>{'en-US': 'not-a-list'}),
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

String _documentJson({
  String format = SpellCheckerSettingsCodec.format,
  int version = SpellCheckerSettingsCodec.version,
  String languageId = 'en-US',
  int limit = 5,
  Map<String, Object?> overrides = const <String, Object?>{},
}) {
  return jsonEncode(<String, Object?>{
    'format': format,
    'version': version,
    'languageId': languageId,
    'suggestionLimit': limit,
    'writingRuleOverrides': overrides,
  });
}
