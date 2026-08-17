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

  test('TextStatistics counts a trailing unfinished sentence', () {
    const text = 'Hello world! This sentence has no final punctuation';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.sentences, 2);
  });

  test('TextStatistics accepts closing punctuation after a sentence mark', () {
    const text = 'She said “Hello.” Then she left';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.sentences, 2);
  });

  test('TextStatistics counts Unicode words and normalized punctuation', () {
    const text = 'Café naïve résumé writer’s open‑source.';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.characters, text.length);
    expect(statistics.words, 5);
    expect(statistics.sentences, 1);
  });

  test('TextStatistics keeps decomposed combining-mark words intact', () {
    const text = 'Cafe\u0301 nai\u0308ve re\u0301sume\u0301.';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.characters, text.length);
    expect(statistics.words, 3);
    expect(statistics.sentences, 1);
  });

  test('TextStatistics keeps Indic joiner conjuncts in one word', () {
    const text = 'क्\u200Dष क्\u200Cष शब्द.';

    final statistics = TextStatistics.fromText(text);

    expect(statistics.characters, text.length);
    expect(statistics.words, 3);
    expect(statistics.sentences, 1);
  });

  test('TextStatistics returns zero sentences for blank text', () {
    final statistics = TextStatistics.fromText('   ');

    expect(statistics.words, 0);
    expect(statistics.sentences, 0);
  });
}
