import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  test('sentence capitalization preserves astral Unicode scalars', () {
    const rule = SentenceCapitalizationRule();
    final pack = SpellLanguageRegistry.englishUs;

    final issues = rule.analyze('𐐨abc. 𐐨xyz', pack).toList();

    expect(issues, hasLength(2));
    expect(
      issues.map((issue) => issue.originalText),
      orderedEquals(<String>['𐐨abc', '𐐨xyz']),
    );
    expect(
      issues.map((issue) => issue.replacement),
      orderedEquals(<String>['𐐀abc', '𐐀xyz']),
    );
    expect(issues.first.start, 0);
    expect(issues.first.end, '𐐨abc'.length);
  });
}
