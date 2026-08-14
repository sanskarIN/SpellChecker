class AnalysisBenchmarkScenario {
  AnalysisBenchmarkScenario({
    required this.name,
    required this.repeats,
    required this.spellingIssueLimit,
    required this.writingIssueLimit,
    required this.suggestionLimit,
    this.chunk = standardChunk,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be blank');
    }
    if (repeats <= 0) {
      throw ArgumentError.value(repeats, 'repeats', 'must be positive');
    }
    if (spellingIssueLimit <= 0) {
      throw ArgumentError.value(
        spellingIssueLimit,
        'spellingIssueLimit',
        'must be positive',
      );
    }
    if (writingIssueLimit <= 0) {
      throw ArgumentError.value(
        writingIssueLimit,
        'writingIssueLimit',
        'must be positive',
      );
    }
    if (suggestionLimit < 0) {
      throw ArgumentError.value(
        suggestionLimit,
        'suggestionLimit',
        'must not be negative',
      );
    }
    if (chunk.isEmpty) {
      throw ArgumentError.value(chunk, 'chunk', 'must not be empty');
    }
  }

  static const String standardChunk =
      'hello wrld  this is is a sentence !! next sentence??  ';

  final String name;
  final int repeats;
  final int spellingIssueLimit;
  final int writingIssueLimit;
  final int suggestionLimit;
  final String chunk;

  int get characterCount =>
      (chunk.length * repeats) + (repeats > 1 ? repeats - 1 : 0);

  String buildText() {
    final buffer = StringBuffer();
    for (var index = 0; index < repeats; index++) {
      if (index > 0) {
        buffer.write('\n');
      }
      buffer.write(chunk);
    }
    return buffer.toString();
  }

  Map<String, Object> toJsonMetadata() => <String, Object>{
    'name': name,
    'repeats': repeats,
    'chunkCharacters': chunk.length,
    'characters': characterCount,
    'spellingIssueLimit': spellingIssueLimit,
    'writingIssueLimit': writingIssueLimit,
    'suggestionLimit': suggestionLimit,
  };
}
