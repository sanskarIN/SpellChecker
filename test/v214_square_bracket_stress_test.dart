import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/language.dart';
import 'package:spellchecker/writing.dart';

void main() {
  const rule = UnmatchedSquareBracketRule();
  final pack = SpellLanguageRegistry.englishUs;

  test('deep balanced square bracket nesting remains iterative and clean', () {
    final openings = List<String>.filled(5000, '[').join();
    final closings = List<String>.filled(5000, ']').join();
    final text = '${openings}content$closings';

    expect(rule.analyze(text, pack), isEmpty);
  });

  test('deep unmatched square brackets report every opening deterministically', () {
    final text = List<String>.filled(5000, '[').join();
    final issues = rule.analyze(text, pack).toList();

    expect(issues, hasLength(5000));
    expect(issues.first.start, 0);
    expect(issues.last.start, 4999);
    expect(issues.every((issue) => issue.originalText == '['), isTrue);
    expect(issues.every((issue) => issue.replacement == null), isTrue);
  });
}
