import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  test('sentence capitalization recognizes an opening quote after a boundary', () {
    const rule = SentenceCapitalizationRule();
    final pack = SpellLanguageRegistry.englishUs;

    final issues = rule
        .analyze('hello world. “next sentence” Then “another”', pack)
        .toList();

    expect(
      issues.map((issue) => issue.originalText),
      orderedEquals(<String>['hello', 'next']),
    );
    expect(
      issues.map((issue) => issue.replacement),
      orderedEquals(<String>['Hello', 'Next']),
    );
  });

  test('sentence capitalization supports closing then opening quotes', () {
    const rule = SentenceCapitalizationRule();
    final pack = SpellLanguageRegistry.englishUs;

    final issues = rule.analyze('“hello.” “next sentence”', pack).toList();

    expect(
      issues.map((issue) => issue.originalText),
      orderedEquals(<String>['hello', 'next']),
    );
  });
}
