import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  const rule = UnmatchedCurlyBraceRule();
  final pack = SpellLanguageRegistry.englishUs;
  final issue = rule.analyze('Hello {world', pack).single;

  test('search finds unmatched curly brace rule and finding metadata', () {
    final query = WritingReviewQuery(search: 'curly brace');

    expect(query.filterRules(const <WritingRule>[rule]), <WritingRule>[rule]);
    expect(
      query.filterIssues(
        <WritingIssue>[issue],
        rules: const <WritingRule>[rule],
      ),
      <WritingIssue>[issue],
    );
  });

  test('mechanics category includes unmatched curly brace diagnostics', () {
    final query = WritingReviewQuery(
      categories: const <WritingRuleCategory>{WritingRuleCategory.mechanics},
    );

    expect(query.filterRules(const <WritingRule>[rule]), <WritingRule>[rule]);
    expect(
      query.filterIssues(
        <WritingIssue>[issue],
        rules: const <WritingRule>[rule],
      ),
      <WritingIssue>[issue],
    );
  });

  test('automatic fixes only excludes advisory curly brace findings', () {
    final query = WritingReviewQuery(automaticFixesOnly: true);

    expect(
      query.filterIssues(
        <WritingIssue>[issue],
        rules: const <WritingRule>[rule],
      ),
      isEmpty,
    );
  });
}
