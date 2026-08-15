import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  const rule = UnmatchedSquareBracketRule();
  final pack = SpellLanguageRegistry.englishUs;
  final issue = rule.analyze('Hello [world', pack).single;

  test('search finds unmatched square bracket rule and finding metadata', () {
    final query = WritingReviewQuery(search: 'square bracket');

    expect(query.filterRules(const <WritingRule>[rule]), <WritingRule>[rule]);
    expect(
      query.filterIssues(
        <WritingIssue>[issue],
        rules: const <WritingRule>[rule],
      ),
      <WritingIssue>[issue],
    );
  });

  test('mechanics category includes unmatched square bracket diagnostics', () {
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

  test('automatic fixes only excludes advisory square bracket findings', () {
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
