import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  test('portable settings round-trip the V3.3 rule id', () {
    final encoded = SpellCheckerSettingsCodec.encode(
      SpellCheckerSettingsDocument(
        languageId: 'en-US',
        suggestionLimit: 5,
        writingRuleOverrides: <String, Iterable<String>>{
          'en-US': const <String>{
            'missing-colon-space',
            'punctuation-spacing',
          },
        },
      ),
    );

    final decoded = SpellCheckerSettingsCodec.decode(encoded);

    expect(decoded.writingRuleIdsFor('en-US'), <String>{
      'missing-colon-space',
      'punctuation-spacing',
    });
  });

  test('V3.2 portable settings remain explicit after V3.3 registry growth', () {
    const v32Rules = <String>{
      'missing-punctuation-space',
      'punctuation-spacing',
      'repeated-punctuation',
      'repeated-space',
      'repeated-word',
      'sentence-capitalization',
      'trailing-whitespace',
      'unmatched-curly-brace',
      'unmatched-parenthesis',
      'unmatched-square-bracket',
    };

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(
        SpellCheckerSettingsDocument(
          languageId: 'en-US',
          suggestionLimit: 5,
          writingRuleOverrides: <String, Iterable<String>>{
            'en-US': v32Rules,
          },
        ),
      ),
    );

    expect(decoded.writingRuleIdsFor('en-US'), v32Rules);
    expect(
      decoded.writingRuleIdsFor('en-US'),
      isNot(contains('missing-colon-space')),
    );
  });
}
