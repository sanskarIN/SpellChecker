import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing/rules/missing_colon_space_rule.dart';
import 'package:spellchecker/writing/writing_correction.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('finds a colon between words without a following space', () {
    const rule = MissingColonSpaceRule();
    const text = 'Topic:details';

    final issues = rule.analyze(text, pack).toList();

    expect(issues, hasLength(1));
    expect(issues.single.ruleId, 'missing-colon-space');
    expect(issues.single.originalText, ':');
    expect(issues.single.replacement, ': ');
    expect(text.substring(issues.single.start, issues.single.end), ':');
  });

  test('automatic correction preserves the surrounding words', () {
    const rule = MissingColonSpaceRule();
    const text = 'Topic:details';
    final issue = rule.analyze(text, pack).single;

    final correction = WritingCorrection.apply(text, issue);

    expect(correction.applied, isTrue);
    expect(correction.text, 'Topic: details');
  });

  test('supports Unicode letter clusters on both sides', () {
    const rule = MissingColonSpaceRule();

    final issues = rule.analyze('Résumé:details', pack).toList();

    expect(issues, hasLength(1));
    expect(issues.single.originalText, ':');
  });

  test('ignores already spaced, numeric, URL, and structural colons', () {
    const rule = MissingColonSpaceRule();

    expect(
      rule.analyze(
        'Topic: details. Time 12:30. https://example.com. key::value',
        pack,
      ),
      isEmpty,
    );
  });
}
