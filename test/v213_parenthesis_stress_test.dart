import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  const rule = UnmatchedParenthesisRule();
  final pack = SpellLanguageRegistry.englishUs;

  test('deep balanced nesting remains iterative and clean', () {
    final text = '${'(' * 5000}content${')' * 5000}';

    expect(rule.analyze(text, pack), isEmpty);
  });

  test('deep unmatched nesting reports every opening deterministically', () {
    final text = '(' * 5000;
    final issues = rule.analyze(text, pack).toList();

    expect(issues, hasLength(5000));
    expect(issues.first.start, 0);
    expect(issues.last.start, 4999);
    expect(issues.every((issue) => issue.originalText == '('), isTrue);
    expect(issues.every((issue) => issue.replacement == null), isTrue);
  });
}
