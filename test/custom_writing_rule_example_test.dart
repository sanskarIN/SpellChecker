import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/core/spell_language_pack.dart';
import 'package:spellchecker/writing/writing_analyzer.dart';
import 'package:spellchecker/writing/writing_issue.dart';
import 'package:spellchecker/writing/writing_rule.dart';
import 'package:spellchecker/writing/writing_rule_category.dart';

import '../tool/examples/custom_writing_rule.dart';

void main() {
  test('custom writing rule example is deterministic and advisory', () {
    const rule = AvoidVeryRule();
    final languagePack = SpellLanguageRegistry.defaultPack;
    final analyzer = WritingAnalyzer(rules: const <WritingRule>[rule]);

    final result = analyzer.analyze(
      'Very clear and very useful.',
      languagePack: languagePack,
    );

    expect(rule.category, WritingRuleCategory.clarity);
    expect(rule.supports(languagePack), isTrue);
    expect(result.analyzedRuleIds, const <String>{'example.avoid-very'});
    expect(result.totalIssueCount, 2);
    expect(result.issues, hasLength(2));
    expect(
      result.issues.map((issue) => issue.originalText),
      orderedEquals(const <String>['Very', 'very']),
    );
    expect(
      result.issues.every((issue) => issue.severity == WritingIssueSeverity.info),
      isTrue,
    );
    expect(result.issues.every((issue) => !issue.hasAutomaticFix), isTrue);
  });
}
