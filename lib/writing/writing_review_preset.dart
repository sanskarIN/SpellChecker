import 'writing_review_query.dart';
import 'writing_rule_category.dart';

/// A stable, reusable review-mode definition for Writing insights.
///
/// Presets intentionally describe only review filtering. Free-text search stays
/// transient and can be layered on top of a preset through [toQuery].
class WritingReviewPreset {
  const WritingReviewPreset({
    required this.id,
    required this.displayName,
    required this.description,
    this.categories = const <WritingRuleCategory>{},
    this.automaticFixesOnly = false,
  });

  /// Stable identifier suitable for UI keys and future preference formats.
  final String id;

  final String displayName;
  final String description;
  final Set<WritingRuleCategory> categories;
  final bool automaticFixesOnly;

  bool get isAllFindings => categories.isEmpty && !automaticFixesOnly;

  WritingReviewQuery toQuery({String search = ''}) {
    return WritingReviewQuery(
      search: search,
      categories: categories,
      automaticFixesOnly: automaticFixesOnly,
    );
  }

  static const WritingReviewPreset allFindings = WritingReviewPreset(
    id: 'all-findings',
    displayName: 'All findings',
    description: 'Review every enabled local writing-rule finding.',
  );

  static const WritingReviewPreset mechanics = WritingReviewPreset(
    id: 'mechanics',
    displayName: 'Mechanics',
    description: 'Focus review on punctuation, spacing, and capitalization.',
    categories: <WritingRuleCategory>{WritingRuleCategory.mechanics},
  );

  static const WritingReviewPreset clarity = WritingReviewPreset(
    id: 'clarity',
    displayName: 'Clarity',
    description: 'Focus review on clarity-oriented findings.',
    categories: <WritingRuleCategory>{WritingRuleCategory.clarity},
  );

  static const WritingReviewPreset automaticFixes = WritingReviewPreset(
    id: 'automatic-fixes',
    displayName: 'Automatic fixes',
    description: 'Show only findings with deterministic local replacements.',
    automaticFixesOnly: true,
  );

  static const List<WritingReviewPreset> values = <WritingReviewPreset>[
    allFindings,
    mechanics,
    clarity,
    automaticFixes,
  ];

  static WritingReviewPreset byId(String? id) {
    for (final preset in values) {
      if (preset.id == id) {
        return preset;
      }
    }
    return allFindings;
  }
}
