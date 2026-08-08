class SpellSuggestion {
  const SpellSuggestion({
    required this.word,
    required this.distance,
    required this.frequencyRank,
    required this.languageId,
    required this.languageDisplayName,
    required this.source,
  });

  final String word;
  final int distance;
  final int frequencyRank;
  final String languageId;
  final String languageDisplayName;
  final String source;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SpellSuggestion &&
            other.word == word &&
            other.distance == distance &&
            other.frequencyRank == frequencyRank &&
            other.languageId == languageId &&
            other.languageDisplayName == languageDisplayName &&
            other.source == source;
  }

  @override
  int get hashCode => Object.hash(
    word,
    distance,
    frequencyRank,
    languageId,
    languageDisplayName,
    source,
  );

  @override
  String toString() => '$word [$languageId, distance=$distance]';
}
