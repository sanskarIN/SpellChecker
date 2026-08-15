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

    test('counts one astral Unicode scalar substitution as one edit', () {
      expect(damerauLevenshteinDistance('a𐐀c', 'a𐐁c'), 1);
    });

    test('counts astral Unicode scalar insertion and deletion once', () {
      expect(damerauLevenshteinDistance('ac', 'a𐐀c'), 1);
      expect(damerauLevenshteinDistance('a𐐀c', 'ac'), 1);
    });

    test('counts adjacent astral Unicode scalar transposition as one edit', () {
      expect(damerauLevenshteinDistance('𐐀𐐁', '𐐁𐐀'), 1);
    });
  });
}
