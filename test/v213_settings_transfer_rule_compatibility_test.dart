import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  const v212RuleIds = <String>{
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
  };

  test('portable V2.12 explicit override remains seven rules', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: const <String, Iterable<String>>{
        'en-US': v212RuleIds,
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.hasWritingRuleOverride('en-US'), isTrue);
    expect(decoded.writingRuleIdsFor('en-US'), v212RuleIds);
    expect(
      decoded.writingRuleIdsFor('en-US'),
      isNot(contains('unmatched-parenthesis')),
    );
  });

  test('portable settings round-trip the V2.13 rule ID when explicit', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: <String, Iterable<String>>{
        'en-US': <String>{...v212RuleIds, 'unmatched-parenthesis'},
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.writingRuleIdsFor('en-US'), hasLength(8));
    expect(
      decoded.writingRuleIdsFor('en-US'),
      contains('unmatched-parenthesis'),
    );
  });

  test('unset portable override remains unset for current defaults', () {
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
