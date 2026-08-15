import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  group('WritingReviewQuery', () {
    final analyzer = WritingAnalyzer();
    final rules = analyzer.rules;
    final analysis = analyzer.analyze(
      'hello  world world!!',
      languagePack: SpellLanguageRegistry.englishUs,
    );

    test('is empty only when no review filter is active', () {
      expect(WritingReviewQuery().isEmpty, isTrue);
      expect(WritingReviewQuery(search: 'space').isEmpty, isFalse);
      expect(
        WritingReviewQuery(
          categories: const <WritingRuleCategory>{
            WritingRuleCategory.mechanics,
          },
        ).isEmpty,
        isFalse,
      );
      expect(WritingReviewQuery(automaticFixesOnly: true).isEmpty, isFalse);
    });

    test('repeated word is categorized as clarity', () {
      final repeatedWord = WritingRuleRegistry.byId('repeated-word');
      expect(repeatedWord, isNotNull);
      expect(repeatedWord!.category, WritingRuleCategory.clarity);
    });

    test('existing external-style rules default to mechanics', () {
      const rule = _UncategorizedRule();
      expect(rule.category, WritingRuleCategory.mechanics);
    });

    test('search filters rules by id, label, description, or category', () {
      expect(
        WritingReviewQuery(search: 'repeated-space')
            .filterRules(rules)
            .map((WritingRule rule) => rule.id),
        contains('repeated-space'),
      );
      expect(
        WritingReviewQuery(search: 'capital')
            .filterRules(rules)
            .map((WritingRule rule) => rule.id),
        contains('sentence-capitalization'),
      );
      expect(
        WritingReviewQuery(search: 'clarity')
            .filterRules(rules)
            .map((WritingRule rule) => rule.id),
        <String>['repeated-word'],
      );
    });

    test('category filters rules and findings consistently', () {
      final query = WritingReviewQuery(
        categories: const <WritingRuleCategory>{WritingRuleCategory.clarity},
      );

      expect(
        query.filterRules(rules).map((WritingRule rule) => rule.id),
        <String>['repeated-word'],
      );
      expect(
        query
            .filterIssues(analysis.issues, rules: rules)
            .map((WritingIssue issue) => issue.ruleId)
            .toSet(),
        <String>{'repeated-word'},
      );
    });

    test('automatic-only filter removes advisory findings', () {
      const issues = <WritingIssue>[
        WritingIssue(
          ruleId: 'advisory',
          ruleName: 'Advisory',
          message: 'Review this.',
          start: 0,
          end: 4,
          originalText: 'text',
          languageId: 'en-US',
        ),
        WritingIssue(
          ruleId: 'repeated-space',
          ruleName: 'Repeated spaces',
          message: 'Use one space.',
          start: 4,
          end: 6,
          originalText: '  ',
          replacement: ' ',
          languageId: 'en-US',
        ),
      ];

      final filtered = WritingReviewQuery(automaticFixesOnly: true)
          .filterIssues(issues, rules: rules);

      expect(filtered, hasLength(1));
      expect(filtered.single.ruleId, 'repeated-space');
    });

    test('search matches finding message and original text', () {
      final messageMatches = WritingReviewQuery(search: 'repeated')
          .filterIssues(analysis.issues, rules: rules);
      expect(messageMatches, isNotEmpty);

      final sourceMatches = WritingReviewQuery(search: 'world')
          .filterIssues(analysis.issues, rules: rules);
      expect(sourceMatches, isNotEmpty);
      expect(
        sourceMatches.map((WritingIssue issue) => issue.originalText).join(),
        contains('world'),
      );
    });

    test('unknown-rule findings are excluded by an active category filter', () {
      const issue = WritingIssue(
        ruleId: 'unknown-rule',
        ruleName: 'Unknown',
        message: 'Unknown finding.',
        start: 0,
        end: 1,
        originalText: 'x',
        replacement: 'y',
        languageId: 'en-US',
      );

      final filtered = WritingReviewQuery(
        categories: const <WritingRuleCategory>{WritingRuleCategory.mechanics},
      ).filterIssues(const <WritingIssue>[issue], rules: rules);

      expect(filtered, isEmpty);
    });
  });
}

class _UncategorizedRule extends WritingRule {
  const _UncategorizedRule();

  @override
  String get id => 'uncategorized';

  @override
  String get displayName => 'Uncategorized';

  @override
  String get description => 'Uses the V2.2 source-compatible category default.';

  @override
  Set<String> get supportedLanguageIds => const <String>{'en'};

  @override
  Iterable<WritingIssue> analyze(String text, SpellLanguagePack languagePack) =>
      const <WritingIssue>[];
}
