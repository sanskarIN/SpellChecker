import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('bounded analysis retains exact totals for V3.3 colon findings', () {
    final analyzer = WritingAnalyzer(
      rules: const <WritingRule>[MissingColonSpaceRule()],
    );

    final result = analyzer.analyze(
      'One:two Three:four Five:six',
      languagePack: pack,
      maxIssues: 2,
    );

    expect(result.capturedIssueCount, 2);
    expect(result.isTruncated, isTrue);
    expect(result.totalIssueCount, 3);
    expect(result.uncapturedIssueCount, 1);
    expect(result.totalIssueCountByRule, <String, int>{
      'missing-colon-space': 3,
    });
    expect(result.issueCountByRule, <String, int>{'missing-colon-space': 2});
  });

  test('complete V3.3 colon analysis reports matching captured totals', () {
    final result = WritingAnalyzer(
      rules: const <WritingRule>[MissingColonSpaceRule()],
    ).analyze('One:two Three:four', languagePack: pack);

    expect(result.isTruncated, isFalse);
    expect(result.totalIssueCount, 2);
    expect(result.totalIssueCountByRule, <String, int>{
      'missing-colon-space': 2,
    });
    expect(result.issueCountByRule, <String, int>{'missing-colon-space': 2});
  });
}
