import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  test('TextStatistics counts words, characters, and sentences', () {
    const text = 'Hello world. How are you?';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.characters, text.length);
    expect(statistics.words, 5);
    expect(statistics.sentences, 2);
  });

  test('TextStatistics counts Unicode words and normalized punctuation', () {
    const text = 'Café naïve résumé writer’s open‑source.';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.characters, text.length);
    expect(statistics.words, 5);
    expect(statistics.sentences, 1);
  });

  test('TextStatistics returns zero sentences for blank text', () {
    final statistics = TextStatistics.fromText('   ');

    expect(statistics.words, 0);
    expect(statistics.sentences, 0);
  });
}
