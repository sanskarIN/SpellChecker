import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  const v214RuleIds = <String>{
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
    'unmatched-parenthesis',
    'unmatched-square-bracket',
  };

  test('portable V2.14 explicit override remains nine rules', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: const <String, Iterable<String>>{
        'en-US': v214RuleIds,
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.hasWritingRuleOverride('en-US'), isTrue);
    expect(decoded.writingRuleIdsFor('en-US'), v214RuleIds);
    expect(
      decoded.writingRuleIdsFor('en-US'),
      isNot(contains('unmatched-curly-brace')),
    );
  });

  test('portable settings round-trip the V2.15 rule ID when explicit', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: <String, Iterable<String>>{
        'en-US': <String>{...v214RuleIds, 'unmatched-curly-brace'},
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.writingRuleIdsFor('en-US'), hasLength(10));
    expect(
      decoded.writingRuleIdsFor('en-US'),
      contains('unmatched-curly-brace'),
    );
  });

  test('unset portable override remains unset for ten-rule defaults', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.hasWritingRuleOverride('en-US'), isFalse);
    expect(decoded.writingRuleIdsFor('en-US'), isNull);
  });
}
