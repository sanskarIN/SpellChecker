import 'package:flutter_test/flutter_test.dart';
import 'package:spellchecker/writing.dart';

void main() {
  group('WritingReviewPreset', () {
    test('built-in IDs are stable and unique', () {
      final ids = WritingReviewPreset.values
          .map((WritingReviewPreset preset) => preset.id)
          .toList(growable: false);

      expect(ids, <String>[
        'all-findings',
        'mechanics',
        'clarity',
        'automatic-fixes',
      ]);
      expect(ids.toSet(), hasLength(ids.length));
    });

    test('all findings maps to an empty review query', () {
      final query = WritingReviewPreset.allFindings.toQuery();

      expect(query.isEmpty, isTrue);
      expect(query.categories, isEmpty);
      expect(query.automaticFixesOnly, isFalse);
    });

    test('mechanics and clarity presets select their categories', () {
      final mechanics = WritingReviewPreset.mechanics.toQuery();
      final clarity = WritingReviewPreset.clarity.toQuery();

      expect(
        mechanics.categories,
        const <WritingRuleCategory>{WritingRuleCategory.mechanics},
      );
      expect(
        clarity.categories,
        const <WritingRuleCategory>{WritingRuleCategory.clarity},
      );
    });

    test('automatic fixes preset enables only deterministic-fix filter', () {
      final query = WritingReviewPreset.automaticFixes.toQuery();

      expect(query.automaticFixesOnly, isTrue);
      expect(query.categories, isEmpty);
    });

    test('free-text search layers over a preset without becoming persistent', () {
      final query = WritingReviewPreset.clarity.toQuery(search: '  RePeAt  ');

      expect(query.search, 'repeat');
      expect(
        query.categories,
        const <WritingRuleCategory>{WritingRuleCategory.clarity},
      );
    });

    test('unknown preset IDs safely fall back to all findings', () {
      expect(
        WritingReviewPreset.byId('future-preset'),
        same(WritingReviewPreset.allFindings),
      );
      expect(
        WritingReviewPreset.byId(null),
        same(WritingReviewPreset.allFindings),
      );
    });
  });
}
