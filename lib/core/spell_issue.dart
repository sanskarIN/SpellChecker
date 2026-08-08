class SpellIssue {
  const SpellIssue({
    required this.word,
    required this.start,
    required this.end,
    this.suggestions = const <String>[],
    this.languageId,
  });

  final String word;
  final int start;
  final int end;
  final List<String> suggestions;

  /// Language pack that produced this issue when known.
  ///
  /// Kept optional so manually-created/test issues from earlier 1.x APIs remain
  /// source-compatible.
  final String? languageId;

  @override
  bool operator ==(Object other) {
    return other is SpellIssue &&
        other.word == word &&
        other.start == start &&
        other.end == end &&
        other.languageId == languageId &&
        _listEquals(other.suggestions, suggestions);
  }

  @override
  int get hashCode =>
      Object.hash(word, start, end, languageId, Object.hashAll(suggestions));

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
