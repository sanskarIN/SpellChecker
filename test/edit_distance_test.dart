import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/spell_checker.dart';

void main() {
  group('damerauLevenshteinDistance', () {
    test('returns zero for equal strings', () {
      expect(damerauLevenshteinDistance('spell', 'spell'), 0);
    });

    test('counts insertion and deletion', () {
      expect(damerauLevenshteinDistance('spel', 'spell'), 1);
      expect(damerauLevenshteinDistance('spells', 'spell'), 1);
    });

    test('counts adjacent transposition as one edit', () {
      expect(damerauLevenshteinDistance('teh', 'the'), 1);
    });
  });
}
