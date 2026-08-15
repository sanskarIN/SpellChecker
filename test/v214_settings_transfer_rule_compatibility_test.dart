import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  const v213RuleIds = <String>{
    'missing-punctuation-space',
    'punctuation-spacing',
    'repeated-punctuation',
    'repeated-space',
    'repeated-word',
    'sentence-capitalization',
    'trailing-whitespace',
    'unmatched-parenthesis',
  };

  test('portable V2.13 explicit override remains eight rules', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: const <String, Iterable<String>>{
        'en-US': v213RuleIds,
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.hasWritingRuleOverride('en-US'), isTrue);
    expect(decoded.writingRuleIdsFor('en-US'), v213RuleIds);
    expect(
      decoded.writingRuleIdsFor('en-US'),
      isNot(contains('unmatched-square-bracket')),
    );
  });

  test('portable settings round-trip the V2.14 rule ID when explicit', () {
    final document = SpellCheckerSettingsDocument(
      languageId: 'en-US',
      suggestionLimit: 5,
      writingRuleOverrides: <String, Iterable<String>>{
        'en-US': <String>{...v213RuleIds, 'unmatched-square-bracket'},
      },
    );

    final decoded = SpellCheckerSettingsCodec.decode(
      SpellCheckerSettingsCodec.encode(document),
    );

    expect(decoded.writingRuleIdsFor('en-US'), hasLength(9));
    expect(
      decoded.writingRuleIdsFor('en-US'),
      contains('unmatched-square-bracket'),
    );
  });

  test('unset portable override remains unset for nine-rule defaults', () {
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
