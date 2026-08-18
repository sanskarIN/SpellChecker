import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  final pack = SpellLanguageRegistry.englishUs;

  test('colon and preceding-space fixes remain adjacent and non-overlapping', () {
    final analyzer = WritingAnalyzer();
    const text = 'Label :value';

    final result = analyzer.analyze(text, languagePack: pack);
    final issues = result.issues
        .where(
          (issue) =>
              issue.ruleId == 'punctuation-spacing' ||
              issue.ruleId == 'missing-colon-space',
        )
        .toList();

    expect(issues, hasLength(2));
    expect(issues[0].end, issues[1].start);
    expect(issues.map((issue) => issue.originalText), <String>[' ', ':']);

    final correction = WritingCorrection.applyAll(text, issues);

    expect(correction.appliedCount, 2);
    expect(correction.skippedCount, 0);
    expect(correction.text, 'Label: value');
  });

  test('rule can be independently disabled without affecting colon cleanup', () {
    final analyzer = WritingAnalyzer();
    const text = 'Label :value';

    final result = analyzer.analyze(
      text,
      languagePack: pack,
      enabledRuleIds: <String>{'punctuation-spacing'},
    );

    expect(result.issues, hasLength(1));
    expect(result.issues.single.ruleId, 'punctuation-spacing');
    expect(WritingCorrection.applyAll(text, result.issues).text, 'Label:value');
  });
}
